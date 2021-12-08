# load the sd card onto media
sudo mount /dev/sdb1 /media/BOOT
sudo mount /dev/sdb2 /media/rootfs/

#copy the files
sudo cp BOOT.BIN /media/BOOT/
sudo cp image.ub /media/BOOT/
sudo cp system.dtb /media/BOOT/
sudo cp boot.scr /media/BOOT/

sudo tar xvf rootfs.tar.gz -C /media/rootfs/

# sync 
sync

# remove media
sudo umount /media/BOOT/
sudo umount /media/rootfs/

