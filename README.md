# ace-osinstaller
To use iPXE to setup my own development machine
This repo is used for creating `ipxe.iso` without DHCP server/tFTP server.

## Getting Started

### Prerequisites
You will need to have at least the following packages installed in order to build iPXE: 
```
gcc (version 3 or later)
binutils (version 2.18 or later)
make
perl
liblzma or xz header files
mtools
mkisofs 
```

Note: there are something specials in answerfile:
1. Use /dev/xvda which is simply the Xen disk storage devices as disk partition , you need to update it if you use other Hypervisor
2. Use Text mode instead of desktop environment
3. Create an encrypted password for the user configuration in answerfile
```
python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
```
4. Install [ace-profile](https://github.com/acefei/ace-profile) in the post install stage

### Installing

To Build an iPXE bootable CD-ROM image using:
```
make
```
you might edit your own setting for the distros in [settings.py](https://github.com/acefei/ace-osinstaller/blob/master/settings.py)

## Deployment
To burn `ipxe.iso` onto a blank CD-ROM or DVD-ROM. 
Or put it into an ISO library for the VM installation on XenServer/Vmware/KVM 

## How to dump answerfile infomation after OS installation
### Centos
- cat /root/anaconda-ks.cfg
### Debian/Ubuntu
1. cat /var/log/installer/cdebconf/questions.dat
2. install `debconf-utils` and run `debconf-get-selections -installer` to dump preseed

## Acknowledgments

* [iPXE Download](http://ipxe.org/download)
* [Error building ISO](https://forum.ipxe.org/showthread.php?tid=8080)
* [Debian (stable) preseed example](https://www.debian.org/releases/stable/example-preseed.txt)
* [Ubuntu (stable) preseed example](https://help.ubuntu.com/stable/installation-guide/example-preseed.txt)
* [Automated Server Installs for 20.04](https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls#Differences_from_debian-installer_preseeding)
* [How to unpack/uncompress and repack/re-compress an initial ramdisk (initrd/initramfs) boot image file](https://access.redhat.com/solutions/24029)

## Known Issues
* Failed to retrieve preconfiguration file ubuntu 1804 as wget can not download https url without `--no-check-certificate` 
