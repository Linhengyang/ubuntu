# nvidia驱动理论上应该在 ubuntu系统初始安装时，通过勾选 “安装第三方软件和驱动” 已经得到安装了
nvidia-smi

# 如果未在ubuntu系统装机时安装 nvidia驱动，那么后装命令如下：
# 1. 更新软件源，获取最新驱动列表
sudo apt update

# 2. 自动识别显卡并安装推荐的最新驱动
sudo ubuntu-drivers autoinstall

# 3. 重启让驱动生效
sudo reboot


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


# 更新 nvidia驱动（版本内更新，即小版本更细：同名包 nvidia-driver 535.104 -> 535.129）的方法
sudo apt update
sudo apt upgrade


# 重装 nvidia驱动（大版本更新，不同名：nvidia-driver 595 -> nvidia-driver 610）的方法
# 1. 确认新的大版本(以610为例子)驱动已经在 ubuntu apt源的 candidate中
apt-cache policy nvidia-driver-610-open

# 2. 模拟安装
sudo apt -s install nvidia-driver-610-open
# 重点看：安装哪些610包，删除哪些595包，是否删除桌面相关组件，是否懂nvidia-prime，是否动其他重要包

# 3. 确认没问题，正式执行安装
sudo apt install nvidia-driver-610-open
# --> 让 metapackage 管理整套依赖: 
#   libnvidia-*-610 / nvidia-utils-610 / nvidia-kernel-common-610 / nviia-kernel-source-610-open / nvidia-dkms-610-open / linux-modules-nvidia-610-open ...

# 更新驱动后，reboot
sudo reboot

# 检查新驱动是否已经加载
nvidia-smi
cat /proc/driver/nvidia/version

# 4. 旧的595不需要手动删除，只需检查
dpkg -l | grep -E '^ii.*nvidia' # 检查所有ii状态的nvidia包版本号
dpkg -l | grep -E '^rc.*nvidia' # 检查所有只留下残留配置的nvidia包版本号

# 5. 清理不需要的依赖
sudo apt autoremove --purge -y

# 注意事项：
#   不要去掉open，保持open。-open是NVIDIA oepn kernel module路线，与普通版不一样。不要同时大版本升级+driver类型切换
#   cuda toolkit不会自动升级。
#   尽量只在 ubuntu官方推荐版本之间升级
# 用 ubuntu-drivers 命令查看ubuntu给出的driver推荐、和可安装driver版本
ubuntu-drivers devices
# 预期输出：会看到 recommended 版本

ubuntu-driver list
# 所有可用 driver版本

sudo ubuntu-drivers autoinstall
# 可能也是一种大版本升级的方式