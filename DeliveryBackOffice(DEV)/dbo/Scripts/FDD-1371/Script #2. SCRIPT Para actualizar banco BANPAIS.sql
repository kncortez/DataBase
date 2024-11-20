-- SCRIP PARA INSERTAR NUEVO REGISTRO DE BANCO BANPAIS HN
BEGIN TRY
    BEGIN TRANSACTION;
		--Actualizar Banco BANPAIS para pagos masivos COD Honduras
		UPDATE DeliveryBackOffice.dbo.DeliveryBank
		SET PayingBank = 113,
		Name = 'Banco Del Pais',
		Acronym = 'BANPAIS',
		Description = 'Banco Del Pais'
		WHERE Id_Bank = 113
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;