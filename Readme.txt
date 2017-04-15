Well, it looks like there's enough information to record to justify using a database for this!  For the database model, something like:

Bus_Type --< Bus --< Device >-- Device_Type --< Device_Type_Register >-- Register_Type

Bus_Type would be one of ASCII, RTU (binary), TCP, or perhaps we'd need separate subtype tables to handle the different attributes (e.g. IP address of slave device)

Bus would need things like device name (e.g. /dev/ttyUSB0 for serial), serial parameters, name.

We're only interested in buses attached to a single Tcl instance, and much of the data will be nonpersistent, so names can be short 'n' friendly.

	Actually, will the strange mix of persistent and nonpersistent data be a nuisance?  Might it actually be handy to have "live" settings stored for future reference? How hard to "resurrect" those nominally-non-persistent objects?

I was originally thinking that using a database (SQLite) would be overkill, but actually it would make for a nice way to configure devices and set up new device types (use an SQLite manager GUI app).

NOTE: see existing code on my LinuxCNC machine for an ongoing initial implementation

