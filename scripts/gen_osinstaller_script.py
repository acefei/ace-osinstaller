#!/usr/bin/python
import os
import sys
try:
    import yaml
except:
    import pip
    import site

    # this makes it work
    if not os.path.exists(site.USER_SITE):
        os.makedirs(site.USER_SITE)

    # since I'm installing with --user, packages should be installed here,
    # so make sure it's on the path
    sys.path.insert(0, site.USER_SITE)

    pip.main(["install", "--user", "yaml"])
    import yaml

################## TEMPLATES #################
IPXE_TEMPLATE = """#!ipxe
#dhcp

#set net0/ip 192.168.1.125
#set net0/netmask 255.255.255.0
#set net0/gateway 192.168.30.1
#set dns 8.8.8.8

menu iPXE boot menu
item
{distro_items} 
item reboot_ipxe              Reboot iPXE Menu
item debug_ipxe               Debug  iPXE Network Connectivity
item

choose --default end --timeout 10000 target && goto ${{target}} || goto debug_ipxe
{distro_isolinux_cfg}

:debug_ipxe
#for ping/nslookup to work enable ping/nslookup command in config.h while buidling ipxe
echo "Interface Stat: net0"
ifstat net0
echo "Ping to gateway should work from here"
shell

:reboot_ipxe
echo "press any key to reboot"
exit
"""

ISOLINUX_CFG_TEMPLATE = """
:{target}
kernel {uri}/{kernel} {kernel_args}
initrd {uri}/{initrd}
boot
"""
################## TEMPLATES END #################

WORKDIR = os.path.split(os.path.realpath(__file__))[0]
config_file = 'netboot.yaml'

def load_config():
    with open(os.path.join(WORKDIR, config_file)) as s:
        return yaml.safe_load(s)
DISTRO_INFO = load_config()

def render_isolinux_cfg():
    isolinux_cfgs = []
    for target, v in DISTRO_INFO.items():
        if v.get("kernel") and v.get("initrd"):
            kernel = v["kernel"]
            initrd = v["initrd"]
        else:
            if target.startswith("centos"):
                kernel = "vmlinuz"
                initrd = "initrd.img"
            elif target.startswith(("debian", "ubuntu")):
                kernel = "linux"
                initrd = "initrd.gz"

        if not (kernel and initrd):
            raise Exception(f"please add 'kernel' and 'initrd' (relative path against 'kernel_location') for the new distro in {config_file}")

        uri = v['kernel_location'].rstrip("/") if v.get("kernel_location") else os.environ['KERNEL_LOC'].rstrip("/")
        answerfile = v["answerfile"] if v.get("answerfile") else ""
        kernel_args = "{} {}".format(v["kernel_args"], answerfile).format(seedfrom=os.environ['SERVER_ADDR'].rstrip("/"))
        isolinux_cfgs.extend(ISOLINUX_CFG_TEMPLATE.format(**locals()))
    return "".join(isolinux_cfgs)


def main():
    distro_items = "\n".join(
        ["item {:25}{}".format(k, v["description"]) for k, v in DISTRO_INFO.items()]
    )
    distro_isolinux_cfg = render_isolinux_cfg()
    output = IPXE_TEMPLATE.format(**locals())
    dest = sys.argv[1] if len(sys.argv) == 2 else '.'
    with open(os.path.join(os.path.realpath(dest), "chainload.ipxe"), "w") as f:
        f.write(output)


if __name__ == "__main__":
    main()
