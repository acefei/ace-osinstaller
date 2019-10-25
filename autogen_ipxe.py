#!/usr/bin/python
import os
from settings import *

IPXE_TEMPLATE = """#!ipxe
dhcp
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
choose --default end --timeout 30000 target && goto ${{target}} || goto debug_ipxe
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
kernel {url}/{kernel} {kernel_args}
initrd {url}/{initrd}
boot
"""

def render_isolinux_cfg():
    isolinux_cfgs = []
    for target, v in DISTRO_INFO.items():
        if target.startswith('centos'):
            kernel = 'vmlinuz'
            initrd = 'initrd.img'
        elif target.startswith(('debian', 'ubuntu')):
            kernel = 'linux'
            initrd = 'initrd.gz'

        url = v['url']
        answerfile = answerfile=v['answerfile'] if v.get('answerfile') else ''         
        kernel_args = "{} {}".format(v['kernel_args'], answerfile) 
        isolinux_cfgs.extend(ISOLINUX_CFG_TEMPLATE.format(**locals()))
    return ''.join(isolinux_cfgs)

def main(): 
    distro_items = '\n'.join([ "item {:25}{}".format(k, v['description']) for k, v in DISTRO_INFO.items()]) 
    distro_isolinux_cfg = render_isolinux_cfg()
    output = IPXE_TEMPLATE.format(**locals())
    print(output)
    with open('installer.ipxe', 'w') as f:
        f.write(output)

if __name__ == "__main__":
   main()
