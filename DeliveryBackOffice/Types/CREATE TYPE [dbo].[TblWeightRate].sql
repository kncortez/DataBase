USE [DeliveryBackOffice]
GO

CREATE TYPE [dbo].[TblWeightRate] AS TABLE(
	[WeightFrom] [decimal](12,2) NULL,
	[WeightTo] [decimal](12,2) NULL,
	[Local] [decimal](14, 2) NULL,
	[Metro] [decimal](14, 2) NULL,
	[Foraneo] [decimal](14, 2) NULL,
	[CatTypeService] [int] NULL,
	[State] [int] NULL
)
GO