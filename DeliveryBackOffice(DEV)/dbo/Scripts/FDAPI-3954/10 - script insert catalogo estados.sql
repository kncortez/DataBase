-- Iniciar transacción
BEGIN TRANSACTION

BEGIN TRY

INSERT INTO dbo.StateByBillingSV (Code, [Name], RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
VALUES
('00', 'Otro (Para extranjeros)', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('01', 'Ahuachapán', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('02', 'Santa Ana', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('03', 'Sonsonate', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('04', 'Chalatenango', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('05', 'La Libertad', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('06', 'San Salvador', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('07', 'Cuscatlán', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('08', 'La Paz', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('09', 'Cabañas', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('10', 'San Vicente', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('11', 'Usulután', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('12', 'San Miguel', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('13', 'Morazán', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('14', 'La Unión', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);


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
