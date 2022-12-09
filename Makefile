.PHONY: help
.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
        match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
        if match:
                target, help = match.groups()
                print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:
	@python3 -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

export SERVER_ADDR ?= http://$(shell ./scripts/default_ip)
DEFAULT_DISK = $(shell ./scripts/default_disk)
DOCKER_BUILD = DOCKER_BUILDKIT=1 docker build $(BUILD_ARGS) -t $@ --target $@ $(<D)

output:
	@mkdir -p -m777 $@

iso: BUILD_ARGS = --build-arg SERVER_ADDR=$(SERVER_ADDR)
iso: output Dockerfile ## build osinstaller.iso to output dir
	$(DOCKER_BUILD)
	@docker run --rm -v $(PWD)/$<:/$@ $@
	@echo "artifact is available on $$(sha256sum output/osinstaller.iso| awk '{print $$2,$$1}')"

chainload_ipxe: output ## build chainload.ipxe to output dir
	@python3 scripts/gen_osinstaller_script.py $<

answerfile: output ## build answerfiles
	@cp -rf answerfiles/. $< && sed -i 's/@DISK@/$(DEFAULT_DISK)/g' $</*

http_server: iso boot_ipxe answerfile ## start http server based on output dir
	@cp scripts/mount_iso.sh output && bash output/mount_iso.sh

mount_iso: boot_ipxe answerfile ## mount local iso in www/ and start http server for it
	@cp scripts/mount_iso.sh output && bash output/mount_iso.sh

clean:
	@sudo rm -rf $(PWD)/output
	@docker rmi build iso
