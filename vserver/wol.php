 <?php
 //
 // I have used the original PHP code from here:
 //
 // Version: 2
 // Author of this application:
 //	DS508_customer (http://www.synology.com/enu/forum/memberlist.php?mode=viewprofile&u=12636)
 //	Please inform the author of any suggestions on (the functionality, graphical design, ... of) this application.
 //	More info: http://wolviaphp.sourceforge.net
 // License: GPLv2.0
 //
 // many thanks for this starting point ;-)
 //
 $mac_address = "bc:5f:f4:7e:44:cc";  // SERVER
 $addr = "10.1.1.1";              // Adresse aus dem eigenen Segment, Router oder aktueller Rechner sind OK.
 $cidr = "24";                        // MASK: 255.255.255.0 ==> 24 (3 Byte * 8 Bit)
 $port = "9";                         // Bei mir ging auch 1 und 7, weitere ?
 //
 function WakeOnLan($mac_address, $addr, $cidr, $port)
 {
    // Prepare magic packet: part 1/3 (defined constant)
 	$buf="";
 	for($a=0; $a<6; $a++) $buf .= chr(255); // the defined constant as represented in hexadecimal: FF FF FF FF FF FF (i.e., 6 bytes of hexadecimal FF)
 	//Check whether $mac_address is valid
 	$mac_address=strtoupper($mac_address);
 	$mac_address=str_replace(":", "-", $mac_address);
 	if ((!preg_match("/([A-F0-9]{2}[-]){5}([0-9A-F]){2}/",$mac_address)) || (strlen($mac_address) != 17))
 	{
 		$error = "Input error: Pattern of MAC-address is not \"xx-xx-xx-xx-xx-xx\" (x = digit or letter).<br>\n";
 		return $error; // false
 	}
 	else
 	{
 		// Prepare magic packet: part 2/3 (16 times MAC-address)
 		$addr_byte = explode('-', $mac_address); // Split MAC-address into an array of (six) bytes
 		$hw_addr="";
 		for ($a=0; $a<6; $a++) $hw_addr .= chr(hexdec($addr_byte[$a])); // Convert MAC-address from bytes to hexadecimal to decimal
 		$hw_addr_string="";
 		for ($a=0; $a<16; $a++) $hw_addr_string .= $hw_addr;
 		$buf .= $hw_addr_string;
 	}
 	// Resolve broadcast address
 	if (filter_var ($addr, FILTER_VALIDATE_IP, FILTER_FLAG_IPV4)) // same as (but easier than):  preg_match("/\b(([01]?\d?\d|2[0-4]\d|25[0-5])\.){3}([01]?\d?\d|2[0-4]\d|25[0-5])\b/",$addr)
 	{
 		// $addr has an IP-adres format
 	}
 	else
 	{
 		// Whitespaces confuse name lookups
 		$addr=trim($addr);
 		// If you pass to gethostbyname() an:
 		//	unresolvable domainname, gethostbyname() returns the domainname (rather than 'false')
 		//	IP address, gethostbyname() returns that IP address.
 		if (gethostbyname($addr) == $addr)
 		{
 			// $addr is NOT a resolvable domainname
 			$error = "Input error: host name of broadcast address is unresolvable.<br>\n";
 			return $error; // false
 		}
 		else
 		{
 			// $addr IS a resolvable domainname
 			$addr = gethostbyname($addr);
 		}
 	}
 	// Store input value for cookie
 	$resolved_addr = $addr;
 	// If $cidr is set, replace $addr for its broadcast address
 	if ($cidr != "")
 	{
 		// Check whether $cidr is valid
 		if ((!ctype_digit($cidr)) || ($cidr < 0) || ($cidr > 32))
 		{
 			$error = "Input error: CIDR subnet mask is not a number within the range of 0 till 32.<br>\n";
 			return $error; // false
 		}
 		// Convert $cidr from one decimal to one inverted binary array
 		$inverted_binary_cidr="";
 		for ($a=0; $a<$cidr; $a++) $inverted_binary_cidr .= "0"; // Build $inverted_binary_cidr by $cidr * zeros (this is the mask)
 		$inverted_binary_cidr = $inverted_binary_cidr.substr("11111111111111111111111111111111",0,32-strlen($inverted_binary_cidr)); // Invert the mask (by postfixing ones to $inverted_binary_cidr untill 32 bits are filled/ complete)
 		$inverted_binary_cidr_array = str_split($inverted_binary_cidr); // Convert $inverted_binary_cidr to an array of bits
 		// Convert IP address from four decimals to one binary array
 		$addr_byte = explode('.', $addr); // Split IP address into an array of (four) decimals
 		$binary_addr="";
 		for ($a=0; $a<4; $a++) {
 			$pre = substr("00000000",0,8-strlen(decbin($addr_byte[$a]))); // Prefix zeros
 			$post = decbin($addr_byte[$a]); // Postfix binary decimal
 			$binary_addr .= $pre.$post;
 		}
 		$binary_addr_array = str_split($binary_addr); // Convert $binary_addr to an array of bits
 		// Perform a bitwise OR operation on arrays ($binary_addr_array & $inverted_binary_cidr_array)
 		$binary_broadcast_addr_array="";
 		for ($a=0; $a<32; $a++) $binary_broadcast_addr_array[$a] = ($binary_addr_array[$a] | $inverted_binary_cidr_array[$a]); // binary array of 32 bit variables ('|' = logical operator 'or')
 		$binary_broadcast_addr = chunk_split(implode("", $binary_broadcast_addr_array),8,"."); // build binary address of four bundles of 8 bits (= 1 byte)
 		$binary_broadcast_addr = substr($binary_broadcast_addr,0,strlen($binary_broadcast_addr)-1); // chop off last dot ('.')
 		$binary_broadcast_addr_array = explode(".", $binary_broadcast_addr); // binary array of 4 byte variables
 		$broadcast_addr_array="";
 		for ($a=0; $a<4; $a++) $broadcast_addr_array[$a] = bindec($binary_broadcast_addr_array[$a]); // decimal array of 4 byte variables
 		$addr = implode(".", $broadcast_addr_array); // broadcast address
 	}
 	// Check whether $port is valid
 	if ((!ctype_digit($port)) || ($port < 0) || ($port > 65536))
 	{
 		$error = "Input error: Port is not a number within the range of 0 till 65536.<br>\n";
 		return $error; // false
 	}
 	// Check whether UDP is supported
 	if (!array_search('udp', stream_get_transports()))
 	{
 		$error = "No magic packet can been sent, since UDP is unsupported (not a registered socket transport).<br>\n";
 		return $error; // false
 	}
 	if (function_exists('fsockopen'))
 	{
 		// Try fsockopen function - To do: handle error 'Permission denied'
 		$socket=fsockopen("udp://" . $addr, $port, $errno, $errstr);
 		if($socket)
 		{
 			$socket_data = fwrite($socket, $buf);
 			if($socket_data)
 			{
 				$function = "fwrite";
 //				$sent_fsockopen = "A magic packet of ".$socket_data." bytes has been sent via UDP to IP address: ".$addr.":".$port.", using the '".$function."()' function.<br>";
 				$sent_fsockopen = "OK (fsockopen)" ;
 //				$content = bin2hex($buf);
 //				$sent_fsockopen = $sent_fsockopen."Contents of magic packet:<br><textarea rows=\"1\" name=\"content\" cols=\"".strlen($content)."\">".$content."</textarea><br>\n";
 				fclose($socket);
 				unset($socket);
 				return $sent_fsockopen; // true
 			}
 			else
 			{
 				echo "Using 'fwrite()' failed, due to error: '".$errstr."' (".$errno.")<br>\n";
 				fclose($socket);
 				unset($socket);
 			}
 		}
 		else
 		{
 			echo "Using 'fsockopen()' failed, due to denied permission.<br>\n";
 			unset($socket);
 		}
 	}
 	// Try socket_create function
 	if (function_exists('socket_create'))
 	{
 		$socket = socket_create(AF_INET, SOCK_DGRAM, SOL_UDP); // create socket based on IPv4, datagram and UDP
 		if($socket)
 		{
 			$level = SOL_SOCKET; // to enable manipulation of options at the socket level (you may have to change this to 1)
 			$optname = SO_BROADCAST; // to enable permission to transmit broadcast datagrams on the socket (you may have to change this to 6)
 			$optval = true;
 			$opt_returnvalue = socket_set_option($socket, $level, $optname, $optval);
 			if($opt_returnvalue < 0)
 			{
 				$error = "Using 'socket_set_option()' failed, due to error: '".socket_strerror($opt_returnvalue)."'<br>\n";
 				return $error; // false
 			}
 			$flags = 0;
 			// To do: handle error 'Operation not permitted'
 			$socket_data = socket_sendto($socket, $buf, strlen($buf), $flags, $addr, $port);
 			if($socket_data)
 			{
 				$function = "socket_sendto";
 //				$socket_create = "A magic packet of ".$socket_data." bytes has been sent via UDP to IP address: ".$addr.":".$port.", using the '".$function."()' function.<br>";
 //				$content = bin2hex($buf);
 //				$socket_create = $socket_create."Contents of magic packet:<br><textarea rows=\"1\" name=\"content\" cols=\"".strlen($content)."\">".$content."</textarea><br>\n";
 				$socket_create = "OK (create)";
 				socket_close($socket);
 				unset($socket);
 				return $socket_create; // true
 			}
 			else
 			{
 				$error = "Using 'socket_sendto()' failed, due to error: '".socket_strerror(socket_last_error($socket))."' (".socket_last_error($socket).")<br>\n";
 				socket_close($socket);
 				unset($socket);
 				return $error; // false
 			}
 		}
 		else
 		{
 			$error = "Using 'socket_create()' failed, due to error: '".socket_strerror(socket_last_error($socket))."' (".socket_last_error($socket).")<br>\n";
 			return $error; // false
 		}
 	}
 	else
 	{
 		$error = "No magic packet has been sent, since no functions are available to transmit it.<br>\n";
 		return $error; // false
 	}
 }
 //
 $Return_WakeOnLan = WakeOnLan($mac_address, $addr, $cidr, $port); // executes this function
 //
 ?>
  <!DOCTYPE HTML>
  <HTML>
   <HEAD>
    <meta name="robots" content="noindex">
    <meta http-equiv="expires" content="0">
    <TITLE>Server starten ... Ergebnis ;-)</TITLE>
   </HEAD>
   <BODY BGCOLOR="#CCFFFF" TEXT="#000000" LINK="#FF0000" VLINK="#800000" ALINK="#FF00FF" BACKGROUND="?">
    <P>Der Startbefehl an den Server wurde erteilt und er sollte in wenigen Minuten verfügbar sein.
    <P>Bitte prüfen Sie über die Links, ob der Server schon verfügbar ist, eventuelle Fehler werden gemeldet.<br>
       Es kann aber sein, dass er nur im LAN verfügbar ist, daher noch die zweite Abfrage.</p>
    <?php
     echo "Rückmeldung:   ",$Return_WakeOnLan;
     $TimeStamp = time();
     $datum = date("d.m.Y",$timeStamp);
     $uhrzeit = date("H:i:s",$TimeStamp);
     echo "   ",$datum," - ",$uhrzeit," Uhr";
    ?>
    <p>
    <A HREF="index.html">zurück zur Auswahl</A>
   </BODY>
  </HTML>
