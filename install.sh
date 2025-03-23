#!/bin/bash

# 设置颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的信息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 检查必要的命令
check_requirements() {
    local missing=0
    
    if ! command -v curl &> /dev/null; then
        print_error "需要安装 curl"
        missing=1
    fi
    
    if [ $missing -eq 1 ]; then
        print_error "请安装缺失的依赖后重试"
        exit 1
    fi
}

# 检查环境变量
check_path() {
    if [[ ":$PATH:" != *":/usr/local/bin:"* ]]; then
        print_warning "/usr/local/bin 不在环境变量中"
        local shell_config=""
        
        # 检测用户使用的 shell
        if [ -n "$ZSH_VERSION" ]; then
            shell_config="$HOME/.zshrc"
        elif [ -n "$BASH_VERSION" ]; then
            shell_config="$HOME/.bashrc"
        fi
        
        if [ -n "$shell_config" ]; then
            print_info "正在添加 /usr/local/bin 到环境变量..."
            echo 'export PATH="/usr/local/bin:$PATH"' >> "$shell_config"
            print_info "请运行 'source $shell_config' 或重新打开终端以使更改生效"
        else
            print_warning "无法确定您的 shell 类型，请手动将 /usr/local/bin 添加到 PATH 环境变量中"
        fi
    fi
}

# 检查已安装版本
check_installed_version() {
    if command -v ip-cn-asn &> /dev/null; then
        local installed_version=$(ip-cn-asn --version 2>/dev/null | cut -d' ' -f2)
        if [ -n "$installed_version" ]; then
            echo "$installed_version"
        else
            echo "unknown"
        fi
    else
        echo "not_installed"
    fi
}

# 获取系统信息
get_system_info() {
    local os=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch=$(uname -m)
    
    # 直接返回对应的系统标识符
    case $os in
        linux)
            echo "linux-x86_64-unknown-linux-gnu"
            ;;
        darwin)
            if [ "$arch" = "arm64" ] || [ "$arch" = "aarch64" ]; then
                echo "macos-arm-aarch64-apple-darwin"
            else
                echo "macos-intel-x86_64-apple-darwin"
            fi
            ;;
        *)
            print_error "不支持的操作系统: $os"
            exit 1
            ;;
    esac
}

# 获取最新版本
get_latest_version() {
    local api_url="https://api.github.com/repos/nobey/ip-cn-asn/releases/latest"
    local version=$(curl -s $api_url | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    
    if [ -z "$version" ]; then
        print_error "无法获取最新版本信息"
        exit 1
    fi
    
    echo $version
}

# 下载并安装
download_and_install() {
    local version=$1
    local system=$2
    # 移除版本号中的 'v' 前缀
    local clean_version=${version#v}
    local filename="ip-cn-asn-${clean_version}-${system}.tar.gz"
    local download_url="https://github.com/nobey/ip-cn-asn/releases/download/${version}/${filename}"
    
    print_info "正在下载 ${filename}..."
    
    # 创建临时目录
    local temp_dir=$(mktemp -d)
    cd $temp_dir
    
    # 下载文件
    if ! curl -L -o $filename $download_url; then
        print_error "下载失败"
        cd - > /dev/null
        rm -rf $temp_dir
        exit 1
    fi
    
    # 检查下载的文件大小
    local file_size=$(stat -f%z "$filename" 2>/dev/null || stat -c%s "$filename")
    if [ "$file_size" -lt 1000 ]; then
        print_error "下载的文件大小异常（${file_size}字节），可能不是正确的压缩包"
        print_info "尝试的下载地址: $download_url"
        cd - > /dev/null
        rm -rf $temp_dir
        exit 1
    fi
    
    # 解压文件
    print_info "正在解压文件..."
    if ! tar -xzf $filename; then
        print_error "解压失败，请检查文件格式是否正确"
        cd - > /dev/null
        rm -rf $temp_dir
        exit 1
    fi
    
    # 安装到系统路径
    print_info "正在安装到 /usr/local/bin..."
    if [ -f "ip-cn-asn" ]; then
        # 检查目标文件是否存在
        if [ -f "/usr/local/bin/ip-cn-asn" ]; then
            print_warning "目标文件已存在，将被覆盖"
            if ! sudo rm -f "/usr/local/bin/ip-cn-asn"; then
                print_error "无法删除已存在的文件"
                cd - > /dev/null
                rm -rf $temp_dir
                exit 1
            fi
        fi
        
        if ! sudo mv ip-cn-asn /usr/local/bin/; then
            print_error "安装失败"
            cd - > /dev/null
            rm -rf $temp_dir
            exit 1
        fi
        
        sudo chmod +x /usr/local/bin/ip-cn-asn
        print_info "安装成功！"
    else
        print_error "解压后的文件不完整"
        print_info "当前目录内容："
        ls -la
        cd - > /dev/null
        rm -rf $temp_dir
        exit 1
    fi
    
    # 清理临时文件
    cd - > /dev/null
    rm -rf $temp_dir
}

# 主函数
main() {
    print_info "开始安装 ip-cn-asn..."
    
    # 检查依赖
    check_requirements
    
    # 检查环境变量
    check_path
    
    # 获取系统信息
    local system=$(get_system_info)
    print_info "检测到系统: $system"
    
    # 获取最新版本
    local latest_version=$(get_latest_version)
    print_info "最新版本: $latest_version"
    
    # 检查已安装版本
    local installed_version=$(check_installed_version)
    if [ "$installed_version" != "not_installed" ]; then
        print_info "检测到已安装版本: $installed_version"
        if [ "$installed_version" = "$latest_version" ]; then
            print_info "您已安装最新版本，无需更新"
            exit 0
        else
            print_warning "发现新版本，将进行更新"
        fi
    fi
    
    # 下载并安装
    download_and_install $latest_version $system
}

# 执行主函数
main 