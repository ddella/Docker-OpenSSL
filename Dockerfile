# Inpired by https://github.com/raesene
# Set master image, Mini root filesystem from https://www.alpinelinux.org/downloads/
FROM scratch
ADD ["alpine-minirootfs-3.17.0-x86_64.tar.gz", "/"]

LABEL Maintainer="DDN <daniel@isociel.com>"
LABEL Description="Lightweight container with OpenSSL 3.0.7 on Alpine 3.17 and libfaketime."
EXPOSE 22

# Update Alpine
RUN ["apk", "--no-cache", "update", "upgrade"]

# OpenSSL, OpenSSH, sudo and bash Installation (sorry we need bash)
RUN ["apk", "--no-cache", "add", "openssl", "openssh", "sudo", "bash"]

COPY banner /etc/ssh/
COPY motd /etc/
COPY entrypoint.sh /

# Install GCC and cie
RUN ["apk", "--no-cache", "add", "make", "gcc", "libc-dev", "git"]

# Get libfaketime sources from github and build
RUN ["sh","-c","git clone https://github.com/wolfcw/libfaketime.git && cd libfaketime && make"]

# Copy the library in /lib
RUN ["cp", "/libfaketime/src/libfaketime.so.1", "/lib/."]

# Copy the program in /bin
RUN ["cp", "/libfaketime/src/faketime", "/bin/."]

RUN ["rm", "-rf", "/libfaketime"]

# Uninstall GCC and cie
RUN ["apk", "--no-cache", "del", "make", "gcc", "libc-dev", "git"]

# Remove any left-over packages, if any...
RUN ["rm", "-rf", "/var/cache/apk/"]

# Make the script 'executable'. Prevents the error: permission denied unknown
RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
