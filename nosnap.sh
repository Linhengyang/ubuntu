# ubuntu 作为 debian系, 直接沿用 apt(apt-get) 包管理器即可, 充分管理 .deb软件包

# ubuntu 自带了 snap应用生态, snap应用 和 apt包 完全独立，不可互相接管或操作。

# 作为一个开发机，我们不需要第二个应用/包管理器。彻底删除 snap

# 首先查看 snap已经安装的 snap应用
snap list
# 预期输出:
    # bare                                  --> 基础运行环境, 随其他Snap使用
    # core24                                --> Snap基础运行环境, 随其他Snap使用
    # desktop-security-center               --> Ubuntu桌面安全中心，可随 Snap一起移除
    # firefox                               --> 用户级 Snap应用
    # firmware-updater                      --> 固件更新工具, 以后可能有用
    # gnome-46-2404                         --> GNOME运行环境，Snap应用依赖
    # gtk-common-themes                     --> GTK主题, Snap应用依赖
    # hwctl                                 --> 硬件控制相关, Ubuntu新组件
    # mesa-2404                             --> Mesa图形运行库, Snap应用依赖
    # prompting-client                      --> Ubuntu的认证/提示组件, 系统组件
    # snap-store                            --> Snap应用商店, 用户级 Snap应用
    # snapd                                 --> Snap本体
    # snapd-desktop-integration             --> Snap桌面集成, 随snapd清理

# 其次查看 snap自身软件包 snapd 的安装状态(它是由 apt安装的)
apt policy snapd
# 预期输出:
# snapd:
#   installed: __version__
#   candidate: __version__


# 首先要删除 snap两个用户级应用
# 1. 卸载 firefox（用chrome了）
sudo snap remove firefox
snap list # 检查是否删除成功

# 2. 删除 snap-store
sudo snap remove snap-store
snap list

# 剩下的都是运行 snap 的基础库。在snap生态里，它们都依赖snapd引擎
# 只要purge snapd, snapd会触发 postrm脚本主动清理它所管理的所有 snap包和基础库(即bare/core24/mesa等)，并卸载相关的loop设备

# 1. 先检查 snap 是否作为手动安装的软件包
apt-mark showmanual | grep -E '^snapd$|snap' # 预期输出空
# 检查已经apt安装的包里，哪些真正依赖 snapd. 如果去掉 --installe 参数, 则会输出可以可能依赖的软件包
apt-cache rdepends --installed snapd
# 预期输出:
    # snapd
    # Reverse Depends:
    #   ubuntu-desktop-minimal
    #   firefox
    #   libsnapd-glib-2-1
    #   apparmor
    #   command-not-found
# 该输出说明真正依赖 snapd 的只有 snapd。出现在 reverse depends列表里的包，说明它们 TODO

# 2. 模拟卸载 snapd
sudo apt -s purge snapd # -s 是simulate，模拟卸载
# 预期输出:
    # 将要卸载:
    #   firefox snapd
# --> 这里将要卸载的只有 snapd 和 firefox(firefox已经被卸载了，这里只是apt识别出的一个引导包, 负责把apt firefox引导到snap，这种可恶的混乱行为坚定了我们卸载snap的决心)
# 可能输出
    # 不再需要
    #   linux-<components>-<old_version>
# --> 这里是提示内核清理。详见 ubuntu.sh

# 3. 正式执行卸载 snapd
sudo apt purge snapd firefox
# 预期输出:
    # ...
    # Removing snap mesa-2404
    # ...
    # Removing snap prompting-client
    # ...
    # Removing snap snapd
    # Removing snap snapd-desktop-integration
    # ...
    # Final directory cleanup
    # Removing snapd cache
    # Removing snapd state
# --> snap应用是以一个个 SquashFS镜像文件的方式 mount到系统里的，又名loop设备(/dev/loop...), 卸载过程中挂载点消失后，会出现在侧边栏 xx MB卷

