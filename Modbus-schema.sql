-- Database schema for my Modbus library (Tcl, but ideally the database could be independent)
-- NOTE: if testing on NFS, try "sqlite3 --vfs unix-dotfile modbus.sqlite3" to avoid locking issues.

-- TODO: table of Modbus function codes, table of support for function codes in device types.


drop table if exists Device;
drop table if exists Bus;
drop table if exists Bus_Type;
--drop table if exists Device_Type_Register_Field;
drop table if exists Register_Type;
drop table if exists Parameter;
drop table if exists Device_Type_Function;
drop table if exists Device_Type_Register;
drop table if exists Device_Type;
drop table if exists Vendor;
drop table if exists Function_Code;
drop table if exists Exception_Code;
drop table if exists Diagnostic_Code;
drop table if exists Conformance_Class;
drop table if exists Unit;
drop table if exists Physical_Quantity;


create table Physical_Quantity
(
	Physical_Quantity varchar,

	constraint Physical_Quantity_PK primary key (Physical_Quantity)
);

-- Physical units that might be used in reporting/specifying operational characteristics of a Modbus device, e.g. temperature in degrees Celsius, 
-- Unit/Physical_Unit/Unit_of_Measurement?
create table Unit
(
	Name                varchar,	-- or Unit_Name?
	Symbol              varchar,
	Physical_Quantity   varchar,	-- e.g. mass, power, etc.  And a separate table for these!

	-- Hmm, maybe it would be preferable to use the symbol as the PK, since it's more concise.
	constraint Unit_PK primary key (Symbol),
	constraint Unit__Physical_Quantity__FK foreign key (Physical_Quantity) references Physical_Quantity
);


-- Names for device-specific parameters (registers). We don't call them registers here because registers have a specific address on a specific device types. Oh, maybe we could call this Register_Type, I suppose...
-- Haha, there is already a Register_Type table in progress.. :D But was I intending for that to be the same thing?
-- Perhaps it would also be good to reserve the name Parameter in case we want to model/document the user settings for Modbus devices (certainly the Delta VFD-M docs refer to these ar Parameters, e.g. Pr.00 for source of commanded frequency).
create table Parameter
(
	Parameter_Name varchar,
	Parameter_Code varchar not null,

	constraint Parameter_PK primary key (Parameter_Name),
	constraint Parameter_AK unique (Parameter_Code)
);


-- Should there be a table describing the four tables in the Modbus data model?  The standard isn't very strict about these..indeed, they can be overlapping in actual implementations.
-- Basically, these are input (command) / output (status), discrete (coil) / register.

-- create table Register_Table/Modbus_Register_Table ...


-- A Conformance Class defines the minimum required set of functions for a given class, e.g. FCs 3 and 16 for basic Master or Slave functionality (Class 0).
-- Might be appropriate to model it as Conformance_Class --< Function_Code, with the relationship indicating the minimum conformance class that mandates the function code.  I don't think there's any need to model it as Conformance_Class >--< Function_Code, exhaustively listing all the functions codes that are required/supported by a particular conformance class.
-- So, to find the set of function codes that should be supported by a particular conformance class:
-- select * from Function_Code where Conformance_Class <= 2 order by Function_Code;
create table Conformance_Class
(
	Class_Code integer,
	Title varchar,
	Description varchar,

	constraint Conformance_Class_PK primary key (Class_Code)
);


