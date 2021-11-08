USE [DeliveryBackOffice]
GO

INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
     VALUES
           ('PortalVersion', 
		   'Versión Actualizada de Portal Web', 
		   '0.9.2.8-20211108',
		   1, 
		   getdate())

		   INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
     VALUES
           ('Images', 
		   'Ruta de portada login', 
		   'portal/assets/images/login.jpg',
		   1, 
		   getdate())

		   INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
     VALUES
           ('Images', 
		   'Ruta de banner', 
		   'portal/assets/images/banner.jpg',
		   1, 
		   getdate())
		   
		   INSERT INTO [dbo].[ConfigParams]
           ([Name]
           ,[Description]
           ,[Value]
           ,[Status]
           ,[CreateDate])
     VALUES
           ('Images', 
		   'Ruta de portada login Corporativo', 
		   'portal/assets/images/login-Corp.jpg',
		   1, 
		   getdate())
GO