USE DeliveryBackOffice
go

ALTER TABLE dbo.CatVehicleCategories ADD
	Length decimal(14,2) NULL,
	Width decimal(14,2) NULL,
	High decimal(14,2) NULL,
	UnitType int NULL


GO

ALTER TABLE dbo.CatVehicleCategories ADD CONSTRAINT	FKUnitType FOREIGN KEY
	(
	UnitType
	) REFERENCES dbo.Unit
	(
	IdUnit
	)
