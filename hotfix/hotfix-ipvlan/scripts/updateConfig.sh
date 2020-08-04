#!/bin/sh
/usr/sbin/sysctl -w net.ipv4.vs.conn_reuse_mode=1
# 如果压测出现客户端分配不到端口可以改成2
EOF

chmod +x /root/set-ipvs-sysctls.sh

echo '*/1 * * * * root bash /root/set-ipvs-sysctls.sh' >> /etc/cron.d/setsysctl

systemctl reload crond
systemctl restart crond