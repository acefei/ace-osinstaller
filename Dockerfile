FROM public.ecr.aws/lts/ubuntu AS base
# Note: using isolinux instead of syslinux
RUN apt update && apt install -y wget unzip build-essential liblzma-dev mkisofs isolinux
# Get iPXE source and Enable extra supports
WORKDIR /workspace
RUN wget  https://github.com/ipxe/ipxe/archive/refs/heads/master.zip \
    && unzip master.zip \
    && mv ipxe-master ipxe \
    && perl -i -pe 's@^(?://#define|#undef)\s+(PING_CMD|NSLOOKUP_CMD|DOWNLOAD_PROTO_HTTPS)(.+)@#define \1\2@' ipxe/src/config/general.h


FROM base AS build
WORKDIR /workspace
ARG SERVER_ADDR
COPY scripts/embed.ipxe ipxe/src
RUN sed -i 's#@SERVER_ADDR@#'"${SERVER_ADDR}"'#p' ipxe/src/embed.ipxe && \
    cd ipxe/src && make bin/ipxe.iso EMBED=embed.ipxe


FROM base AS iso
WORKDIR /iso
VOlUME /iso
# Note: put artifact to volume dir using CMD
# rather than COPY or RUN that only executes command in the intermediate layer 
COPY --from=build /workspace/ipxe/src/bin/ipxe.iso /tmp/
CMD [ "cp", "/tmp/ipxe.iso", "/iso/osinstaller.iso" ]
