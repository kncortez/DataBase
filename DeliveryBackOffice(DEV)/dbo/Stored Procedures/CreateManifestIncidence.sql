-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-09-20>
-- Description: <Guarda la incidencia en el proceso de liquidación de rutas asociandolo a un manifiesto>
-- =============================================
CREATE PROCEDURE [dbo].[CreateManifestIncidence]
	@CatRouteId INT,
	@ManifestNumber INT,
	@TotalAmount DECIMAL(14,2),
	@GuidesQuantity SMALLINT,
	@TotalNumberOfPieces SMALLINT,
	@CatManifestSettlementIncidenceTypeId INT,
	@IncidenceComment NVARCHAR(300),
	@TokenCreated NVARCHAR(50),
	@CountryId VARCHAR(2),	
    @ListOfGuidesAsCSV NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	-- Control de guardado
	DECLARE @Saved INT
	DECLARE @CourierId INT
	DECLARE @NewManifestSettlementIncidenciaID INT

	-- Tabla para manejar las guías 
	DECLARE @ListOfGuides TABLE (GuideSerie NVARCHAR(2), GuideNumber INT)

		-- Convertir la lista de guías separadas por coma en una tabla
	INSERT INTO @ListOfGuides
	SELECT SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
	FROM DeliveryBackOffice.dbo.SplitUnlimited(@ListOfGuidesAsCSV,',')

	SET @CourierId = (SELECT ID_Courier 
						FROM DeliveryOrderBySettlement 
						WHERE ID = @ManifestNumber)

    BEGIN TRANSACTION
		BEGIN TRY	

			INSERT INTO [dbo].[ManifestSettlementIncidence]
			   ([CatRouteId]
			   ,[CourierId]
			   ,[ManifestNumber]
			   ,[TotalAmount]
			   ,[GuidesQuantity]
			   ,[TotalNumberOfPieces]
			   ,[IncidenceApproved]
			   ,[CatManifestSettlementIncidenceTypeId]
			   ,[IncidenceComment]
			   ,[ResolutionComment]
			   ,[CountryId]
			   ,[RowStatus]
			   ,[DateCreated]
			   ,[TokenCreated]
			   ,[DateUpdated]
			   ,[TokenUpdated]
			   ,[isCOD])
		 VALUES
			   (@CatRouteId
			   ,@CourierId
			   ,@ManifestNumber
			   ,@TotalAmount
			   ,@GuidesQuantity
			   ,@TotalNumberOfPieces
			   ,0
			   ,@CatManifestSettlementIncidenceTypeId
			   ,@IncidenceComment
			   ,NULL
			   ,@CountryId
			   ,1
			   ,GETDATE()
			   ,@TokenCreated
			   ,NULL
			   ,NULL
			   ,0)

			   SET @NewManifestSettlementIncidenciaID = SCOPE_IDENTITY();
			   SET @Saved = @@ROWCOUNT

			   -- Registrar listado de guías no liquidadas en liquidación de entregas
				INSERT INTO ManifestSettlementIncidenceDetail (Guide_Serie,Guide_Number,ManifestSettlementIncidenceId,RowStatus,TokenCreated,DateCreated)
				SELECT do.Guide_Serie, do.Guide_Number, @NewManifestSettlementIncidenciaID, 1, @TokenCreated, GETDATE()
				FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
					INNER JOIN @ListOfGuides t 
						ON do.Guide_Serie = t.GuideSerie 
						AND do.Guide_Number = t.GuideNumber
				WHERE ISNULL(do.SenderCountryId, 'GT') = @CountryId

			   -- Actualizar manifiesto
			   UPDATE dsd
			   SET dsd.Guide_Settlement = 1, dsd.Guide_Returned = 0, dsd.Guide_Delivered = 0, dsd.StatusOrderId = do.StatusOrderId
			   FROM [dbo].[DeliverySettlementDetail] dsd
					INNER JOIN [dbo].[DeliveryOrder] do
						ON dsd.Guide_Number = do.Guide_Number
						AND dsd.Guide_Serie = do.Guide_Serie
					INNER JOIN @ListOfGuides t 
						ON do.Guide_Serie = t.GuideSerie 
						AND do.Guide_Number = t.GuideNumber
				WHERE ISNULL(do.SenderCountryId, 'GT') = @CountryId    
		END TRY
		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
			ROLLBACK TRANSACTION
		END CATCH;

		IF @@TRANCOUNT > 0
		BEGIN
			IF (@Saved > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
END
