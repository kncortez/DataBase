/* =================================================
   Script:    Creación de nuevos estados.
   Propósito: Se encargara en crear nuevos estados para los smart lockers.
   Autor:     Walter Orozco
   Historia:  FDAPI-4827 [FDAPI-4831],[FDAPI-4832],[FDAPI-4834]
   Fecha:     2025-10-23
=================================================*/

BEGIN TRY
    BEGIN TRANSACTION;

	IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Paquete en Smart Locker')
	BEGIN
		INSERT INTO [dbo].[StatusOrder]
           ([OrderDescription]
           ,[CatCheckpointTypeId]
           ,[CatStatusTypeId]
           ,[StatusMessage]
           ,[StatusOrderTrackingDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[NextSteps]
           ,[CatStatusProcessId])
		 VALUES
			('Paquete en Smart Locker'
			,2 --Checkpoint de proceso
			,2 --Externo
			,'La guía se encuentra en Smart Locker'
			,'Guía se encuentra en Smart Locker'
			,1
			,'SYS-WOROZCO'
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,3 --En instalaciones
			)
	END

	IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Entregado en Smart Locker')
	BEGIN
		INSERT INTO [dbo].[StatusOrder]
           ([OrderDescription]
           ,[CatCheckpointTypeId]
           ,[CatStatusTypeId]
           ,[StatusMessage]
           ,[StatusOrderTrackingDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[NextSteps]
           ,[CatStatusProcessId])
		 VALUES
			('Entregado en Smart Locker'
			,3 --Checkpoint final
			,2 --Externo
			,'Estimado cliente, el paquete fue entregado en Smart Locker'
			,'Guía entregada a travez de Smart Locker'
			,1
			,'SYS-WOROZCO'
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,5 --Entregado
			)
	END

	IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.StatusOrder WITH(NOLOCK) WHERE OrderDescription = 'Retirado en Smart Locker')
	BEGIN
		INSERT INTO [dbo].[StatusOrder]
           ([OrderDescription]
           ,[CatCheckpointTypeId]
           ,[CatStatusTypeId]
           ,[StatusMessage]
           ,[StatusOrderTrackingDescription]
           ,[RowStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[NextSteps]
           ,[CatStatusProcessId])
		 VALUES
			('Retirado en Smart Locker'
			,3 --Checkpoint final
			,2 --Externo
			,'Estimado cliente, el paquete fue devuelto en Smart Locker'
			,'Guía entregada por devolución a travez de Smart Locker'
			,1
			,'SYS-WOROZCO'
			,GETDATE()
			,NULL
			,NULL
			,NULL
			,5 --Entregado
			)
	END

	IF NOT EXISTS (SELECT 1 FROM DeliveryBackOffice.dbo.KindOfVPClient WITH(NOLOCK) WHERE KindOfVPName = 'Smart Locker Extern')
	BEGIN
		INSERT INTO [dbo].[KindOfVPClient]
           ([KindOfVPName]
           ,[KindOfVPStatus]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdated]
           ,[IdCountry])
		 VALUES
			   ('Smart Locker Extern'
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,'GT'),
			   ('Smart Locker Extern'
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,'HN'),
			   ('Smart Locker Extern'
			   ,1
			   ,'SYS-WOROZCO'
			   ,GETDATE()
			   ,NULL
			   ,NULL
			   ,'SV')
	END
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;