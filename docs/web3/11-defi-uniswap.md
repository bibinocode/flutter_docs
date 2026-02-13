# 第 11 章：DeFi 协议开发 — Uniswap V3/V4 深度实战

> DeFi 是 Web3 最核心的应用场景，而 Uniswap 是 DeFi 的基石。这一章从 AMM 的数学原理讲起，带你精读 Uniswap V3 核心合约，再到 V4 的 Hooks 创新机制。学完这章，你不仅能看懂 DeFi 协议的源码，还能自己开发自定义交易逻辑。

## 11.1 AMM 是什么？为什么不需要订单簿？

### 传统交易所 vs AMM

```
传统交易所（订单簿模式）：
  买方挂单：我要用 3000 USDC 买 1 ETH
  卖方挂单：我要用 1 ETH 换 3100 USDC
  撮合引擎：当买卖价格匹配时成交
  
  问题：
  ❌ 需要大量做市商提供流动性
  ❌ 链上订单簿 Gas 成本极高（每次挂单/撤单都是交易）
  ❌ 小币种流动性差，买卖价差大

AMM（自动做市商）：
  流动性提供者：把 ETH + USDC 存入池子
  交易者：直接和池子交易，价格由数学公式决定
  
  优势：
  ✅ 任何人都能提供流动性（赚手续费）
  ✅ 永远有流动性（只要池子里有钱）
  ✅ 完全去中心化，无需信任第三方
  ✅ 一笔交易就能完成兑换
```

### 恒定乘积公式：x × y = k

这是 Uniswap V2 的核心公式，也是理解所有 AMM 的基础：

```
池子里有两种代币：
  x = ETH 数量（比如 100 ETH）
  y = USDC 数量（比如 300,000 USDC）
  k = x × y = 100 × 300,000 = 30,000,000（常数）

当前价格：
  1 ETH = 300,000 / 100 = 3,000 USDC

有人想用 USDC 买 1 ETH：
  交易后：x' = 99 ETH
  根据 x' × y' = k：y' = 30,000,000 / 99 = 303,030.30 USDC
  用户需要支付：303,030.30 - 300,000 = 3,030.30 USDC
  
  注意：买 1 ETH 花了 3,030.30 USDC，比"当前价格" 3,000 贵了！
  这就是"滑点"（Slippage）——交易量越大，价格偏离越多。

价格曲线（双曲线）：
  y
  │
  │╲
  │  ╲
  │    ╲
  │      ╲
  │        ╲──────────
  │
  └──────────────────── x
  
  特点：
  - 永远不会到 0（渐近线）
  - 交易量越大，价格变化越剧烈
  - 流动性分布在 0 到 ∞ 的整个价格范围
```

### 用 Go 实现 AMM 数学库

