#!/usr/bin/env ruby

require "mysql"
require "net/netmask"

accounts = {
    'redcat'=>{'target_ip'=>Netmask.new('192.168.0.2/32').to_i, 'eth_out'=>0},
    'mike'=>{'target_ip'=>Netmask.new('192.168.0.3/32').to_i, 'eth_out'=>0},
    'berkus'=>{'target_ip'=>Netmask.new('212.220.206.98/32').to_i, 'eth_out'=>-1},
    'ru'=>{'target_ip'=>Netmask.new('192.168.0.4/32').to_i, 'eth_out'=>0},
}

user = 'mike'


begin
    acc = accounts[user]

    # connect to the MySQL server
    dbh = Mysql.real_connect("localhost", "trafficmeter", "measureme", "eth_traffic")

    query = "SELECT SUM(bytes) AS total FROM rawdata 
             WHERE stamp>=20040801000000 AND stamp<20040901000000 
	     AND source_ip=0
	     AND target_ip=#{acc['target_ip']} 
	     AND eth_in=1
	     AND eth_out=#{acc['eth_out']}"

    puts "Incoming bytes for #{user}:"
    res = dbh.query("#{query}")
    res.each do |row|
	printf "%s bytes\n\n", row[0]
    end
    res.free

rescue MysqlError => e
    print "MySQL connect error"
    print "Error code: ", e.errno, "\n"
    print "Error message: ", e.error, "\n"
ensure
    # disconnect from server
    dbh.close
end
