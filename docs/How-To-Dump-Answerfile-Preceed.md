### Centos
- cat /root/anaconda-ks.cfg
### Debian/Ubuntu
1. cat /var/log/installer/cdebconf/questions.dat
2. install `debconf-utils` and run `debconf-get-selections -installer` to dump preseed
