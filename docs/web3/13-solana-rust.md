# 第 13 章：Solana 合约开发 — Rust + Anchor

> 以太坊之外，Solana 是最重要的公链之一。它的 TPS 高达数千、交易费用极低（不到 1 美分），是高频交易和游戏类 DApp 的首选。但 Solana 的编程模型和 EVM 完全不同——用 Rust 写合约、Account Model 代替 Storage、PDA 代替 mapping。这一章带你从零掌握 Solana 开发。

## 13.1 Solana vs Ethereum：核心区别

```
┌─────────────────┬──────────────────┬──────────────────┐
│                 │    Ethereum      │     Solana       │
├─────────────────┼──────────────────┼──────────────────┤
│ 合约语言         │ Solidity         │ Rust             │
│ 虚拟机           │ EVM (栈机器)      │ SVM (BPF)        │
│ 数据存储         │ Storage (合约内)  │ Account (合约外)  │
│ 状态模型         │ 账户模型          │ 账户模型 (不同!)   │
│ 并行执行         │ 串行             │ 并行 (Sealevel)   │
│ TPS             │ ~15-30           │ ~4000+           │
│ 交易费           │ $1-50+           │ ~$0.00025        │
│ 出块时间         │ ~12秒            │ ~400ms           │
│ 合约大小限制      │ 24KB             │ 10MB             │
│ 开发框架         │ Hardhat/Foundry  │ Anchor           │
│ 代币标准         │ ERC-20/721       │ SPL Token        │
└─────────────────┴──────────────────┴──────────────────┘
```

### Solana 的 Account Model

这是理解 Solana 开发的关键——和以太坊完全不同：

```
以太坊：数据存在合约内部
  ┌─────────────────────────┐
  │  ERC-20 合约             │
  │  ┌─────────────────────┐│
  │  │ balances mapping    ││  ← 数据存在合约的 Storage 里
  │  │ 0xABC → 1000        ││
  │  │ 0xDEF → 500         ││
  │  └─────────────────────┘│
  └─────────────────────────┘

Solana：数据存在独立的 Account 里
  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
  │ Program      │     │ Token Account│     │ Token Account│
  │ (合约代码)    │     │ (Alice 的)   │     │ (Bob 的)     │
  │              │     │ balance: 1000│     │ balance: 500 │
  │ 只有逻辑     │     │ owner: Alice │     │ owner: Bob   │
  │ 没有数据     │     │ mint: USDC   │     │ mint: USDC   │
  └──────────────┘     └──────────────┘     └──────────────┘
        ↑                     ↑                    ↑
        │                     │                    │
        └─────────────────────┴────────────────────┘
              Program 操作这些 Account 的数据

关键区别：
  - 以太坊：合约 = 代码 + 数据（绑定在一起）
  - Solana：Program = 只有代码，数据在独立的 Account 里
  - 每次调用 Program，必须告诉它要操作哪些 Account
  - 这就是为什么 Solana 能并行执行——不同 Account 可以同时处理
```

## 13.2 Rust 快速入门（面向 Solana 开发）

你不需要成为 Rust 专家才能写 Solana 合约，但需要理解几个核心概念。

### 所有权系统

```rust
// Rust 最独特的特性：所有权（Ownership）
// 每个值只能有一个所有者，所有者离开作用域时值被释放

fn main() {
    // s1 拥有这个 String
    let s1 = String::from("hello");
    
    // 所有权转移（Move）给 s2
    let s2 = s1;
    
    // ❌ 编译错误！s1 已经不拥有这个值了
    // println!("{}", s1);
    
    // ✅ s2 是当前所有者
    println!("{}", s2);
}

// 借用（Borrowing）：不转移所有权，只是"借"来用
fn print_length(s: &String) {  // & 表示借用
    println!("长度: {}", s.len());
}  // s 离开作用域，但因为不拥有值，所以什么都不会发生

fn main() {
    let s = String::from("hello");
    print_length(&s);  // 借给函数用
    println!("{}", s);  // ✅ 还能用，因为所有权没有转移
}

// 可变借用：借来还能修改
fn add_world(s: &mut String) {
    s.push_str(" world");
}

fn main() {
    let mut s = String::from("hello");
    add_world(&mut s);
    println!("{}", s); // "hello world"
}
```