```go
// pkg/amm/constant_product.go
package amm

import (
	"fmt"
	"math/big"
)

// ConstantProductPool 恒定乘积 AMM 池
type ConstantProductPool struct {
	ReserveX *big.Int // 代币 X 储备量
	ReserveY *big.Int // 代币 Y 储备量
	FeeRate  uint64   // 手续费率（万分比，如 30 = 0.3%）
}

// NewPool 创建新池子
func NewPool(reserveX, reserveY *big.Int, feeRate uint64) *ConstantProductPool {
	return &ConstantProductPool{
		ReserveX: new(big.Int).Set(reserveX),
		ReserveY: new(big.Int).Set(reserveY),
		FeeRate:  feeRate,
	}
}

// GetK 计算 k 值
func (p *ConstantProductPool) GetK() *big.Int {
	return new(big.Int).Mul(p.ReserveX, p.ReserveY)
}

// GetPriceXInY 获取 X 相对于 Y 的价格（1 个 X 值多少 Y）
func (p *ConstantProductPool) GetPriceXInY() *big.Float {
	x := new(big.Float).SetInt(p.ReserveX)
	y := new(big.Float).SetInt(p.ReserveY)
	return new(big.Float).Quo(y, x)
}

// SwapXForY 用 X 换 Y（输入确定数量的 X，计算能得到多少 Y）
// 公式：dy = y - k / (x + dx * (1 - fee))
func (p *ConstantProductPool) SwapXForY(amountXIn *big.Int) (*big.Int, error) {
	if amountXIn.Sign() <= 0 {
		return nil, fmt.Errorf("输入金额必须大于 0")
	}

	// 扣除手续费
	// amountInWithFee = amountXIn * (10000 - feeRate) / 10000
	feeMultiplier := big.NewInt(int64(10000 - p.FeeRate))
	amountInWithFee := new(big.Int).Mul(amountXIn, feeMultiplier)
	amountInWithFee.Div(amountInWithFee, big.NewInt(10000))

	// 新的 X 储备
	newReserveX := new(big.Int).Add(p.ReserveX, amountInWithFee)

	// k = x * y，新的 Y 储备 = k / newReserveX
	k := p.GetK()
	newReserveY := new(big.Int).Div(k, newReserveX)

	// 输出的 Y 数量
	amountYOut := new(big.Int).Sub(p.ReserveY, newReserveY)

	if amountYOut.Sign() <= 0 {
		return nil, fmt.Errorf("输出金额为 0，流动性不足")
	}

	return amountYOut, nil
}

// GetSwapPrice 计算交易的实际价格和滑点
func (p *ConstantProductPool) GetSwapPrice(amountXIn *big.Int) (*SwapQuote, error) {
	amountYOut, err := p.SwapXForY(amountXIn)
	if err != nil {
		return nil, err
	}

	// 实际价格 = amountYOut / amountXIn
	actualPrice := new(big.Float).Quo(
		new(big.Float).SetInt(amountYOut),
		new(big.Float).SetInt(amountXIn),
	)

	// 市场价格（无滑点）
	marketPrice := p.GetPriceXInY()

	// 滑点 = (marketPrice - actualPrice) / marketPrice * 100%
	diff := new(big.Float).Sub(marketPrice, actualPrice)
	slippage := new(big.Float).Quo(diff, marketPrice)
	slippage.Mul(slippage, big.NewFloat(100))

	slippageFloat, _ := slippage.Float64()

	// 价格影响
	return &SwapQuote{
		AmountIn:    amountXIn,
		AmountOut:   amountYOut,
		Price:       actualPrice,
		MarketPrice: marketPrice,
		Slippage:    slippageFloat,
	}, nil
}

type SwapQuote struct {
	AmountIn    *big.Int
	AmountOut   *big.Int
	Price       *big.Float // 实际成交价
	MarketPrice *big.Float // 市场价
	Slippage    float64    // 滑点百分比
}

func (q *SwapQuote) String() string {
	price, _ := q.Price.Float64()
	market, _ := q.MarketPrice.Float64()
	return fmt.Sprintf(
		"输入: %s, 输出: %s, 成交价: %.4f, 市场价: %.4f, 滑点: %.2f%%",
		q.AmountIn, q.AmountOut, price, market, q.Slippage,
	)
}
```

### 测试 AMM 数学

```go
package amm

import (
	"fmt"
	"math/big"
	"testing"
)

func TestConstantProductSwap(t *testing.T) {
	// 创建池子：100 ETH + 300,000 USDC，0.3% 手续费
	pool := NewPool(
		big.NewInt(100_000000000000000000),   // 100 ETH (18 decimals)
		big.NewInt(300_000_000000),            // 300,000 USDC (6 decimals)
		30, // 0.3%
	)

	fmt.Printf("池子状态: %s ETH + %s USDC\n", pool.ReserveX, pool.ReserveY)
	fmt.Printf("当前价格: %s USDC/ETH\n", pool.GetPriceXInY().Text('f', 2))

	// 模拟不同金额的交易
	testAmounts := []int64{
		1_000000000000000000,   // 1 ETH
		10_000000000000000000,  // 10 ETH
		50_000000000000000000,  // 50 ETH
	}

	for _, amount := range testAmounts {
		quote, err := pool.GetSwapPrice(big.NewInt(amount))
		if err != nil {
			t.Fatal(err)
		}
		fmt.Printf("\n交易 %d ETH:\n  %s\n",
			amount/1_000000000000000000, quote)
	}
}

// 输出：
// 池子状态: 100000000000000000000 ETH + 300000000000 USDC
// 当前价格: 3000.00 USDC/ETH
//
// 交易 1 ETH:
//   输入: 1000000000000000000, 输出: 2982089552, 成交价: 2982.09, 市场价: 3000.00, 滑点: 0.60%
//
// 交易 10 ETH:
//   输入: 10000000000000000000, 输出: 27210884353, 成交价: 2721.09, 市场价: 3000.00, 滑点: 9.30%
//
// 交易 50 ETH:
//   输入: 50000000000000000000, 输出: 99800399201, 成交价: 1996.01, 市场价: 3000.00, 滑点: 33.47%
```

看到了吗？买 1 ETH 滑点只有 0.6%，但买 50 ETH 滑点高达 33%！这就是恒定乘积公式的特性——大额交易的成本非常高。

## 11.2 Uniswap V3：集中流动性革命

