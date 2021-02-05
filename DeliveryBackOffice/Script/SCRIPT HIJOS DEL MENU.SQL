USE [DeliveryBackOffice]
GO
SELECT * INTO TMP_CatModule FROM [dbo].[CatModule]; /*PARA ROLLBACK*/
GO
INSERT INTO [dbo].[CatModule]
           ([ModName]
           ,[ModIdModuleParent]
           ,[ModPath]
           ,[ModDescription]
           ,[ModOrder]
           ,[ModMetadata]
           ,[ModVisible]
           ,[ModRowStatus]
           ,[ModTokenCreated]
           ,[ModDateCreated])
     VALUES
           ('Mis Datos'
           ,2
           ,'/perfil'
           ,'Mis Datos'
           ,9
           ,'file-png'
           ,1
           ,1
           ,'SYS-CAQUINO'
           ,GETDATE()
           ),
		   ('Mis cuentas bancarias'
           ,2
           ,'/mis-cuentas-bancarias'
           ,'Cuentas bancarias'
           ,10
           ,'file-png'
           ,1
           ,1
           ,'SYS-CAQUINO'
           ,GETDATE()
           )
GO
update [DeliveryBackOffice]
set [ModIdModuleParent] = 2 
where LTRIM(RTRIM(ModName)) in ('Facturación','Direcciones Favoritas')
GO
/*AL TENER BIEN EL MENU HACER EL DROP*/
/*
DROP TABLE 
 TMP_CatModule*/
/*PARA ROLLBACK*/