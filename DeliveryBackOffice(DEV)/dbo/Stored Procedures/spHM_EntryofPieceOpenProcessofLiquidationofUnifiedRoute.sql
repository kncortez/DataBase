-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-10-06>
-- Description:	<SP ingreso de pieza de guía en proceso abierto de liquidación de ruta unificada>
-- =============================================

CREATE PROCEDURE [dbo].[spHM_EntryofPieceOpenProcessofLiquidationofUnifiedRoute]
@GuideSerie  AS NVARCHAR(2),
@GuideNumber AS INT,
@PieceNumber AS INT,
@Token AS NVARCHAR(50)

AS
BEGIN

    DECLARE @IdUnifiedRouteSettlementDetail AS INT
	DECLARE @Result AS INT = 0; 

	SELECT @IdUnifiedRouteSettlementDetail=IdUnifiedRouteSettlementDetail  
	FROM dbo.UnifiedRouteSettlementDetail WITH(NOLOCK)
    WHERE GuideSerie = @GuideSerie AND 
	      GuideNumber = @GuideNumber

  
   
	SET NOCOUNT ON;

BEGIN TRANSACTION
BEGIN TRY

	IF (EXISTS(
	SELECT TOP 1 1 
	FROM dbo.ActDetail AD WITH(NOLOCK)
	INNER JOIN dbo.ActDetailPiece ADP WITH(NOLOCK)
	ON AD.IdActDetail = ADP.ActDetailId
	WHERE AD.GuideSerie  = @GuideSerie  AND 
	      AD.GuideNumber = @GuideNumber AND
		  AD.RowStatus   = 1 AND
		  ADP.PieceNumber = @PieceNumber
		  ))
	BEGIN

	UPDATE ADP 
	SET ADP.DateRevoke = GETDATE(),
	    ADP.UserRevoke = @Token,
		ADP.RowStatus  = 0
		FROM dbo.ActDetail AD WITH(NOLOCK)
	INNER JOIN dbo.ActDetailPiece ADP WITH(NOLOCK)
	ON AD.IdActDetail = ADP.ActDetailId
	WHERE AD.GuideSerie  = @GuideSerie  AND 
	      AD.GuideNumber = @GuideNumber AND
		  AD.RowStatus   = 1 AND
		  ADP.PieceNumber = @PieceNumber

	END
		IF(EXISTS(
		SELECT TOP 1 1  FROM dbo.UnifiedRouteSettlement a
		INNER JOIN  dbo.UnifiedRouteSettlementDetail b
		ON a.IdUnifiedRouteSettlement = b.UnifiedRouteSettlementId
		 WHERE b.GuideSerie=@GuideSerie  AND B.GuideNumber = @GuideNumber AND b.RowStatus = 1 AND  b.IsOpenProcess=1 and b.UserProcess IS NOT NULL  )
		)
		BEGIN
				INSERT INTO  dbo.UnifiedRouteSettlementDetailPiece 
				(
				UnifiedRouteSettlementDetailId,
				PieceNumber,
				IsDryPiece,
				ActCode,
				RowStatus,
				TokenCreated,
				DateCreated
				)
				VALUES
				(
				@IdUnifiedRouteSettlementDetail,
				@PieceNumber,
				(SELECT CASE WHEN X.IsDry = 1 THEN 1 ELSE 0 END FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] X
				WHERE GuideSerie=@GuideSerie AND GuideNumber=@GuideNumber AND NoPiece= @PieceNumber),
				0,
				1,
				@Token,
				GETDATE()
				)
		END
		SET @RESULT = 1; /* PROCESESO EXITOSO */
		COMMIT TRANSACTION

		END TRY
		BEGIN CATCH

			ROLLBACK TRANSACTION

			SET @RESULT = 2; /* PROCESESO FALLIDO */

		END CATCH
		 SELECT @Result AS Result
END