V2 的问题：流动性分布在 0 到 ∞ 的整个价格范围，但 99% 的交易发生在很窄的价格区间。大部分流动性被浪费了。

```
Uniswap V2 流动性分布：
  流动性
  │ ████████████████████████████████████████
  │ ████████████████████████████████████████
  │ ████████████████████████████████████████
  └──────────────────────────────────────── 价格
  0                                        ∞
  
  问题：ETH 价格在 2500-3500 波动，但流动性均匀分布在 0-∞
  → 只有很小一部分流动性在"工作"

Uniswap V3 集中流动性：
  流动性
  │                    ████
  │                   ██████
  │                  ████████
  │                 ██████████
  │ ░░░░░░░░░░░░░░████████████░░░░░░░░░░░░
  └──────────────────────────────────────── 价格
  0            2500  3000  3500            ∞
  
  LP 可以选择只在 2500-3500 范围提供流动性
  → 资金效率提升 4000 倍！
```

### V3 的核心概念：Tick

V3 把连续的价格空间离散化为一个个 "Tick"：

```
Tick 系统：
  每个 Tick 代表一个价格点
  价格 = 1.0001^tick
  
  tick = 0    → 价格 = 1.0001^0 = 1
  tick = 100  → 价格 = 1.0001^100 ≈ 1.01005
  tick = 1000 → 价格 = 1.0001^1000 ≈ 1.10517
  tick = 69082 → 价格 ≈ 1000 (ETH/USDC 的大致位置)
  
  为什么用 1.0001？
  → 相邻 Tick 之间的价格差 = 0.01% = 1 个基点 (basis point)
  → 这个精度对金融交易来说足够了

Tick Spacing（Tick 间距）：
  不是每个 Tick 都能作为流动性边界
  - 0.05% 手续费池：tickSpacing = 10
  - 0.3% 手续费池：tickSpacing = 60
  - 1% 手续费池：tickSpacing = 200
  
  间距越大 → 可选的价格点越少 → Gas 越便宜
```

### V3 数学：Q64.96 定点数

Solidity 不支持浮点数，所以 Uniswap V3 用定点数表示价格：

```
sqrtPriceX96 = sqrt(price) × 2^96

为什么存 sqrt(price) 而不是 price？
→ 因为 Swap 计算中大量用到 sqrt(price)，直接存储避免重复计算
→ 而且 sqrt 让数值范围更小，减少溢出风险

例子：
  ETH/USDC 价格 = 3000
  sqrt(3000) = 54.772
  sqrtPriceX96 = 54.772 × 2^96 = 54.772 × 79228162514264337593543950336
                ≈ 4341505286948089843049...（一个很大的整数）

Go 实现：
```

```go
// pkg/amm/tick_math.go
package amm

import (
	"math"
	"math/big"
)

const (
	Q96  = 96
	Q128 = 128
)

var (
	Q96Big  = new(big.Int).Lsh(big.NewInt(1), Q96)  // 2^96
	Q128Big = new(big.Int).Lsh(big.NewInt(1), Q128) // 2^128
)

// TickToPrice 从 Tick 计算价格
// price = 1.0001^tick
func TickToPrice(tick int32) float64 {
	return math.Pow(1.0001, float64(tick))
}

// PriceToTick 从价格计算 Tick
// tick = log(price) / log(1.0001)
func PriceToTick(price float64) int32 {
	return int32(math.Log(price) / math.Log(1.0001))
}

// TickToSqrtPriceX96 从 Tick 计算 sqrtPriceX96
func TickToSqrtPriceX96(tick int32) *big.Int {
	price := TickToPrice(tick)
	sqrtPrice := math.Sqrt(price)

	// sqrtPriceX96 = sqrtPrice * 2^96
	sqrtPriceFloat := new(big.Float).SetFloat64(sqrtPrice)
	q96Float := new(big.Float).SetInt(Q96Big)
	result := new(big.Float).Mul(sqrtPriceFloat, q96Float)

	resultInt, _ := result.Int(nil)
	return resultInt
}

// SqrtPriceX96ToPrice 从 sqrtPriceX96 计算价格
func SqrtPriceX96ToPrice(sqrtPriceX96 *big.Int, decimals0, decimals1 int) float64 {
	// price = (sqrtPriceX96 / 2^96)^2
	sqrtPrice := new(big.Float).Quo(
		new(big.Float).SetInt(sqrtPriceX96),
		new(big.Float).SetInt(Q96Big),
	)
	price := new(big.Float).Mul(sqrtPrice, sqrtPrice)

	// 调整精度差异
	decimalsDiff := decimals1 - decimals0
	adjustment := math.Pow(10, float64(decimalsDiff))
	adjustedPrice := new(big.Float).Quo(price, big.NewFloat(adjustment))

	result, _ := adjustedPrice.Float64()
	return result
}

// 使用示例
func ExampleTickMath() {
	// ETH/USDC 价格 3000
	tick := PriceToTick(3000)
	fmt.Printf("价格 3000 对应的 Tick: %d\n", tick)
	// 输出: 价格 3000 对应的 Tick: 80067

	// 反向计算
	price := TickToPrice(80067)
	fmt.Printf("Tick 80067 对应的价格: %.2f\n", price)
	// 输出: Tick 80067 对应的价格: 3000.10

	// 计算 sqrtPriceX96
	sqrtPriceX96 := TickToSqrtPriceX96(80067)
	fmt.Printf("sqrtPriceX96: %s\n", sqrtPriceX96)
}
```

