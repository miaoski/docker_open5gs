FROM ubuntu:bionic

# Install updates and dependencies
RUN apt-get update && \
    apt-get -y install python3-pip python3-setuptools python3-wheel ninja-build \
                    build-essential flex bison git libsctp-dev libgnutls28-dev \
                    libgcrypt-dev libssl-dev libidn11-dev libmongoc-dev libbson-dev \
                    libyaml-dev meson vim ifupdown mongodb curl gnupg gdb iptables net-tools \
                    iputils-ping


# Dependencies of Kamailio
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install libxml2-dev libmysqlclient-dev libmnl-dev \
		mysql-server tcpdump screen ntp ntpdate dkms make \
		libcurl4-openssl-dev libpcre3-dev bash-completion \
		ipsec-tools libradcli-dev libradcli4 netcat

# Dependencies of Open5GS
RUN pip3 install click
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - && apt-get install -y nodejs && \
    apt-get autoremove -y && apt-get clean

# Get open5gs code and install
WORKDIR /
RUN git clone --recursive https://github.com/open5gs/open5gs && cd open5gs && \
    git checkout tags/v1.2.3 && meson build --prefix=`pwd`/install && \
    ninja -C build && cd build && ninja install

# Get Kamailio and build
WORKDIR /
RUN git clone https://github.com/herlesupreeth/kamailio && \
    cd kamailio

COPY modules.lst /tmp/

# Set the working directory to open5gs
WORKDIR /open5gs/webui
RUN npm install

# Compile kamailio
WORKDIR /kamailio
ENV RADCLI=1
RUN make cfg && \
    cp /tmp/modules.lst ./src/ && \
    make -j4 Q=0 all | tee make_all.txt && \
    make install | tee make_install.txt && \
    ldconfig
RUN adduser --quiet --system --group --disabled-password --shell /bin/false --gecos "Kamailio" --home /var/run/kamailio kamailio && \
    chown kamailio:kamailio /var/run/kamailio

WORKDIR /
