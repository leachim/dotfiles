#!/bin/bash
# Warning: This script directy edits some configuration files that may
# render your OS unusable if there is an error. Use at your own risk.

############ CONFIGURATION ################
###########################################
###### SSH service port
port=22
username=username

##### server IP
#echo "Please enter server ip"
#sleep 3
#read SERVER_IP

#### email for logwatch updates
#email=unknown@mail.nl

###########################################
###########################################

echo "Setting up server. You need to have root access."
sleep 3

echo "ALERT! Ypu are entering into a secured area! Your IP, Login Time, Username has been noted and has been sent to the server administrator! This service is restricted to authorized users only. All activities on this system are logged. Unauthorized access will be fully investigated and reported to the appropriate law enforcement agencies." > /etc/issue.net

echo "Installing Software .."
apt-get update
apt-get upgrade -y
#apt-get install ufw vim tmux fail2ban unattended-upgrades -y
apt-get install tmux fail2ban ufw vim unattended-upgrades denyhosts dstat git iptables logwatch rkhunter curl shorewall rsync -y
# apt-get install fail2ban mosh ufw vim unattended-upgrades -y
# selinux-basics selinux-policy-default selinux-utils

## USER
echo "User settings"
useradd $username
mkdir /home/$username
mkdir /home/$username/.ssh
chmod 700 /home/$username/.ssh
chsh -s /bin/bash $username
cp .bashrc .profile /home/$username
 
cp /root/.ssh/authorized_keys /home/$username/.ssh/authorized_keys
chmod 400 /home/$username/.ssh/authorized_keys
chown $username:$username /home/$username -R
 
#echo "Set password for user $username"
#passwd $username
echo "Disable password login for user $username"
passwd --lock $username

## SUDO
cat << EOF > /etc/sudoers
Defaults        env_reset
Defaults        mail_badpass
Defaults        secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
 
root    ALL=(ALL:ALL) ALL
$username  ALL=(ALL:ALL) ALL
EOF
 
## SSH
echo "ssh configuration"
cat << EOF > /etc/ssh/sshd_config
Port $port
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_dsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
UsePrivilegeSeparation yes
KeyRegenerationInterval 3600
ServerKeyBits 2048
SyslogFacility AUTH
LogLevel INFO
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
RSAAuthentication no
PubkeyAuthentication yes
IgnoreRhosts yes
RhostsRSAAuthentication no
HostbasedAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
PasswordAuthentication no
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
AcceptEnv LANG LC_*
MaxAuthTries 5
MaxSessions 10
#AllowUsers $username@(your-ip) username@(another-ip-if-any)
Subsystem sftp /usr/lib/openssh/sftp-server
UsePAM yes
EOF

#systemctl restart sshd 
/etc/init.d/ssh restart

## FIREWALL
echo "firewall setup"
ufw allow $port
ufw allow 80
ufw allow 443
ufw allow 60000:61000/udp
ufw --force enable
 
## Unattended upgrades
cat << EOF > /etc/apt/apt.conf.d/10periodic
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Download-Upgradeable-Packages "1";
APT::Periodic::AutocleanInterval "7";
APT::Periodic::Unattended-Upgrade "1";
EOF
 
cat << EOF > /etc/apt/apt.conf.d/50unattended-upgrades 
Unattended-Upgrade::Allowed-Origins {
        "${distro_id} stable";
        "${distro_id} stable-security";
};
EOF


## Logwatch
#vim /etc/cron.daily/00logwatch
#/usr/sbin/logwatch --output mail --mailto $email --detail high


## iptables/firewall
# this has already been solved by using ufw
## My system IP/set ip address of server

### set iptable/firewall
##SERVER_IP="65.55.12.13"

### Flushing all rules
#iptables -F
#iptables -X
### Setting default filter policy
#iptables -P INPUT DROP
#iptables -P OUTPUT DROP
#iptables -P FORWARD DROP
### Allow unlimited traffic on loopback
#iptables -A INPUT -i lo -j ACCEPT
#iptables -A OUTPUT -o lo -j ACCEPT
 
### Allow incoming ssh only
#iptables -A INPUT -p tcp -s 0/0 -d $SERVER_IP --sport 513:65535 --dport $port -m state --state NEW,ESTABLISHED -j ACCEPT
#iptables -A OUTPUT -p tcp -s $SERVER_IP -d 0/0 --sport $port --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT
## make sure nothing comes or goes out of this box
#iptables -A INPUT -j DROP
#iptables -A OUTPUT -j DROP

### Allow incoming ssh only from IP 202.54.1.20
##iptables -A INPUT -p tcp -s 202.54.1.20 -d $SERVER_IP --sport 513:65535 --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT
##iptables -A OUTPUT -p tcp -s $SERVER_IP -d 202.54.1.20 --sport 22 --dport 513:65535 -m state --state ESTABLISHED -j ACCEPT