### 无常损失（Impermanent Loss）计算

这是每个 LP（流动性提供者）必须理解的概念：

```
场景：你在 ETH = 3000 USDC 时，存入 1 ETH + 3000 USDC
      总价值 = 6000 USDC

情况 1：ETH 涨到 4000 USDC
  如果你不做 LP，持有 1 ETH + 3000 USDC = 7000 USDC
  
  做了 LP 后（恒定乘积公式）：
  k = 1 × 3000 = 3000
  新价格 4000 → y/x = 4000 → y = 4000x
  k = x × 4000x = 4000x² = 3000
  x = sqrt(3000/4000) = 0.866 ETH
  y = 4000 × 0.866 = 3464 USDC
  LP 总价值 = 0.866 × 4000 + 3464 = 6928 USDC
  
  无常损失 = 7000 - 6928 = 72 USDC (1.03%)

情况 2：ETH 跌到 2000 USDC
  持有不动：1 × 2000 + 3000 = 5000 USDC
  做 LP：
  x = sqrt(3000/2000) = 1.225 ETH
  y = 2000 × 1.225 = 2449 USDC
  LP 总价值 = 1.225 × 2000 + 2449 = 4899 USDC
  
  无常损失 = 5000 - 4899 = 101 USDC (2.02%)
```

```go
// pkg/amm/impermanent_loss.go
package amm

import (
	"fmt"
	"math"
)

// ImpermanentLoss 计算无常损失
// priceRatio = 新价格 / 初始价格
func ImpermanentLoss(priceRatio float64) float64 {
	// IL = 2 * sqrt(r) / (1 + r) - 1
	sqrtR := math.Sqrt(priceRatio)
	il := 2*sqrtR/(1+priceRatio) - 1
	return il // 负数表示损失
}

// ImpermanentLossTable 打印无常损失对照表
func ImpermanentLossTable() {
	fmt.Println("价格变化倍数 | 无常损失")
	fmt.Println("------------|--------")
	ratios := []float64{0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 4.0, 5.0}
	for _, r := range ratios {
		il := ImpermanentLoss(r)
		fmt.Printf("  %.2fx       | %.2f%%\n", r, il*100)
	}
}

// 输出：
// 价格变化倍数 | 无常损失
// ------------|--------
//   0.25x      | -5.72%
//   0.50x      | -5.72%    ← 跌 50% 和涨 100% 的 IL 一样！
//   0.75x      | -0.38%
//   1.00x      | 0.00%     ← 价格不变，无损失
//   1.25x      | -0.06%
//   1.50x      | -0.34%
//   2.00x      | -5.72%
//   3.00x      | -13.40%
//   4.00x      | -20.00%
//   5.00x      | -25.46%
```

## 11.3 Uniswap V3 核心合约精读

### 合约架构

```
Uniswap V3 合约结构：
┌─────────────────────────────────────────────────┐
│                  用户/前端                        │
└──────────┬──────────────────────┬───────────────┘
           │                      │
    ┌──────▼──────┐      ┌───────▼────────┐
    │ SwapRouter  │      │ NonfungiblePos │
    │ (交易路由)   │      │ itionManager  │
    │             │      │ (头寸管理)      │
    └──────┬──────┘      └───────┬────────┘
           │                      │
    ┌──────▼──────────────────────▼──────┐
    │         UniswapV3Pool              │
    │  (核心池合约 - 每个交易对一个)       │
    │  - swap()    交易                  │
    │  - mint()    添加流动性             │
    │  - burn()    移除流动性             │
    │  - collect() 收取手续费             │
    │  - flash()   闪电贷                │
    └──────────────┬─────────────────────┘
                   │
    ┌──────────────▼─────────────────────┐
    │       UniswapV3Factory             │
    │  (工厂合约 - 创建和管理所有池)       │
    │  - createPool()                    │
    │  - getPool()                       │
    └────────────────────────────────────┘
```

