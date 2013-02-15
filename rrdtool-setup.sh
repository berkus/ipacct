#!/bin/sh

. /etc/ipacct.conf

# 26784 = 93 days
rrdtool create ${RRDFILE} -s 300 DS:InBytes:COUNTER:600:0:U  \
                                 DS:OutBytes:COUNTER:600:0:U \
				 RRA:AVERAGE:0.5:1:600       \
				 RRA:MAX:0.5:1:600           \
                                 RRA:LAST:0.5:1:600
#26784
