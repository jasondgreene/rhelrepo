#!/bin/bash
# Ugly script to create repos for RHEL7
# Jason Greene
#
# Check for yum-utils and install if needed
rpm -qa | grep -qw yum-utils || yum -y install yum-utils
# Check for httpd and install if needed
rpm -qa | grep -qw httpd || yum -y install httpd
systemctl is-active --quiet httpd || systemctl start httpd
mkdir -p /var/www/html/repos/{rhel-7-server-rpms,rhel-7-server-extras-rpms,rhel-7-server-optional-rpms,rhel-7-server-supplementary-rpms,epel}
yum-config-manager --enable {rhel-7-server-rpms,rhel-7-server-extras-rpms,rhel-7-server-optional-rpms,rhel-7-server-supplementary-rpms}
echo '========================================================'
echo 'Installing EPEL'
rpm -qa | grep -qw epel-release || rpm -ivh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm ; rpm --import http://dl.fedoraproject.org/pub/epel/RPM-GPG-KEY-EPEL-7 ; rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep EPEL
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
# Create repos
createrepo -g comps.xml /var/www/html/repos/rhel-7-server-rpms
createrepo -g comps.xml /var/www/html/repos/rhel-7-server-extras-rpms
createrepo -g comps.xml /var/www/html/repos/rhel-7-server-optional-rpms
createrepo -g comps.xml /var/www/html/repos/rhel-7-server-supplementary-rpms
createrepo -g comps.xml /var/www/html/repos/epel
# allow httpd through firewall
firewall-cmd --permanent --add-service=http
echo '========================================================'
echo 'Done'
