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

export HTTP_SERVER_IP ?= $(shell ./scripts/default_ip)
DEFAULT_DISK = $(shell ./scripts/default_disk)
DOCKER_BUILD = DOCKER_BUILDKIT=1 docker build $(BUILD_ARGS) -t $@ --target $@ $(<D)

build: BUILD_ARGS = --build-arg HTTP_SERVER_IP=$(HTTP_SERVER_IP)
build: Dockerfile
	$(DOCKER_BUILD)

output:
	@mkdir -p -m777 $@

iso: output build ## build ipxe.iso to output dir
	@docker run --rm -v $(PWD)/$<:/$@ $@
	@echo "artifact is available on $$(sha256sum output/ipxe.iso| awk '{print $$2,$$1}')"

boot_ipxe: output ## build boot.ipxe to output dir
	@python3 scripts/gen_embedded_script.py $<

answerfile: output
	@cp -rf answerfiles/. $< && sed -i 's/@DISK@/$(DEFAULT_DISK)/g' $</*

http_server: iso boot_ipxe answerfile ## start http server based on output dir
	@cp scripts/mount_iso.sh output && bash output/mount_iso.sh

mount_iso: boot_ipxe answerfile ## mount local iso in www/ and start http server for it
	@cp scripts/mount_iso.sh output && bash output/mount_iso.sh

clean:
	@sudo rm -rf $(PWD)/output
