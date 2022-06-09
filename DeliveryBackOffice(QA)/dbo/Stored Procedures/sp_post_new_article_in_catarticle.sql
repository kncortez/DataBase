
CREATE PROCEDURE [dbo].[sp_post_new_article_in_catarticle]
	@IdTypeArticle INT,
	@ArticleName VARCHAR(50),
	@Token VARCHAR(50)
AS
BEGIN

--DECLARE @IdTypeArticle INT = 8;
--DECLARE @ArticleName VARCHAR(50) = 'Nuevo';
--DECLARE @Token VARCHAR(50) = 'AJORTIZP';
DECLARE @FlagEnabledArticle INT = 1;
DECLARE @FlagShowDefaultArticle INT = 0;
DECLARE @DateCreated DATETIME = GETDATE();
DECLARE @NewArticleId INT = -1;
DECLARE @ExistArticleId INT = -1;

BEGIN TRANSACTION;

BEGIN TRY
	IF NOT EXISTS (SELECT * FROM dbo.CatArticle WHERE UPPER(ArtName) = UPPER(@ArticleName))
    BEGIN
		INSERT INTO dbo.CatArticle
		(
			ArtIdTypeArticle,
			ArtName,
			ArtShowDefault,
			ArtRowStatus,
			ArtTokenCreated,
			ArtDateCreated
		)
		VALUES
		(
			@IdTypeArticle,
			@ArticleName,
			@FlagShowDefaultArticle,
			@FlagEnabledArticle,
			@Token,
			@DateCreated
		);

		SET @NewArticleId = SCOPE_IDENTITY();
	END
	ELSE
	BEGIN
		SELECT @ExistArticleId = ArtId 
		FROM dbo.CatArticle 
		WHERE UPPER(ArtName) = UPPER(@ArticleName);
	END
END TRY
BEGIN CATCH
	SELECT 'RollBackTransaction' AS message,
			-1 AS ArtId,
			@IdTypeArticle AS ArtIdTypeArticle,
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
	IF @NewArticleId <> -1
	BEGIN
		SELECT	'Succesfull' AS message,
				@NewArticleId AS ArtId,
				@IdTypeArticle AS ArtIdTypeArticle,
				'TRUE' blnResult,
				CAST(@NewArticleId AS VARCHAR(50)) IdResult,
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
			@ExistArticleId AS ArtId,
			@IdTypeArticle AS ArtIdTypeArticle,
			'FALSE' blnResult,
			CAST(@ExistArticleId AS VARCHAR(50)) IdResult,
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
