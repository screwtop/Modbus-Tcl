# Modbus-Tcl, a Tcl package for Modbus communication

Author (2017-): Chris Edwards


## Overview

Modbus-Tcl is a Tcl package for interacting with Modbus industrial control and automation devices. It started out due to the author's need for a LinuxCNC component that could control the spindle motor VFD on his CNC router. It seemed reasonable to try to generalise the Modbus functions and device descriptions to support a variety of slave devices.

Tcl's channel infrastructure, event processing, and exception capabilities should make this sort of "glue" fairly easy and robust. One specific use case is to handle Linux reconnecting the underlying serial device due to excessive errors due to EMI.  One limitation of a C program using libmodbus is that if a serial device reconnects, the new device will likely have a different device name and the Modbus connection will be lost (and libmodbus does not appear to support /dev/serial/by-id/ paths).

An SQLite database is used to record information about Modbus generally, specific device types/families and how their registers are to be interpreted.  The idea is to allow new device types to be defined and used easily, without the need to compile new components.

The package aims to permit simple high-level scripted usage such as the following example (API not finalised yet!):

package require Modbus
::modbus::connect vfd 1 /dev/ttyUSB0 ASCII 9600 8 N 1
# or maybe:
::modbus::bus router /dev/ttyUSB0 ASCII 9600 8 N 1
::modbus::slave vfd router 1 Delta VFD-M
# or
router slave 1 vfd Delta VFD-M
# and then:
vfd query temperature
vfd set spindle-speed 15000
vfd close/disconnect/::modbus::disconnect vfd


## Dependencies

 - Linux, probably (untested elsewhere)
 - Tcl 8.5 or later
 - Tk (for GUI)?
 - SQLite3 (sqlite3 command-line program and libsqlite3-dev package for Tcl)
 - Modbus hardware (e.g. USB to RS-485 adapter with an attached slave device)

Also suggested:

 - SQLite3 browser/manager/GUI (sqlitebrowser, sqliteman)
 - LinuxCNC (for machine motion control)
 

## Dev Notes

Well, it looks like there's enough information to record to justify using a database for this!  For the database model, something like:

Bus_Type --< Bus --< Device >-- Device_Type --< Device_Type_Register >-- Register_Type

Bus_Type would be one of ASCII, RTU (binary), TCP, or perhaps we'd need separate subtype tables to handle the different attributes (e.g. IP address of slave device)

Bus would need things like device name (e.g. /dev/ttyUSB0 for serial), serial parameters, name.

We're only interested in buses attached to a single Tcl instance, and much of the data will be nonpersistent, so names can be short 'n' friendly.

	Actually, will the strange mix of persistent and nonpersistent data be a nuisance?  Might it actually be handy to have "live" settings stored for future reference? How hard to "resurrect" those nominally-non-persistent objects?

I was originally thinking that using a database (SQLite) would be overkill, but actually it would make for a nice way to configure devices and set up new device types (use an SQLite manager GUI app).

NOTE: see existing code on my LinuxCNC machine for an ongoing initial implementation

Where to put the database file?  Under the user's linuxcnc dir?  In a system-wide linuxcnc-related path?  Somewhere configurable?

NOTE: SQLite3 3.7.13 doesn't recognise hexadecimal strings a la '0x2102'.  This is unfortunate, as this is the version bundled with the current (2.7.8) version of LinuxCNC.  3.8.7.1 is fine with them.

	Could we define an SQLite function to convert from a hex string to an integer? Modbus device docs often give the register addresses in hex, so it would be nice to be able to enter these fairly directly.

		Well, SQLite has no built-in facilities for defining additional functions. But maybe use create_function() in the Python binding...
		

import sqlite3

def hex2int(hex_string):
	return int(hex_string,0)

con = sqlite3.connect("/tmp/modbus.sqlite3")
con.create_function("hex2int", 1, hex2int)

cur = con.cursor()
cur.execute("select hex2int(?)", ("0xff",))
print cur.fetchone()[0]

		Bah, only that only exists within that Python environment - it can't be called from SQL from other contexts.
