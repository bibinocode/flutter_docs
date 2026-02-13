# 第 6 章：Solidity 智能合约开发

> 智能合约是 Web3 的灵魂。这一章从零开始写 Solidity，最终实现一个完整的 ERC-20 代币合约，用 Foundry 测试和部署。

## 6.1 Solidity 第一个合约

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title HelloWeb3 - 你的第一个智能合约
/// @notice 这个合约演示了 Solidity 的基本语法
contract HelloWeb3 {
    // 状态变量 — 永久存储在区块链上
    string public greeting;
    address public owner;
    uint256 public count;

    // 事件 — 用于通知前端
    event GreetingChanged(address indexed by, string oldGreeting, string newGreeting);
    event CountIncremented(uint256 newCount);

    // 构造函数 — 部署时执行一次
    constructor(string memory _greeting) {
        greeting = _greeting;
        owner = msg.sender; // msg.sender = 部署合约的地址
    }

    // 修饰符 — 权限控制
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _; // 继续执行被修饰的函数
    }

    // 写入函数 — 修改状态，需要 Gas
    function setGreeting(string memory _greeting) public {
        string memory oldGreeting = greeting;
        greeting = _greeting;
        emit GreetingChanged(msg.sender, oldGreeting, _greeting);
    }

    // 只读函数 — 不修改状态，不需要 Gas
    function getGreeting() public view returns (string memory) {
        return greeting;
    }

    // 计数器
    function increment() public {
        count += 1;
        emit CountIncremented(count);
    }

    // 只有 owner 可以重置计数器
    function reset() public onlyOwner {
        count = 0;
    }
}
```

### 用 Foundry 编译、测试、部署

```bash
# 创建项目
forge init hello-web3
cd hello-web3

# 把上面的合约保存到 src/HelloWeb3.sol
# 编译
forge build

# 编写测试
```

```solidity
// test/HelloWeb3.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/HelloWeb3.sol";

contract HelloWeb3Test is Test {
    HelloWeb3 public hello;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        // 每个测试前都会执行
        hello = new HelloWeb3("Hello Web3!");
    }

    function test_InitialGreeting() public view {
        assertEq(hello.greeting(), "Hello Web3!");
    }

    function test_SetGreeting() public {
        hello.setGreeting("GM!");
        assertEq(hello.greeting(), "GM!");
    }

    function test_OwnerIsDeployer() public view {
        assertEq(hello.owner(), address(this));
    }

    function test_Increment() public {
        hello.increment();
        hello.increment();
        hello.increment();
        assertEq(hello.count(), 3);
    }

    function test_OnlyOwnerCanReset() public {
        hello.increment();

        // Bob 不是 owner，应该失败
        vm.prank(bob); // 模拟 Bob 调用
        vm.expectRevert("Not the owner");
        hello.reset();

        // Owner 可以重置
        hello.reset();
        assertEq(hello.count(), 0);
    }

    function test_EmitEvent() public {
        vm.expectEmit(true, false, false, true);
        emit HelloWeb3.GreetingChanged(address(this), "Hello Web3!", "New greeting");
        hello.setGreeting("New greeting");
    }
}
```

```bash
# 运行测试
forge test -vvv
# -v: 显示测试名称
# -vv: 显示日志
# -vvv: 显示调用栈
# -vvvv: 显示所有细节

# 部署到本地链
anvil &  # 启动本地链
forge create src/HelloWeb3.sol:HelloWeb3 \
  --constructor-args "Hello Web3!" \
  --rpc-url http://127.0.0.1:8545 \
  --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

# 部署到测试网
forge create src/HelloWeb3.sol:HelloWeb3 \
  --constructor-args "Hello Web3!" \
  --rpc-url $ETH_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --verify \
  --etherscan-api-key $ETHERSCAN_API_KEY
```

## 6.2 数据类型与存储

### 值类型

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract DataTypes {
    // 整数类型
    uint256 public maxUint = type(uint256).max;  // 2^256 - 1
    int256 public minInt = type(int256).min;      // -2^255
    uint8 public smallNum = 255;                  // 0-255

    // 地址类型
    address public wallet = 0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045;
    address payable public payableWallet = payable(wallet); // 可接收 ETH

    // 布尔
    bool public isActive = true;

    // 字节
    bytes32 public hash = keccak256("hello");     // 固定长度
    bytes public dynamicBytes = hex"deadbeef";    // 动态长度

    // 枚举
    enum Status { Pending, Active, Closed }
    Status public status = Status.Pending;
}
```

