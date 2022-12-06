FROM public.ecr.aws/lts/ubuntu AS base
# Note: using isolinux instead of syslinux
RUN apt update && apt install -y wget unzip build-essential liblzma-dev mkisofs isolinux
# Get iPXE source and Enable extra supports
WORKDIR /workspace
RUN wget  https://github.com/ipxe/ipxe/archive/refs/heads/master.zip \
    && unzip master.zip \
    && mv ipxe-master ipxe \
    && perl -pe -i 's@//(?=#define (?:NSLOOKUP_CMD|PING_CMD))@@' ipxe/src/config/general.h


FROM base AS build
WORKDIR /workspace
ARG HTTP_SERVER_IP
# Note: Put embedded script into ipxe/src
RUN echo "#!ipxe\ndhcp\nchain http://$HTTP_SERVER_IP/boot.ipxe" > ipxe/src/chain.ipxe && \
    cd ipxe/src && make bin/ipxe.iso EMBED=chain.ipxe NO_WERROR=1


FROM base AS iso
WORKDIR /iso
VOlUME /iso
# Note: put artifact to volume dir using CMD
# rather than COPY or RUN that only executes command in the intermediate layer 
COPY --from=build /workspace/ipxe/src/bin/ipxe.iso /tmp
CMD [ "cp", "/tmp/ipxe.iso", "/iso/" ]