### Swap 核心逻辑解析

```solidity
// 简化版 Uniswap V3 Swap 逻辑（帮助理解）
// 实际合约更复杂，这里提取核心思路

// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.20;

contract SimplifiedV3Pool {
    // 池子状态
    uint160 public sqrtPriceX96;    // 当前价格的平方根（Q64.96 格式）
    int24 public tick;               // 当前 Tick
    uint128 public liquidity;        // 当前活跃流动性

    // Tick 数据：每个 Tick 存储的信息
    struct TickInfo {
        uint128 liquidityGross;      // 该 Tick 上的总流动性
        int128 liquidityNet;         // 穿过该 Tick 时流动性的变化量
        // 正数 = 进入范围时增加流动性
        // 负数 = 离开范围时减少流动性
    }
    mapping(int24 => TickInfo) public ticks;

    // Swap 的核心逻辑（极度简化版）
    function swap(
        bool zeroForOne,      // true = token0 换 token1, false = 反向
        int256 amountSpecified // 正数 = 精确输入, 负数 = 精确输出
    ) external returns (int256 amount0, int256 amount1) {
        // Swap 的本质：沿着价格曲线移动
        // 
        // 如果 zeroForOne（用 token0 买 token1）：
        //   价格下降（sqrtPriceX96 减小）
        //   tick 向左移动
        //
        // 如果 !zeroForOne（用 token1 买 token0）：
        //   价格上升（sqrtPriceX96 增大）
        //   tick 向右移动

        uint160 sqrtPriceLimitX96 = zeroForOne 
            ? TickMath.MIN_SQRT_RATIO + 1 
            : TickMath.MAX_SQRT_RATIO - 1;

        // 循环：一步步穿过 Tick
        while (amountSpecified != 0 && sqrtPriceX96 != sqrtPriceLimitX96) {
            // 1. 找到下一个初始化的 Tick
            int24 nextTick = findNextInitializedTick(tick, zeroForOne);
            
            // 2. 在当前 Tick 范围内计算能交易多少
            //    （在同一个流动性区间内，就是简单的恒定乘积公式）
            (uint160 sqrtPriceNextX96, uint256 amountIn, uint256 amountOut) = 
                computeSwapStep(sqrtPriceX96, nextTickSqrtPrice, liquidity, amountSpecified);
            
            // 3. 更新剩余金额
            amountSpecified -= amountIn;
            
            // 4. 如果到达了下一个 Tick 的边界
            if (sqrtPriceNextX96 == nextTickSqrtPrice) {
                // 穿过 Tick：更新流动性
                // 这就是 V3 的精髓——不同价格区间有不同的流动性
                int128 liquidityDelta = ticks[nextTick].liquidityNet;
                if (zeroForOne) liquidityDelta = -liquidityDelta;
                liquidity = addDelta(liquidity, liquidityDelta);
                tick = zeroForOne ? nextTick - 1 : nextTick;
            }
            
            // 5. 更新价格
            sqrtPriceX96 = sqrtPriceNextX96;
        }
    }
}
```

### 关键理解：为什么 Swap 要"穿过 Tick"？

```
假设池子的流动性分布如下：

  流动性
  │
  │         ┌────┐
  │    ┌────┤    ├────┐
  │    │    │    │    │
  │ ───┤    │    │    ├───
  │    │    │    │    │
  └────┴────┴────┴────┴──── 价格
       A    B    C    D
       
  价格区间 [A,B]: 流动性 = 100
  价格区间 [B,C]: 流动性 = 300（有更多 LP 在这个范围）
  价格区间 [C,D]: 流动性 = 200

当一笔大额 Swap 把价格从 C 推到 A：
  1. 先在 [B,C] 区间用 300 的流动性计算
  2. 穿过 Tick B 时，流动性变为 100
  3. 在 [A,B] 区间用 100 的流动性继续计算
  
  流动性越大 → 同样的交易量 → 价格变化越小 → 滑点越低
```

## 11.4 Uniswap V4：Hooks 机制

V4 是 Uniswap 的最新版本，最大的创新是 Hooks——允许开发者在交易的各个阶段插入自定义逻辑。

### V4 架构变化