### Storage vs Memory vs Calldata

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract StorageDemo {
    // Storage: 永久存储在区块链上，最贵
    uint256[] public numbers;           // storage
    mapping(address => uint256) public balances; // storage

    // Memory: 函数执行期间的临时存储，便宜
    function processArray(uint256[] memory input) public pure returns (uint256) {
        uint256 sum = 0;
        for (uint256 i = 0; i < input.length; i++) {
            sum += input[i]; // 在 memory 中操作，Gas 低
        }
        return sum;
    }

    // Calldata: 只读的函数参数，最便宜
    // 适用于 external 函数的引用类型参数
    function readOnly(string calldata name) external pure returns (uint256) {
        return bytes(name).length;
    }

    // Storage 引用 — 直接修改状态变量
    function addNumber(uint256 num) public {
        numbers.push(num); // 写入 storage，Gas 高
    }

    // ⚠️ 常见陷阱：storage 引用 vs memory 复制
    function updateBalance(address user) public {
        // 这是 storage 引用，修改会直接影响状态
        uint256 balance = balances[user]; // 值类型是复制
        balance += 100; // ❌ 这不会修改 balances[user]！

        balances[user] += 100; // ✅ 正确写法
    }
}
```

::: warning Gas 优化核心原则
1. 尽量减少 Storage 写入（SSTORE = 20000 Gas）
2. 用 Memory 做中间计算
3. External 函数的参数用 calldata 而不是 memory
4. 打包存储：多个小变量放在同一个 Storage Slot（32 字节）
:::

## 6.3 实战：完整的 ERC-20 代币合约

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title MyToken - 一个完整的 ERC-20 代币实现
/// @notice 包含铸造、销毁、授权、暂停等功能
contract MyToken {
    // ============ 状态变量 ============

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    address public owner;
    bool public paused;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // ============ 事件 ============

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    event Mint(address indexed to, uint256 amount);
    event Burn(address indexed from, uint256 amount);
    event Paused(address account);
    event Unpaused(address account);

    // ============ 错误 ============

    error InsufficientBalance(address account, uint256 balance, uint256 needed);
    error InsufficientAllowance(address spender, uint256 allowance, uint256 needed);
    error Unauthorized();
    error ContractPaused();
    error ZeroAddress();

    // ============ 修饰符 ============

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier whenNotPaused() {
        if (paused) revert ContractPaused();
        _;
    }

    modifier notZeroAddress(address account) {
        if (account == address(0)) revert ZeroAddress();
        _;
    }

    // ============ 构造函数 ============

    constructor(string memory _name, string memory _symbol, uint256 _initialSupply) {
        name = _name;
        symbol = _symbol;
        owner = msg.sender;

        // 铸造初始供应量给部署者
        _mint(msg.sender, _initialSupply * 10 ** decimals);
    }

    // ============ 核心功能 ============

    /// @notice 转账代币
    function transfer(address to, uint256 amount)
        public
        whenNotPaused
        notZeroAddress(to)
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    /// @notice 授权第三方使用代币
    function approve(address spender, uint256 amount)
        public
        whenNotPaused
        notZeroAddress(spender)
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    /// @notice 第三方转账（需要先 approve）
    function transferFrom(address from, address to, uint256 amount)
        public
        whenNotPaused
        notZeroAddress(to)
        returns (bool)
    {
        uint256 currentAllowance = allowance[from][msg.sender];
        if (currentAllowance < amount) {
            revert InsufficientAllowance(msg.sender, currentAllowance, amount);
        }

        // 扣减授权额度
        unchecked {
            allowance[from][msg.sender] = currentAllowance - amount;
        }

        _transfer(from, to, amount);
        return true;
    }

    // ============ 管理功能 ============

    /// @notice 铸造新代币（仅 owner）
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    /// @notice 销毁自己的代币
    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    /// @notice 暂停合约
    function pause() public onlyOwner {
        paused = true;
        emit Paused(msg.sender);
    }

    /// @notice 恢复合约
    function unpause() public onlyOwner {
        paused = false;
        emit Unpaused(msg.sender);
    }

    // ============ 内部函数 ============

    function _transfer(address from, address to, uint256 amount) internal {
        uint256 fromBalance = balanceOf[from];
        if (fromBalance < amount) {
            revert InsufficientBalance(from, fromBalance, amount);
        }

        unchecked {
            balanceOf[from] = fromBalance - amount;
            balanceOf[to] += amount; // 不会溢出，因为 totalSupply 有上限
        }

        emit Transfer(from, to, amount);
    }

    function _mint(address to, uint256 amount) internal notZeroAddress(to) {
        totalSupply += amount;
        balanceOf[to] += amount;
        emit Transfer(address(0), to, amount);
        emit Mint(to, amount);
    }

    function _burn(address from, uint256 amount) internal {
        uint256 fromBalance = balanceOf[from];
        if (fromBalance < amount) {
            revert InsufficientBalance(from, fromBalance, amount);
        }

        unchecked {
            balanceOf[from] = fromBalance - amount;
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
        emit Burn(from, amount);
    }
}
```

