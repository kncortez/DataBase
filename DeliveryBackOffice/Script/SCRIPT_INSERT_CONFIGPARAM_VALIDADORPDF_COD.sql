--SCRIPT INSERT CONFIG PARAM
INSERT INTO ConfigParams VALUES('ValidateHour_COD', 'Se configura la hora en que se debe ejecutar el módulo que envía el PDF del informe de entregas','22:00',1,GETDATE())
INSERT INTO ConfigParams VALUES('DebugValidateHour_COD', 'Se activa el modo DEBUG para ejecutar el módulo que envía el PDF del informe de entregas',1,1,GETDATE())