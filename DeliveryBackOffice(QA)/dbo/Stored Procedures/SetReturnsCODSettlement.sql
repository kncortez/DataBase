-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-02-23>
-- Description:	<Registra liquidación en rutas de devoluciones COD>
-- =============================================
CREATE PROCEDURE [dbo].[SetReturnsCODSettlement]
	-- Add the parameters for the stored procedure here
	@InGuides NVARCHAR(MAX),
	@ManifestId INT,
	@Token NVARCHAR(150)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Control actualización
	DECLARE @RModified INT
	-- Tabla con las guías 
	DECLARE @GuidesTable TABLE (GuideSerie NVARCHAR(2), GuideNumber INT)

    BEGIN TRANSACTION

		BEGIN TRY
			

			-- Convertir la lista de guías separadas por coma en una tabla
			INSERT INTO @GuidesTable
			SELECT SUBSTRING(Item, 1,2) ItemSerie,SUBSTRING(Item,3,len(Item)) ItemNumber 
			FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides,',')

			-- Actualizar guía en liquidación COD
			UPDATE sbpd
			SET 
				CODSettlement_TokenCreated = @Token, 
				CODSettlement_DateCreated = GETDATE(), 
				IsCODSettlement = 1 -- guía liquidada en COD
			FROM SettlementByPickupDetail sbpd
			INNER JOIN SettlementByPickup sbp
				ON sbp.Id = sbpd.SettlementByPickupId
			INNER JOIN @GuidesTable t 
				ON sbpd.GuideSerie = t.GuideSerie 
				AND sbpd.GuideNumber = t.GuideNumber
			WHERE sbp.SequenceCode = @ManifestId
				AND sbpd.IsPieceLiquidaded = 1

			SET @RModified = @@ROWCOUNT
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
			IF (@RModified > 0)
				SELECT			  
					1 AS 'StatusCode',
					'Registro guardado correctamente' AS 'Description', 
					@@TRANCOUNT AS 'NumTransferID'
			ELSE
				SELECT			  
					0 AS 'StatusCode',
					'Registro no encontrado' AS 'Description', 
					0 AS 'NumTransferID'

			COMMIT TRANSACTION;			
		END
		ELSE
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID'
END
