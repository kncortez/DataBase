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
	@VolumetricWeight DECIMAL(18, 2),
	@ShowDefault BIT
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

BEGIN TRANSACTION;

BEGIN TRY
	UPDATE dbo.ArticleByCustomer
	SET AbcTokenUpdated = @TokenUpdated,
		AbcDateUpdated = @DateUpdated,
		Code = @Code,
		PriceDefault = @PriceDefault,
		Height = @Height,
		Width = @Width,
		Length = @Length,
		MassWeight = @MassWeight,
		VolumetricWeight = @VolumetricWeight,
		ShowDefault = @ShowDefault
	WHERE AbcId = @IdABC;
END TRY
BEGIN CATCH
	SELECT 'RollBackTransaction' AS message,
			-1 AS AbcId,
			'FALSE'	blnResult,
			CAST(-1 AS VARCHAR(5)) IdResult,
			CAST(500 AS VARCHAR(5)) StatusResult,
			CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
			CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
			CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
			CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
			CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
			CAST(ERROR_MESSAGE() AS VARCHAR) AS ResultMessage;

    ROLLBACK TRANSACTION;
END CATCH;

IF @@TRANCOUNT > 0
BEGIN
	SELECT	'Succesfull' AS message,
			@IdABC AS AbcId,
			'TRUE' blnResult,
			CAST(@IdABC AS VARCHAR(50)) IdResult,
			CAST(200 AS VARCHAR(50)) StatusResult,
			'' AS ErrorNumber,
			'' AS ErrorSeverity,
			'' AS ErrorState,
			'' AS ErrorProcedure,
			'' AS ErrorLine,
			'Success' AS ResultMessage;

    COMMIT TRANSACTION;
END

END
GO


