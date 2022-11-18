-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2020-10-25>
-- Description:	<Liquidación de rutas unificadas COD en desktop>
-- =============================================
CREATE PROCEDURE [dbo].[SetCODUnifiedRouteSettlement]
	-- Add the parameters for the stored procedure here
	@StationId INT,
	@Token NVARCHAR(50),
	@Table TblId READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	BEGIN TRANSACTION

	BEGIN TRY

		UPDATE ursd 
		SET ursd.UserCODSettlement = @Token
			,ursd.DateCODSettlement = GETDATE()
			,ursd.TokenUpdated = @Token
			,ursd.DateUpdated = GETDATE()
		FROM UnifiedRouteSettlementDetail ursd
		INNER JOIN @Table tbl
			ON ursd.IdUnifiedRouteSettlementDetail = tbl.Id
		
		UPDATE urs
		SET urs.CODSettlementStation = @StationId
		   ,urs.TotalCODGuidesSettled += (SELECT
					COUNT(1)
				FROM UnifiedRouteSettlement urs2
				INNER JOIN UnifiedRouteSettlementDetail ursd2
					ON urs2.IdUnifiedRouteSettlement = ursd2.UnifiedRouteSettlementId
				INNER JOIN @Table tbl2
					ON ursd2.IdUnifiedRouteSettlementDetail = tbl2.Id
				WHERE urs2.IdUnifiedRouteSettlement = urs.IdUnifiedRouteSettlement)
		   ,urs.UserCODSettlement = @Token
		   ,urs.DateCODSettlement = GETDATE()
		   ,urs.TokenUpdated = @Token
		   ,urs.DateUpdated = GETDATE()
		FROM UnifiedRouteSettlement urs
		INNER JOIN UnifiedRouteSettlementDetail ursd
			ON urs.IdUnifiedRouteSettlement = ursd.UnifiedRouteSettlementId
		INNER JOIN @Table tbl
			ON ursd.IdUnifiedRouteSettlementDetail = tbl.Id

		COMMIT TRANSACTION

		SELECT
			1 'StatusCode'
		   ,'Operación exitosa.' 'Description'
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT
			0 'StatusCode'
		   ,ERROR_MESSAGE() 'Description'
	END CATCH
END