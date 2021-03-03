	USE [DeliveryBackOffice]
	GO
		ALTER TABLE DeliveryBackOffice.dbo.CatVehicle  
		ADD Long DECIMAL (14,2) null
		,Width DECIMAL (14,2) null
		,High DECIMAL (14,2) NULL
		,CubicMeters DECIMAL (14,2) NULL
		,CapabilityEcomerce DECIMAL (14,2) NULL
	GO