-- SCRIP PARA INSERTAR NUEVO ESTADO
BEGIN TRY
    BEGIN TRANSACTION;
		
		INSERT INTO DeliveryBackOffice.dbo.StatusOrder (OrderDescription,CatCheckpointTypeId,CatStatusTypeId,StatusMessage,StatusOrderTrackingDescription,RowStatus,TokenCreated,DateCreated, CatstatusProcessId)
		VALUES ('Recepcionado en Express Center COD Anticipado',2,2,'La guia de COD Anticipado fue Recibida en Express Center','Guia COD Anticipado Recepcionada en Express Center de manera Exitosa',1,'SYS-ORODRIGUEZ',GETDATE(),2)
	
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH
