USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_post_new_articlebycustomer_in_articlebycustomer]    Script Date: 9/07/2021 20:29:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_post_new_articlebycustomer_in_articlebycustomer]
	@IdArticle INT,
	@TokenCreated VARCHAR(50),
	@Code NVARCHAR(20),
	@PriceDefault DECIMAL(12, 2),
	@Height DECIMAL(18, 2),
	@Width DECIMAL(18, 2),
	@Length DECIMAL(18, 2),
	@MassWeight DECIMAL(18, 2),
	@VolumetricWeight DECIMAL(18, 2)
AS
BEGIN

--DECLARE @IdArticle INT = 8;
--DECLARE @TokenCreated VARCHAR(50) = 'AJORTIZP';
--DECLARE @Code NVARCHAR(20) = 'EPA020';
--DECLARE @PriceDefault DECIMAL(12, 2) = 125.50;
--DECLARE @Height DECIMAL(18, 2) = 25.50;
--DECLARE @Width DECIMAL(18, 2) = 25.50;
--DECLARE @Length DECIMAL(18, 2) = 25.50;
--DECLARE @MassWeight DECIMAL(18, 2) = 5.75;
--DECLARE @VolumetricWeight DECIMAL(18, 2) = 2.25;
DECLARE @FlagEnabledABC INT = 1;
DECLARE @DateCreated DATETIME = GETDATE();

INSERT INTO dbo.ArticleByCustomer
(
	AbcIdArticle,
	AbcRowStatus,
	AbcTokenCreated,
	AbcDateCreated,
	Code,
	PriceDefault,
	Height,
	Width,
	Length,
	MassWeight,
	VolumetricWeight
)
VALUES
(
	@IdArticle,
	@FlagEnabledABC,
	@TokenCreated,
	@DateCreated,
	@Code,
	@PriceDefault,
	@Height,
	@Width,
	@Length,
	@MassWeight,
	@VolumetricWeight
);

END
GO


