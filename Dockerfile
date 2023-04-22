# Inpired by https://github.com/raesene
# Set master image, Mini root filesystem from https://www.alpinelinux.org/downloads/
FROM scratch
ADD ["alpine-minirootfs-3.17.3-x86_64.tar.gz", "/"]

LABEL org.opencontainers.image.authors="DDN <daniel@isociel.com>"
LABEL version="2.00"
LABEL Description="Lightweight container with OpenSSL 3.1.0 on Alpine 3.17.3 with libfaketime."

EXPOSE 22

# Update Alpine
RUN ["apk", "--no-cache", "update", "upgrade"]

# OpenSSH, sudo and bash Installation (sorry we need bash)
RUN ["apk", "--no-cache", "add", "openssh", "sudo", "bash"]

COPY banner /etc/ssh/
COPY motd /etc/
COPY entrypoint.sh /

# Install GCC and cie
RUN ["apk", "--no-cache", "add", "make", "gcc", "libc-dev", "git", "perl", "linux-headers"]

# Get libfaketime sources from github and build
RUN ["sh","-c","git clone https://github.com/wolfcw/libfaketime.git && cd libfaketime && make"]

# Copy the library in /lib
RUN ["cp", "/libfaketime/src/libfaketime.so.1", "/lib/."]

# Copy the program in /bin
RUN ["cp", "/libfaketime/src/faketime", "/bin/."]

# Copy, compile and install OpenSSL 3.1.x
ADD ["openssl-3.1.0.tar.gz", "/tmp"]
COPY buildopenssl.sh /tmp
WORKDIR /tmp
RUN ["chmod", "+x", "./buildopenssl.sh"]
RUN ["./buildopenssl.sh"]
WORKDIR /

# Uninstall GCC and cie
RUN ["apk", "--no-cache", "del", "make", "gcc", "libc-dev", "git", "perl", "linux-headers"]

# Remove any left-over packages, if any...
RUN ["rm", "-rf", "/var/cache/apk/"]
RUN ["rm", "-rf", "/libfaketime"]

# Remove OpenSSL source & doc
RUN ["rm", "-rf", "/usr/local/share/doc/openssl/"]
RUN ["rm", "-rf", "/tmp/openssl-3.1.0/"]
RUN ["rm", "-f", "/tmp/buildopenssl.sh"]

# Make the script 'executable'. Prevents the error: permission denied unknown
RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
