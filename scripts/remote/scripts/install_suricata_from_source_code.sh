#!/bin/bash
latest=$(curl https://github.com/OISF/suricata/releases/latest | grep -o 'https://[^"]*')
echo "Latest github release: $latest"
version=$(echo $latest | rev | cut -d "/" -f 1 | rev)
download_link="https://www.openinfosecfoundation.org/download/$version.tar.gz"
echo "Will download from: $download_link"
wget --no-check-certificate $download_link
filename="$version.tar.gz"
tar xvzf $filename
# name of folder is suricata-X.X.X , that is the version
cd $version
sudo ./configure -prefix=/usr -sysconfdir=/etc && make && make install-full
sudo adduser suri
sudo addgroup suri
sudo adduser suri suri
sudo mkdir /var/log/suricata
sudo chown -R suri:suri /var/log/suricata/
# LD_LIBRARY_PATH=/usr/local/lib /usr/local/bin/suricata -c /etc/suricata/suricata.yaml -i any -l /var/log/suricata –user=suri –group=suri -D
