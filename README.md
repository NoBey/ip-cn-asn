# IP-CN-ASN

一个用于检测和标记中国运营商 ASN 信息的命令行工具。当输入包含 IP 地址时，会自动识别并用不同颜色标记出其所属的运营商和线路质量。

## 功能特点

- 自动识别输入中的 IP 地址
- 识别中国三大运营商（电信、联通、移动）的 ASN 信息
- 区分优质线路和普通线路
- 使用彩色输出增强可读性：
  - 电信 CN2 (AS4809): 紫色
  - 联通 9929 (AS9929): 黄色
  - 移动 CMIN2 (AS58807): 蓝色
  - 其他线路: 白色

## 技术实现

- 使用 Rust 语言编写，保证高性能和可靠性
- 使用 regex 库进行 IP 地址匹配
- 使用 termcolor 库实现跨平台彩色终端输出
- 使用 lazy_static 优化静态数据初始化

## 安装

### 从 GitHub Releases 下载预编译二进制文件

访问 [GitHub Releases 页面](https://github.com/yourusername/ip-cn-asn/releases) 下载适合您系统的预编译二进制文件。

支持的平台:
- Linux x86_64
- macOS x86_64 (Intel)
- macOS aarch64 (Apple Silicon M1/M2)

下载后解压并将可执行文件移动到系统路径：

```bash
tar -xzf ip-cn-asn-x86_64-unknown-linux-gnu.tar.gz
sudo mv ip-cn-asn /usr/local/bin/
```

### 从源码编译

确保已安装 Rust 开发环境：

```bash
# 安装 Rust (如果尚未安装)
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

克隆仓库并编译：

```bash
git clone https://github.com/yourusername/ip-cn-asn.git
cd ip-cn-asn
cargo build --release
```

编译好的可执行文件会在 `./target/release/ip-cn-asn` 目录下。

### 安装到系统路径

```bash
cargo install --path .
```

### 使用 Docker

```bash
# 构建 Docker 镜像
docker build -t ip-cn-asn .

# 使用 Docker 运行
cat your_input_file.txt | docker run -i ip-cn-asn
```

## 使用方法

该工具可以作为管道处理器使用，也可以直接接受标准输入：

```bash
# 作为管道处理器使用
ping example.com | ip-cn-asn

# 或者配合 traceroute 使用
traceroute example.com | ip-cn-asn

# 直接处理包含 IP 的文本
echo "Server IP: 59.43.180.45" | ip-cn-asn
```

## 示例输出

```
PING example.com (223.119.50.121): 56 data bytes [移动CMI]
64 bytes from 223.119.50.121 [移动CMI]: icmp_seq=0 ttl=52 time=12.754 ms
64 bytes from 223.119.50.121 [移动CMI]: icmp_seq=1 ttl=52 time=13.459 ms
```

```
traceroute to example.com (59.43.186.185) [电信CN2], 64 hops max, 52 byte packets
 1  router.local (192.168.1.1)  2.206 ms  1.721 ms  1.487 ms
 2  59.43.246.1 [电信CN2]  8.152 ms  7.517 ms  7.057 ms
```

## 开发与构建

### 打包发布

可以使用项目根目录的 `build.sh` 脚本进行多平台编译和打包：

```bash
# 赋予脚本执行权限
chmod +x build.sh

# 执行打包脚本
./build.sh
```

打包后的文件会存放在 `dist/` 目录下。

### 发布到 GitHub Releases

项目使用 GitHub Actions 自动化发布流程。当推送新的版本标签时，会自动触发构建并发布到 GitHub Releases。

```bash
# 创建新版本标签
git tag v0.1.0

# 推送标签到 GitHub，触发自动构建和发布
git push origin v0.1.0
```

## 许可证

MIT License

## 贡献与反馈

欢迎提交 Issues 和 Pull Requests。 