-- Maybe it would be OK to call this Function rather than Function_Code (even though the docs usually talk about Function Codes, cos that's what implementers mostly care about)
create table Function_Code
(
	Function_Code integer, -- or varchar for hex representation?
	Function_Name varchar not null,
	Conformance_Class integer, -- (or Class_Code?) The minimum class code that requires this function

	constraint Function_Code_PK primary key (Function_Code),
	constraint Function_Name_AK unique (Function_Name)
	constraint Function_Code__Conformance_Class__FK foreign key (Conformance_Class) references Conformance_Class
);

create table Diagnostic_Code
(
	Diagnostic_Code integer, -- or varchar for hex representation?
	Diagnostic_Name varchar not null,

	constraint Diagnostic_Code_PK primary key (Diagnostic_Code),
	constraint Diagnostic_Name_AK unique (Diagnostic_Name)
);

-- TODO: diagnostic registers too?  These are device-dependent.
-- create table ...

-- TODO: exception codes as well
create table Exception_Code
(
	Exception_Code integer,
	Exception_Name varchar not null,
	-- TODO: Also a textual code?

	constraint Exception_Code_PK primary key (Exception_Code)
);


-- Vendor/Manufacturer/Make
create table Vendor
(
	Make varchar,
	-- TODO: other info? Nationality? Year founded?

	constraint Vendor_PK primary key (Make)
);


-- Separate tables for specific device types within a family?  As far as this library is concerned, we only really care about the Modbus interface commonality (although I could imagine even that changing slightly between firmware revisions, hmm).
-- Device_Type/Model/Device_Family/Family?
create table Device_Type
(
	Make varchar,
	Model varchar,
	-- Firmware version as well, as part of the PK? That could make a difference to the supported registers and commands. But maybe there should be a separate table for device versions...
	-- Perhaps also general specs about the device (output power, input power, etc.) - although often each type is an entire range of products, each with their own specs, so maybe not!
	-- For supported function codes, is it enough to identify the conformance class, or should we M:N the individual codes?  Maybe both (conformance class to get the general idea, then itemize esp. the implementation-dependent FCs).
	Conformance_Class integer,

	constraint Device_Type_PK primary key (Make, Model),
	constraint Device_Type__Vendor__FK foreign key (Make) references Vendor,
	constraint Device_Type__Conformance_Class__FK foreign key (Conformance_Class) references Conformance_Class
);

-- Specifics of which function codes each device type supports (beyond those defined by the basic conformance class)
create table Device_Type_Function
(
	Make varchar,
	Model varchar,
	Function_Code varchar,

	constraint Device_Type_Function_PK primary key (Make, Model, Function_Code),
	constraint Device_Type_Function__Device_Type__FK foreign key (Make, Model) references Device_Type,
	constraint Device_Type_Function__Function_Code__FK foreign key (Function_Code) references Function_Code
);



-- Oh, is Rester_Type actually the same as Parameter..? I think prefer this. Can maybe use Parameter for device settings.
create table Register_Type
(
	Register_Type_Code varchar,
	Register_Type_Name varchar,
	Physical_Quantity varchar, -- Might sometimes be dimensionless (e.g. power factor, status)
	-- Probably not units, as that can vary between devices
	-- Probably not scaling factor either, ditto
	-- RW/RO (Command/Status) register type? Or should that be specified in Device_Type_Register[_Type]?
	-- Note that not all register types will be for physical quantities, notably status indicators, firmware revision, etc.

	-- Which PK?  Code or Name?  The other should still be an AK.
	constraint Register_Type_PK primary key (Register_Type_Name),
	constraint Register_Type__Physical_Quantity__FK foreign key (Physical_Quantity) references Physical_Quantity
);


-- Registers supported by a particular device type (what registers does a particular device type have?):
-- Should this be called Device_Type_Register_Type for consistency?
create table Device_Type_Register
(
	Make varchar,
	Model varchar,
	Register_Address varchar,	-- Modbus register address. Not necessarily unique (command register could have the same address as a status register?)?  So should that also be part of the PK?  Hexadecimal string? Or corresponding numeric value?
	Register_Type varchar,	-- Um, what did I have in mind for this? Any old name? Ah, now lookup table (-> Register_Type)
	-- RW/RO (Command/Status) register type? Or is that reliably determined by the address (the Modbus data table that that implies)? There may of course be multiple registers with the same apparent address but different meanings!  Should we have a FK referencing Modbus_Table?
	Scaling_Factor numeric,
	Unit varchar,	-- Hmm, probably want to use the abbrevations here, not the full name! As long as those would be unique...

	constraint Device_Type_Register_PK primary key (Make, Model, Register_Type),
	constraint Device_Type_Register__Device_Type__FK foreign key (Make, Model) references Device_Type,
	constraint Device_Type_Register__Register_Type__FK foreign key (Register_Type) references Register_Type,
	constraint Device_Type_Register__Unit__FK foreign key (Unit) references Unit (Symbol)
);


-- TODO: more stuff on registers, especially on their interpretation. Basically a map of these per device.  How to model different types (e.g. combined registers, individual bits within a larger 16-bit word)?  And also indicate endianness, etc.
/*
create table Device_Type_Register_Field (
	-- TODO...
	constraint Device_Type_Register_Field__PK primary key (),
	constraint Device_Type_Register_Field__Device_Type_Register__FK foreign key () references Device_Type_Register,
	constraint Device_Type_Register_Field__Register_Type__FK foreign key () references Register_Type
);
*/

-- Even though many devices can be configured by the integrator for different comms parameters, might it make sense to record the default settings?  E.g. my Delta VFD-M is factory-configured for Modbus ASCII, 9600 bits/s, 7N2.


-- Since bus setup is done at runtime, maybe these don't need to be in the database...

-- Bus type: ASCII, RTU, TCP
-- Or should there be separate tables for these different types? They will likely have different attributes.
create table Bus_Type
(
	Bus_Type varchar,

	constraint Bus_Type_PK primary key (Bus_Type)
);

-- These are actual buses available on the system. No need to support multiple systems? These data are basically going to be non-persistent anyway, right?
create table Bus
(
	Bus_Name varchar,
	Bus_Type varchar,
	-- ASCII/RTU(/TCP?), baud rate, etc.

	constraint Bus_PK primary key (Bus_Name),
	constraint Bus__Bus_Type__FK foreign key (Bus_Type) references Bus_Type
);

-- Probably don't need to store actual device instances persistently either, but...
create table Device
(
	Device_Name varchar, -- User/installer/integrator-defined
	Make varchar,
	Model varchar,
	Bus_Name varchar,

	constraint Device_PK primary key (Device_Name),
	constraint Device__Device_Type__FK foreign key (Make, Model) references Device_Type,
	constraint Device__Bus__FK foreign key (Bus_Name) references Bus
);

-- Endut! Hoch hech!
