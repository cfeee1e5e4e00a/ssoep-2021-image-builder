## Building image
1. Install `binfmt-qemu-static`, `qemu-user-static` and `docker`
1. Add yourself to `docker` group
2. Generate ssh key: `ssh-keygen -t rsa -N '' -f repo-key`, add repo-key.pub to your github account
1. Run `./fetch-resources`
1. Run `./build`
1. Partition sdcard and mount it to rootfs directory (for example `mkdir -p rootfs/boot && sudo mount /dev/sdb2 rootfs && sudo mount /dev/sdb1 rootfs/boot`)
1. Write image to sdcard: `sudo bsdtar -xpf img.tar.gz -C rootfs --exclude ".dockerenv"`
1. ???
1. PROFIT 

## Known issues
Bluetooth not working (some packages from AUR must be installed)