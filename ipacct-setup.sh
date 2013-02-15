#!/bin/sh

. /etc/ipacct.conf

# Set up iptables accounting rules
${IPTABLES} -F ${ACCT}
${IPTABLES} -D INPUT -j ${ACCT}
${IPTABLES} -D OUTPUT -j ${ACCT}
${IPTABLES} -D FORWARD -j ${ACCT}

${IPTABLES} -N ${ACCT}
${IPTABLES} -I INPUT -j ${ACCT}
${IPTABLES} -I OUTPUT -j ${ACCT}
${IPTABLES} -I FORWARD -j ${ACCT}

# Count everything that goes off of this box into the wild
${IPTABLES} -I ${ACCT} -o ${IP_ETH} -s ${IP} -d 0/0
${IPTABLES} -I ${ACCT} -i ${IP_ETH} -s 0/0 -d ${IP}

for DOWNLINK in ${DOWNLINKS}; do
    # Count what goes on internal network
    ${IPTABLES} -I ${ACCT} -o ${LOCALIP_ETH} -s ${LOCALIP} -d ${DOWNLINK}
    ${IPTABLES} -I ${ACCT} -i ${LOCALIP_ETH} -s ${DOWNLINK} -d ${LOCALIP}

    # Count what goes through our box for downlink
    ${IPTABLES} -I ${ACCT} -i ${LOCALIP_ETH} -s ${DOWNLINK} -o ${IP_ETH} -d 0/0
    ${IPTABLES} -I ${ACCT} -i ${IP_ETH} -s 0/0 -o ${LOCALIP_ETH} -d ${DOWNLINK}
done
