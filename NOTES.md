


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