### 枚举与模式匹配

```rust
// Rust 的枚举比其他语言强大得多——每个变体可以携带数据
enum TokenInstruction {
    Transfer { amount: u64 },
    Mint { amount: u64, decimals: u8 },
    Burn { amount: u64 },
    Approve { amount: u64, delegate: String },
}

// 模式匹配：必须处理所有情况（编译器强制）
fn process_instruction(instruction: TokenInstruction) {
    match instruction {
        TokenInstruction::Transfer { amount } => {
            println!("转账 {} 个代币", amount);
        }
        TokenInstruction::Mint { amount, decimals } => {
            println!("铸造 {} 个代币 (精度: {})", amount, decimals);
        }
        TokenInstruction::Burn { amount } => {
            println!("销毁 {} 个代币", amount);
        }
        TokenInstruction::Approve { amount, delegate } => {
            println!("授权 {} 给 {}", amount, delegate);
        }
    }
}

// Result 和 Option：Rust 的错误处理
fn divide(a: f64, b: f64) -> Result<f64, String> {
    if b == 0.0 {
        Err("除数不能为零".to_string())
    } else {
        Ok(a / b)
    }
}

fn main() {
    // ? 运算符：如果是 Err 就提前返回
    let result = divide(10.0, 3.0).unwrap(); // 简单场景用 unwrap
    println!("结果: {}", result);

    match divide(10.0, 0.0) {
        Ok(value) => println!("结果: {}", value),
        Err(e) => println!("错误: {}", e),
    }
}
```

## 13.3 Anchor 框架实战

Anchor 是 Solana 开发的标准框架，类似于以太坊的 Hardhat/Foundry。它大幅简化了 Solana 的开发体验。

### 环境搭建

```bash
# 安装 Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# 安装 Solana CLI
sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"

# 安装 Anchor
cargo install --git https://github.com/coral-xyz/anchor avm --force
avm install latest
avm use latest

# 验证安装
solana --version
anchor --version

# 配置本地开发网络
solana config set --url localhost
solana-keygen new  # 生成开发用密钥对
```

### 创建第一个 Anchor 项目

```bash
anchor init my_counter
cd my_counter
```

```
项目结构：
my_counter/
├── Anchor.toml          # 项目配置
├── Cargo.toml           # Rust 依赖
├── programs/
│   └── my_counter/
│       ├── Cargo.toml
│       └── src/
│           └── lib.rs   # 合约代码
├── tests/
│   └── my_counter.ts    # 测试（TypeScript）
└── app/                 # 前端（可选）
```

### 计数器合约（完整示例）

```rust
// programs/my_counter/src/lib.rs
use anchor_lang::prelude::*;

// 程序 ID（部署后会自动生成）
declare_id!("11111111111111111111111111111111");

#[program]
pub mod my_counter {
    use super::*;

    // 初始化计数器
    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        counter.count = 0;
        counter.authority = ctx.accounts.authority.key();
        msg!("计数器已初始化！authority: {}", counter.authority);
        Ok(())
    }

    // 增加计数
    pub fn increment(ctx: Context<Increment>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        counter.count = counter.count.checked_add(1)
            .ok_or(ErrorCode::Overflow)?;
        msg!("计数器增加到: {}", counter.count);
        Ok(())
    }

    // 减少计数
    pub fn decrement(ctx: Context<Decrement>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        require!(counter.count > 0, ErrorCode::Underflow);
        counter.count -= 1;
        msg!("计数器减少到: {}", counter.count);
        Ok(())
    }

    // 重置计数（只有 authority 可以）
    pub fn reset(ctx: Context<Reset>) -> Result<()> {
        let counter = &mut ctx.accounts.counter;
        counter.count = 0;
        msg!("计数器已重置");
        Ok(())
    }
}

// ========== Account 结构定义 ==========

// 计数器数据账户
#[account]
pub struct Counter {
    pub count: u64,          // 8 bytes
    pub authority: Pubkey,   // 32 bytes
}

// Counter 账户大小：8 (discriminator) + 8 (count) + 32 (authority) = 48 bytes
impl Counter {
    pub const SIZE: usize = 8 + 8 + 32;
}

// ========== 指令的 Account 约束 ==========

#[derive(Accounts)]
pub struct Initialize<'info> {
    // 创建新的 Counter 账户
    #[account(
        init,                          // 创建新账户
        payer = authority,             // 谁付租金
        space = Counter::SIZE,         // 账户大小
    )]
    pub counter: Account<'info, Counter>,

    // 付款人（签名者）
    #[account(mut)]
    pub authority: Signer<'info>,

    // 系统程序（创建账户需要）
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Increment<'info> {
    #[account(mut)]  // 可变：要修改 count
    pub counter: Account<'info, Counter>,
}

#[derive(Accounts)]
pub struct Decrement<'info> {
    #[account(mut)]
    pub counter: Account<'info, Counter>,
}

#[derive(Accounts)]
pub struct Reset<'info> {
    #[account(
        mut,
        // 约束：只有 authority 才能重置
        has_one = authority @ ErrorCode::Unauthorized,
    )]
    pub counter: Account<'info, Counter>,

    pub authority: Signer<'info>,
}

// ========== 自定义错误 ==========

#[error_code]
pub enum ErrorCode {
    #[msg("计数器溢出")]
    Overflow,
    #[msg("计数器不能小于 0")]
    Underflow,
    #[msg("无权限操作")]
    Unauthorized,
}
```

