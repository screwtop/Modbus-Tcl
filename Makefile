all: db doc

db: modbus.sqlite3

modbus.sqlite3: Modbus-schema.sql Modbus-data.sql
	sqlite3 --vfs unix-dotfile -batch modbus.sqlite3 < Modbus-schema.sql
	sqlite3 --vfs unix-dotfile -batch modbus.sqlite3 < Modbus-data.sql

doc: schema.png Readme.pdf Design.pdf

Readme.pdf: Readme.md
	pandoc -t latex Readme.md -o Readme.pdf

Design.pdf: Design.md
	pandoc -t latex Design.md -o Design.pdf

schema.png: schema.pu
	java -jar /usr/share/java/plantuml.jar schema.pu
	feh schema.png 

schema.pu: Modbus-schema.sql
	../PlantUML2implementation/SQL2UML.tcl > schema.pu


