USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_delete_articlebycustomer_from_articlebycustomer]    Script Date: 9/07/2021 19:53:56 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_delete_articlebycustomer_from_articlebycustomer]
	@IdABC INT,
	@TokenUpdated VARCHAR(50)
AS
BEGIN

--DECLARE @IdABC INT = 12;
--DECLARE @TokenUpdated VARCHAR(50) = 'AJORTIZP';
DECLARE @AbcRowStatus INT = 0;
DECLARE @DateUpdated DATETIME = GETDATE();

BEGIN TRANSACTION;

BEGIN TRY
	UPDATE dbo.ArticleByCustomer
	SET AbcTokenUpdated = @TokenUpdated,
		AbcDateUpdated = @DateUpdated,
		AbcRowStatus = @AbcRowStatus
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


