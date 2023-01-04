# OpenSSL and libfaketime on Docker
## Introduction
This will build a Docker image, from scratch, with OpenSSL 3.0.7 on Alpine Linux 3.17.0. I also included [libfaketime](https://github.com/wolfcw/libfaketime). The purpose of this container is to be able to generate certificate in different moment in time, for testing purposes.  

The build is a five step process:

1. Get the Alpine Mini RootFS
2. Build the Docker image from scratch
3. Test the container locally
4. Trim down are container
5. Run the container

## 1. Alpine Mini RootFS
Use this command to copy the Alpine 3.17.0 mini root filesystem:
```shell
curl -O https://dl-cdn.alpinelinux.org/alpine/v3.17/releases/x86_64/alpine-minirootfs-3.17.0-x86_64.tar.gz
```
>The file is ~3.2Mb
## 2. Build the Docker image from scratch
You need the files `Dockerfile`, `banner`, `motd`, and `entrypoint.sh`. Use this command to build the Docker image:
```shell
docker build . -t tempo:3.17.0
```
## 3. Test the container locally
Use this command to run your container and get a shell.
```sh
docker run -it --rm --entrypoint /bin/sh --env TZ='EAST+5EDT,M3.2.0/2,M11.1.0/2' --env TIMEZONE='America/New_York' --name openssl --hostname=openssl tempo:3.17.0
```
The root password is `root`. I know, not the most secure password and it can be easily be guessed 😀  
You can also use the username `remote`. This time I had security in mind so the password is very complicated. It will be in clear on the login page 🤣  

If you want to test `libfaketime`, use this command:
```shell
LD_PRELOAD=libfaketime.so.1 FAKETIME="2025-01-01 10:10:00" FAKETIME_DONT_RESET=1 /bin/date
```
>Output:  
>Wed Jan  1 10:10:00 EAST 2025

Don't exit the container for now.
## 4. Trim down the container
If you take a look at the container, the size is 177MB. We could do way better. Let's trim it down.
>```
>REPOSITORY               TAG               IMAGE ID       CREATED          SIZE
>tempo                    3.17.0            1c9fc5f9d9f6   2 minutes ago   177MB
>```

Use the following command to export the root filesystem to a local file **It NEEDS to be run as root**:
```shell
sudo docker export $(docker ps -f "name=openssl" -q) > openssl.tar
```

Use the following command to import the root filesystem to Docker:
```shell
docker import -c 'ENTRYPOINT ["/entrypoint.sh"]' openssl.tar openssl:3.17.0
```
### Cleanup
Exit the running container and delete the temporary image.  

Use this command to delete image:
```shell
docker rmi tempo:3.17.0
```

>The final Docker image `openssl:3.17.0` is ~16Mb
## 5. Run the container
Use this command to start the container in detach mode:
```shell
docker run --rm -d -p 2222:22 --name openssl --env TZ='EAST+5EDT,M3.2.0/2,M11.1.0/2' --env TIMEZONE='America/New_York' -v ~/Downloads/:/var/tmp --hostname=openssl openssl:3.17.0
```
>**Note**: Change the mapping of the local drive to suit your needs.  

Open a terminal an SSH to the new container with the username `root`. You remember the password 😀:
```shell
ssh -l root -p 2222 127.0.0.1
```

Open a terminal an SSH to the new container with the username `remote`. Take a look at the banner, you should see the password:
```shell
ssh -l remote -p 2222 127.0.0.1
```

>In my case, if you do `ls -la /var/tmp` inside the container, I see my local `~/Downloads/` directory.  
## 6. Terminate the container
Use this to terminate the container:
```sh   
docker rm -f openssl:3.17.0
```
## License
This project is licensed under the [MIT license](/LICENSE).  

[_^ back to top of page_](#OpenSSL-and-libfaketime-on-Docker)  
[_<< back to root_](../../../)