### Foundry 测试

```solidity
// test/MyToken.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MyToken.sol";

contract MyTokenTest is Test {
    MyToken public token;
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    uint256 constant INITIAL_SUPPLY = 1_000_000; // 100万代币

    function setUp() public {
        token = new MyToken("My Token", "MTK", INITIAL_SUPPLY);
        // 部署者（address(this)）拥有所有初始代币
    }

    function test_Metadata() public view {
        assertEq(token.name(), "My Token");
        assertEq(token.symbol(), "MTK");
        assertEq(token.decimals(), 18);
    }

    function test_InitialSupply() public view {
        assertEq(token.totalSupply(), INITIAL_SUPPLY * 1e18);
        assertEq(token.balanceOf(address(this)), INITIAL_SUPPLY * 1e18);
    }

    function test_Transfer() public {
        uint256 amount = 1000 * 1e18;
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(address(this)), (INITIAL_SUPPLY * 1e18) - amount);
    }

    function test_TransferInsufficientBalance() public {
        vm.prank(alice); // Alice 没有代币
        vm.expectRevert(
            abi.encodeWithSelector(
                MyToken.InsufficientBalance.selector,
                alice, 0, 1000
            )
        );
        token.transfer(bob, 1000);
    }

    function test_ApproveAndTransferFrom() public {
        uint256 amount = 500 * 1e18;

        // Owner 授权 Alice 使用 500 代币
        token.approve(alice, amount);
        assertEq(token.allowance(address(this), alice), amount);

        // Alice 代替 Owner 转给 Bob
        vm.prank(alice);
        token.transferFrom(address(this), bob, amount);

        assertEq(token.balanceOf(bob), amount);
        assertEq(token.allowance(address(this), alice), 0);
    }

    function test_Mint() public {
        uint256 mintAmount = 100 * 1e18;
        token.mint(alice, mintAmount);

        assertEq(token.balanceOf(alice), mintAmount);
        assertEq(token.totalSupply(), (INITIAL_SUPPLY * 1e18) + mintAmount);
    }

    function test_Burn() public {
        uint256 burnAmount = 100 * 1e18;
        token.burn(burnAmount);

        assertEq(token.balanceOf(address(this)), (INITIAL_SUPPLY * 1e18) - burnAmount);
        assertEq(token.totalSupply(), (INITIAL_SUPPLY * 1e18) - burnAmount);
    }

    function test_Pause() public {
        token.pause();

        vm.expectRevert(MyToken.ContractPaused.selector);
        token.transfer(alice, 100);
    }

    // Fuzz 测试：随机金额转账
    function testFuzz_Transfer(uint256 amount) public {
        // 限制金额范围
        amount = bound(amount, 1, token.balanceOf(address(this)));

        uint256 balanceBefore = token.balanceOf(address(this));
        token.transfer(alice, amount);

        assertEq(token.balanceOf(alice), amount);
        assertEq(token.balanceOf(address(this)), balanceBefore - amount);
    }
}
```

```bash
# 运行测试
forge test -vvv

# 查看 Gas 报告
forge test --gas-report

# 运行 Fuzz 测试（默认 256 次随机输入）
forge test --match-test testFuzz -vvv
```

## 6.4 本章小结与练习

### 你学到了什么

- Solidity 基本语法：变量、函数、修饰符、事件、错误
- Storage / Memory / Calldata 的区别和 Gas 影响
- 完整的 ERC-20 代币合约实现
- Foundry 测试框架：单元测试、Fuzz 测试、Gas 报告

### 动手练习

1. **增加 Permit 功能**：为 MyToken 添加 EIP-2612 Permit 功能（链下签名授权），避免用户需要两笔交易（approve + transferFrom）

2. **ERC-721 NFT**：实现一个 NFT 合约，支持铸造、转让、元数据 URI、版税（ERC-2981）

3. **可升级合约**：用 UUPS 代理模式重构 MyToken，使其支持合约升级

### 下一章预告

下一章进入 Flutter DApp 前端开发——用 Dart 连接以太坊，实现钱包连接、代币查询、交易发送的完整 UI。
