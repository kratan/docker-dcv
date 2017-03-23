NICE DCV only works with nvidia cards

Requirements:

- Get a license from NICE DCV. https://www.nice-software.com/contacts/demo-license

- Get a nice-dcv install file for linux and place it in the directory, maybe you have to modify the filename in Dockerfile

- You need a free TTY for mapping into the Docker Container

HowTo:

Copy the license from e-mail to license.lic file besides Dockerfile

Copy nice-dcv-2016.0-16811.run install file besides Dockerfile

Build your Docker Container:

```
docker build -t dcv-docker .
```

Run your Container with e.g. tty60 and third nvidia card:

```
docker run --device=/dev/nvidiactl --device=/dev/nvidia-uvm --device=/dev/nvidia2 --device=/dev/tty60 -e USERVNC=testing -e USERPASS=38983KK!! -h nice-dcv --name nice-dcv -p 7300-7399:7300-7399 -p 5900-5999:5900-5999 dcv-docker 
```

Connect via Nice VNC Viewer on port 5901

