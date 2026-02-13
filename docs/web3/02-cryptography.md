# 第 2 章：密码学基础与钱包原理

> 私钥、公钥、地址、签名——这些词你可能听过无数次，但它们之间到底是什么关系？这一章用 Go 代码把整个链路跑通。

## 2.1 非对称加密：公钥密码学

Web3 的安全基石是**非对称加密**。核心概念很简单：

```
私钥（Private Key）→ 公钥（Public Key）→ 地址（Address）
     ↓ 单向推导，不可逆 ↓         ↓ 单向推导，不可逆 ↓
```

- **私钥**：一个 256 位的随机数，只有你知道
- **公钥**：从私钥通过椭圆曲线运算推导出来
- **地址**：公钥经过哈希运算得到的简短标识

类比：
- 私钥 = 你的银行密码（绝对不能泄露）
- 公钥 = 你的银行账号（可以公开）
- 地址 = 你的银行账号的简写版

### 以太坊使用的椭圆曲线：secp256k1

以太坊和比特币都使用 secp256k1 椭圆曲线。这条曲线的方程是：

```
y² = x³ + 7 (mod p)
```

其中 p 是一个非常大的素数。椭圆曲线上的点可以做"加法"运算，而从 `k * G`（k 是私钥，G 是基点）推导出公钥是容易的，但从公钥反推 k 是计算上不可行的。

## 2.2 用 Go 生成以太坊密钥对

```go
package wallet

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"math/big"

	"golang.org/x/crypto/sha3"
)

// KeyPair 密钥对
type KeyPair struct {
	PrivateKey *ecdsa.PrivateKey
	PublicKey  *ecdsa.PublicKey
}

// GenerateKeyPair 生成新的密钥对
func GenerateKeyPair() (*KeyPair, error) {
	// 使用 secp256k1 曲线生成私钥
	// 注意：Go 标准库没有 secp256k1，这里用 P256 演示
	// 生产环境请使用 github.com/ethereum/go-ethereum/crypto
	privateKey, err := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
	if err != nil {
		return nil, fmt.Errorf("生成密钥失败: %w", err)
	}

	return &KeyPair{
		PrivateKey: privateKey,
		PublicKey:  &privateKey.PublicKey,
	}, nil
}

// PrivateKeyHex 返回私钥的十六进制表示
func (kp *KeyPair) PrivateKeyHex() string {
	return hex.EncodeToString(kp.PrivateKey.D.Bytes())
}

// PublicKeyBytes 返回未压缩的公钥字节（04 + X + Y）
func (kp *KeyPair) PublicKeyBytes() []byte {
	pubKey := kp.PublicKey
	// 未压缩公钥 = 04 || X || Y
	x := pubKey.X.Bytes()
	y := pubKey.Y.Bytes()

	// 确保 X 和 Y 都是 32 字节
	pubBytes := make([]byte, 65)
	pubBytes[0] = 0x04
	copy(pubBytes[1+32-len(x):33], x)
	copy(pubBytes[33+32-len(y):65], y)
	return pubBytes
}

// Address 从公钥推导以太坊地址
// 地址 = Keccak256(公钥)[12:32] 的十六进制，加上 0x 前缀
func (kp *KeyPair) Address() string {
	pubBytes := kp.PublicKeyBytes()

	// Keccak-256 哈希（注意：不是标准 SHA3，以太坊用的是 Keccak）
	hash := sha3.NewLegacyKeccak256()
	hash.Write(pubBytes[1:]) // 去掉 04 前缀
	hashBytes := hash.Sum(nil)

	// 取最后 20 字节作为地址
	address := hashBytes[12:]
	return "0x" + hex.EncodeToString(address)
}
```

```go
func main() {
	kp, err := wallet.GenerateKeyPair()
	if err != nil {
		log.Fatal(err)
	}

	fmt.Printf("私钥: %s\n", kp.PrivateKeyHex())
	fmt.Printf("公钥: %x\n", kp.PublicKeyBytes())
	fmt.Printf("地址: %s\n", kp.Address())
}
```

输出示例：
```
私钥: 4c0883a69102937d6231471b5dbb6204fe512961708279f...
公钥: 04b9d1c2e3f4a5b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1...
地址: 0x71C7656EC7ab88b098defB751B7401B5f6d8976F
```

::: danger 安全警告
永远不要在代码中硬编码私钥！永远不要把私钥提交到 Git 仓库！在生产环境中，私钥应该存储在硬件安全模块（HSM）或加密的密钥库中。
:::

## 2.3 数字签名：证明"这笔交易是我发起的"

数字签名的流程：

