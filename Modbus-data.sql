-- Initial set of data for Modbus driver in Tcl (or other languages, why not?)

pragma foreign_keys = 1;

insert into Physical_Quantity (Physical_Quantity) values ('(dimensionless)');

insert into Physical_Quantity (Physical_Quantity) values ('current');
insert into Physical_Quantity (Physical_Quantity) values ('voltage'); -- Was going to follow Frink and use electric_potential, but meh
insert into Physical_Quantity (Physical_Quantity) values ('frequency');
insert into Physical_Quantity (Physical_Quantity) values ('power');
insert into Physical_Quantity (Physical_Quantity) values ('temperature');

-- If in doubt, follow Frink for these. ;)
insert into Unit (Name, Symbol, Physical_Quantity) values ('(dimensionless)', '', '(dimensionless)');
insert into Unit (Name, Symbol, Physical_Quantity) values ('volt', 'V', 'voltage');
insert into Unit (Name, Symbol, Physical_Quantity) values ('ampere', 'A', 'current');
insert into Unit (Name, Symbol, Physical_Quantity) values ('watt', 'W', 'power');
insert into Unit (Name, Symbol, Physical_Quantity) values ('horsepower', 'hp', 'power');
-- Bah, are we now committed to adding systematic variants such as kW now?! Maybe just to be quick and dirty, yes.  We'll no doubt have nonsystematic equivalents such as horsepower anyway.
-- I think it's beyond the scope of this to handle conversions between units! Though it might be handy, it's not really the job of a Modbus library.
insert into Unit (Name, Symbol, Physical_Quantity) values ('hertz', 'Hz', 'frequency');
insert into Unit (Name, Symbol, Physical_Quantity) values ('revolutions per minute', 'RPM', 'frequency');
-- radians per second? /tau?
-- TODO: temperature, ...
insert into Unit (Name, Symbol, Physical_Quantity) values ('degrees Celsius', '°C', 'temperature'); -- "degree" or "degrees"? Some of the others are plural (revolutions per minute)

