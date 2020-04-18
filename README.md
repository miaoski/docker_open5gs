# docker_open5gs with IMS

This repository is meant to be a install-and-run lab for Open5GS + Kamailio IMS
VoLTE study, a follow-up project of [Open5GS Tutorial: VoLTE Setup with Kamailio IMS and Open5GS](https://open5gs.org/open5gs/docs/tutorial/02-VoLTE-setup/), 
which is mainly contributed by Herle Supreeth.  This repo is also based on his
[docker_open5gs](github.com/herlesupreeth/docker_open5gs).

The main purpose is to save researchers' and students' time to debug for a
minimum-viable environment before actual study can be proceeded.

## Important notice before you start

1. @supreeth's "noipv6" hack of Open5GS is used, because my phone isn't able to
   connect to IMS via IPv6.  Even if you choose "IPv4 Only" in APN, Open5GS
   still allocates an IPv6 address to both APN *internet* and *ims*.
1. @supreeth's fork of Kamailio is used to support ipsec.
1. Java 7 is downloaded from an alternative location.  You have to agree with
   Oracle's term of service and have an Oracle account, to legally use Java SDK
   7u80.  By using this repo, I assume you have the legal right to use it and
   hold no liability.

You have to prepare IMSI, Ki, OP (yes, not **OPc**), SQN of your SIM cards.  You
may want to disable SQN checking in the SIM card.  Check out
https://github.com/herlesupreeth/pysim for a slightly modified pysim.


## Build and Run

* Mandatory requirements:
  * [docker-ce](https://docs.docker.com/install/linux/docker-ce/ubuntu)
  * [docker-compose](https://docs.docker.com/compose)

Clone the repository and build base docker images of open5gs and Kamailio:

```
git clone https://github.com/miaoski/docker_open5gs
cd docker_open5gs/base
docker build --no-cache --force-rm -t docker_open5gs .

cd ../kamailio_base
docker build --no-cache --force-rm -t open5gs_kamailio .

cd ..
docker-compose build --no-cache

# Copy DNS setting to containers.  Do this whenever you change IP in .env
./copy-env.sh

# Start MySQL and MongoDB first, in order to initialize the databases
docker-compose up mongo mysql dns

# To start Open5GS core network without IMS
docker-compose up hss mme pcrf pgw sgw

# To start IMS
docker-compose up rtpengine fhoss pcscf icscf scscf

# To test whether DNS is properly running
./test-dns.sh
```

You may want to review `.env` for IP allocation.


## Run srsENB in a separate container

I use srsENB and USRP B210 in the lab.  Sometimes you may want to restart
srsENB while keeping the core network running.  It is thus recommended to run
srsENB separately.

Edit `.env` first to set EARFCN, TX_GAIN, RX_GAIN.  Thereafter,

```
docker-compose -f srsenb.yaml build --no-cache
docker-compose -f srsenb.yaml up
```

## Configuration and register two UE

The configuration files for each of the Core Network component can be found
under their respective folder. Edit the .yaml files of the components and run
`docker-compose build` again.

Open (http://<DOCKER_HOST_IP>:3000) in a web browser, where <DOCKER_HOST_IP> is
the IP of the machine/VM running the open5gs containers. Login with following
credentials

```
Username : admin
Password : 1423
```

Follow the instructions in [VoLTE Setup](https://open5gs.org/open5gs/docs/tutorial/02-VoLTE-setup/):
- Step 18, set IMSI, Ki, OP, SQN and APN of your SIM cards.
- Step 20, add IMS subscriptions to FHoSS.

For already running systems, copy SQN from Open5GS and type it in FHoSS.  You
can type SQN in decimal.  FHoSS will automagically convert it to hex.

Pay special attention to copy/paste.  You might have leading or trailing spaces
in FHoSS, resulting in failed connections!


# Illustrations

## Network topology

Thanks to Sukchan Lee's Open5GS, the topology is super similar to [SAE on Wikipedia](https://en.wikipedia.org/wiki/System_Architecture_Evolution#/media/File:Evolved_Packet_Core.svg).
![Network topology of Open5GS + IMS](https://raw.githubusercontent.com/miaoski/docker_open5gs/master/network-topology.png)


## SIP REGISTER

(Some screenshots)


## PCAP

PCAP files of successful calls can be found on [VoLTE Setup](https://open5gs.org/open5gs/docs/tutorial/02-VoLTE-setup/).

If your cellphone stuck on ipsec (like mine), the PCAP looks like this:
(Screenshot)

# Known issues

- IPv6 is not supported.
- If your cellphone mandates IPsec (such as Xiaomi Mi 9 Pro 5G), it might not work.
  However, you should at least see SIP REGISTRATION and a couple of 401 Unauthorized.

I'm currently stuck by IPsec.  If anyone successfully made a VoLTE call by
using this repo, please submit an issue and let me know!


# References

- https://github.com/onmyway133/blog/issues/284
- https://realtimecommunication.wordpress.com/2015/05/26/at-your-service/
- https://www.sharetechnote.com/html/Handbook_LTE_VoLTE.html

# License

Derived from @supreeth's repos, therefore BSD 2-Clause.