```
发送方（Alice）:
  1. 构造交易数据: "Alice → Bob: 10 ETH"
  2. 对交易数据做哈希: hash = Keccak256(交易数据)
  3. 用私钥对哈希签名: signature = Sign(hash, privateKey)
  4. 广播: {交易数据, signature}

验证方（任何节点）:
  1. 收到 {交易数据, signature}
  2. 对交易数据做哈希: hash = Keccak256(交易数据)
  3. 从签名中恢复公钥: publicKey = Recover(hash, signature)
  4. 从公钥推导地址: address = Address(publicKey)
  5. 验证 address == Alice 的地址 → 签名有效！
```

### Go 实现交易签名与验证

```go
package wallet

import (
	"crypto/ecdsa"
	"crypto/elliptic"
	"crypto/rand"
	"math/big"

	"golang.org/x/crypto/sha3"
)

// Signature ECDSA 签名
type Signature struct {
	R *big.Int
	S *big.Int
}

// SignMessage 用私钥对消息签名
func SignMessage(privateKey *ecdsa.PrivateKey, message []byte) (*Signature, error) {
	// 1. 对消息做 Keccak256 哈希
	hash := keccak256(message)

	// 2. 用私钥签名
	r, s, err := ecdsa.Sign(rand.Reader, privateKey, hash)
	if err != nil {
		return nil, err
	}

	return &Signature{R: r, S: s}, nil
}

// VerifySignature 验证签名
func VerifySignature(publicKey *ecdsa.PublicKey, message []byte, sig *Signature) bool {
	hash := keccak256(message)
	return ecdsa.Verify(publicKey, hash, sig.R, sig.S)
}

// keccak256 计算 Keccak-256 哈希
func keccak256(data []byte) []byte {
	h := sha3.NewLegacyKeccak256()
	h.Write(data)
	return h.Sum(nil)
}
```

```go
func main() {
	// 生成密钥对
	kp, _ := wallet.GenerateKeyPair()

	// 构造交易消息
	message := []byte("Alice sends 10 ETH to Bob")

	// Alice 用私钥签名
	sig, _ := wallet.SignMessage(kp.PrivateKey, message)
	fmt.Printf("签名 R: %x\n", sig.R)
	fmt.Printf("签名 S: %x\n", sig.S)

	// 任何人都可以用 Alice 的公钥验证
	valid := wallet.VerifySignature(kp.PublicKey, message, sig)
	fmt.Printf("签名验证: %v\n", valid) // true

	// 如果消息被篡改，验证失败
	tampered := []byte("Alice sends 1000 ETH to Bob")
	valid2 := wallet.VerifySignature(kp.PublicKey, tampered, sig)
	fmt.Printf("篡改后验证: %v\n", valid2) // false
}
```

::: tip 以太坊的签名特殊之处
以太坊的签名除了 R 和 S，还有一个 V 值（recovery id），用于从签名中恢复公钥。这就是为什么以太坊交易不需要附带发送方的公钥——可以直接从签名中恢复出来。
:::

## 2.4 HD 钱包：一个助记词管理无限地址

HD（Hierarchical Deterministic）钱包是现代加密钱包的标准。核心思想：**从一个种子（Seed）可以派生出无限个密钥对。**

### BIP 标准体系

```
BIP-39: 助记词 → 种子
  "abandon ability able about above absent ..." (12/24个英文单词)
  ↓
  种子 (512 bit)

BIP-32: 种子 → 主密钥 → 子密钥树
  种子 → Master Key
         ├── Child Key 0
         │   ├── Grandchild Key 0
         │   └── Grandchild Key 1
         ├── Child Key 1
         └── ...

BIP-44: 定义了标准的派生路径
  m / purpose' / coin_type' / account' / change / address_index
  m / 44'      / 60'        / 0'       / 0      / 0
  │              │             │          │        └── 第几个地址
  │              │             │          └── 0=外部地址, 1=找零地址
  │              │             └── 第几个账户
  │              └── 币种 (60=ETH, 0=BTC, 501=SOL)
  └── 固定值 44
```

### 助记词生成流程

```
1. 生成 128-256 位随机熵
2. 计算校验和（SHA256 的前几位）
3. 将 熵+校验和 按 11 位分组
4. 每组对应 BIP-39 词表中的一个单词
5. 得到 12-24 个助记词
```

### Go 实现助记词生成

