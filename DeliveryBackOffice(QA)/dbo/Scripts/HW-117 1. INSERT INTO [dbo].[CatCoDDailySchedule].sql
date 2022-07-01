/*


Horarios internos del servicio
Configuration_Reload						00:15:00
File_Cleaning								02:00:00

Horarios tomados de configuración a base de datos
CoD_Batch					5,33,31,3,1		07:00:00,08:00:00,09:00:00,10:00:00,11:00:00,12:00:00,13:00:00,14:00:00,15:00:00,16:00:00,17:00:00,18:00:00,19:00:00,20:00:00,21:00:00
											07:30:00,08:30:00,09:30:00,10:30:00,11:30:00,12:30:00,13:30:00,14:30:00,15:30:00,16:30:00,17:30:00,18:30:00,19:30:00,20:30:00

COD_Daily_Batch				5,33,31,3,1		07:05:00,20:05:00

Commision_Batch				31				14:10:00,22:10:00		

Collect_Batch				31				06:00:00,22:05:00

Pickup_Batch				31				06:10:00,22:15:00

Customer_Daily_Report		31				20:30:00



*/


INSERT INTO
	[DeliveryBackOffice].[dbo].[CatCoDDailySchedule]
	(CoDProcessName, DeliveryBankId, ExecutionTime, ProcessPriority, TokenCreated, DateCreated)
VALUES
	-- Procesos de lotes de CoD
		-- Lote 07:00:00
		('CoD_Batch', 1,  '07:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '07:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '07:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '07:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '07:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 07:30:00
		('CoD_Batch', 1,  '07:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '07:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '07:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '07:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '07:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 08:00:00
		('CoD_Batch', 1,  '08:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '08:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '08:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '08:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '08:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 08:30:00
		('CoD_Batch', 1,  '08:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '08:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '08:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '08:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '08:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 09:00:00
		('CoD_Batch', 1,  '09:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '09:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '09:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '09:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '09:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 09:30:00
		('CoD_Batch', 1,  '09:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '09:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '09:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '09:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '09:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 10:00:00
		('CoD_Batch', 1,  '10:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '10:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '10:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '10:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '10:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 10:30:00
		('CoD_Batch', 1,  '10:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '10:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '10:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '10:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '10:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 11:00:00
		('CoD_Batch', 1,  '11:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '11:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '11:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '11:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '11:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 11:30:00
		('CoD_Batch', 1,  '11:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '11:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '11:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '11:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '11:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 12:00:00
		('CoD_Batch', 1,  '12:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '12:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '12:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '12:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '12:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 12:30:00
		('CoD_Batch', 1,  '12:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '12:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '12:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '12:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '12:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 13:00:00
		('CoD_Batch', 1,  '13:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '13:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '13:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '13:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '13:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 13:30:00
		('CoD_Batch', 1,  '13:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '13:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '13:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '13:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '13:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 14:00:00
		('CoD_Batch', 1,  '14:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '14:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '14:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '14:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '14:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 14:30:00
		('CoD_Batch', 1,  '14:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '14:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '14:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '14:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '14:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 15:00:00
		('CoD_Batch', 1,  '15:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '15:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '15:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '15:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '15:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 15:30:00
		('CoD_Batch', 1,  '15:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '15:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '15:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '15:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '15:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 16:00:00
		('CoD_Batch', 1,  '16:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '16:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '16:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '16:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '16:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 16:30:00
		('CoD_Batch', 1,  '16:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '16:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '16:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '16:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '16:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 17:00:00
		('CoD_Batch', 1,  '17:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '17:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '17:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '17:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '17:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 17:30:00
		('CoD_Batch', 1,  '17:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '17:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '17:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '17:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '17:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 18:00:00
		('CoD_Batch', 1,  '18:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '18:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '18:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '18:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '18:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 18:30:00
		('CoD_Batch', 1,  '18:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '18:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '18:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '18:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '18:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 19:00:00
		('CoD_Batch', 1,  '19:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '19:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '19:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '19:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '19:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 19:30:00
		('CoD_Batch', 1,  '19:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '19:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '19:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '19:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '19:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 20:00:00
		('CoD_Batch', 1,  '20:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '20:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '20:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '20:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '20:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 20:30:00
		('CoD_Batch', 1,  '20:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '20:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '20:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '20:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '20:30:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 21:00:00
		('CoD_Batch', 1,  '21:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 3,  '21:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 5,  '21:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 31, '21:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		('CoD_Batch', 33, '21:00:00', 1, 'SYS-ARUIZ', GETDATE()),
	-- Procesos de lotes diarios de CoD
		-- Lote 07:15:00
		('COD_Daily_Batch', 1, '07:15:00', 1, 'SYS-ARUIZ', GETDATE()),
		('COD_Daily_Batch', 3, '07:15:00', 1, 'SYS-ARUIZ', GETDATE()),
		('COD_Daily_Batch', 5, '07:15:00', 1, 'SYS-ARUIZ', GETDATE()),
		('COD_Daily_Batch', 31, '07:15:00', 1, 'SYS-ARUIZ', GETDATE()),
		('COD_Daily_Batch', 33, '07:15:00', 1, 'SYS-ARUIZ', GETDATE()),

		-- Lote 20:15:00
		('COD_Daily_Batch', 1, '20:15:00', 1, 'SYS-ARUIZ', GETDATE()),
		('COD_Daily_Batch', 3, '20:15:00', 1, 'SYS-ARUIZ', GETDATE()),
		('COD_Daily_Batch', 5, '20:15:00', 1, 'SYS-ARUIZ', GETDATE()),
		('COD_Daily_Batch', 31, '20:15:00', 1, 'SYS-ARUIZ', GETDATE()),
		('COD_Daily_Batch', 33, '20:15:00', 1, 'SYS-ARUIZ', GETDATE()),
	-- Procesos de lotes de comisiones y envios
		-- Lote 14:10:00
		('Commision_Batch', 31, '14:10:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 22:00:00
		('Commision_Batch', 31, '22:00:00', 1, 'SYS-ARUIZ', GETDATE()),
	-- Procesos de lotes de collect
		-- Lote 06:00:00
		('Collect_Batch', 31, '06:00:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 22:10:00
		('Collect_Batch', 31, '22:05:00', 1, 'SYS-ARUIZ', GETDATE()),
	-- Procesos de lotes de recolección
		-- Lote 06:10:00
		('Pickup_Batch', 31, '06:10:00', 1, 'SYS-ARUIZ', GETDATE()),
		-- Lote 22:15:00
		('Pickup_Batch', 31, '22:15:00', 1, 'SYS-ARUIZ', GETDATE()),
	-- Procesos de envio de reportes a clientes por depositos
		-- Lote 20:40:00
		('Customer_Daily_Report', 31, '20:40:00', 1, 'SYS-ARUIZ', GETDATE())