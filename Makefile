all: db doc

db: modbus.sqlite3

modbus.sqlite3: Modbus-schema.sql Modbus-data.sql
	sqlite3 --vfs unix-dotfile -batch modbus.sqlite3 < Modbus-schema.sql
	sqlite3 --vfs unix-dotfile -batch modbus.sqlite3 < Modbus-data.sql
	
doc: schema.png

schema.png: schema.pu
	java -jar /usr/share/java/plantuml.jar schema.pu
	feh schema.png 

schema.pu: Modbus-schema.sql
	../PlantUML2implementation/SQL2UML.tcl > schema.pu