### PDA（Program Derived Address）

PDA 是 Solana 最重要的概念之一——程序可以"拥有"账户，而不需要私钥。

```rust
// PDA 的作用：让程序拥有和控制账户
// 
// 普通账户：有私钥 → 私钥持有者控制
// PDA 账户：没有私钥 → 只有程序能控制
//
// 用途：
// - 存储程序的全局状态
// - 作为代币的保管账户（Vault）
// - 实现类似 Solidity mapping 的功能

#[derive(Accounts)]
pub struct InitializeVault<'info> {
    #[account(
        init,
        payer = user,
        space = 8 + Vault::SIZE,
        // seeds + bump = PDA
        // 用 user 的公钥作为种子，每个用户有唯一的 Vault
        seeds = [b"vault", user.key().as_ref()],
        bump,
    )]
    pub vault: Account<'info, Vault>,

    #[account(mut)]
    pub user: Signer<'info>,

    pub system_program: Program<'info, System>,
}

#[account]
pub struct Vault {
    pub owner: Pubkey,
    pub balance: u64,
    pub bump: u8,  // 存储 bump 以便后续使用
}

impl Vault {
    pub const SIZE: usize = 32 + 8 + 1;
}

// PDA 就像以太坊的 mapping：
// Solidity: mapping(address => uint256) balances;
// Solana:   PDA(seeds=["vault", user_pubkey]) → Vault Account
```

## 13.4 SPL Token Staking 程序

一个实际的 Solana DeFi 项目：用户质押 SPL Token，按时间获得奖励。