```go
package hdwallet

import (
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"strings"
)

// BIP39 英文词表（这里只展示前 20 个，完整词表有 2048 个）
var wordList = []string{
	"abandon", "ability", "able", "about", "above",
	"absent", "absorb", "abstract", "absurd", "abuse",
	"access", "accident", "account", "accuse", "achieve",
	"acid", "acoustic", "acquire", "across", "act",
	// ... 完整词表请参考 BIP-39 规范
	// https://github.com/bitcoin/bips/blob/master/bip-0039/english.txt
}

// GenerateEntropy 生成随机熵
// 128 bits → 12 个助记词
// 256 bits → 24 个助记词
func GenerateEntropy(bits int) ([]byte, error) {
	if bits != 128 && bits != 160 && bits != 192 && bits != 224 && bits != 256 {
		return nil, fmt.Errorf("熵的位数必须是 128/160/192/224/256")
	}
	entropy := make([]byte, bits/8)
	_, err := rand.Read(entropy)
	return entropy, err
}

// EntropyToMnemonic 将熵转换为助记词
func EntropyToMnemonic(entropy []byte) (string, error) {
	// 计算校验和
	hash := sha256.Sum256(entropy)
	checksumBits := len(entropy) / 4 // 校验和位数 = 熵位数 / 32

	// 将熵和校验和拼接成比特串
	bits := bytesToBits(entropy)
	checksumBitStr := bytesToBits(hash[:])[:checksumBits]
	bits = append(bits, checksumBitStr...)

	// 每 11 位对应一个单词
	var words []string
	for i := 0; i < len(bits); i += 11 {
		index := bitsToInt(bits[i : i+11])
		if index >= len(wordList) {
			// 实际使用时词表有 2048 个词，这里简化处理
			index = index % len(wordList)
		}
		words = append(words, wordList[index])
	}

	return strings.Join(words, " "), nil
}

// bytesToBits 将字节数组转换为比特数组
func bytesToBits(data []byte) []byte {
	bits := make([]byte, 0, len(data)*8)
	for _, b := range data {
		for i := 7; i >= 0; i-- {
			bits = append(bits, (b>>uint(i))&1)
		}
	}
	return bits
}

// bitsToInt 将比特数组转换为整数
func bitsToInt(bits []byte) int {
	result := 0
	for _, b := range bits {
		result = result*2 + int(b)
	}
	return result
}
```

### 从助记词到以太坊地址的完整流程

```go
package main

import (
	"fmt"
	"log"

	// 生产环境推荐使用这些库：
	// "github.com/tyler-smith/go-bip39"
	// "github.com/tyler-smith/go-bip32"
	// "github.com/ethereum/go-ethereum/crypto"
)

func main() {
	// 实际项目中使用 go-bip39 库：
	//
	// 1. 生成助记词
	// entropy, _ := bip39.NewEntropy(128)
	// mnemonic, _ := bip39.NewMnemonic(entropy)
	// fmt.Println("助记词:", mnemonic)
	// // 输出: "abandon ability able about above absent absorb abstract absurd abuse access accident"
	//
	// 2. 助记词 → 种子（使用 PBKDF2 + 可选密码）
	// seed := bip39.NewSeed(mnemonic, "可选的密码")
	//
	// 3. 种子 → 主密钥（BIP-32）
	// masterKey, _ := bip32.NewMasterKey(seed)
	//
	// 4. 按 BIP-44 路径派生子密钥
	// // m/44'/60'/0'/0/0 → 第一个以太坊地址
	// purpose, _ := masterKey.NewChildKey(bip32.FirstHardenedChild + 44)
	// coinType, _ := purpose.NewChildKey(bip32.FirstHardenedChild + 60)
	// account, _ := coinType.NewChildKey(bip32.FirstHardenedChild + 0)
	// change, _ := account.NewChildKey(0)
	// addressKey, _ := change.NewChildKey(0)
	//
	// 5. 子密钥 → 以太坊地址
	// privateKey, _ := crypto.ToECDSA(addressKey.Key)
	// address := crypto.PubkeyToAddress(privateKey.PublicKey)
	// fmt.Println("地址:", address.Hex())

	fmt.Println("完整的 HD 钱包实现请参考上述注释中的代码")
	fmt.Println("需要安装依赖:")
	fmt.Println("  go get github.com/tyler-smith/go-bip39")
	fmt.Println("  go get github.com/tyler-smith/go-bip32")
	fmt.Println("  go get github.com/ethereum/go-ethereum")
}
```

::: warning 助记词安全
助记词等同于你所有资产的控制权。任何获得你助记词的人都可以恢复你的所有钱包地址和资产。
- 永远不要截图保存助记词
- 永远不要在网络上传输助记词
- 用纸笔抄写，存放在安全的物理位置
- 考虑使用金属助记词板（防火防水）
:::

## 2.5 以太坊地址格式：EIP-55 校验和

