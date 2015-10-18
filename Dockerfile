FROM ubuntu:latest

RUN apt-get update && apt-get install -y \
        build-essential python-dev python-pip debootstrap debian-archive-keyring libjpeg-dev zlib1g-dev unzip wget graphviz curl git wget flex bison libtool automake autoconf autotools-dev pkg-config libglib2.0-dev

RUN curl -o /tmp/libcapstone3.deb "http://www.capstone-engine.org/download/3.0.4/ubuntu-14.04/libcapstone3_3.0.4-0.1ubuntu1_amd64.deb"

RUN dpkg -i /tmp/libcapstone3.deb

RUN git clone https://github.com/BinaryAnalysisPlatform/qira

WORKDIR /qira

RUN pip install --upgrade -r /qira/requirements.txt

RUN mkdir tracers/qemu

WORKDIR /qira/tracers/qemu

RUN wget http://wiki.qemu-project.org/download/qemu-2.1.3.tar.bz2
RUN tar xf qemu-2.1.3.tar.bz2
RUN ln -s qemu-2.1.3 qemu-latest

RUN ln -s qemu-latest/arm-linux-user/qemu-arm qira-arm
RUN ln -s qemu-latest/i386-linux-user/qemu-i386 qira-i386
RUN ln -s qemu-latest/x86_64-linux-user/qemu-x86_64 qira-x86_64
RUN ln -s qemu-latest/ppc-linux-user/qemu-ppc qira-ppc
RUN ln -s qemu-latest/aarch64-linux-user/qemu-aarch64 qira-aarch64
RUN ln -s qemu-latest/mips-linux-user/qemu-mips qira-mips
RUN ln -s qemu-latest/mipsel-linux-user/qemu-mipsel qira-mipsel

WORKDIR /qira/tracers/qemu/qemu-latest

RUN patch -p1 < /qira/tracers/qemu.patch

RUN ./configure --target-list=i386-linux-user,x86_64-linux-user,arm-linux-user,ppc-linux-user,aarch64-linux-user,mips-linux-user,mipsel-linux-user --enable-tcg-interpreter --enable-debug-tcg --cpu=unknown --enable-tcg-interpreter --enable-debug-tcg --cpu=unknown
RUN make -j $(grep processor < /proc/cpuinfo | wc -l)

RUN ln -s /qira/qira /usr/local/bin/qira

WORKDIR /

COPY qira_starter /qira/qira

RUN chmod uog+x /qira/qira
