#!/usr/bin/rrdcgi
<HTML>
<HEAD><TITLE>Traffic info</TITLE></HEAD>
<BODY>
<H1>rage Traffic Info</H1>
<P>
<RRD::GRAPH traffic.png --lazy 
      -w 450 -h 150 --interlaced -t "Traffic info" -v "Bytes"
      DEF:I=/var/lib/ipacct/ipacct.rrd:InBytes:AVERAGE AREA:I#0000FF:Input
      DEF:O=/var/lib/ipacct/ipacct.rrd:OutBytes:AVERAGE AREA:O#00FF00:Output
      GPRINT:I:LAST:"(current=%.0lf"
      GPRINT:I:AVERAGE:"ave=%.0lf"
      GPRINT:I:MAX:"max=%.0lf)">
</P>
</BODY>
</HTML>
