# ace-osinstaller
To use iPXE to setup my own development machine

This repo is used for creating `osinstaller.iso` without deploying extra DHCP server/tFTP server.

## Getting Started

### Prerequisites
Promptly start as long as there is `docker` (curl -fsSL https://get.docker.com | sh) and `make` on your host and get help running `make` in the root path of this repo.

### Usage
#### Use official ipxe.iso
1. Generate chainload.ipxe and put it on http server using `make http_server`
2. Download official [ipxe.iso](http://boot.ipxe.org/ipxe.iso) and follow the steps on [Quick Start](https://ipxe.org/) into PXE cli
3. Run the following cmd
```
iPXE> dhcp
iPXE> chain http://<server ip>/chainload.ipxe
```
There are limitations to this way:
- Not able to chain https url
- Inconvenience to debug without ping/nslookup

#### Build your own ipxe.iso (rename osinstaller.iso for distinction)
```
# Specified a IP for fetching chainload.ipxe over HTTP. If bypass this variable, it will use default IP
make iso SERVER_ADDR=http://<server ip>

# Start local http server with sudo priviledge.
make http_server
```
> There are some artifacts, `osinstaller.iso chainload.ipxe <some answerfile>` and it will launch a http server against output/ dir
Then, burn osinstaller.iso onto a blank CD-ROM or DVD-ROM or put it into the ISO library for the VM installation on XenServer/Vmware/KVM

For more details usage, just run `make` to get help.

### Add Extra Distro
You can find available distro configuration in [netboot.json](https://github.com/acefei/ace-osinstaller/blob/master/scripts/netboot.json)
 
1. Add new section as below for new distro support 
```
"New Distro Name": {
        "description": "the details for distro",
        "url": "http://<your local server ip>",
        "kernel": "<relative path>/vmlinuz",
        "initrd": "<relative path>/initrd.img",
        "kernel_args": "<literal as the key name>"
    },
```
2. Put new distro iso into output dir which created by `make output`
3. Restart http server `make http_server`
4. If wanted to tweak the kernel args, we only need to change it in `output/chainload.ipxe` instead of building `osinstaller.iso` again because of chain loading feature.

<details>
  <summary>There are something specials in answerfile</summary>

1. Use /dev/xvda which is simply the Xen disk storage devices as disk partition , you need to update it if you use other Hypervisor
2. Use Text mode instead of desktop environment
3. Create an encrypted password for the user configuration in answerfile
 ```
   python3 -c 'import crypt,getpass;pw=getpass.getpass();print(crypt.crypt(pw) if (pw==getpass.getpass("Confirm: ")) else exit())'
 ```
</details>

## Further Read
[docs](https://github.com/acefei/ace-osinstaller/blob/master/docs)
