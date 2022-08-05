USE [DeliveryBackOffice]
GO

DECLARE @IdBank INT = ( SELECT
		Id_bank
	FROM DeliveryBank
	WHERE Name = 'BANCO PROMERICA'
	AND Id_country = 'GT'
	AND Id_status = 1)

IF @IdBank IS NOT NULL
	INSERT INTO
		[DeliveryBackOffice].[dbo].[CatCoDDailySchedule]
		(CoDProcessName, DeliveryBankId, ExecutionTime, ProcessPriority, TokenCreated, DateCreated)
	VALUES
		-- Procesos de lotes de CoD
		-- Lote 07:00:00
		('CoD_Batch', @IdBank,  '07:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 07:30:00
		('CoD_Batch', @IdBank,  '07:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 08:00:00
		('CoD_Batch', @IdBank,  '08:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 08:30:00
		('CoD_Batch', @IdBank,  '08:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 09:00:00
		('CoD_Batch', @IdBank,  '09:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 09:30:00
		('CoD_Batch', @IdBank,  '09:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 10:00:00
		('CoD_Batch', @IdBank,  '10:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 10:30:00
		('CoD_Batch', @IdBank,  '10:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 11:00:00
		('CoD_Batch', @IdBank,  '11:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 11:30:00
		('CoD_Batch', @IdBank,  '11:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 12:00:00
		('CoD_Batch', @IdBank,  '12:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 12:30:00
		('CoD_Batch', @IdBank,  '12:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 13:00:00
		('CoD_Batch', @IdBank,  '13:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 13:30:00
		('CoD_Batch', @IdBank,  '13:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 14:00:00
		('CoD_Batch', @IdBank,  '14:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 14:30:00
		('CoD_Batch', @IdBank,  '14:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 15:00:00
		('CoD_Batch', @IdBank,  '15:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 15:30:00
		('CoD_Batch', @IdBank,  '15:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 16:00:00
		('CoD_Batch', @IdBank,  '16:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 16:30:00
		('CoD_Batch', @IdBank,  '16:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 17:00:00
		('CoD_Batch', @IdBank,  '17:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 17:30:00
		('CoD_Batch', @IdBank,  '17:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 18:00:00
		('CoD_Batch', @IdBank,  '18:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 18:30:00
		('CoD_Batch', @IdBank,  '18:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 19:00:00
		('CoD_Batch', @IdBank,  '19:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 19:30:00
		('CoD_Batch', @IdBank,  '19:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 20:00:00
		('CoD_Batch', @IdBank,  '20:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 20:30:00
		('CoD_Batch', @IdBank,  '20:30:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Lote 21:00:00
		('CoD_Batch', @IdBank,  '21:00:00', 1, 'SYS-OMORALES', GETDATE()),
		-- Procesos de lotes diarios de CoD
		-- Lote 07:05:00
		('COD_Daily_Batch', @IdBank, '07:05:00', 1, 'SYS-OMORALES', GETDATE()),

		-- Lote 20:05:00
		('COD_Daily_Batch', @IdBank, '20:05:00', 1, 'SYS-OMORALES', GETDATE())