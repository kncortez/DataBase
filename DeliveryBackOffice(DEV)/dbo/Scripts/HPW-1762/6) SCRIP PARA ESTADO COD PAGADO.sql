-- SCRIP PARA INSERTAR NUEVO ESTADO
BEGIN TRY
    BEGIN TRANSACTION;
		
		UPDATE DeliveryBackOffice.dbo.StatusOrder
		SET CatCheckpointTypeId = 1,
		CatStatusTypeId = 2,
		CatStatusProcessId = 1
		WHERE OrderDescription = 'COD pagado'

	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH
