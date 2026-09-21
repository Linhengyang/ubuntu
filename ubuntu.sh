# 查看ubuntu内核
uname -r

# apt是 debian/ubuntu 最重要的 包管理器

# 查看当前 apt记录的 软件包源
cat /etc/apt/sources.list.d/ubuntu.sources

# 原生 apt源: http://archive.ubuntu.com/ubuntu/
# 镜像 apt源: http://cn.archive.ubuntu.com/ubuntu/
# 镜像实质会指向: http://mirros.tuna.tsinghua.edu.cn/ubuntu/

# 如果网络受限，要么将 apt源改成镜像源，要么安装 clash verge 以代理上网，并给 apt命令注入环境变量，详见 clash-verge.sh
# 修改 apt源的方法是：
sudo nano /etc/apt/sources.list.d/ubuntu.sources
# CTRL + O 写入，CTRL + X 退出



# 安装 clash verge 以代理上网，详见 clashverge.sh


# apt更新包
sudo apt update # 查找软件源，是否有新版本
sudo apt upgrade # 执行更新安装查到的新版本。sudo apt full-upgrade会执行删除旧组件/安装全新依赖


# 安装 curl 工具
sudo apt install curl

# 测试终端命令是否走代理: command -> 127.0.0.1:7897 -> clash -> proxy_node_server -> target_server
curl -I https://github.com

# 查看 curl
which curl
apt policy curl # 会显示 apt 当前安装的 包版本, 以及 apt源查找到的最新版本


# 此时 /home/<user> 下面都是中文名的目录, 下载、公共、图片、文档、桌面等等 ---> 改成英文
# 查看 用户目录 配置
cat ~/.config/user-dirs.dirs
# 预期输出:
# XDG_DESKTOP_DIR="$HOME/桌面"
# XDG_DOWNLOAD_DIR="$HOME/下载"
# XDG_TEMPLATES_DIR="$HOME/模板"
# XDG_PUBLICSHARE_DIR="$HOME/公共"
# XDG_DOCUMENTS_DIR="$HOME/文档"
# XDG_MUSIC_DIR="$HOME/音乐"
# XDG_PICTURES_DIR="$HOME/图片"
# XDG_VIDEOS_DIR="$HOME/视频"

# 设定语言新建 user-dirs
LANG=C xdg-user-dirs-update --force

# 确认中文目录都是空的
ls -lah ~
# 在 linux中m, 一个空目录本身就会占据 4.0K

# 删除这些空中文目录
rm -rf ~/文件1 ~/文件2
# 或
rmdr ~/文件1 ~/文件2 # 更安全, 只有空目录才会被删除



# 安装 chrome 作为浏览器
cd download_path
sudo apt install ./google-chrome-stable_current_amd64.deb
# 查看可执行文件位置
which google-chrome # 预期在 /usr/bin/google-chrome



# 清除 snap，详见 nosnap.sh


# 内核清理: autoremove旧版linux内核库包 详见 clean.sh


# 安装 基础开发工具
sudo apt install git build-essential cmake ninja-build pkg-config


# 安装 docker 详见 docker.sh


# 安装 nvidia driver。