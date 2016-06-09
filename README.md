btfs dl vm
==========


### Why?
+   originally the intension was to have a very simple, convenient and sort of containerized thing, that downloads arbitrary torrent content in a fully automated way. One could say, it is a *headless bulk downloader for torrents*. And it was intended to make my first steps in the golang world


### Features
+   opening up a VPN connection to IPredator
+   watching for torrent files, downloading their content and share it with the host system


### Components
+   [btfs](https://github.com/johang/btfs)
+   [OpenVPN]()
+   [ferm]()
+   DNScrypt


### Dependencies
+   vagrant
+   virtualbox
+   ubuntu box


### Worth noticing
+   the provisioning is heavily based on [IPredator HOWTOs](https://blog.ipredator.se/howto.html)


### Future Works
+   remove the hard-coded IPredator support, to enable other VPN providers
+   support magnet links (not only torrent files)
+   check for version of files loaded from IPredator