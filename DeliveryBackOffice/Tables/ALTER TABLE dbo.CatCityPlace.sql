/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.CatCityPlace
	DROP CONSTRAINT PK_CatCityPlace
GO
ALTER TABLE dbo.CatCityPlace ADD CONSTRAINT
	PK_CatCityPlace PRIMARY KEY CLUSTERED 
	(
	IdCityPlace
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.CatCityPlace SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.UserAddress ADD
	IdCityPlace int NULL
GO
ALTER TABLE dbo.UserAddress ADD CONSTRAINT
	FK_UserAddress_CatCityPlace FOREIGN KEY
	(
	IdCityPlace
	) REFERENCES dbo.CatCityPlace
	(
	IdCityPlace
	) ON UPDATE  NO ACTION 
	 ON DELETE  NO ACTION 
	
GO
ALTER TABLE dbo.UserAddress SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
Go
/*Post inserts*/
alter table DeliveryBackOffice.dbo.CatCityPlace add  OrderCityPlace int;
go
update DeliveryBackOffice.dbo.CatCityPlace
set OrderCityPlace = 1
where Upper(CityPlace) = 'CASA'

update DeliveryBackOffice.dbo.CatCityPlace
set OrderCityPlace = 2
where Upper(CityPlace) = 'TRABAJO'

update DeliveryBackOffice.dbo.CatCityPlace
set OrderCityPlace = 3
where Upper(CityPlace) = 'GIMNASIO'

update DeliveryBackOffice.dbo.CatCityPlace
set OrderCityPlace = 4
where Upper(CityPlace) = 'IGLESIA'

update DeliveryBackOffice.dbo.CatCityPlace
set OrderCityPlace = 5
where Upper(CityPlace) = 'UNIVERSIDAD'