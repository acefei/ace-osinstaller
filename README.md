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

### Installing

To Build an iPXE bootable CD-ROM image using:
```
make
```
you might edit your own setting for the distros in [settings.py](https://github.com/acefei/ace-osinstaller/blob/master/settings.py)

## Deployment
To burn `ipxe.iso` onto a blank CD-ROM or DVD-ROM. 
Or put it into an ISO library for the VM installation on XenServer/Vmware/KVM 

## Acknowledgments

* [iPXE Download](http://ipxe.org/download)
* To create an encrypted password for the user configuration in kickstart
```
python -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
```
