-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-10-05>
-- Description:	<SP para cancelar un proceso abierto de un proceso de liquidación de ruta unificada>
CREATE PROCEDURE [dbo].[spHM_CancelOpenProcessLiquidationUnifiedRoutes] 
@GuideSerie AS NVARCHAR(2),
@GuideNumber AS INT,
@Token AS NVARCHAR(50),
@IdCourier AS INT,
@DateRoute AS DATETIME	
AS
BEGIN

      DECLARE @IdDetail AS INT;
	  DECLARE @Result AS INT = 0; /* 0 GUÍA SIN PROCESO ABIERTO */
	  DECLARE @IdRouteAssignment AS INT 
	  DECLARE @TotalPiecesSettled AS INT
	  DECLARE @IdRoute AS INT
	  DECLARE @TotalPiecesMissing AS INT
	  
	SET NOCOUNT ON;
	 
	IF (EXISTS(SELECT TOP 1 1 FROM dbo.UnifiedRouteSettlementDetail WHERE GuideSerie=@GuideSerie AND GuideNumber=@GuideNumber AND IsOpenProcess = 1 AND UserProcess = @Token))
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY
		
			UPDATE  URSDP
			SET     
					RowStatus= 0,
					TokenUpdated= @Token,
					DateUpdated=GETDATE()
					FROM 
					[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
					INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlement]  URS WITH (NOLOCK)
					ON URS.RouteAssignmentId = RA.IdRouteAssigment
					INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
					ON URS.IdUnifiedRouteSettlement =URSD.UnifiedRouteSettlementId
					AND URSD.GuideSerie = @GuideSerie
					AND URSD.GuideNumber = @GuideNumber
					AND URSD.IsOpenProcess = 1
					AND URSD.UserProcess = @Token
					INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDP WITH(NOLOCK)
					ON URSD.IdUnifiedRouteSettlementDetail = URSDP.UnifiedRouteSettlementDetailId
			WHERE   
				   RA.IdCurrierMan = @IdCourier
				   AND RA.DateOfRoute = CAST(@DateRoute AS DATE)
				   
			UPDATE  URSD
			SET     UserProcess   = NULL, 
					IsOpenProcess = 0,
					RowStatus= 0,
					TokenUpdated= @Token,
					DateUpdated=GETDATE()
					FROM 
					[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlement]  URS WITH (NOLOCK)
						ON URS.RouteAssignmentId = RA.IdRouteAssigment
						INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
						ON URS.IdUnifiedRouteSettlement =URSD.UnifiedRouteSettlementId
						AND URSD.GuideSerie = @GuideSerie
						AND URSD.GuideNumber = @GuideNumber
						AND URSD.IsOpenProcess = 1
						AND URSD.UserProcess = @Token
				WHERE   
					   RA.IdCurrierMan = @IdCourier
					   AND RA.DateOfRoute = CAST(@DateRoute AS DATE)
					   
			--- Actualizar conteos de piezas por guía
			UPDATE
				URSD
			SET
				URSD.PiecesSettled = TotalPieces.TotalSettled,
				URSD.PiecesMissing = TotalPieces.TotalMissing
			FROM 
				[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
				INNER JOIN
				(
					SELECT
						URSD.IdUnifiedRouteSettlementDetail,
						COUNT(DISTINCT URSDPreal.IdUnifiedRouteSettlementDetailPiece) 'TotalSettled',
						COUNT(DISTINCT URSDPmiss.IdUnifiedRouteSettlementDetailPiece) 'TotalMissing'
					FROM
						[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlement]  URS WITH (NOLOCK)
						ON URS.RouteAssignmentId = RA.IdRouteAssigment
						INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
						ON URS.IdUnifiedRouteSettlement =URSD.UnifiedRouteSettlementId
						AND URSD.RowStatus = 1
						LEFT JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDPreal WITH(NOLOCK)
						ON URSD.IdUnifiedRouteSettlementDetail = URSDPreal.UnifiedRouteSettlementDetailId
						AND URSDPreal.RowStatus = 1
						AND URSDPreal.ActCode IS NULL
						LEFT JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDPmiss WITH(NOLOCK)
						ON URSD.IdUnifiedRouteSettlementDetail = URSDPmiss.UnifiedRouteSettlementDetailId
						AND URSDPmiss.RowStatus = 1
						AND URSDPreal.ActCode IS NOT NULL
					WHERE   
						   RA.IdCurrierMan = @IdCourier
						   AND RA.DateOfRoute = CAST(@DateRoute AS DATE)
					GROUP BY
						URSD.IdUnifiedRouteSettlementDetail
				) TotalPieces
				ON
					URSD.IdUnifiedRouteSettlementDetail = TotalPieces.IdUnifiedRouteSettlementDetail
				INNER JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSDaux WITH(NOLOCK)
					ON
						URSDaux.UnifiedRouteSettlementId = URSD.UnifiedRouteSettlementId
						AND
						URSDaux.GuideSerie = @GuideSerie
						AND
						URSDaux.GuideNumber = @GuideNumber

			--- Actualizar la preparación de ruta en base a los datos almacenados
			UPDATE
				URS
			SET
				URS.TotalGuidesSettled = TotalPieces.TotalGuides
				,URS.TotalPiecesSettled = TotalPieces.TotalSettled
				,URS.TotalPiecesMissing = TotalPieces.TotalMissing
			FROM 
				[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] URS WITH(NOLOCK)
				INNER JOIN
				(
					SELECT
						URS.IdUnifiedRouteSettlement,
						COUNT(DISTINCT URSD.GuideNumber) 'TotalGuides',
						COUNT(DISTINCT URSDPreal.IdUnifiedRouteSettlementDetailPiece) 'TotalSettled',
						COUNT(DISTINCT URSDPmiss.IdUnifiedRouteSettlementDetailPiece) 'TotalMissing'
					FROM
						[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
						INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlement]  URS WITH (NOLOCK)
						ON URS.RouteAssignmentId = RA.IdRouteAssigment
						INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
						ON URS.IdUnifiedRouteSettlement =URSD.UnifiedRouteSettlementId
						AND URSD.RowStatus = 1
						LEFT JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDPreal WITH(NOLOCK)
						ON URSD.IdUnifiedRouteSettlementDetail = URSDPreal.UnifiedRouteSettlementDetailId
						AND URSDPreal.RowStatus = 1
						AND URSDPreal.ActCode IS NULL
						LEFT JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDPmiss WITH(NOLOCK)
						ON URSD.IdUnifiedRouteSettlementDetail = URSDPmiss.UnifiedRouteSettlementDetailId
						AND URSDPmiss.RowStatus = 1
						AND URSDPreal.ActCode IS NOT NULL
					WHERE   
						   RA.IdCurrierMan = @IdCourier
						   AND RA.DateOfRoute = CAST(@DateRoute AS DATE)
					GROUP BY
						URS.IdUnifiedRouteSettlement
				) TotalPieces
				ON
					URS.IdUnifiedRouteSettlement = TotalPieces.IdUnifiedRouteSettlement
				INNER JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSDaux WITH(NOLOCK)
					ON
						URSDaux.UnifiedRouteSettlementId = URS.IdUnifiedRouteSettlement
						AND
						URSDaux.GuideSerie = @GuideSerie
						AND
						URSDaux.GuideNumber = @GuideNumber

			------------------------------------
			SET @RESULT = 1; /* PROCESESO EXITOSO */
		COMMIT TRANSACTION
		
        END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @RESULT = 2; /* PROCESESO FALLIDO */
			END  CATCH
	END 
	ELSE
	BEGIN
		SET @RESULT = 2; /* PROCESESO FALLIDO */
	END
	 
	 SELECT @Result AS Result;				

END