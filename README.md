
## To build working sd memory card:
Device         Boot    Start      End  Sectors  Size Id Type
/dev/mmcblk0p1      20975616 21499903   524288  256M  b W95 FAT32
/dev/mmcblk0p2          4096 20975615 20971520   10G 83 Linux
/dev/mmcblk0p3          2048     4095     2048    1M a2 unknown

sudo dd if=preloader-mkpimage.bin of=/dev/mmcblk0p3 bs=64k seek=0

sudo mkfs.vfat           /dev/mmcblk0p1
sudo mkfs.ext4 -L rootfs /dev/mmcblk0p2

sudo mount /dev/mmcblk0p1 /tmp/p1/
sudo cp u-boot.img u-boot.scr soc_system.dtb    /tmp/p1/
sudo cp output_file.rbf                         /tmp/p1/soc_system.rbf
sudo cp 4.6.5-socfpga-r1.zImage                 /tmp/p1/zImage

sudo mount /dev/mmcblk0p2                       /tmp/p2/
sudo tar xfv armhf-rootfs-debian-jessie.tar -C  /tmp/p2/
sudo tar xfv 4.6.5-socfpga-r1-modules.tar.gz -C /tmp/p2/
sudo chown root:root                            /tmp/p2/
sudo chmod 755                                  /tmp/p2/

sudo umount /dev/mmcblk0p1
sudo umount /dev/mmcblk0p2