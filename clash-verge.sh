# 从 https://www.clashverge.dev/install.html 下载 Clash.Verge_x.x.x-_xxx.deb 到 download_path
cd download_path
sudo apt install -y ./Clash.Verge_x.x.x-_xxx.deb

# 查看是否安装成功
dpkg -l | grep -i clash
# 成功预期输出: ii clash-verge <__version__> amd64 <...>
# ii表示已经正确安装, 后接的第一个输出 clash-verge 就是查到的具体包名字， 格式是:
# <状态, ii表示成功> <报名> <版本> <架构> <描述>


# 包名非常有用:

# 查看可执行文件位置
which clash-verge
# 可以直接在终端输入 clash-verge ENTER 打开

# 卸载
sudo apt remove clash-verge # 删除程序, 保留配置
sudo apt purge clash-verge # 删除程序+系统级配置

# 清除 订阅、日志等配置文件
rm -rf ~/.local/share/io.github.clash-verge-rev.clash-verge-rev

# 清理不再需要的依赖
sudo apt autoremove

# 再检查是否卸载成功: 若卸载成功, 应该没有输出
dpkg -l | grep -i clash



# 当打开 系统代理 之后, 主要是支持 GNOME系统代理 的GNOME桌面应用程序受用, 比如浏览器.
# terminal/shell窗口里并不马上受用。需要设定环境变量, 让终端里的命令走代理。
# 核心在于设定环境变量：
export http_proxy="http://127.0.0.1:7897"
export https_proxy="http://127.0.0.1:7897"
export no_proxy="localhost,127.0.0.1,*.local,169.254.0.0/16,172.16.0.0/12"
export HTTP_PROXY="http://127.0.0.1:7897"
export HTTPS_PROXY="http://127.0.0.1:7897"
export NO_PROXY="localhost,127.0.0.1,*.local,169.254.0.0/16,172.16.0.0/12"


# 有一些命令比如 curl可以直接从 shell环境变量读取，所以代理会对它们会立刻起作用
# 有些命令比如 apt包管理器，需要额外配置（即将环境变量或代理地址）注入到命令中，所以需要额外编写“带注入环境变量的apt命令”，即：

# 1. apt自动持久生效（不推荐）                              --> 将下列配置写入 /etc/apt/apt.conf.d/01-endor-ubuntu
    # Acquire::http::Proxy "http://127.0.0.1:7897"
    # Acquire::https::Proxy "http://127.0.0.1:7897"

# 2. apt临时注入当前shell生效（推荐）                       --> 将下列函数写入临时脚本 ~/proxy.sh 并source执行。后续使用 aptp 代替 sudo apt
aptp() {
  if [ -n "${HTTP_PROXY:-}" ] && [ -n "${HTTPS_PROXY:-}" ]; then
    sudo apt \
      -o "Acquire::http::Proxy=$HTTP_PROXY" \
      -o "Acquire::https::Proxy=$HTTP_PROXY" \
      "$@"
  else
    sudo apt "$@"
  fi
}

# 3. 关闭代理环境变量
unset HTTP_PROXY HTTPS_PROXY NO_PROXY http_proxy https_proxy no_proxy