```rust
// programs/staking/src/lib.rs
use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, TokenAccount, Transfer};

declare_id!("22222222222222222222222222222222");

#[program]
pub mod staking {
    use super::*;

    // 初始化质押池
    pub fn initialize_pool(
        ctx: Context<InitializePool>,
        reward_rate: u64,  // 每秒每个代币的奖励（精度 1e9）
    ) -> Result<()> {
        let pool = &mut ctx.accounts.pool;
        pool.authority = ctx.accounts.authority.key();
        pool.staking_mint = ctx.accounts.staking_mint.key();
        pool.reward_rate = reward_rate;
        pool.total_staked = 0;
        pool.last_update_time = Clock::get()?.unix_timestamp as u64;
        pool.bump = ctx.bumps.pool;
        Ok(())
    }

    // 质押代币
    pub fn stake(ctx: Context<Stake>, amount: u64) -> Result<()> {
        require!(amount > 0, StakingError::InvalidAmount);

        // 更新奖励
        update_rewards(&mut ctx.accounts.pool, &mut ctx.accounts.user_stake)?;

        // 转移代币到质押池
        let cpi_accounts = Transfer {
            from: ctx.accounts.user_token_account.to_account_info(),
            to: ctx.accounts.pool_token_account.to_account_info(),
            authority: ctx.accounts.user.to_account_info(),
        };
        let cpi_program = ctx.accounts.token_program.to_account_info();
        token::transfer(CpiContext::new(cpi_program, cpi_accounts), amount)?;

        // 更新状态
        let user_stake = &mut ctx.accounts.user_stake;
        user_stake.staked_amount += amount;
        
        let pool = &mut ctx.accounts.pool;
        pool.total_staked += amount;

        msg!("质押 {} 个代币成功", amount);
        Ok(())
    }

    // 取消质押
    pub fn unstake(ctx: Context<Unstake>, amount: u64) -> Result<()> {
        let user_stake = &mut ctx.accounts.user_stake;
        require!(amount <= user_stake.staked_amount, StakingError::InsufficientStake);

        // 更新奖励
        update_rewards(&mut ctx.accounts.pool, user_stake)?;

        // 从质押池转回代币（PDA 签名）
        let pool = &ctx.accounts.pool;
        let seeds = &[
            b"pool".as_ref(),
            pool.staking_mint.as_ref(),
            &[pool.bump],
        ];
        let signer_seeds = &[&seeds[..]];

        let cpi_accounts = Transfer {
            from: ctx.accounts.pool_token_account.to_account_info(),
            to: ctx.accounts.user_token_account.to_account_info(),
            authority: ctx.accounts.pool.to_account_info(),
        };
        token::transfer(
            CpiContext::new_with_signer(
                ctx.accounts.token_program.to_account_info(),
                cpi_accounts,
                signer_seeds,
            ),
            amount,
        )?;

        // 更新状态
        user_stake.staked_amount -= amount;
        ctx.accounts.pool.total_staked -= amount;

        msg!("取消质押 {} 个代币成功", amount);
        Ok(())
    }

    // 领取奖励
    pub fn claim_rewards(ctx: Context<ClaimRewards>) -> Result<()> {
        update_rewards(&mut ctx.accounts.pool, &mut ctx.accounts.user_stake)?;

        let rewards = ctx.accounts.user_stake.pending_rewards;
        require!(rewards > 0, StakingError::NoRewards);

        // 转移奖励代币...（简化）
        ctx.accounts.user_stake.pending_rewards = 0;

        msg!("领取 {} 奖励成功", rewards);
        Ok(())
    }
}

// 更新奖励计算
fn update_rewards(pool: &mut Account<Pool>, user_stake: &mut Account<UserStake>) -> Result<()> {
    let now = Clock::get()?.unix_timestamp as u64;
    let time_elapsed = now - pool.last_update_time;

    if time_elapsed > 0 && user_stake.staked_amount > 0 {
        // 奖励 = 质押数量 × 奖励率 × 时间
        let rewards = (user_stake.staked_amount as u128)
            .checked_mul(pool.reward_rate as u128)
            .unwrap()
            .checked_mul(time_elapsed as u128)
            .unwrap()
            .checked_div(1_000_000_000)  // 精度调整
            .unwrap() as u64;

        user_stake.pending_rewards += rewards;
    }

    pool.last_update_time = now;
    Ok(())
}

// ========== Account 结构 ==========

#[account]
pub struct Pool {
    pub authority: Pubkey,
    pub staking_mint: Pubkey,
    pub reward_rate: u64,
    pub total_staked: u64,
    pub last_update_time: u64,
    pub bump: u8,
}

#[account]
pub struct UserStake {
    pub owner: Pubkey,
    pub pool: Pubkey,
    pub staked_amount: u64,
    pub pending_rewards: u64,
    pub last_stake_time: u64,
    pub bump: u8,
}

#[error_code]
pub enum StakingError {
    #[msg("金额必须大于 0")]
    InvalidAmount,
    #[msg("质押余额不足")]
    InsufficientStake,
    #[msg("没有可领取的奖励")]
    NoRewards,
}

// ========== Account 约束（简化） ==========

#[derive(Accounts)]
pub struct InitializePool<'info> {
    #[account(
        init,
        payer = authority,
        space = 8 + 32 + 32 + 8 + 8 + 8 + 1,
        seeds = [b"pool", staking_mint.key().as_ref()],
        bump,
    )]
    pub pool: Account<'info, Pool>,
    pub staking_mint: Account<'info, token::Mint>,
    #[account(mut)]
    pub authority: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct Stake<'info> {
    #[account(mut)]
    pub pool: Account<'info, Pool>,
    #[account(mut)]
    pub user_stake: Account<'info, UserStake>,
    #[account(mut)]
    pub user_token_account: Account<'info, TokenAccount>,
    #[account(mut)]
    pub pool_token_account: Account<'info, TokenAccount>,
    pub user: Signer<'info>,
    pub token_program: Program<'info, Token>,
}

#[derive(Accounts)]
pub struct Unstake<'info> {
    #[account(mut)]
    pub pool: Account<'info, Pool>,
    #[account(mut)]
    pub user_stake: Account<'info, UserStake>,
    #[account(mut)]
    pub user_token_account: Account<'info, TokenAccount>,
    #[account(mut)]
    pub pool_token_account: Account<'info, TokenAccount>,
    pub user: Signer<'info>,
    pub token_program: Program<'info, Token>,
}

#[derive(Accounts)]
pub struct ClaimRewards<'info> {
    #[account(mut)]
    pub pool: Account<'info, Pool>,
    #[account(mut)]
    pub user_stake: Account<'info, UserStake>,
    pub user: Signer<'info>,
}
```

