btfs dl vm
==========


### Why?

originally the intention was to have a very simple, convenient and sort of containerized thing, 
that downloads arbitrary torrent content in a fully automated way. One could say, it is a 
*headless bulk downloader for torrents*. It was intended for making my first steps in the 
golang world (which is still a *future work*). For now the core logic is written in shell script
and daemonized by *systemd*.



### Features

+   opens up a VPN connection to IPredator
+   watches for torrent files and magnets, downloads their content and then shares it with the 
    host system


### Components

+   [btfs](https://github.com/johang/btfs)
+   [OpenVPN](https://openvpn.net/)
+   [ferm](http://ferm.foo-projects.org/) *(firewall)*
+   [DNScrypt Proxy](https://github.com/jedisct1/dnscrypt-proxy)


### Dependencies

+   vagrant
+   virtualbox
+   valid IPredator account (if you have none, [get one](https://ipredator.se/))
+   Ubuntu 16.04 [bento box](https://github.com/chef/bento)


### Installation

1.  clone the repo
2.  add the file `./conf/IPredator.auth` containing


        USERNAME
        PASSWORD


3.  adjust desired configurations (`./conf`)
4.  run `vagrant up` from within `./vm`
5.  wait until the provisioning has finished and then spin up the vm again



### Howto use

Just put `.torrent` files into the shared folder (or folders with such files) or paste 
magnet links into the corresponding file `./share/magnet-links` ... and wait.



### Worth knowing

+   after the provisioning has finished, the vm will be shutdown, just to make sure everything 
    comes up as expected after the installation (e.g. mounting synced folders). So in order 
    to use this whole thing, one has to get the machine up and running again
+   the provisioning was originally based on 
    [IPredator HOWTOs](https://blog.ipredator.se/howto.html)
+   [vagrant documentation](https://www.vagrantup.com/docs/) 
    and [CLI](https://www.vagrantup.com/docs/cli/)



### Future Works

+ [x]   switching form *upstart* to *systemd*
+ []    remove the hard-coded IPredator support, to enable other VPN providers
+ []    support magnet links (not only torrent files)
+ []    check for version of files loaded from IPredator
+ []    write the core logic in *golang*
+ []    eventually moving from ubuntu to debian
+ []    containerize this whole thing (e.g. w/ rkt, coreos)
+ []    move the firewall switch (`fermreload.sh`) to a systemd unit/service



### Known issues

+   the provisioning can be kind of unstable. If it breaks, please destroy the machine and
    have another try



### License

[FVUS](./LICENSE)
