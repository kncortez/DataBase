-- Iniciar transacción
BEGIN TRANSACTION

BEGIN TRY

INSERT INTO dbo.DistrictByBillingSV (CodeDistrict, StateCode, [Name],StateId, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
VALUES
('00', '00', 'Otro (Para extranjeros)',1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('13', '01', 'Ahuachapán Norte',2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('14', '01', 'Ahuachapán Centro',2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('15', '01', 'Ahuachapán Sur',2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('14', '02', 'Santa Ana Norte',3, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('15', '02', 'Santa Ana Centro',3, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('16', '02', 'Santa Ana Este', 3,1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('17', '02', 'Santa Ana Oeste',3, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('17', '03', 'Sonsonate Norte',4, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('18', '03', 'Sonsonate Centro',4, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('19', '03', 'Sonsonate Este',4, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('20', '03', 'Sonsonate Oeste',4, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('34', '04', 'Chalatenango Norte',5, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('35', '04', 'Chalatenango Centro',5, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('36', '04', 'Chalatenango Sur',5, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('23', '05', 'La Libertad Norte',6, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('24', '05', 'La Libertad Centro',6, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('25', '05', 'La Libertad Oeste',6, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('26', '05', 'La Libertad Este',6, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('27', '05', 'La Libertad Costa',6, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('28', '05', 'La Libertad Sur',6, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('20', '06', 'San Salvador Norte',7, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('21', '06', 'San Salvador Oeste',7, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('22', '06', 'San Salvador Este',7, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('23', '06', 'San Salvador Centro',7, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('24', '06', 'San Salvador Sur',7, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('17', '07', 'Cuscatlán Norte',8, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('18', '07', 'Cuscatlán Sur',8, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('23', '08', 'La Paz Oeste',9, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('24', '08', 'La Paz Centro',9, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('25', '08', 'La Paz Este',9, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('10', '09', 'Cabañas Oeste',10, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('11', '09', 'Cabañas Este',10, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('14', '10', 'San Vicente Norte',11, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('15', '10', 'San Vicente Sur',11, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('24', '11', 'Usulután Norte',12, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('25', '11', 'Usulután Este',12, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('26', '11', 'Usulután Oeste',12, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('21', '12', 'San Miguel Norte',13, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('22', '12', 'San Miguel Centro',13, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('23', '12', 'San Miguel Oeste',13, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('27', '13', 'Morazán Norte',14, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('28', '13', 'Morazán Sur',14, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('19', '14', 'La Unión Norte',15, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('20', '14', 'La Unión Sur',15, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);


	COMMIT TRANSACTION
	print 'Inserción exitosa'

END TRY
BEGIN CATCH
	-- Revertir transacción en caso de error
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
    
	-- Capturar información del error
	SELECT ERROR_MESSAGE(),
			ERROR_SEVERITY(),
			ERROR_STATE()

END CATCH

