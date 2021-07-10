USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_put_articlebycustomer_in_articlebycustomer]    Script Date: 9/07/2021 23:21:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_put_articlebycustomer_in_articlebycustomer]
	@IdABC INT,
	@TokenUpdated VARCHAR(50),
	@Code NVARCHAR(20),
	@PriceDefault DECIMAL(12, 2),
	@Height DECIMAL(18, 2),
	@Width DECIMAL(18, 2),
	@Length DECIMAL(18, 2),
	@MassWeight DECIMAL(18, 2),
	@VolumetricWeight DECIMAL(18, 2)
AS
BEGIN

--DECLARE @IdABC INT = 12;
--DECLARE @TokenUpdated VARCHAR(50) = 'AJORTIZP';
--DECLARE @Code NVARCHAR(20) = 'EPA020';
--DECLARE @PriceDefault DECIMAL(12, 2) = 152.50;
--DECLARE @Height DECIMAL(18, 2) = 52.50;
--DECLARE @Width DECIMAL(18, 2) = 52.50;
--DECLARE @Length DECIMAL(18, 2) = 52.50;
--DECLARE @MassWeight DECIMAL(18, 2) = 5.75;
--DECLARE @VolumetricWeight DECIMAL(18, 2) = 2.25;
DECLARE @DateUpdated DATETIME = GETDATE();

UPDATE dbo.ArticleByCustomer
SET AbcTokenUpdated = @TokenUpdated,
	AbcDateUpdated = @DateUpdated,
	Code = @Code,
	PriceDefault = @PriceDefault,
	Height = @Height,
	Width = @Width,
	Length = @Length,
	MassWeight = @MassWeight,
	VolumetricWeight = @VolumetricWeight
WHERE AbcId = @IdABC;

END
GO


