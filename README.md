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

If you have a lot of crazy errors come up at the end, you might want to try re-creating your box. Do this using the commands:
```sh
$ vagrant destroy
$ vagrant up
```
When you open the new machine it will be locked. Hit enter and login with password: vagrant.
Open a terminal window on the machine that comes up and get to work:

```sh
$ sudo -s
$ mkdir /home/vagrant/xpTransfer
$ cd ~/xpTransfer
$ wget http://effbot.org/downloads/PIL-1.1.7.win32-py2.7.exe
$ wget https://www.python.org/ftp/python/2.7.9/python-2.7.9.msi
$ cp ../cuckoo/agent/agent.py .
$ /usr/lib/virtualbox/VirtualBox
```

### Set up XP box for analysis
You should be in **VirtualBox Manager** at this point.
1. Click File
2. Click Import Appliance
3. Input the following for the import path: /vagrant/vm/IE6.WinXP/IE6 - WinXP.ova NOTE: If the folder /vagrant/vm does not exist, go back to the terminal in the Linux VM and run:
```sh
$ sudo mkdir /vagrant/vm
$ cd /vagrant/vm
$ sudo curl -O https://az412801.vo.msecnd.net/vhd/VMBuild_20141027/VirtualBox/IE6/Mac/IE6.XP.For.Mac.VirtualBox.zip
$ unzip IE6.XP.For.Mac.VirtualBox.zip
```
Then try the import again.
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
4. Click Network Connections
5. Double click on Local Area Connection
6. Click Properties
7. Double click TCP/IP
8. Set the ip settings as follows for malwarrior: 

**IP address:** 192.168.56.130 

**Subnet Mask:** 255.255.255.0

**Default gateway:** 192.168.56.1

You can leave the DNS Server blank.

Lastly, we need to get the cuckoo agent, pil and python-2.7.9 installed.

1. Go to My Computer
2. Go to xpTransfer under Network Drives
3. Pull all three files to the Desktop
4. Double click python-2.7.9.msi and follow prompts to install
5. Double click PIL-1.1.7.win32-py2.7.exe and follow prompts to install
6. Double click agent.py - this will open a terminal window, leave it open

Go back to the VirtualBox Manager on the malwarrior machine
1. Click Snapshots
2. Ctrl-shift-s to take a snapshot, or click the camera
3. Rename the snapshot **Snapnum1** and click OK

###To create our snapshot for analysis
1. Power off the Windows machine
2. Click Restore Snapshot
3. Unclick Create Snapshot (do not create another) and click **Restore**

```sh
$ sudo -s
$ cd ~/cuckoo/conf
$ sublime cuckoo.conf
```

Set version_check = off

**Exit the file**
```sh
$ sublime kvm.conf
```

Set the following paramters like so:

[kvm]

\# Specify ...

machines = xp

This appears directly above the **label** field and may appear as **cuckoo1**:
[xp]

label = xp

(Obviously this will change depending on the IP of the machine you're on)
ip = 192.168.56.130

**Exit the file**

```sh
$ sublime virtualbox.conf
```

Set the following paramters like so:

machines = xp

This appears directly above the **label** field and may appear as **cuckoo1**:
[xp] 

label = xp

ip = 192.168.56.130

**Exit the file**

### Time to start Cuckoo

As root:

```sh
$ cd ~/cuckoo
$ python cuckoo.py
```

### Let's submit a file
Open a new tab

```sh
$ sudo -s
$ cd ~/cuckoo/utils
$ python submit.py <file name>
```

### To start the web server to view results

Open new tab

```sh
$ sudo -s
$ cd ~/cuckoo/utils/
$ python web.py
```

**Open web browser** and navigate to http://localhost:8080 to view the dashboard.

### To start the API server for REST interactions
Open new tab

```{.sh}
$ sudo -s
$ cd ~/cuckoo/utils/
$ python api.py
```

This will bind to port 8090

On the malwarrior machine, to get output from a submitted byte file: 

curl http://localhost:8090/tasks/report/1 > <output_name>.txt

Use this documentation for the commands:
http://cuckoo.readthedocs.org/en/latest/usage/api/


### API Script
This repo now has a simple script to pull and filter JSON information from
cuckoo's api. It is located in the `json_tools` directory. 


For running samples through cuckoo, put all the malware files in a directory
called `samples` in the cuckoo directory. Make a folder in samples called
`json` and another in `json` called `processed`.

You must modify the script at the following places with the correct
directories:

```{.sh}
## EDIT these paths
CUCKOOUTILS=/cuckoo/utils/
SAMPLEPATH=/cuckoo/samples/
```
Put the python script (`filter_json.py`) in the `json` folder and start the
cuckoo web api.

you can then run the script as: 

```{.sh}
sh get_json.sh
```

and modify as ness.

Resources
---

Cuckoo - https://github.com/cuckoobox/cuckoo

Vagrant - https://github.com/mitchellh/vagrant

David Reguera's Cuckoo Auto Install Script - https://github.com/buguroo/

License
----

Apache


