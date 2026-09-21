


# nvidia理论上应该在 ubuntu系统初始安装时，通过勾选 “安装第三方软件和驱动” 已经得到安装了
nvidia-smi

# 查看驱动版本号
cat /proc/driver/nvidia/version


# 查看 nvidia驱动 的包名，以及位置
dpkg -l | grep -E 'nvidia|libnvidia' | grep '^ii'
# 预期输出：
    # ii  nvidia-driver-595-open
    # ii  nvidia-utils-595
    # ii  nvidia-kernel-common-595
    # ...

# 这些都是驱动包。可以查看每个包都安装了哪些文件
dpkg -L nvidia-driver-595-open


# nvidia驱动不是安装在一个单独的目录里的，它会分散到标准 linux目录：
    # /usr/lib/x86_64-linux-gnu/                    --> nvidia用户态库
    # /usr/lib/x86_64-linux-gnu/nvidia/             
    # /usr/bin/                                     --> nvidia-smi等工具
    # /lib/modules/$(uname -r)/                     --> nvidia内核模块
# --> 不要手工管理 nvidia驱动，让 apt管理


# 查看 驱动包的源, 并且查看是否有可更新版本
apt-cache policy nvidia-driver-595-open


# 更新 nvidia驱动的方法
sudo apt update
sudo apt upgrade



# 更新驱动后，如果 nvidia内核模块发送变化，执行
sudo reboot


# 检查新驱动是否已经加载
nvidia-smi