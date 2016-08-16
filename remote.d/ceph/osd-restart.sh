SERVICE=$(systemctl | grep 'ceph-osd@' | grep running | awk '{print $1}')
systemctl restart $SERVICE
