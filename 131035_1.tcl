#Lan simulation
set ns [new Simulator]

#defining color for data flows
$ns color 1 Blue
$ns color 2 Red
$ns color 3 Green

#opening trace files
set tracefile1 [open out.tr w]
set winfile [open winfile w]
$ns trace-all $tracefile1

#opening nam file
set namfile [open out.nam w]
$ns namtrace-all $namfile
proc finish {} {
global ns tracefile1 namfile
$ns flush-trace
close $tracefile1
close $namfile
exec nam out.nam &
exit 0
}

#creating ten nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]
set n10 [$ns node]

#creating links between the nodes
$ns duplex-link $n0 $n1 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n0 $n3 2Mb 10ms DropTail
$ns duplex-link $n3 $n2 2Mb 10ms DropTail
$ns duplex-link $n4 $n5 2Mb 10ms DropTail
$ns duplex-link $n4 $n6 2Mb 10ms DropTail
$ns duplex-link $n5 $n6 2Mb 10ms DropTail
$ns duplex-link $n6 $n7 2Mb 10ms DropTail
$ns duplex-link $n6 $n8 2Mb 10ms DropTail
$ns duplex-link $n9 $n10 2Mb 10ms DropTail

set lan [$ns newLan "$n2 $n9 $n4" 0.5Mb 40ms LL Queue/DropTail MAC/Csma/Cd Channel]

#setting positions 
$ns duplex-link-op $n0 $n1 orient down
$ns duplex-link-op $n1 $n2 orient right
$ns duplex-link-op $n0 $n3 orient right
$ns duplex-link-op $n3 $n2 orient down
$ns duplex-link-op $n4 $n5 orient left-up
$ns duplex-link-op $n4 $n6 orient right-up
$ns duplex-link-op $n5 $n6 orient right-down
$ns duplex-link-op $n6 $n7 orient right-down
$ns duplex-link-op $n6 $n8 orient right-up
$ns duplex-link-op $n9 $n10 orient down

#set queue size of links to 20
$ns queue-limit $n0 $n1 20
$ns queue-limit $n1 $n2 20
$ns queue-limit $n0 $n3 20
$ns queue-limit $n3 $n2 20
$ns queue-limit $n4 $n5 20
$ns queue-limit $n4 $n6 20
$ns queue-limit $n5 $n6 20
$ns queue-limit $n6 $n7 20
$ns queue-limit $n6 $n8 20
$ns queue-limit $n9 $n10 20


#set up TCP connection
set tcp [new Agent/TCP/Newreno]
$ns attach-agent $n2 $tcp
set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set packet_size_ 552
set ftp [new Application/FTP]
$ftp attach-agent $tcp

#setup a UDP0 connection
set udp0 [new Agent/UDP]
$ns attach-agent $n1 $udp0
set null [new Agent/Null]
$ns attach-agent $n10 $null
$ns connect $udp0 $null
$udp1 set fid_ 2

#setup a CBR0 over UDP0 connection
set cbr0 [new Application/Traffic/CBR]
$cbr1 attach-agent $udp0
$cbr1 set type_ CBR
$cbr1 set packet_size_ 1000
$cbr1 set rate_ 0.01Mb
$cbr1 set random_ false

#setup a UDP1 connection
set udp1 [new Agent/UDP]
$ns attach-agent $n8 $udp1
set null [new Agent/Null]
$ns attach-agent $n0 $null
$ns connect $udp1 $null
$udp2 set fid_ 3

#setup a CBR1 over UDP1 connection
set cbr1 [new Application/Traffic/CBR]
$cbr2 attach-agent $udp1
$cbr2 set type_ CBR
$cbr2 set packet_size_ 1000
$cbr2 set rate_ 0.01Mb
$cbr2 set random_ false

#scheduling the events
$ns at 0.1 "$cbr0 start"
$ns at 0.5 "$cbr1 start"
$ns at 1.0 "$ftp start"
$ns at 124.0 "$ftp stop"
$ns at 125.0 "$cbr1 stop"
$ns at 125.5 "$cbr0 stop"
proc plotWindow {tcpSource file} {
global ns
set time 0.1
set now [$ns now]
set cwnd [$tcpSource set cwnd_]
puts $file "$now $cwnd"
$ns at [expr $now+$time ] "plotWindow $tcpSource $file"
}
$ns at 0.1 "plotWindow $tcp $winfile"
$ns at 125.0 "finish"
$ns run
