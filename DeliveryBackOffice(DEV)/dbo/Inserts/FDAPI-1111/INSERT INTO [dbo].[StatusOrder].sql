USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[StatusOrder]
           ([OrderDescription]
           ,[CatCheckpointTypeId]
           ,[CatStatusTypeId]
           ,[StatusOrderTrackingDescription]
           ,[RowStatus]
           ,[TokenUpdated]
           ,[DateUpdated]
           ,[Statusmessage])
     VALUES
           ('Incidencia en ruta'
           ,(SELECT IdCatCheckpointType FROM CatCheckpointType WHERE CheckpointTypeDescription = 'Checkpoint de incidencia')
           ,(SELECT IdCatStatusType FROM CatStatusType WHERE StatusType = 'Externo')
           ,'No fue posible entregar su envío debido a <incidencia>'
           ,1
           ,'SYS-OMORALES'
           ,GETDATE()
           ,'No fue posible entregar su envío debido a <incidencia>')
GO
