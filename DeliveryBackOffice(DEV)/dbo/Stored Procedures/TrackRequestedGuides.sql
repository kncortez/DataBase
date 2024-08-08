
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-08-12>
-- Description:	< Obtener datos de guías necesarios para reporte de incidencias de SAC >
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-06-28>
-- Description:	<Se agrega parametro que indica pais para filtra por tipo de guia(DOM o INT)>
-- =============================================
CREATE PROCEDURE [dbo].[TrackRequestedGuides]
	@GuideList NVARCHAR(MAX),
	@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN

	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;
	IF OBJECT_ID('tempdb.dbo.#ResponseTable', 'U') IS NOT NULL
			DROP TABLE #ResponseTable;

	CREATE TABLE #listGuides (
		ItemSerie NVARCHAR(2),
		ItemNumber INT
	);

	CREATE NONCLUSTERED INDEX Temp_GuideSplit ON #listGuides (ItemSerie, ItemNumber);
	
	CREATE TABLE #ResponseTable (
		GUIA NVARCHAR(50),
		[ESTADO ACTUAL] NVARCHAR(200),
		UBICACION NVARCHAR(50),
		REMITENTE NVARCHAR(200),
		[DESPACHADO A RUTA] DATETIME
	);

	BEGIN TRY

		INSERT INTO #listGuides
		SELECT 
			CAST(SUBSTRING(Item, 1, 2) AS NVARCHAR) ItemSerie,
            CAST(SUBSTRING(Item, 3, IIF(CHARINDEX('-', Item) = 0, (LEN(Item)), (CHARINDEX('-', Item) - 1))) AS INT) ItemNumber
        FROM 
			DeliveryBackOffice.dbo.SplitUnlimited(@GuideList, ',');

		INSERT INTO
			#ResponseTable
		SELECT 
			   CAST(CONCAT(do.Guide_Serie, do.Guide_Number) AS NVARCHAR) GUIA,
			   so.OrderDescription 'ESTADO ACTUAL',
			   wh.Rack_Position UBICACION,
			   CAST(CONCAT(do.Sender_FirstName, do.Sender_LastName) AS NVARCHAR) REMITENTE,
			   do.Dispatched_Date 'DESPACHADO A RUTA'
		FROM 
			DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
			INNER JOIN
				#listGuides LG
				ON
					do.Guide_Serie = LG.ItemSerie
					AND
					do.Guide_Number = LG.ItemNumber
			INNER JOIN 
				DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
				ON 
					so.StatusOrderId = do.StatusOrderId
			LEFT JOIN 
				DeliveryBackOffice.dbo.Warehouse wh WITH (NOLOCK)
				ON 
					wh.Guide_Serie = do.Guide_Serie
					AND 
					wh.Guide_Number = do.Guide_Number
					AND 
					wh.Active = 1
		WHERE (ISNULL(do.GuideType,'DOM')='INT' OR (ISNULL(do.SenderCountryId,'GT')=@IdCountry AND ISNULL(do.GuideType,'DOM')='DOM'))

		IF( EXISTS( SELECT TOP 1 1 FROM #ResponseTable ) )
		BEGIN

			SELECT
				CAST(1 AS BIT) [blnResult]

			SELECT
				RT.GUIA,
				RT.[ESTADO ACTUAL],
				RT.UBICACION,
				RT.REMITENTE,
				RT.[DESPACHADO A RUTA]
			FROM
				#ResponseTable RT

		END
		ELSE
		BEGIN

			SELECT
				CAST(0 AS BIT) [blnResult]

		END

	END TRY
	BEGIN CATCH

		SELECT
			CAST(0 AS BIT) [blnResult]

	END CATCH
	
	IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
			DROP TABLE #listGuides;
	IF OBJECT_ID('tempdb.dbo.#ResponseTable', 'U') IS NOT NULL
			DROP TABLE #ResponseTable;

END