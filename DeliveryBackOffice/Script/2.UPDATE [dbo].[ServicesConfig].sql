USE DELIVERYBACKOFFICE
GO
--- SOLO EJECUTAR PARA PRUEBAS ---
UPDATE 
ServicesConfig
SET TimeSchedule = '12:00:00,12:10:00,12:30:00,13:00:00,14:10:00,22:10:00' --Ingresar el horario que se necesita para probar
WHERE ServiceProcess = 'RECOLECTION'