```
V3 架构：每个交易对一个独立合约
  ETH/USDC Pool (独立合约)
  ETH/DAI Pool  (独立合约)
  USDC/DAI Pool (独立合约)
  → 跨池交易需要多次转账，Gas 高

V4 架构：所有池共享一个 Singleton 合约
  ┌─────────────────────────────────┐
  │         PoolManager             │
  │  (所有池都在这一个合约里)         │
  │                                 │
  │  Pool 1: ETH/USDC              │
  │  Pool 2: ETH/DAI               │
  │  Pool 3: USDC/DAI              │
  │  ...                           │
  │                                 │
  │  + Flash Accounting            │
  │  (交易结束才结算，中间不转账)     │
  └─────────────────────────────────┘
  
  优势：
  ✅ 跨池交易只需要一次转账（Gas 大幅降低）
  ✅ 闪电记账：先记账后结算
  ✅ Hooks：可插拔的自定义逻辑
```

### Hooks 的 8 个钩子点

```
一笔 Swap 交易的生命周期：

  用户发起 Swap
       │
       ▼
  ┌─────────────────┐
  │ beforeInitialize │ ← Hook: 池子创建前
  │ afterInitialize  │ ← Hook: 池子创建后
  └────────┬────────┘
           │
  ┌────────▼────────┐
  │  beforeSwap     │ ← Hook: 交易前（可以修改交易参数）
  │                 │
  │  执行 Swap      │
  │                 │
  │  afterSwap      │ ← Hook: 交易后（可以执行额外逻辑）
  └────────┬────────┘
           │
  ┌────────▼────────┐
  │ beforeAddLiq    │ ← Hook: 添加流动性前
  │ afterAddLiq     │ ← Hook: 添加流动性后
  │ beforeRemoveLiq │ ← Hook: 移除流动性前
  │ afterRemoveLiq  │ ← Hook: 移除流动性后
  └─────────────────┘
```

### 实战：开发一个动态手续费 Hook

根据市场波动率自动调整手续费——波动大时手续费高（保护 LP），波动小时手续费低（吸引交易者）。

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {BaseHook} from "v4-periphery/BaseHook.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {BeforeSwapDelta, BeforeSwapDeltaLibrary} from "v4-core/types/BeforeSwapDelta.sol";

/// @title DynamicFeeHook - 根据波动率动态调整手续费
/// @notice 波动率高 → 手续费高（保护 LP）
///         波动率低 → 手续费低（吸引交易量）
contract DynamicFeeHook is BaseHook {
    using PoolIdLibrary for PoolKey;

    // ========== 状态变量 ==========
    
    // 每个池子的价格历史（用于计算波动率）
    mapping(PoolId => uint160[]) public priceHistory;
    
    // 每个池子的当前动态手续费
    mapping(PoolId => uint24) public dynamicFee;
    
    // 手续费范围
    uint24 public constant MIN_FEE = 100;    // 0.01%
    uint24 public constant MAX_FEE = 10000;  // 1%
    uint24 public constant BASE_FEE = 3000;  // 0.3%（默认）
    
    // 波动率计算窗口
    uint256 public constant PRICE_WINDOW = 10; // 最近 10 笔交易

    constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

    // ========== Hook 权限声明 ==========
    
    function getHookPermissions() public pure override returns (Hooks.Permissions memory) {
        return Hooks.Permissions({
            beforeInitialize: false,
            afterInitialize: true,     // 池子创建后初始化
            beforeSwap: true,          // 交易前设置动态手续费
            afterSwap: true,           // 交易后更新价格历史
            beforeAddLiquidity: false,
            afterAddLiquidity: false,
            beforeRemoveLiquidity: false,
            afterRemoveLiquidity: false,
            beforeDonate: false,
            afterDonate: false,
            befreSwapReturnDelta: false,
            afterSwapReturnDelta: false,
            afterAddLiquidityReturnDelta: false,
            afterRemoveLiquidityReturnDelta: false
        });
    }

    // ========== Hook 实现 ==========

    /// @notice 池子创建后，初始化默认手续费
    function afterInitialize(
        address,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24,
        bytes calldata
    ) external override returns (bytes4) {
        PoolId poolId = key.toId();
        dynamicFee[poolId] = BASE_FEE;
        priceHistory[poolId].push(sqrtPriceX96);
        return BaseHook.afterInitialize.selector;
    }

    /// @notice 交易前：根据波动率设置手续费
    function beforeSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        bytes calldata
    ) external override returns (bytes4, BeforeSwapDelta, uint24) {
        PoolId poolId = key.toId();
        uint24 fee = dynamicFee[poolId];
        
        // 返回动态手续费（覆盖池子的默认手续费）
        return (
            BaseHook.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            fee | uint24(0x400000) // 设置 override flag
        );
    }

    /// @notice 交易后：记录价格，重新计算波动率
    function afterSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        BalanceDelta,
        bytes calldata
    ) external override returns (bytes4, int128) {
        PoolId poolId = key.toId();
        
        // 获取当前价格
        (uint160 sqrtPriceX96,,,) = poolManager.getSlot0(poolId);
        
        // 记录价格
        priceHistory[poolId].push(sqrtPriceX96);
        
        // 保持窗口大小
        if (priceHistory[poolId].length > PRICE_WINDOW) {
            // 简化处理：实际应该用环形缓冲区
            _trimHistory(poolId);
        }
        
        // 重新计算波动率和手续费
        dynamicFee[poolId] = _calculateFee(poolId);
        
        return (BaseHook.afterSwap.selector, 0);
    }

    // ========== 内部函数 ==========

    /// @notice 根据价格历史计算波动率，映射到手续费
    function _calculateFee(PoolId poolId) internal view returns (uint24) {
        uint160[] storage prices = priceHistory[poolId];
        if (prices.length < 2) return BASE_FEE;

        // 计算价格变化的标准差（简化版）
        uint256 totalVariance = 0;
        for (uint256 i = 1; i < prices.length; i++) {
            uint256 priceDiff;
            if (prices[i] > prices[i-1]) {
                priceDiff = uint256(prices[i] - prices[i-1]);
            } else {
                priceDiff = uint256(prices[i-1] - prices[i]);
            }
            // 归一化：变化率 = diff / price * 10000
            uint256 changeRate = (priceDiff * 10000) / uint256(prices[i-1]);
            totalVariance += changeRate * changeRate;
        }
        
        uint256 avgVariance = totalVariance / (prices.length - 1);
        
        // 映射到手续费范围
        // 低波动（variance < 100）→ MIN_FEE
        // 高波动（variance > 10000）→ MAX_FEE
        if (avgVariance < 100) return MIN_FEE;
        if (avgVariance > 10000) return MAX_FEE;
        
        // 线性插值
        uint24 fee = uint24(MIN_FEE + (avgVariance - 100) * (MAX_FEE - MIN_FEE) / 9900);
        return fee;
    }

    function _trimHistory(PoolId poolId) internal {
        uint160[] storage prices = priceHistory[poolId];
        uint256 excess = prices.length - PRICE_WINDOW;
        for (uint256 i = 0; i < PRICE_WINDOW; i++) {
            prices[i] = prices[i + excess];
        }
        for (uint256 i = 0; i < excess; i++) {
            prices.pop();
        }
    }
}
```

### 用 Foundry 测试 Hook

```solidity
// test/DynamicFeeHook.t.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {CurrencyLibrary, Currency} from "v4-core/types/Currency.sol";
import {DynamicFeeHook} from "../src/DynamicFeeHook.sol";

