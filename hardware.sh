# 查看硬盘
lsblk

# 查看内存
free -h

# 查看cpu
lscpu

# 查看gpu
lspci -nnk | grep -A 3 -E 'VGA|3D|Display'


