USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Morales,Oscar>
-- Create date: <2021-09-02>
-- Description:	<Registra liquidación en rutas recolectoras COD>
-- =============================================
CREATE PROCEDURE [dbo].[SetRoutePickUpCODSettlement]
	-- Add the parameters for the stored procedure here
	@InGuides NVARCHAR(MAX),
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
				TokenUpdated = @Token, 
				DateUpdated = GETDATE(), 
				IsCODSettlement = 1 -- guía liquidada en COD
			FROM SettlementByPickupDetail sbpd
			INNER JOIN @GuidesTable t 
				ON sbpd.GuideSerie = t.GuideSerie 
				AND sbpd.GuideNumber = t.GuideNumber
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