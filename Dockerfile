# Inpired by https://github.com/raesene and https://github.com/sickp.
# Set master image, Mini root filesystem from https://www.alpinelinux.org/downloads/
FROM scratch
ADD ["alpine-minirootfs-3.17.0-x86_64.tar.gz", "/"]

LABEL Maintainer="DDN <daniel@isociel.com>"
LABEL Description="Lightweight container with OpenSSL 3.0.7 on Alpine 3.17."
EXPOSE 22

# Update Alpine
RUN ["apk", "--no-cache", "update", "upgrade"]

# OpenSSL Installation
RUN ["apk", "--no-cache", "add", "openssl"]

# OpenSSH installation, permit "root" and set "root" password
RUN ["apk", "--no-cache", "add", "openssh"]

# sudo installation.
RUN ["apk", "--no-cache", "add", "sudo"]

# We need bash :-(
RUN ["apk", "--no-cache", "add", "bash"]

# remove packages, if any...
RUN ["rm", "-rf", "/var/cache/apk/"]

COPY banner /etc/ssh/
COPY motd /etc/
COPY entrypoint.sh /

# Install GCC and cie
RUN ["apk", "--no-cache", "add", "make"]
RUN ["apk", "--no-cache", "add", "gcc"]
RUN ["apk", "--no-cache", "add", "libc-dev"]
RUN ["apk", "--no-cache", "add", "git"]

# Get the sources from github
# see https://github.com/wolfcw/libfaketime/releases
#RUN ["git", "clone", "https://github.com/wolfcw/libfaketime.git", "&&\", "cd", "libfaketime", "&&\", "make"]
RUN git clone https://github.com/wolfcw/libfaketime.git && \
    cd libfaketime && \
    make

RUN ["cp", "/libfaketime/src/libfaketime.so.1", "/lib/."]

RUN ["rm", "-rf", "/libfaketime"]

# Uninstall GCC and cie
RUN ["apk", "--no-cache", "del", "make"]
RUN ["apk", "--no-cache", "del", "gcc"]
RUN ["apk", "--no-cache", "del", "libc-dev"]
RUN ["apk", "--no-cache", "del", "git"]

# The following line is to prevent the error:
# Make the script 'executable'. Prevents the error: permission denied unknown
RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
