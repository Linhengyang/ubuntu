# 1. 确认无可升级
apt list --upgradable


# 2. 模拟 autoremove
sudo apt autoremove --dry-run
# 预期输出:
# 将要卸载:
#   linux-headers-<old_version>
#   linux-image-unsigned-<old_version>-generic
#   linux-main-modules-zfs-<old_version>-generic
#   linux-modules-<old_version>-generic
#   linux-tools-<old_version>
#   linux-tools-<old_version>-generic

# 3. 与当前内核版本对比，确认都是旧版本
uname -r # 预期输出: 新版本
dpkg -l | grep -E 'linux-(image|modules|headers)' | grep '<linux大版本号, 比如7.0.0>'
# 预期输出:
    #   ii  linux-headers-<new_version>
    #   ii  linux-image-unsigned-<new_version>-generic
    #   ii  linux-main-modules-zfs-<new_version>-generic
    #   ii  linux-modules-<new_version>-generic
    #   ii  linux-tools-<new_version>
    #   ii  linux-tools-<new_version>-generic
    #   ii  linux-modules-nvidia-<driver_version>-open-<new_version>-generic
    #   ii  ...
    #   rc  linux-<component>-<old_version>-generic
    #   rc  linux-<component>-<old_version>-generic
# --> 确认当前内核正在使用 <new_version>，确认对应的核心组件都在，确认 nvidia驱动安装在当前内核上
# --> 确认 <old_version> 的组件是 rc 状态（本体已经删除，只剩下配置文件）


# 4. 正式执行 autoremove
sudo apt autoremove --purge -y


# 可选：删除 rc状态下的 残留包（仅剩配置文件）
sudo dpkg --purge $(dpkg -l | awk '/^rc/ {print $2}')


# 5. 确认无需升级
sudo apt pdate
apt list --upgradable # 预期输出为空

