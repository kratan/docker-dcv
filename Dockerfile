FROM centos:7
LABEL maintainer="andreas.kratzer@kit.edu"

#Set Versions, nice-dcv setup File has to be downloaded from NICE manually, Nvidia Drivers has to be the same as on your docker host
ENV NVIDIA_DRIVER 375.39
ENV NVIDIA_INSTALL http://us.download.nvidia.com/XFree86/Linux-x86_64/${NVIDIA_DRIVER}/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run
ENV NICE_DCV_INSTALL nice-dcv-2016.0-16811.run

RUN yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflags=nodocs install epel-release \
    yum -y --setopt=tsflags=nodocs update && \
    yum -y --setopt=tsflag=nodocs install pciutils kbd which sudo && \
    yum -y --setopt=tsflag=nodocs groupinstall "X Window System"

#Set WorkDir to temp
WORKDIR "/tmp"

#Add nvidia driver to current image
RUN curl -o /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run ${NVIDIA_INSTALL} 
RUN sh /tmp/NVIDIA-Linux-x86_64-${NVIDIA_DRIVER}.run -a -N --ui=none --no-kernel-module

#Setup Nice Installation
COPY install.conf /tmp/install.conf
COPY ${NICE_DCV} /tmp
RUN sh /tmp/${NICE_DCV_INSTALL} -- --batch="/tmp/install.conf" > /dev/null
COPY license.lic /opt/nice/dcv/license/license.lic

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN yum clean all && rm -Rf /tmp/*

WORKDIR "/"

EXPOSE 7300-7399 5900-5999 

CMD ["/entrypoint.sh"]
