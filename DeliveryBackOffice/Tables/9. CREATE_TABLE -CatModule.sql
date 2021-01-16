USE [DeliveryBackOffice]
GO

CREATE TABLE DeliveryBackOffice.dbo.CatModule 
   (ModIdModule int IDENTITY(1,1) PRIMARY KEY NOT NULL,  
	ModName varchar(100) NOT NULL,
	ModIdModuleParent int  NULL,
	ModPath varchar(200)  not NULL,
	ModDescription varchar(150)  NULL,
	ModOrder int not   NULL,
	ModMetadata varchar(50)  NULL,
	ModVisible bit not  NULL,
	ModRowStatus bit NOT NULL,
	ModTokenCreated varchar(50)  NOT NULL,
	ModDateCreated datetime  NOT NULL,
	ModTokenUpdated varchar(50)   NULL,
	ModDateUpdated datetime   NULL,
	FOREIGN KEY (ModIdModuleParent) REFERENCES CatModule(ModIdModule)
	)
GO  

insert into DeliveryBackOffice.dbo.CatModule  
	(ModName
	,ModIdModuleParent
	,ModPath
	,ModDescription
	,ModOrder
	,ModMetadata
	,ModVisible
	,ModRowStatus
	,ModTokenCreated
	,ModDateCreated
	)
Values('Login',null,'/login', 'Módulo de inicio de sesión', 1,'file.png',0, 1,'SYS-DEVELOP',GETDATE()),
	('Mi perfil',null,'/perfil', 'Perfil de usuario', 1,'file.png',0, 1,'SYS-CAQUINO',GETDATE()),
	('Facturación',null,'/facturacion', 'Pefiles de facturación', 1,'file.png',0, 1,'SYS-CAQUINO',GETDATE()),
	('Direcciónes',null,'/direcciones', 'Perfil de usuario', 1,'file.png',0, 1,'SYS-CAQUINO',GETDATE()),
	('Métodos de Pago',null,'/pagos', 'Definición de métodos de pago', 1,'file.png',0, 1,'SYS-CAQUINO',GETDATE())

select * from DeliveryBackOffice.dbo.CatModule  