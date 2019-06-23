

### 2018-

+   relocated parts in filesystem
    -   `/opt/btfsdl`
    -   relocated Vagrantfile into ``./provision`` 


### 2016-07-09

+   in some situations `btfsdl.service` wont start properly, because the file `btfsdl.sh` get
    pulled into the vm via shared folder, and that share might be established to late.
    solution: copy the core into the vm, is already done with the service unit file
 
+   provision wont work in some cases at the first time when the vm get initialized, 
    only a reboot of the vm can fix this. 
    a `vagrant up --no-provision && vagrant halt && vagrant up --provision` 


### 2016-06-17

+   since I am currently not able to bypass `/etc/resolv.conf` on *Ubuntu 16.06*, 
    I am going along with the IP configured in `dnscrypt-proxy.service` after installation,
    which is Ubuntu's (non conventional) local resolver `127.0.2.1`
     
+   `https://blog.ipredator.se/ubuntu-dnscrypt-howto.html` didn't work for ubuntu 16.04 
    (at least for me), so I made a systemd+conf file version
    
+   putting all config files provided by IPredator into `conf/vendor`, just as a precaution
    for when they might change


### 2016-06-15

+   provisioning for ubuntu 14.04 randomly fails (openvpn dep is not installable, additional
    there a errors in apt-get key validity). therefore I switched to ubuntu 16.04, which needs
    latest virtualbox and vagrant version. The original box  
    [ubuntu/xenial64](https://atlas.hashicorp.com/ubuntu/boxes/xenial64) still not works, so I
    used the one from [bento](https://github.com/chef/bento)




// https://fabianlee.org/2017/05/21/golang-running-a-go-binary-as-a-systemd-service-on-ubuntu-16-04/
// https://blog.sgmansfield.com/2016/06/how-to-block-forever-in-go/
// https://guzalexander.com/2017/05/31/gracefully-exit-server-in-go.html
// https://stackoverflow.com/questions/36419054/go-projects-main-goroutine-sleep-forever
// https://medium.com/@kpbird/golang-gracefully-stop-application-23c2390bb212
// golang run infinite exit graceful
// https://github.com/golang/go/blob/master/src/net/http/server.go#L2864