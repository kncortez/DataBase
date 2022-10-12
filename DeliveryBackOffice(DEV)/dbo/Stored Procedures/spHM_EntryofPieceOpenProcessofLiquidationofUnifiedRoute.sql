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
	DECLARE @ResultMessage NVARCHAR(50) = '';

	-- Última liquidación iniciada de la guía correspondiente
	SELECT 
		@IdUnifiedRouteSettlementDetail = URSD.IdUnifiedRouteSettlementDetail  
	FROM 
		dbo.UnifiedRouteSettlementDetail URSD WITH(NOLOCK)
    WHERE 
		GuideSerie = @GuideSerie
		AND 
	    GuideNumber = @GuideNumber
		AND 
		IsOpenProcess=1 
		AND 
		UserProcess IS NOT NULL
	ORDER BY
		URSD.DateCreated DESC

	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY

		-- Extraer pieza de acta si existe
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

		-- Verificar que la guía este dentro de la liquidación en un proceso abierto
		IF(
			EXISTS(
				SELECT 
					TOP 1 
						1 
				FROM dbo.UnifiedRouteSettlement a
				INNER JOIN  dbo.UnifiedRouteSettlementDetail b
				ON a.IdUnifiedRouteSettlement = b.UnifiedRouteSettlementId
				WHERE b.GuideSerie=@GuideSerie  AND B.GuideNumber = @GuideNumber AND b.RowStatus = 0 AND  b.IsOpenProcess=1 and b.UserProcess IS NOT NULL
			)
		)
		BEGIN

			-- Verificar que la pieza no este ingresada a la liquidación
			IF(
				NOT EXISTS (
					SELECT TOP 1 1
					FROM dbo.UnifiedRouteSettlement a
					INNER JOIN  dbo.UnifiedRouteSettlementDetail b
					ON a.IdUnifiedRouteSettlement = b.UnifiedRouteSettlementId
					INNER JOIN dbo.UnifiedRouteSettlementDetailPiece c
					ON b.IdUnifiedRouteSettlementDetail = c.UnifiedRouteSettlementDetailId
					WHERE b.GuideSerie=@GuideSerie  AND B.GuideNumber = @GuideNumber AND c.PieceNumber = @PieceNumber
				)
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
					(SELECT CASE WHEN X.IsDry = 1 THEN 1 ELSE 0 END FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] X WHERE GuideSerie=@GuideSerie AND GuideNumber=@GuideNumber AND NoPiece= @PieceNumber),
					NULL,
					0,
					@Token,
					GETDATE()
				)

				SET @Result = 1; /* PROCESESO EXITOSO */
				SET @ResultMessage = 'Pieza ingresada exitosamente'

				COMMIT TRANSACTION
			END
			ELSE
			BEGIN
			
				ROLLBACK TRANSACTION

				SET @Result = 3; /* PROCESESO FALLIDO */
				SET @ResultMessage = 'Pieza indicada ya existe dentro de liquidación'

			END
		END
		ELSE
		BEGIN

			ROLLBACK TRANSACTION

			SET @Result = 2; /* PROCESESO FALLIDO */
			SET @ResultMessage = 'Problemas al ingresar la pieza indicada'

		END

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION

		SET @Result = 2; /* PROCESESO FALLIDO */
		SET @ResultMessage = 'Problemas al ingresar la pieza indicada'

	END CATCH

	-- Respuesta
	SELECT 
		@Result AS Result,
		@ResultMessage AS ResultMessage,
		@GuideSerie 'GuideSerie',
		@GuideNumber 'GuideNumber',
		@PieceNumber 'PieceNumber'

END