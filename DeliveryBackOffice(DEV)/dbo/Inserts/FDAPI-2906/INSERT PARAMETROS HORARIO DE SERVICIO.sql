--PARAMETROS QUE INDICAN HORARIO DE SERVICIO
INSERT INTO ConfigParams VALUES('MaximumSchedulePickup','Hora máxima para realizar recolecciones','5:00 pm',1,GETDATE(),'HN',NULL);
INSERT INTO ConfigParams VALUES('MaximumSchedulePickup','Hora máxima para realizar recolecciones','5:00 pm',1,GETDATE(),'GT',NULL);

INSERT INTO ConfigParams VALUES('DeliveryStartSchedule','Hora de inicio para realizar entregas','7:00 am',1,GETDATE(),'HN',NULL);
INSERT INTO ConfigParams VALUES('DeliveryStartSchedule','Hora de inicio para realizar entregas','7:00 am',1,GETDATE(),'GT',NULL);

INSERT INTO ConfigParams VALUES('DeliveryEndSchedule','Hora de finalización para realizar entregas','7:00 pm',1,GETDATE(),'HN',NULL);
INSERT INTO ConfigParams VALUES('DeliveryEndSchedule','Hora de finalización para realizar entregas','7:00 pm',1,GETDATE(),'GT',NULL);