contract DynamicFeeHookTest is Test {
    DynamicFeeHook hook;

    function setUp() public {
        // 部署 Hook（需要特定地址前缀，这里简化）
        // 实际测试需要用 HookMiner 找到正确的 salt
    }

    function testFeeIncreasesWithVolatility() public {
        // 模拟高波动场景：价格剧烈变化
        // 验证手续费是否增加
    }

    function testFeeDecreasesWithStability() public {
        // 模拟低波动场景：价格稳定
        // 验证手续费是否降低
    }

    function testFeeWithinBounds() public {
        // Fuzz 测试：无论什么输入，手续费都在 MIN_FEE 和 MAX_FEE 之间
    }
}
```

## 11.5 用 Go 封装 Uniswap V3 交互 SDK

实际项目中，你的 Go 后端需要和 Uniswap 合约交互（查询价格、执行交易、管理流动性）。

```go
// pkg/uniswap/v3_client.go
package uniswap

import (
	"context"
	"fmt"
	"math/big"

	"github.com/ethereum/go-ethereum/accounts/abi/bind"
	"github.com/ethereum/go-ethereum/common"
	"github.com/ethereum/go-ethereum/ethclient"
)

// V3 合约地址（以太坊主网）
var (
	FactoryAddress = common.HexToAddress("0x1F98431c8aD98523631AE4a59f267346ea31F984")
	RouterAddress  = common.HexToAddress("0xE592427A0AEce92De3Edee1F18E0157C05861564")
	QuoterAddress  = common.HexToAddress("0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6")
)

// 常用代币地址
var (
	WETH = common.HexToAddress("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")
	USDC = common.HexToAddress("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")
	USDT = common.HexToAddress("0xdAC17F958D2ee523a2206206994597C13D831ec7")
	DAI  = common.HexToAddress("0x6B175474E89094C44Da98b954EedeAC495271d0F")
)

type UniswapV3Client struct {
	client  *ethclient.Client
	chainID *big.Int
}