-- TODO: another table perhaps for the set of parameter types (names) that could appear in device-specific registers, e.g. bus voltage.  Underscores or dashes for the codes?  LinuxCNC HAL signal names tend to use dashes.
-- Could possibly reference Physical_Quantity, CTTOI, although not Unit of course (different devices might report a quantity in different units - that's register/device specific).
insert into Parameter (Parameter_Name, Parameter_Code) values ('bus voltage', 'bus-voltage');
insert into Parameter (Parameter_Name, Parameter_Code) values ('output voltage', 'output-voltage');
insert into Parameter (Parameter_Name, Parameter_Code) values ('output current', 'output-current');
insert into Parameter (Parameter_Name, Parameter_Code) values ('output frequency', 'output-frequency');
insert into Parameter (Parameter_Name, Parameter_Code) values ('target frequency', 'target-frequency');
insert into Parameter (Parameter_Name, Parameter_Code) values ('temperature', 'temperature');
-- TODO: many more...

-- Actually, those should be in Register_Type instead:
insert into Register_Type (Register_Type_Code, Register_Type_Name, Physical_Quantity) values ('bus-voltage', 'Bus Voltage', 'voltage');
insert into Register_Type (Register_Type_Code, Register_Type_Name, Physical_Quantity) values ('output-voltage', 'Output Voltage', 'voltage');
insert into Register_Type (Register_Type_Code, Register_Type_Name, Physical_Quantity) values ('output-current', 'Output Current', 'current');
insert into Register_Type (Register_Type_Code, Register_Type_Name, Physical_Quantity) values ('output-frequency', 'Output Frequency', 'frequency');
insert into Register_Type (Register_Type_Code, Register_Type_Name, Physical_Quantity) values ('target-frequency', 'Target Frequency', 'frequency');
insert into Register_Type (Register_Type_Code, Register_Type_Name, Physical_Quantity) values ('temperature', 'Temperature', 'temperature');	-- Or should it specify what the temperature is of, e.g. vfd-temperature or drive-temperature or device-temperature, ambient-temperature, coolant-temperature?
insert into Register_Type (Register_Type_Code, Register_Type_Name, Physical_Quantity) values ('power-factor', 'Power Factor', '(dimensionless)');


insert into Conformance_Class (Class_Code, Title, Description) values (0, 'minimum', 'Minimum useful set of functions for both Master and Slave devices');
insert into Conformance_Class (Class_Code, Title, Description) values (1, '?', 'Typically different meaning for each slave family');
insert into Conformance_Class (Class_Code, Title, Description) values (2, 'data transfer', 'Data transfer functions for HMI, supervision, etc.');
insert into Conformance_Class (Class_Code, Title, Description) values (99, 'machine-dependent', 'Implementation-specific functions, generally not interoperable'); -- Code 99 isn't used in the standard, just wanted something large and obviously special.


-- Modbus function codes (command types):
-- Decimal or hex for the codes?  Decimal is probably more user-friendly, and used by most of the official documentation.
-- These names are according to the Modbus spec, but they aren't the nicest for using in code. Maybe include a single concise alias for code. Probably overkill to permit <n> aliases per function!
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (1, 'Read Coil Status', 1);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (2, 'Read Input Status', 1);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (3, 'Read Holding Registers', 0);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (4, 'Read Input Registers', 1);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (5, 'Force Single Coil', 1);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (6, 'Preset Single Register', 1); -- i.e., write
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (7, 'Read Exception Status', 1);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (8, 'Diagnostics', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (9, 'Program 484', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (10, 'Poll 484', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (11, 'Fetch Communication Event Counter', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (12, 'Fetch Communication Event Log', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (13, 'Program Controller', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (14, 'Poll Controller', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (15, 'Force Multiple Coils', 2);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (16, 'Preset Multiple Registers', 0);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (17, 'Report Slave ID', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (18, 'Program 884/M84', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (19, 'Reset Communication Link', 99);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (20, 'Read General Reference', 2);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (21, 'Write General Reference', 2);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (22, 'Mask Write 4X Registers', 2);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (23, 'Read/Write 4X Registers', 2);
insert into Function_Code (Function_Code, Function_Name, Conformance_Class) values (24, 'Read FIFO Queue', 2);
-- TODO: codes 40 (program (ConCept)), 125 (firmware replacement), 126 (program (584/984)), 127 (report local address (MODBUS)) are also mentioned; implementation-defined.


-- TODO: same for diagnostic codes
-- Note that exception codes (cf. diagnostic codes) are simply the original function code + 0x80.
insert into Diagnostic_Code (Diagnostic_Code, Diagnostic_Name) values (0, 'Return Query Data');
/*
insert into Diagnostic_Code (Diagnostic_Code, Diagnostic_Name) values (, '');
insert into Diagnostic_Code (Diagnostic_Code, Diagnostic_Name) values (, '');
insert into Diagnostic_Code (Diagnostic_Code, Diagnostic_Name) values (, '');
insert into Diagnostic_Code (Diagnostic_Code, Diagnostic_Name) values (, '');
*/

-- TODO: include descriptive text as well, for error reporting? See Modbus spec p96-97
insert into Exception_Code (Exception_Code, Exception_Name) values (1, 'ILLEGAL FUNCTION');
insert into Exception_Code (Exception_Code, Exception_Name) values (2, 'ILLEGAL DATA ADDRESS');
insert into Exception_Code (Exception_Code, Exception_Name) values (3, 'ILLEGAL DATA VALUE');
insert into Exception_Code (Exception_Code, Exception_Name) values (4, 'SLAVE DEVICE FAILURE'); -- RTA gives this as ILLEGAL RESPONSE LENGTH
insert into Exception_Code (Exception_Code, Exception_Name) values (5, 'ACKNOWLEDGE');
insert into Exception_Code (Exception_Code, Exception_Name) values (6, 'SLAVE DEVICE BUSY');
insert into Exception_Code (Exception_Code, Exception_Name) values (7, 'NEGATIVE ACKNOWLEDGE');
insert into Exception_Code (Exception_Code, Exception_Name) values (8, 'MEMORY PARITY ERROR');
-- RTA also give the following, for Modbus Plus:
insert into Exception_Code (Exception_Code, Exception_Name) values (10, 'GATEWAY PATH UNAVAILABLE');
insert into Exception_Code (Exception_Code, Exception_Name) values (11, 'GATEWAY TARGET DEVICE FAILED TO RESPOND');

-- How to handle changing brand names, mergers, etc.?  Just use the historic label, if nothing significant functionally has changed?
insert into Vendor (Make) values ('Danfoss');
insert into Vendor (Make) values ('Delta');
insert into Vendor (Make) values ('Eaton');
insert into Vendor (Make) values ('Fuji Electric');
insert into Vendor (Make) values ('Hitachi');
insert into Vendor (Make) values ('Huanyang');
insert into Vendor (Make) values ('Mitsubishi');
insert into Vendor (Make) values ('Siemens');
insert into Vendor (Make) values ('Toshiba-Schneider');
insert into Vendor (Make) values ('Yaskawa');

insert into Device_Type (Make, Model) values ('Delta', 'VFD-B');
insert into Device_Type (Make, Model) values ('Delta', 'VFD-E');
insert into Device_Type (Make, Model) values ('Delta', 'VFD-M');

-- Command registers (TODO: distinguish from status regs!):
--insert into Register (Make, Model, Register_Address, Register_Type, Scaling_Factor, Unit) values ('Delta', 'VFD-M', 0x2001, 'Target Frequency', 0.01, 'Hz');

-- Status registers:
insert into Register (Make, Model, Register_Address, Register_Type, Scaling_Factor, Unit) values ('Delta', 'VFD-M', 8450, 'Target Frequency', 0.01, 'Hz'); -- 0x2102
insert into Register (Make, Model, Register_Address, Register_Type, Scaling_Factor, Unit) values ('Delta', 'VFD-M', 8451, 'Output Frequency', 0.01, 'Hz'); -- 0x2103
insert into Register (Make, Model, Register_Address, Register_Type, Scaling_Factor, Unit) values ('Delta', 'VFD-M', 8452, 'Output Current', 0.1, 'A'); -- 0x2104
insert into Register (Make, Model, Register_Address, Register_Type, Scaling_Factor, Unit) values ('Delta', 'VFD-M', 8453, 'Bus Voltage', 0.1, 'V'); -- 0x2105
insert into Register (Make, Model, Register_Address, Register_Type, Scaling_Factor, Unit) values ('Delta', 'VFD-M', 8454, 'Output Voltage', 0.1, 'V'); -- 0x2106
insert into Register (Make, Model, Register_Address, Register_Type, Scaling_Factor, Unit) values ('Delta', 'VFD-M', 8458, 'Power Factor', 0.1, ''); -- 0x210A  TODO: how to indicate dimensionless?  Empty string, or NULL, or '(dimensionless)' or something?
insert into Register (Make, Model, Register_Address, Register_Type, Scaling_Factor, Unit) values ('Delta', 'VFD-M', 8461, 'Temperature', 0.1, '°C'); -- 0x210D

-- What about sub-register fields such as status bits?  Might need to include a separate attribute for which bit or range of bits applies.  Might require multiple tables due to the variant structure.


