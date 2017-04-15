# Modbus-Tcl Design Documentation

So, it seems I'm going to create a Modbus library for Tcl so I can control the VFD on my CNC router.

## Architecture:

 - A Tcl package for Modbus communication
 - An SQLite database of Modbus device types, including what various registers do, allowing a uniform device-independent abstraction layer to be created.
 - A Tcl script that runs under haltcl that mediates between LinuxCNC/HAL and the Modbus device. It should be OK for this to be a userspace/loadusr component.
 - An INI file for easier user setting of the Modbus connection and device parameters.

## Modbus overview:

Modbus is a ...  All devices on a bus must share the same communication settings.

Modbus transactions are request-response ("query" and "response" in the spec), and are always initiated by the bus master (of which there can be only one).  Slave devices only speak when spoken to.  Broadcast messages are possible from the master, but slaves do not respond to these.

Messages consist of a device (or broadcast) address, a function code (command type), data (payload, function-dependent format), and an error-checking field.  Responses from slaves use the same message format.

Owing to its 1970s origins, Modbus does not have provision for certain "modern" data types, or for slaves to report their capabilities (units, scaling factors, etc.).


### Modbus bus types:

 - ASCII serial
 - binary serial (RTU)
 - TCP
 - Ethernet? I've seen mention of it but wonder if it's just a misnomer for TCP

### Modbus message types:

03	0x03	read_holding_register_group
	0x10	write_register_group

** byte-count sub-field?


### Error detection and reporting:

There are several aspects to this:
 - Serial-level parity per character/byte
 - Timing: slave response timeout, master/slave per-character timeout (note that in ASCII mode, relatively long inter-character delays are permitted)
 - Frame-level LRC/CRC error-checking (trailing field)
 - Function codes indicating error conditions (from slave)

0x83 function code


### Terminology
	coil
	holding register


### Conformance Classes

Some useful extra information here on Conformance Classes and other

<http://www.rtaautomation.com/technologies/modbus-tcpip/>

Conformance_Class >---< Function_Code ?

Or perhaps every Class implies that all lower classes must also support it, in which case:

Function_Code >---- Conformance_Class

(Note: transaction type = function (code))

Level 0 is universally supported. Might also be useful to flag non-interoperable (device-dependent) function codes.

Modbus/TCP?  Note that the message format is a little different, with Unit Identifier replacing Slave Address (used for interacting with network infrastructure).

Can exceptions be recognised by examining a single bit in the response?  It has the effect of adding 0x80 to the function code of the request.  So, yes - the most significant bit is set if it is an exception response.  The remaining bits identify the function code being responded to.

Note timing: some PLCs will buffer incoming messages and scan periodically, perhaps on a 20..200 ms cycle time.  So, it would be reasonable to wait up to maybe 500 ms for a response?  Perhaps the timeout should be able to be specified for each connection (or bus?).  Clearly, what's reasonable will be situation-dependent, so it probably won't work to have one size fits all.  Certainly the modbus library in Tcl-measure has timeout as a property.