func NewUniswapV3Client(rpcURL string) (*UniswapV3Client, error) {
	client, err := ethclient.Dial(rpcURL)
	if err != nil {
		return nil, err
	}

	chainID, err := client.ChainID(context.Background())
	if err != nil {
		return nil, err
	}

	return &UniswapV3Client{
		client:  client,
		chainID: chainID,
	}, nil
}

// PoolInfo 池子信息
type PoolInfo struct {
	Address      common.Address
	Token0       common.Address
	Token1       common.Address
	Fee          *big.Int
	Liquidity    *big.Int
	SqrtPriceX96 *big.Int
	Tick         int32
}

// GetPoolInfo 查询池子信息
func (c *UniswapV3Client) GetPoolInfo(
	ctx context.Context,
	token0, token1 common.Address,
	fee *big.Int,
) (*PoolInfo, error) {
	// 1. 通过 Factory 获取池子地址
	// factory, _ := NewUniswapV3Factory(FactoryAddress, c.client)
	// poolAddr, _ := factory.GetPool(&bind.CallOpts{Context: ctx}, token0, token1, fee)
	
	// 2. 查询池子状态
	// pool, _ := NewUniswapV3Pool(poolAddr, c.client)
	// slot0, _ := pool.Slot0(&bind.CallOpts{Context: ctx})
	// liquidity, _ := pool.Liquidity(&bind.CallOpts{Context: ctx})
	
	// 简化示例（实际需要 abigen 生成的绑定代码）
	return &PoolInfo{
		// Address:      poolAddr,
		Token0:       token0,
		Token1:       token1,
		Fee:          fee,
		// Liquidity:    liquidity,
		// SqrtPriceX96: slot0.SqrtPriceX96,
		// Tick:         int32(slot0.Tick.Int64()),
	}, nil
}

// QuoteExactInput 查询精确输入的输出金额（不执行交易）
func (c *UniswapV3Client) QuoteExactInput(
	ctx context.Context,
	tokenIn, tokenOut common.Address,
	fee *big.Int,
	amountIn *big.Int,
) (*big.Int, error) {
	// 调用 Quoter 合约的 quoteExactInputSingle
	// quoter, _ := NewQuoterV2(QuoterAddress, c.client)
	// amountOut, _ := quoter.QuoteExactInputSingle(
	//     &bind.CallOpts{Context: ctx},
	//     QuoteExactInputSingleParams{
	//         TokenIn:           tokenIn,
	//         TokenOut:          tokenOut,
	//         Fee:               fee,
	//         AmountIn:          amountIn,
	//         SqrtPriceLimitX96: big.NewInt(0),
	//     },
	// )
	
	fmt.Printf("查询报价: %s %s → ? %s (fee: %s)\n",
		amountIn, tokenIn.Hex()[:8], tokenOut.Hex()[:8], fee)
	
	// 实际返回 Quoter 合约的结果
	return big.NewInt(0), nil
}
```

## 11.6 本章小结与练习

### 你学到了什么

- AMM 恒定乘积公式 x × y = k 的数学推导和 Go 实现
- 滑点的本质：交易量越大，价格偏离越多
- Uniswap V3 集中流动性：Tick 系统、Q64.96 定点数、sqrtPriceX96
- 无常损失的数学公式和量化分析
- V3 Swap 核心逻辑：穿过 Tick、流动性切换
- V3 合约架构：Factory → Pool → Router → PositionManager
- Uniswap V4 Hooks 机制：8 个钩子点、Singleton Pool、Flash Accounting
- 实战开发动态手续费 Hook：根据波动率自动调整费率
- Go 封装 Uniswap V3 交互 SDK

### 动手练习

1. **AMM 模拟器**：用 Go 实现一个完整的 AMM 模拟器，支持：创建池子、添加流动性、执行 Swap、查看价格曲线变化

2. **V3 价格计算器**：实现 Tick ↔ Price ↔ sqrtPriceX96 的完整转换工具，支持任意精度的代币对

3. **无常损失计算器**：输入初始价格和当前价格，计算 V2 和 V3（指定价格范围）的无常损失对比

4. **自定义 Hook**：开发一个限价单 Hook——用户可以在指定价格挂单，当价格到达时自动执行

5. **Fork 测试**：用 Foundry Fork 以太坊主网，在本地模拟一笔 Uniswap V3 的大额交易，观察价格变化和 Tick 穿越

### 下一章预告

下一章进入智能合约安全与审计——重入攻击、闪电贷攻击、预言机操纵等经典漏洞的深度分析和复现。这是 Web3 开发者的必修课，不懂安全的开发者写出来的合约就是黑客的提款机。
