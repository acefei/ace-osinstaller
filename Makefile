WORKSPACE         = $(PWD)/workspace
ISOLINUX_VER      = 6.03
ISOLINUX_PATH     = ${WORKSPACE}/syslinux-${ISOLINUX_VER}
ISOLINUX_TARBALL  = https://cdn.kernel.org/pub/linux/utils/boot/syslinux/syslinux-${ISOLINUX_VER}.tar.gz
ISOLINUX_BIN_PATH = ${ISOLINUX_PATH}/bios/core/isolinux.bin
LDLINUX_PATH      = ${ISOLINUX_PATH}/bios/com32/elflink/ldlinux/ldlinux.c32
IPXE_SRC          = ${WORKSPACE}/ipxe/src

ipxe.iso: installer.ipxe
	make -C ${IPXE_SRC} -j 4 ISOLINUX_BIN=${ISOLINUX_BIN_PATH} LDLINUX_C32=${LDLINUX_PATH} bin/$@ EMBED=./$<
	@echo "---> ipxe.iso is availiable on ${IPXE_SRC}/bin"

installer.ipxe: provision
	python autogen_ipxe.py && mv $@ ${IPXE_SRC}

.PHONY: provision
provision: clean
	mkdir -p ${WORKSPACE} && cd ${WORKSPACE} && git clone --depth=1 http://git.ipxe.org/ipxe.git && wget -qO- ${ISOLINUX_TARBALL} | tar -xz
	# Enable the commands `nslookup` and `ping` for iPXE
	perl  -i -pe 's@//(?=#define (?:NSLOOKUP_CMD|PING_CMD))@@' ${IPXE_SRC}/config/general.h

.PHONY: clean
clean:
	rm -rf ${WORKSPACE}
