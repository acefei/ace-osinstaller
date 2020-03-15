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
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

BUILD_ARGS := 
DOCKER_BUILD = DOCKER_BUILDKIT=1 docker build $(BUILD_ARGS) -t $@ --target $@ $(<D)

build: Dockerfile
	$(DOCKER_BUILD)

# Need to assign HTTP SERVER IP
iso: private BUILD_ARGS := --build-arg HTTP_SERVER=$(HTTP_SERVER)
iso: Dockerfile ## build ipxe.iso to output dir
	@echo "Ensure http://$${HTTP_SERVER:? please run make with 'HTTP_SERVER=<ip>'}/boot.ipxe is available before installing ipxe.iso"
	$(DOCKER_BUILD)
	@docker run --rm -v $(PWD)/output:/$@ $@
	@echo "artifact is available on $$(sha256sum output/ipxe.iso| awk '{print $$2,$$1}')"

boot_ipxe: www ## generate boot.ipxe to www dir
	@python3 scripts/gen_embedded_script.py $<

ifdef HTTP_SERVER
http_server: iso boot_ipxe ## set up http server for boot.ipxe and the local distro iso in www/
else
http_server: boot_ipxe 
endif
	@bash www/mount_iso.sh