以太坊地址是 40 个十六进制字符，但直接使用容易出错。EIP-55 通过大小写混合来实现校验和：

```
原始地址:    0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed
EIP-55地址:  0x5aAeb6053F3E94C9b9A09f33669435E7Ef1BeAed
                ↑ 大写和小写的混合就是校验和
```

### Go 实现 EIP-55

```go
package wallet

import (
	"encoding/hex"
	"strings"

	"golang.org/x/crypto/sha3"
)

// ToChecksumAddress 将地址转换为 EIP-55 校验和格式
func ToChecksumAddress(address string) string {
	// 去掉 0x 前缀，转小写
	addr := strings.ToLower(strings.TrimPrefix(address, "0x"))

	// 对小写地址做 Keccak256
	h := sha3.NewLegacyKeccak256()
	h.Write([]byte(addr))
	hash := hex.EncodeToString(h.Sum(nil))

	// 根据哈希值决定每个字符的大小写
	result := make([]byte, len(addr))
	for i, c := range addr {
		if c >= 'a' && c <= 'f' {
			// 如果哈希对应位置的值 >= 8，则大写
			if hash[i] >= '8' {
				result[i] = byte(c - 32) // 转大写
			} else {
				result[i] = byte(c)
			}
		} else {
			result[i] = byte(c)
		}
	}

	return "0x" + string(result)
}

// IsValidChecksumAddress 验证 EIP-55 校验和地址
func IsValidChecksumAddress(address string) bool {
	if !strings.HasPrefix(address, "0x") || len(address) != 42 {
		return false
	}
	return address == ToChecksumAddress(address)
}
```

```go
func main() {
	addr := "0x5aaeb6053f3e94c9b9a09f33669435e7ef1beaed"
	checksumAddr := wallet.ToChecksumAddress(addr)
	fmt.Printf("原始地址:    %s\n", addr)
	fmt.Printf("校验和地址:  %s\n", checksumAddr)
	fmt.Printf("校验结果:    %v\n", wallet.IsValidChecksumAddress(checksumAddr))
}
```

## 2.6 零知识证明入门

零知识证明（ZKP）是 Web3 中越来越重要的密码学技术。核心思想：**证明者可以向验证者证明某个陈述是真的，而不泄露任何额外信息。**

### 生活中的类比

想象一个色盲测试：
- 你有两个球，一红一绿
- 你的朋友是色盲，他看不出区别
- 你要证明这两个球颜色不同，但不告诉他哪个是红哪个是绿

方法：让朋友把球藏在背后，随机交换或不交换，然后拿出来问你"交换了吗？"。如果你每次都能正确回答，重复 100 次后，朋友就相信这两个球确实不同——但他仍然不知道哪个是红色。

### ZKP 在 Web3 中的应用

| 应用 | 说明 |
|------|------|
| zkRollup | 将大量交易压缩成一个证明，提升 L2 吞吐量（zkSync, StarkNet） |
| 隐私交易 | 证明交易有效但不暴露金额和地址（Tornado Cash, Zcash） |
| 身份验证 | 证明你满足某个条件（如年龄>18）但不暴露具体信息 |
| 跨链桥 | 证明某条链上发生了某个事件 |

::: info 深入学习
零知识证明是一个深度话题，本课程在后续的 L2 和跨链章节会进一步展开。如果你想提前深入，推荐阅读 [ZK Book](https://www.rareskills.io/zk-book)。
:::

## 2.7 本章小结与练习

### 你学到了什么

- 非对称加密的原理：私钥 → 公钥 → 地址的单向推导
- ECDSA 数字签名的签名与验证流程
- HD 钱包的 BIP-39/32/44 标准体系
- EIP-55 校验和地址的实现
- 零知识证明的基本概念

### 动手练习

1. **完整 HD 钱包**：使用 `go-bip39` 和 `go-bip32` 库，实现一个命令行 HD 钱包工具，支持：
   - 生成 12/24 位助记词
   - 从助记词派生多个以太坊地址
   - 从助记词派生 Solana 地址（BIP-44 路径 m/44'/501'/0'/0'）

2. **交易签名器**：实现一个 Go 程序，能够：
   - 构造 EIP-1559 交易
   - 用私钥签名
   - 输出签名后的 RLP 编码（可以直接广播到以太坊网络）

3. **地址簿工具**：实现一个命令行工具，支持：
   - 输入任意格式的以太坊地址，输出 EIP-55 校验和格式
   - 批量验证地址格式是否正确
   - 检测地址是 EOA 还是合约地址（通过查询链上 code）

### 下一章预告

下一章我们进入以太坊的世界——EVM 执行模型、账户体系、交易生命周期，以及多链生态的全景图。
