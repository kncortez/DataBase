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
           ('Depositado en buzón'
           ,2 -- Checkpoint de proceso
           ,1 -- interno
           ,'Estimado cliente, el paquete ha sido depositado en un buzón para su preparación'
           ,'Guía depositada en un buzón de manera exitosa'
           ,1
           ,'SYSTEM'
           ,GETDATE()
           ,NULL
           ,NULL
           ,NULL
           ,2 -- recibido por forza
		   );