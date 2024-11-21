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
           ('Recepcionado en Express Center'
           ,2 -- Checkpoint de proceso
           ,2 -- externo
           ,'Estimado cliente, el paquete ha sido recepcionado para su deposito en buzón'
           ,'Guía recepcionada en express centrer de manera exitosa'
           ,1
           ,'SYSTEM'
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL
           ,2 -- recibido por forza
		   );