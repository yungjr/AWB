#!/bin/bash

# 检查参数是否正确
if [ $# -lt 1 ]; then
    echo "Usage: $0 {add|remove|show} [swap_size]"
    exit 1
fi

# 检查是否已经存在swap分区
if grep -q "swapfile" /etc/fstab; then
    swapfile=$(grep "swapfile" /etc/fstab | awk '{print $1}')
else
    swapfile="/swapfile"
fi

# 根据命令执行相应的操作
case "$1" in
    add)
        # 检查参数是否正确
        if [ $# -ne 2 ]; then
            echo "Usage: $0 add swap_size"
            exit 1
        fi

        # 如果已经存在swap分区，则先关闭swap分区
        if [ -n "$swapfile" ]; then
            swapoff "$swapfile"
            rm "$swapfile"
        fi

        # 创建一个新的swap文件
        fallocate -l "$2" "$swapfile"
        chmod 600 "$swapfile"
        mkswap "$swapfile"

        # 启用新的swap文件
        swapon "$swapfile"

        # 将新的swap文件添加到/etc/fstab中，以便在下次启动时自动启用
        echo "$swapfile none swap sw 0 0" >> /etc/fstab

        # 确认新的swap文件已经启用
        swapon --show

        echo "Swap partition added successfully."
        ;;
    remove)
        # 如果已经存在swap分区，则先关闭swap分区并删除Swap文件和相关配置。
        if [ -n "$swapfile" ]; then
            swapoff "$swapfile"
            rm "$swapfile"

            # 从/etc/fstab中删除旧的Swap文件配置
            sed -i "/$swapfile/d" /etc/fstab

            echo "Swap partition removed successfully."
        else
            echo "No Swap partition found."
        fi
        ;;
    show)
        # 如果已经存在Swap分区，则显示详细信息
        if [ -n "$swapfile" ]; then
            PS3='Please enter your choice: '
            options=("Show Swap Partition Configuration" "Add Swap Partition" "Remove Swap Partition" "Quit")
            select opt in "${options[@]}"
            do
                case $opt in
                    "Show Swap Partition Configuration")
                        echo "Swap partition is configured as follows:"
                        swapon --show | awk '{print $1"\t"$3"\t"$4}'
                        cat /proc/swaps | tail -n +2 | awk '{print $1"\t"$3"\t"$4}'
                        break;;
                    "Add Swap Partition")
                        read -p "Enter the size of the new Swap partition (e.g. 2G): " size
                        # 如果已经存在swap分区，则先关闭swap分区
                        if [ -n "$swapfile" ]; then
                            swapoff "$swapfile"
                            rm "$swapfile"
                        fi

                        # 创建一个新的swap文件
                        fallocate -l "$size" "$swapfile"
                        chmod 600 "$swapfile"
                        mkswap "$swapfile"

                        # 启用新的swap文件
                        swapon "$swapfile"

                        # 将新的swap文件添加到/etc/fstab中，以便在下次启动时自动启用。
                        echo "$swapfile none swap sw 0 0" >> /etc/fstab

                        # 确认新的Swap文件已经启用。
                        swapon --show

                        echo "Swap partition added successfully."
                        break;;
                    "Remove Swap Partition")
                        # 如果已经存在Swap分区，则先关闭Swap分区并删除Swap文件和相关配置。
                        if [ -n "$swapfile" ]; then
                            swapoff "$swa
