# 卸载 conda

# 找到 conda安装路径
conda info --base

# 假设安装路径为 ~/miniconda3
rm -rf ~/miniconda3


# 除去 环境设置
nano ~/.bashrc # 除去 >>> conda initialize >>> 和 <<< conda initialize <<< 之间的代码块
source ~/.bashrc

# 除去配置文件
rm -rf ~/.conda
rm -rf ~/.condarc


# 安装 uv: 全部默认安装
curl -LsSf https://astral.sh/uv/install.sh | sh
# 预期输出：
    # downloading uv 0.12.18 x86_64-unknown-linux-gnu
    # installing to /home/lhy/.local/bin
    #   uv
    #   uvx
    # everything's installed!

    # To add $HOME/.local/bin to your PATH, either restart your shell or run:

    #     source $HOME/.local/bin/env (sh, bash, zsh)
    #     source $HOME/.local/bin/env.fish (fish)


# 把 ~/.local/bin 加入环境变量, 让 安装在该目录下的 uv 可以得到执行
source ~/.local/bin/env

# 确认 uv 安装成功
uv --version

which uv # uv程序本身安装目录

uv python dir # uv 管理的python所在
uv tool dir # uv tool install 安装工具所在
uv cache dir # uv 下载/构建的缓存所在