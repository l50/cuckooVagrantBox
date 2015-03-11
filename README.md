# Cuckoo Vagrant Box
This is used to build a cuckoo vm which can be used for malware analysis.

## Prerequisites
1. Download vagrant from here: http://www.vagrantup.com/downloads.html
2. To install on a debian-based platform, use dpkg -i
3. Download and install Virtual Box from here: https://www.virtualbox.org/wiki/Downloads

### UNM specific instructions:
Set up VNC and get access to a trucks machine. If VNC is too painful to use then give TeamViewer a shot by setting it up on the malwarrior box:
```sh
$ vagrant ssh
$ wget http://www.teamviewer.com/download/teamviewer_linux.deb
$ sudo dpkg --add-architecture i386
$ sudo apt-get update
$ sudo apt-get install gdebi
$ sudo gdebi teamviewer_linux.deb
```

### Installation of a cuckoo box
```sh
$ git clone https://github.com/l50/cuckooVagrantBox.git
$ cd cuckooVagrantBox
$ vagrant plugin install vagrant-puppet-install
$ vagrant up
```
Wait while the VM is downloaded, which could take a bit of time. Eventually, the machine will boot and it will begin the configuration of cuckoo with all of its dependencies utilizing puppet and this script (which has been modified) - https://github.com/buguroo/cuckooautoinstall

If you're on the CS machines you will get an error. No worries.
Open the VirtualBox GUI and uncheck 3D acceleration under the graphics settings for the machine. Go ahead and hook the machine up with 4 cores and 4096 MB of RAM while you're in there. Finally, run:
```sh
$ vagrant up
```

If you have not already modified the resources of the machine, once it is finished building (you might get an SSH timeout, who knows why), go to the open GUI window and shut down the machine. Hook the machine up with 4 cores and 4096 MB of RAM and reboot the machine with the **vagrant up** command. Open a terminal window and get to work:

```sh
$ sudo -s
# mkdir /home/vagrant/xpTransfer
# mkdir /vagrant/vm
# unzip ~/IE6.XP.For.Mac.VirtualBox.zip -d /vagrant/vm
# /usr/lib/virtualbox/VirtualBox
```

### Set up XP box for analysis
You should be in **VirtualBox Manager** at this point.
1. Click File
2. Click Import Appliance
3. Input the following for the import path: /vagrant/vm/IE6.WinXP/IE6 - WinXP.ova
4. Click import
5. Go into the settings for the box
6. Change the name to **xp**
7. Upgrade the RAM to 1024 MB
8. Change Adapter 1 to Host-only in vboxnet0
9. Create shared folder at /home/vagrant/xpTransfer, tick auto mount
10. Start the VM

### Configure XP box
1. Click start
2. Click Control Panel
3. Turn off Windows Firewall
4. Set the ip settings as follows for malwarrior: 

**IP address:** 192.168.56.130 

**Subnet Mask:** 255.255.255.0

**Default gateway:** 192.168.56.1

You can leave the DNS Server blank.

Lastly, we need to get the cuckoo agent, pil and python-2.7.9 installed.

**Go to the malwarrior box**
```sh
$ sudo -s
# cd ~/xpTransfer
# wget http://effbot.org/downloads/PIL-1.1.7.win32-py2.7.exe
# wget https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi
# cp ../cuckoo/agent/agent.py
```
** Go back to the windows box**

Go to My Computer
Go to xpTransfer under Network Drives
Pull all three files to the Desktop
1. Run python-2.7.9.smi
2. Run PIL-1.1.7.win32-py2.7.exe
3. Run agent.py

License
----

Apache
