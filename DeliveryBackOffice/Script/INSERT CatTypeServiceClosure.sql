USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[CatTypeServiceClosure]
           ([NameTypeService]
           ,[DescriptionTypeService]
           ,[StatusTypeService]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdate])
     VALUES
           ('Estándar'
           ,'Servicio para pago de contado con tarjeta y efectivo'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatTypeServiceClosure]
           ([NameTypeService]
           ,[DescriptionTypeService]
           ,[StatusTypeService]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdate])
     VALUES
           ('Entrega'
           ,'Servicio de entrega'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatTypeServiceClosure]
           ([NameTypeService]
           ,[DescriptionTypeService]
           ,[StatusTypeService]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdate])
     VALUES
           ('Recepción'
           ,'Servicio de recepción'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL)

INSERT INTO [dbo].[CatTypeServiceClosure]
           ([NameTypeService]
           ,[DescriptionTypeService]
           ,[StatusTypeService]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdate])
     VALUES
           ('Devolución'
           ,'Servicio de devolución'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL)
INSERT INTO [dbo].[CatTypeServiceClosure]
           ([NameTypeService]
           ,[DescriptionTypeService]
           ,[StatusTypeService]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdate])
     VALUES
           ('Internacional'
           ,'Servicio internacional'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL)

		   INSERT INTO [dbo].[CatTypeServiceClosure]
           ([NameTypeService]
           ,[DescriptionTypeService]
           ,[StatusTypeService]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdate])
     VALUES
           ('Fotocopias'
           ,'Servicio de Fotocopias'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL)

		   INSERT INTO [dbo].[CatTypeServiceClosure]
           ([NameTypeService]
           ,[DescriptionTypeService]
           ,[StatusTypeService]
           ,[TokenCreated]
           ,[DateCreated]
           ,[TokenUpdate]
           ,[DateUpdate])
     VALUES
           ('Artículos'
           ,'Servicio de venta de artículos'
           ,1
           ,'SYS-FMONTERROSO'
           ,GETDATE()
           ,NULL
           ,NULL)


GO