## 13.5 测试与部署

```bash
# 启动本地验证器
solana-test-validator

# 构建
anchor build

# 测试
anchor test

# 部署到 devnet
solana config set --url devnet
anchor deploy
```

```typescript
// tests/my_counter.ts
import * as anchor from "@coral-xyz/anchor";
import { Program } from "@coral-xyz/anchor";
import { MyCounter } from "../target/types/my_counter";
import { expect } from "chai";

describe("my_counter", () => {
  const provider = anchor.AnchorProvider.env();
  anchor.setProvider(provider);

  const program = anchor.workspace.MyCounter as Program<MyCounter>;
  const counter = anchor.web3.Keypair.generate();

  it("初始化计数器", async () => {
    await program.methods
      .initialize()
      .accounts({
        counter: counter.publicKey,
        authority: provider.wallet.publicKey,
        systemProgram: anchor.web3.SystemProgram.programId,
      })
      .signers([counter])
      .rpc();

    const account = await program.account.counter.fetch(counter.publicKey);
    expect(account.count.toNumber()).to.equal(0);
  });

  it("增加计数", async () => {
    await program.methods
      .increment()
      .accounts({ counter: counter.publicKey })
      .rpc();

    const account = await program.account.counter.fetch(counter.publicKey);
    expect(account.count.toNumber()).to.equal(1);
  });

  it("连续增加 5 次", async () => {
    for (let i = 0; i < 5; i++) {
      await program.methods
        .increment()
        .accounts({ counter: counter.publicKey })
        .rpc();
    }

    const account = await program.account.counter.fetch(counter.publicKey);
    expect(account.count.toNumber()).to.equal(6); // 1 + 5
  });

  it("非 authority 不能重置", async () => {
    const fakeUser = anchor.web3.Keypair.generate();
    
    try {
      await program.methods
        .reset()
        .accounts({
          counter: counter.publicKey,
          authority: fakeUser.publicKey,
        })
        .signers([fakeUser])
        .rpc();
      expect.fail("应该抛出错误");
    } catch (err) {
      expect(err.toString()).to.include("Unauthorized");
    }
  });
});
```

## 13.6 本章小结与练习

### 你学到了什么

- Solana vs Ethereum 的核心区别：Account Model、并行执行、BPF 虚拟机
- Rust 核心概念：所有权、借用、枚举、模式匹配、Result/Option
- Anchor 框架：项目结构、Account 约束、PDA、CPI
- 完整的计数器合约：初始化、增减、权限控制
- SPL Token Staking 程序：质押、取消质押、奖励计算
- PDA 的作用：程序控制的账户，类似 Solidity 的 mapping

### 动手练习

1. **扩展计数器**：添加一个 `set_count` 指令，只有 authority 可以设置任意值

2. **SPL Token 铸造**：用 Anchor 创建一个自定义 SPL Token，支持铸造和转账

3. **简单 DEX**：实现一个 Token Swap 程序——用户存入 Token A，按固定汇率换取 Token B

4. **NFT 铸造**：用 Metaplex 标准铸造一个 Solana NFT，包含元数据和图片

### 下一章预告

下一章回到 Flutter，深入开发跨平台钱包——HD 钱包派生、多链支持、安全存储、交易签名的完整实现。
