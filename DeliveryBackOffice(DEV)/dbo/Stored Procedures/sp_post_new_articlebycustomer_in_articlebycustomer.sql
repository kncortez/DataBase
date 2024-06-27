-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Update date: <2024-06-26>
-- Description:	<Se agrega parametro para indicar moneda>
-- =============================================
CREATE PROCEDURE [dbo].[sp_post_new_articlebycustomer_in_articlebycustomer]
	@IdArticle INT,
	@TokenCreated VARCHAR(50),
	@Code NVARCHAR(20),
	@PriceDefault DECIMAL(12, 2),
	@Height DECIMAL(18, 2),
	@Width DECIMAL(18, 2),
	@Length DECIMAL(18, 2),
	@MassWeight DECIMAL(18, 2),
	@VolumetricWeight DECIMAL(18, 2),
	@ShowDefault BIT,
	@IdCurrency INT = 1--POR DEFECTO QUETZAL
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
DECLARE @NewArticleByCustomerId INT = -1;
DECLARE @ExistArticleByCustomerId INT = -1;

BEGIN TRANSACTION;

BEGIN TRY
	IF NOT EXISTS (SELECT * FROM dbo.ArticleByCustomer WHERE UPPER(Code) = UPPER(@Code))
    BEGIN
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
			VolumetricWeight,
			ShowDefault,
			IdCurrency
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
			@VolumetricWeight,
			@ShowDefault,
			@IdCurrency
		);

		SET @NewArticleByCustomerId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		SELECT @ExistArticleByCustomerId = AbcId 
		FROM dbo.ArticleByCustomer 
		WHERE UPPER(Code) = UPPER(@Code);
	END
END TRY
BEGIN CATCH
	SELECT 'RollBackTransaction' AS message,
			-1 AS AbcId,
			@IdArticle AS AbcIdArticle,
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
	IF @NewArticleByCustomerId <> -1
	BEGIN
		SELECT	'Succesfull' AS message,
				@NewArticleByCustomerId AS AbcId,
				@IdArticle AS AbcIdArticle,
				'TRUE' blnResult,
				CAST(@NewArticleByCustomerId AS VARCHAR(50)) IdResult,
				CAST(200 AS VARCHAR(50)) StatusResult,
				'' AS ErrorNumber,
				'' AS ErrorSeverity,
				'' AS ErrorState,
				'' AS ErrorProcedure,
				'' AS ErrorLine,
				'Success' AS ResultMessage;
	END
	ELSE
	BEGIN
		SELECT	'Exist' AS message,
				@ExistArticleByCustomerId AS AbcId,
				@IdArticle AS AbcIdArticle,
				'FALSE' blnResult,
				CAST(@ExistArticleByCustomerId AS VARCHAR(50)) IdResult,
				CAST(200 AS VARCHAR(50)) StatusResult,
				'' AS ErrorNumber,
				'' AS ErrorSeverity,
				'' AS ErrorState,
				'' AS ErrorProcedure,
				'' AS ErrorLine,
				'Success' AS ResultMessage;
	END

    COMMIT TRANSACTION;
END

END
