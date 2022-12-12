At the end of the day, iPXE is just a really flexible bootloader. You have to be careful about determining where the problems lie.

Saying the system doesn't work is unhelpful at best. Please describe the boot sequence and what you see from power on to PXE and beyond.

If you want to capture logs, there are several sections on how to do this: https://www.ipxe.org/buildcfg/console_syslog Syslog is not enabled by default due to security/ binary size issues. It is for debugging only.

I) Describe your DHCP TFTP environment and which iPXE bootloader you are using (undionly.kpxe, ipxe.efi, etc...) iPXE build numbers may be helpful.

II) Describe each of the following steps in the boot cycle:

    A) BIOS splash screen 

    B) PXE Boot Screen 

        1. PXE DHCP Request
        2. IP address info

    C) iPXE Boot Screen
        1. iPXE Kernel Entry
        2. iPXE DHCP Request
        3. Embedded/Downloaded Script Entry
        4. Initrd/vmlinuz download

    D) Ubuntu Kernel Entry
        1. vmlinuz/ initrd Execution
