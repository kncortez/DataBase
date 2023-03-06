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
           ,[Statusmessage]
           ,[NextSteps])
     VALUES
           ('Paquete abandonado'
           ,(SELECT IdCatCheckpointType FROM CatCheckpointType WHERE CheckpointTypeDescription = 'Checkpoint final')
           ,(SELECT IdCatStatusType FROM CatStatusType WHERE StatusType = 'Interno' and RowStatus = 1)
           ,'Guía ya cumplió sus inténtos de devolución'
           ,1
           ,NULL
           ,NULL
           ,'Estimado cliente, la guía  se encuentra en el estado Paquete abandonado, gracias por usar nuestros servicios'
           ,NULL)