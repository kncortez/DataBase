-- SCRIP PARA INSERTAR NUEVO ESTADO
BEGIN TRY
    BEGIN TRANSACTION;
		
		INSERT INTO DeliveryBackOffice.dbo.StatusOrder (OrderDescription,CatCheckpointTypeId,CatStatusTypeId,StatusMessage,StatusOrderTrackingDescription,RowStatus,TokenCreated,DateCreated, CatstatusProcessId)
		VALUES 
		('COD Anticipado',1,2,'La guia de COD Anticipado fue procesada exitosamente','La guia de COD Anticipado fue procesada exitosamente',1,'SYS-ORODRIGUEZ',GETDATE(),1),
		('COD Pagado Anticipado',1,2,'La guia de COD Anticipado fue Pagada exitosamente','La guia de COD Anticipado fue Pagada exitosamente',1,'SYS-ORODRIGUEZ',GETDATE(),1)
	
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH
