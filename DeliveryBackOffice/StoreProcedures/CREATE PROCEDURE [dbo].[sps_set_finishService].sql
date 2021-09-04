USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sp_put_articlebycustomer_in_articlebycustomer]    Script Date: 9/07/2021 23:21:48 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sps_set_finishService]
	@InGuidesP VARCHAR(MAX),
	@IdModuleP INT,
	@TokenP VARCHAR(100)
AS
BEGIN

DECLARE @DateCreated DATETIME = GETDATE();

BEGIN TRANSACTION;

BEGIN TRY
	-- Insert statements for procedure here
	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
	IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL DROP TABLE #listGuidesEnabled;
	IF OBJECT_ID('tempdb.dbo.#listGuidesDisabled', 'U') IS NOT NULL DROP TABLE #listGuidesDisabled;

	-- CONVERTIR CADENA DE GUIAS A UNA TABLA ------------------------------------------------
	CREATE TABLE #listGuides
	(
		Guide_Serie NVARCHAR(2),
		Guide_Number INT
	);
	
	CREATE NONCLUSTERED INDEX tempSerie ON #listGuides (Guide_Serie);
	CREATE NONCLUSTERED INDEX tempGuide ON #listGuides (Guide_Number);
	
	INSERT INTO #listGuides
	(
		Guide_Serie,
		Guide_Number
	)
	SELECT SUBSTRING(Item, 1, 2) Guide_Serie, 
		   SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 3))) Guide_Number
	FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuidesP, ',');
	------------------------------------------------------------------------------------------------

	-- OBTENER GUIAS HABILITADAS ---------------------------------------------------------------------
	CREATE TABLE #listGuidesEnabled
	(
		Guide_Serie NVARCHAR(2),
		Guide_Number INT
	);
	
	CREATE NONCLUSTERED INDEX IX_LGE_SERIE ON #listGuidesEnabled (Guide_Serie);
	CREATE NONCLUSTERED INDEX IX_LGE_NUMBER ON #listGuidesEnabled (Guide_Number);
	
	INSERT INTO #listGuidesEnabled
	(
		Guide_Serie,
		Guide_Number
	)
	SELECT lg.Guide_Serie,
		   lg.Guide_Number
	FROM #listGuides lg
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
		ON lg.Guide_Serie = do.Guide_Serie
		AND lg.Guide_Number = do.Guide_Number
	WHERE do.StatusOrderId <> 7;
	-----------------------------------------------------------------------------------------------------

	-- OBTENER GUIAS DESHABILITADAS ---------------------------------------------------------------------
	CREATE TABLE #listGuidesDisabled
	(
		Guide_Serie NVARCHAR(2),
		Guide_Number INT
	);
	
	CREATE NONCLUSTERED INDEX IX_LGD_SERIE ON #listGuidesDisabled (Guide_Serie);
	CREATE NONCLUSTERED INDEX IX_LGD_NUMBER ON #listGuidesDisabled (Guide_Number);
	
	INSERT INTO #listGuidesDisabled
	(
		Guide_Serie,
		Guide_Number
	)
	SELECT lg.Guide_Serie,
		   lg.Guide_Number
	FROM #listGuides lg
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
		ON lg.Guide_Serie = do.Guide_Serie
		AND lg.Guide_Number = do.Guide_Number
	WHERE do.StatusOrderId = 7;
	-----------------------------------------------------------------------------------------------------

	INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
		(
			Guide_Serie,
			Guide_Number,
			StatusOrderId,
			UserCreated,
			DateCreated,
			DateCreatedInSystem
		)
	SELECT lge.Guide_Serie,
		   lge.Guide_Number,
		   CASE @IdModuleP
				WHEN 34 THEN 2
				WHEN 35 THEN 5
				WHEN 36 THEN 14
			END StatusOrderId,
		   @TokenP UserCreated,
		   @DateCreated DateCreated,
		   @DateCreated DateCreatedInSystem
	FROM #listGuidesEnabled lge;
END TRY
BEGIN CATCH
	SELECT 'ERROR' AS message,
			'FALSE'	blnResult,
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
	SELECT	'OK' AS message,
			'TRUE' blnResult,
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


