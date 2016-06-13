btfs dl vm
==========


### Why?

+   originally the intention was to have a very simple, convenient and sort of containerized thing, 
    that downloads arbitrary torrent content in a fully automated way. One could say, it is a 
    *headless bulk downloader for torrents*. And it was intended to make my first steps in the 
    golang world (which is still a *future work*). For now the core logic is written in shell script
    and daemonized by *upstart*.



### Features

+   opens up a VPN connection to IPredator
+   watches for torrent files and magnets, downloading their content and share it with the 
    host system


### Components

+   [btfs](https://github.com/johang/btfs)
+   [OpenVPN](https://openvpn.net/)
+   [ferm](http://ferm.foo-projects.org/) *(firewall)*
+   [DNScrypt](https://dnscrypt.org/)


### Dependencies

+   vagrant
+   virtualbox
+   valid IPredator account
+   Ubuntu 14.04


### Installation

1.  clone the repo
2.  add the file `./conf/IPredator.auth` containing


        USERNAME
        PASSWORD


3.  adjust desired configurations
4.  run `vagrant up` from within `./vm`
5.  wait until the provisioning has finished and spin up the vm again


### Howto use

Just put `.torrent` files into the shared folder (or folders with such files) or past magnet links
into the corresponding file `./share/magnet-links` ... and wait.


### Worth knowing

+   after the provisioning has finished, the vm will be shutdown, just ot make sure everything 
    comes up as expected after the installation. So in order to use this whole thing, one has to
    get the machine up and running again
+   the provisioning is heavily based on [IPredator HOWTOs](https://blog.ipredator.se/howto.html)
+   [vagrant documentation](https://www.vagrantup.com/docs/) and [CLI](https://www.vagrantup.com/docs/cli/)


### Future Works

+   remove the hard-coded IPredator support, to enable other VPN providers
+   support magnet links (not only torrent files)
+   check for version of files loaded from IPredator
+   write the core logic in *golang*
+   eventually moving from ubuntu to debian


### Known issues

+   from time to time the provisioning might be broken, depending on the mood of the ubuntu 
    package servers. My guess, it's the vagrant box or because an older version of *ubuntu* 
    is used (and that's because 16.04 is still not working well will virtualbox 5.x).
    So there is room for improvements ;)
