
# Ubuntu installer ecosystem

## Debian Installer (d-i)

Classic installer that has been used until 18.04, deprecated in 20.04.
    
## Ubiquity

Graphical [desktop installer](https://wiki.ubuntu.com/Ubiquity). D-i preseed based [auto install](https://wiki.ubuntu.com/UbiquityAutomation) is available. See [manual](http://manpages.ubuntu.com/manpages/jammy/man8/ubiquity.8.html) also. LiveCD can be booted from [nfsroot](https://wiki.ubuntu.com/LiveCDNetboot) ([alternate documentation](https://help.ubuntu.com/community/Installation/LocalNet#A_variation:_Booting_the_.22Live_CD.22_image)). There are a number of [arguments](https://wiki.ubuntu.com/DesktopCDOptions) that you can pass to the installer on the kernel command line.
    
## Ubuntu Desktop Installer

New desktop installer, that replaces Ubiquity. GitHub repo is [here](https://github.com/canonical/ubuntu-desktop-installer). Discussion on [Ubuntu Discourse](https://discourse.ubuntu.com/t/new-desktop-installer-preview-build/24765) about the new preview build. [Refreshing the Ubuntu Desktop Installer](https://discourse.ubuntu.com/t/refreshing-the-ubuntu-desktop-installer/20659) thread.
    
## Subiquity

Server installer frontend. GitHub repo can be [found here](https://github.com/canonical/subiquity).
    
## Casper

An initramfs hook to boot live, preinstalled systems from read-only media. [See Casper manpage](http://manpages.ubuntu.com/manpages/jammy/man7/casper.7.html). Ubiquity desktop and subiquity server install ISO medias relies on it.
    
## Curtin

[The curt installer](https://curtin.readthedocs.io/en/latest/index.html) is written in Python. Subiquity runs curtin in the background.
    
## Cloud-init

Final [configuration](https://cloudinit.readthedocs.io/en/latest/) in the running system. Subiquity creates initial user, sets up ssh authorized key in the target system through cloud-init.

# Download ISO Installer:
wget https://ubuntu.volia.net/ubuntu-releases/20.04.3/ubuntu-20.04.3-live-server-amd64.iso

# Create ISO distribution dirrectory:
mkdir -p iso/nocloud/

# Extract ISO using 7z:
7z x ubuntu-20.04.3-live-server-amd64.iso -x'![BOOT]' -oiso
# Or extract ISO using xorriso and fix permissions:
xorriso -osirrox on -indev "ubuntu-20.04.3-live-server-amd64.iso" -extract / iso && chmod -R +w iso

# Create empty meta-data file:
touch iso/nocloud/meta-data

# Copy user-data file:
cp user-data iso/nocloud/user-data

# Update boot flags with cloud-init autoinstall:
## Should look similar to this: initrd=/casper/initrd quiet autoinstall ds=nocloud;s=/cdrom/nocloud/ ---
sed -i 's|---|autoinstall ds=nocloud\\\;s=/cdrom/nocloud/ ---|g' iso/boot/grub/grub.cfg
sed -i 's|---|autoinstall ds=nocloud;s=/cdrom/nocloud/ ---|g' iso/isolinux/txt.cfg

# Disable mandatory md5 checksum on boot:
md5sum iso/.disk/info > iso/md5sum.txt
sed -i 's|iso/|./|g' iso/md5sum.txt

# (Optionally) Regenerate md5:
# The find will warn 'File system loop detected' and return non-zero exit status on the 'ubuntu' symlink to '.'
# To avoid that, temporarily move it out of the way
mv iso/ubuntu .
(cd iso; find '!' -name "md5sum.txt" '!' -path "./isolinux/*" -follow -type f -exec "$(which md5sum)" {} \; > ../md5sum.txt)
mv md5sum.txt iso/
mv ubuntu iso

# Create Install ISO from extracted dir (ArchLinux):
xorriso -as mkisofs -r \
  -V Ubuntu\ custom\ amd64 \
  -o ubuntu-20.04.3-live-server-amd64-autoinstall.iso \
  -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
  -isohybrid-mbr /usr/lib/syslinux/bios/isohdpfx.bin  \
  iso/boot iso

# Create Install ISO from extracted dir (Ubuntu):
xorriso -as mkisofs -r \
  -V Ubuntu\ custom\ amd64 \
  -o ubuntu-20.04.3-live-server-amd64-autoinstall.iso \
  -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot \
  -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -isohybrid-gpt-basdat -isohybrid-apm-hfsplus \
  -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin  \
  iso/boot iso

# Reference
 - https://www.molnar-peter.hu/en/ubuntu-jammy-netinstall-pxe.html
 - https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls
 - https://wiki.ubuntu.com/FoundationsTeam/AutomatedServerInstalls/ConfigReference
 - https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html
 - https://discourse.ubuntu.com/t/please-test-autoinstalls-for-20-04/15250/53
