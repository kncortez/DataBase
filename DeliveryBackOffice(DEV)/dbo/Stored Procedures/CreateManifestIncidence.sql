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
	@CountryId VARCHAR(2)
AS
BEGIN
	SET NOCOUNT ON;

	-- Control de guardado
	DECLARE @Saved INT
	DECLARE @CourierId INT

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
			   ,[TokenValidator]
			   ,[CatManifestSettlementIncidenceTypeId]
			   ,[IncidenceComment]
			   ,[ResolutionComment]
			   ,[CountryId]
			   ,[RowStatus]
			   ,[DateCreated]
			   ,[TokenCreated]
			   ,[DateUpdated]
			   ,[TokenUpdated])
		 VALUES
			   (@CatRouteId
			   ,@CourierId
			   ,@ManifestNumber
			   ,@TotalAmount
			   ,@GuidesQuantity
			   ,@TotalNumberOfPieces
			   ,NULL
			   ,NULL
			   ,@CatManifestSettlementIncidenceTypeId
			   ,@IncidenceComment
			   ,NULL
			   ,@CountryId
			   ,1
			   ,GETDATE()
			   ,@TokenCreated
			   ,NULL
			   ,NULL)

			   SET @Saved = @@ROWCOUNT
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