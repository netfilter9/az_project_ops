#!/bin/bash
vm_type=""
swap_filename="/mnt/resource/swapfile"
size_in_gb=2 #edit this for non sap swapsize
check_vm_type() {
    if [ $(df -h | grep "/hana/data$" | wc -l) -eq 1 ]; then
        vm_type="hana"
    elif [ $(df -h | grep "/usr/sap$" | wc -l) -eq 1 ] && [ $(df -h | grep "/hana/data$" | wc -l) -ne 1 ]; then
        vm_type="sap"
    else
        vm_type="non_sap"
    fi
}

set_swap_size() {
    if [ $vm_type = "hana" ]; then
        swap_size=2
    elif [ $vm_type = "sap" ]; then
        memsize=$(awk '/MemTotal/ { printf "%.0f", $2 / 1000 / 1000 }' /proc/meminfo)
        if [  $memsize -lt 32  ]; then
            swap_size=`expr $memsize \* 2`
        elif [ $memsize -lt 63 ]; then
            swap_size=64
        elif [ $memsize -lt 127 ]; then
            swap_size=96
        elif [ $memsize -lt 255 ]; then
            swap_size=128
        elif [ $memsize -lt 511 ]; then
            swap_size=160
        elif [ $memsize -lt 1023 ]; then
            swap_size=192
        elif [ $memsize -lt 2047 ]; then
            swap_size=224
        elif [ $memsize -lt 4095 ]; then
            swap_size=256
        elif [ $memsize -lt 8191 ]; then
            swap_size=288
        fi
    elif [ $vm_type = "non_sap" ] && [ -n "$size_in_gb" ]; then
          swap_size=$size_in_gb
    fi
    swap_size=$(numfmt --from=iec "${swap_size}G")
}

check_swap () {
    existing_swap=$(free | awk '/^Swap:/ {print $2}')

    if [ $existing_swap -eq 0 ]; then
        echo "No active swap found. Proceeding..."
        return
    fi

    if [ -f "$swap_filename" ]; then
        existing_file_size=$(stat -c%s "$swap_filename")

        if [ $existing_file_size -ne $swap_size ]; then
            echo "Swap exists but size mismatch."
            sudo swapoff "$swap_filename"
            sudo rm -f "$swap_filename"
            return
        else
            echo "Swap exists and size matches. Nothing to change."
            exit 0
        fi
    fi
}

check_mnt () {
  mntsize=$(df --output=avail /mnt | tail -1 | tr -d ' ' | awk '{print $1 * 1024}')
    if [ -f "$swap_filename" ]; then
        existing_file_size=$(stat -c%s "$swap_filename") 
        mntsize=$((mntsize + existing_file_size))
        mntsize=$(numfmt --from=iec $mntsize)
    fi
    if [ $swap_size -lt $mntsize ]; then
        echo "/mnt sufficient space"
            if [ ! -d /mnt/resource ]; then
              echo "Creating /mnt/resource..."
              sudo mkdir -p /mnt/resource
             else
                 echo "/mnt/resource exists"
            fi
    else
        echo "/mnt insufficient space"
        exit 1
    fi
}

create_swap () {
    sudo fallocate --length $swap_size $swap_filename
    sudo chmod 600 $swap_filename
    sudo mkswap $swap_filename
    sudo swapon $swap_filename
    sudo swapon -a
    free -h
}

check_vm_type
set_swap_size
check_swap
check_mnt
create_swap


