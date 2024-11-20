-- SCRIP para actualizar datos de banco Davivienda
BEGIN TRY
    BEGIN TRANSACTION;
		--Actualizar Banco Davivienda para pagos masivos COD Honduras
		UPDATE DeliveryBackOffice.dbo.DeliveryBank
			SET PayingBank = 27
		WHERE Id_bank = 27
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;
