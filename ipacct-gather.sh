#!/bin/sh
# Gather ipacct info
# Run from crontab:
# */5 * * * * /path/to/ipacct-gather.sh

. /etc/ipacct.conf

${IPTABLES} -vxnL -Z ${ACCT} | ruby -e '

require "mysql"
require "net/netmask"

flag = false

begin
    # connect to the MySQL server
    dbh = Mysql.real_connect("localhost", "trafficmeter", "measureme", "eth_traffic")

    query = "INSERT INTO rawdata (stamp, bytes, eth_in, eth_out, source_ip, target_ip) VALUES "
    q2 = ""

    readlines.each { |line|
	flag = false if line =~ /^Zeroing/

	if flag
	    dat = line.split
	    
	    eth_in  = dat[4].gsub(/^eth(\d+)$/, "\\1").gsub(/^\*$/, "-1").to_i
	    eth_out = dat[5].gsub(/^eth(\d+)$/, "\\1").gsub(/^\*$/, "-1").to_i

	    source_ip = Netmask.new(dat[6]).to_i
	    target_ip = Netmask.new(dat[7]).to_i

	    q2 << "," if q2.length > 0
	    q2 << "(NOW(), #{dat[1]}, #{eth_in}, #{eth_out}, #{source_ip}, #{target_ip})"
	end
    
	flag = true if line =~ /^[[:space:]]+pkts.+$/
    }

    if q2.length > 0
	dbh.query("#{query}#{q2}")
    end    

rescue MysqlError => e
    print "MySQL connect error"
    print "Error code: ", e.errno, "\n"
    print "Error message: ", e.error, "\n"
ensure
    # disconnect from server
    dbh.close
end

'
