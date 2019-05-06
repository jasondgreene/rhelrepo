#!/bin/bash
# Ugly script to create repos for RHEL7
# Jason Greene
#
rpm -qa | grep -qw yum-utils || yum -y install yum-utils
rpm -qa | grep -qw httpd || yum -y install httpd
systemctl is-active --quiet httpd || systemctl start httpd
mkdir -p /var/www/html/repos/{rhel-7-server-rpms,rhel-7-server-extras-rpms,rhel-7-server-optional-rpms,rhel-7-server-supplementary-rpms,epel}
yum-config-manager --enable {rhel-7-server-rpms,rhel-7-server-extras-rpms,rhel-7-server-optional-rpms,rhel-7-server-supplementary-rpms}
echo '========================================================'
echo 'Installing EPEL'
cd /tmp
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install epel-release-latest-7.noarch.rpm
echo '========================================================'
yum repolist all | grep enabled


echo 'Syncing Repos Now'
echo '========================================================'
reposync -g -l -d -m --repoid=rhel-7-server-rpms --newest-only --download-metadata --download_path=/var/www/html/repos/
reposync -g -l -d -m --repoid=rhel-7-server-extras-rpms --newest-only --download-metadata --download_path=/var/www/html/repos/
reposync -g -l -d -m --repoid=rhel-7-server-optional-rpms --newest-only --download-metadata --download_path=/var/www/html/repos/
reposync -g -l -d -m --repoid=rhel-7-server-supplementary-rpms --newest-only --download-metadata --download_path=/var/www/html/repos/
reposync -g -l -d -m --repoid=epel --newest-only --download-metadata --download_path=/var/www/html/repos/
echo '========================================================'
echo 'Creating Repos'
echo '========================================================'
createrepo -g comps.xml /var/www/html/repos/{rhel-7-server-rpms,rhel-7-server-extras-rpms,rhel-7-server-optional-rpms,rhel-7-server-supplementary-rpms,epel}
echo '========================================================'
echo 'Done'
ls /var/www/html/repos
