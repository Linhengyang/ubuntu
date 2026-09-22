# repo网址：https://developer.download.nvidia.cn/compute/cuda/repos/wsl-ubuntu/x86_64/
# 安装 cuda-toolkit，基本上归纳起来就是如下：

# 1. 要下载 keyring.gpg 文件到 /usr/share/keyrings ---> /usr/share/keyrings/cuda-<...>-keyring.gpg
#   如果从 网址下载 gpg文件，那么用 wget 再mv到目标文件夹；
#   如果是local repo安装（dpkg -i cuda.*.deb文件），那么dpkg命令会自动从 /var/cuda-repo-<dist>-X-Y-local 目录内部拷贝 keyring.gpg文件到目标文件夹。

# 2. 要在 /etc/apt/sources.list.d 写入 keyring.gpg文件地址 和 download_url 组成的钥匙-下载源址 list文件 ---> /etc/apt/sources.list.d/cuda-<dist>-X-Y-local.list
# .list 文件里写的是：
#   deb [signed-by=/usr/share/keyrings/cuda-<...>-keyring.gpg] <download_url> /
#   如果是从网址下载，那么 download_url 即 repo网址（是包含所有.deb包的url地址）；
#   如果是从local repo安装，那么此 download_url 即为 file::///var/cuda-repo-<dist>-X-Y-local，其内包含了所有dpkg命令从 cuda.*.deb 解压出来的.deb包。

# 3. 要在 /etc/apt/preferences.d 写入pin文件，还重命名成 cuda-repository-pin-600。
#   /var/cuda-repo-local目录内 不含这个pin文件，所以即使是 local repo安装，也得从网络上下载这个pin文件并重命名。

# 4. 确认 kerings.gpg文件、sources.list.d/下的 .list文件、preference.d/下的 pin文件，都在正确位置。
#   执行 sudo apt install cuda-toolkit-X-Y


# 卸载 cuda-toolkit
sudo apt --purge remove <cuda-toolkit-X-Y>
sudo apt purge <cudnnN-cuda-X-Y>
sudo apt autoremove --purge -y



# 可以继续清除 cuda & cudnn 包的 gpg文件、list文件、pin文件，分别在 /usr/share/keyrings、/etc/apt/sources.list.d、/etc/apt/preferences.d
# 可以清除 /usr/share/doc 中的 残留文件
# 如果是 local repo 安装，可以清除 /var 目录下的 /var/cuda-repo-<distribution>-X-Y-local目录，以及 /var 目录下的 /var/cudnn-local-<distribution>目录
# 最后可以清除 dowload file下的 local repo .deb包

# 检查是否清理干净
dpkg -l | grep -i cuda

# 可以反找到未清除的包 所在的地址，并前往地址清除
dpkg -L <package_name>

# 如果是 local repo 安装 .deb,，那么在系统里还有一个缓存文件夹，会在 dpkg -l | grep -i cuda 命令中显示出来。下列命令可以删除掉缓存：
sudo dpkg --purge <cuda-repo-<dist>-X-Y-local>
sudo dpkg --purge <cudnn-local-repo-<dist>-X-Y>

# 最后，不要忘了把 ~/.bashrc 里添加的 环境变量 去掉
sudo nano ~/.bashrc


# --> 彻底删除了 旧版本 cuda-toolkit。可以开始新版本 cuda-toolkit 安装了。