# 4. 检测snap是否卸载完全
snap list
# 预期输出: command not found

# 列出 loop设备
ls -l /dev/loop*
# 预期输出: /dev/loop0  ...  /dev/loop13 等, 它们只是 linux的loop设备接口，可以复用，无需关注

# 检查 loop设备挂载点
mount | grep loop
# 预期输出为空。如果还有输出，说明有残留，重启电脑通常会自动清除

# 5. 删除 snap残留库包文件
# 检查相关系统目录里的 snap残留
ls -ld /snap /var/snap /var/lib/snapd /var/cache/snapd 2>/dev/null
# 预期输出为空。或者去掉 2>/dev/null 输出 ls cannot access. no such fiel or directory

# 检查 snap相关 apt包
dpkg -l | grep -E 'snapd|snap-confine|snapd-desktop'
# 预期输出:
    # ii    gir1.2-snapd-2:amd64       1.72-0ubuntu3 amd64     Typelib file for libsnapd-glib1
    # ii    libsnapd-glib-2-1:amd64    1.72-0ubuntu3 amd64     GLib snapd library

# --> 这两个 apt库只是一些程序与 snap API 通信用的库。如果 pruge它们不会引发副作用，那么也可以删除它们

# 模拟删除 gir1.2-snapd 和 libsnapd-glib
sudo apt -s purge gir1.2-snapd-2 libsnapd-glib-2-1
# 如果输出的 following packages will be REMOVED 列表里只有 gir1.2-snapd-2 和 libsnapd-glib-2-1，那么可以正式执行
# sudo apt purge gir1.2-snapd-2 libsnapd-glib-2-1，并在随后再次检查 dpkg -l | grep -i snap。当输出无snap相关，说明彻底将snap清干净了

# 事与愿违, 输出的 following packages will be REMOVED 列表非常长，涵盖了非常多ubuntu核心组件
# 说明 ubuntu并不是将这两个 apt库仅仅当成与 snap API通信库, 更基于它们写了一大堆组件
# --> 放弃删除这两个 apt库

# 6. 删除 snap在用户目录 ~/ 留下的数据目录
ls -la ~/snap # 展示 ~/snap 内部的目录，包括隐藏

du -sh ~/snap # 展示 ~/snap 的总大小

find ~/snap -maxdepth 2 -type f -printf '%p\n' # 寻找 ~/snap 内部目录二级深度的非空文件

du -ah ~/snap/prompting-client | sort -h | tail -20 # 排序 ~/snap 内部 prompting-client 目录内部的文件

du -ah ~/snap/snapd-desktop-integration | sort -h | tail -20 # 排序 ~/snap 内部 snapd-desktop-integration 目录内部的文件

rm -rf ~/snap # 总共才几百KB，都是写空配置文件

# 6. 最后确认
dpkg -l | grep -i snap
# 预期输出:
#   gir1.2-snapd-2              --> snapd的 Glib接口库。保留吧，ubuntu很多核心依赖它，没办法零snap字样
#   libsnapd-glib-2-1           --> snapd的 Glib库。保留吧，ubuntu很多核心依赖它，没办法零snap字样
#   libsnappy1v5                --> 与 snap 无关。snappy压缩算法库
#   xdg-desktop-portal          --> 与 snap 关系不大。桌面集成组件, 支持Flatpak/Snap，仅在描述中提到snap而已


# snap清除完毕。按理应该是 sudo apt autoremove --purge -y 来清除所有辅助性的 .deb包。在那之前，可以执行 内核清理 详见 ubuntu.sh

# 7. 彻底封印 snap
# ubuntu有些组件会在 apt中配置对 snapd的依赖, 从而在 apt install时 把 snapd重新装回来
# 再次强调，这种可恶的无赖行为坚定了我们彻底清除 snap 的决心

# 创建屏蔽规则
cat <<EOF | sudo tee /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

# 在这之后再尝试 sudo apt install snapd, 会输出: Package snapd is not available... (包 snapd 不可用)