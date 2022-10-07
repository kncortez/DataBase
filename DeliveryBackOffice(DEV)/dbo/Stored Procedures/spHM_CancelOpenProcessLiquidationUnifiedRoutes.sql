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
	  
	  SELECT @IdRouteAssignment=IdRouteAssigment,
	        @IdRoute = IdRoute
	  FROM dbo.RouteAssigment RA WITH (NOLOCK) 
	  WHERE RA.IdCurrierMan=@IdCourier AND RA.DateOfRoute=FORMAT(@DateRoute,'yyyy-MM-dd')

	  select *   FROM dbo.RouteAssigment RA WITH (NOLOCK) 
		SELECT @TotalPiecesMissing = COUNT(PieceNumber)  FROM  dbo.Act A WITH (NOLOCK)
		INNER JOIN 
		dbo.ActDetail AD WITH (NOLOCK)
		ON A.IdAct = AD.ActId
		INNER JOIN dbo.ActDetailPiece ADP WITH (NOLOCK)
		ON AD.IdActDetail= ADP.ActDetailId
		WHERE AD.GuideSerie=GuideSerie AND 
			  AD.GuideNumber=@GuideNumber AND 
			  ADP.RowStatus = 1   AND
			  A.CatRouteId = @IdRoute
			  

       SELECT @TotalPiecesSettled= COUNT(NoPiece) - @TotalPiecesMissing 
	   FROM dbo.DeliveryOrderPiece WITH (NOLOCK)
	   WHERE GuideSerie=@GuideSerie and GuideNumber=@GuideNumber

	SET NOCOUNT ON;
	 
		SELECT @IdDetail = ISNULL(LRPCD.IdUnifiedRouteSettlementDetail,0)
					FROM [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] LRPCD WITH (NOLOCK)
					WHERE LRPCD.GuideSerie  = @GuideSerie   AND 
						  LRPCD.GuideNumber = @GuideNumber  AND 
						  LRPCD.UserProcess  = @Token       AND 
						  LRPCD.IsOpenProcess = 1

	IF (@IdDetail > 0 OR  @IdDetail IS NOT NULL)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			UPDATE [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] 
			SET    UserProcess = NULL,
				   IsOpenProcess = 0,
				   RowStatus = 0
			WHERE  GuideSerie   =  @GuideSerie   AND 
				   GuideNumber  =  @GuideNumber  AND 
				   UserProcess   =  @Token        AND 
				   IsOpenProcess = 1;
           
		   UPDATE [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece]
		   SET RowStatus =0
		   WHERE UnifiedRouteSettlementDetailId = @IdDetail;

		   --- Actualizar los tipos de pieza del detalle de la preparación de ruta segun lo almacenado
			UPDATE RPDP
			SET RPDP.IsDryPiece = (CASE WHEN DOP.IsDry = 1 THEN 1 ELSE 0 END)
			FROM
				[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] RPDP WITH(NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] RPD WITH(NOLOCK)
					ON
						RPDP.UnifiedRouteSettlementDetailId = RPD.IdUnifiedRouteSettlementDetail
						AND
						RPD.RowStatus = 1
				INNER JOIN
					[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] RP WITH(NOLOCK)
					ON
						RPD.UnifiedRouteSettlementId= RP.IdUnifiedRouteSettlement
						AND
						RP.RowStatus = 1
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
					ON
						RPD.GuideSerie = DOP.GuideSerie
						AND
						RPD.GuideNumber = DOP.GuideNumber
						
			WHERE
				RP.RouteAssignmentId = @IdRouteAssignment -- Validar Ruta asignada
				AND
				RP.DateSettlement = @DateRoute -- validar si el campo de comparación es la fecha de liquidación asignada en la tabla
				AND
				RPDP.RowStatus = 1

			--- Actualizar la preparación de ruta en base a los datos almacenados
			UPDATE RP
			SET
				RP.TotalGuidesSettled = ISNULL(RPA.RealGuideQuantity,0),
				RP.TotalPiecesSettled = ISNULL(@TotalPiecesSettled ,0),-- Piezas liquidadas
				RP.TotalPiecesMissing= ISNULL(@TotalPiecesMissing ,0) -- Piezas en actas
				
			FROM 
				[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] RP WITH(NOLOCK)
				LEFT JOIN
				(
				
					SELECT
						RPA.IdUnifiedRouteSettlement,
						COUNT (DISTINCT RPD.IdUnifiedRouteSettlementDetail) 'RealGuideQuantity'
						
					FROM
						[DeliveryBackOffice].[dbo].[UnifiedRouteSettlement] RPA WITH(NOLOCK)
					INNER JOIN
							[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] RPD WITH(NOLOCK)
							ON
								RPA.IdUnifiedRouteSettlement = RPD.UnifiedRouteSettlementId
								AND
								RPD.RowStatus = 1
					INNER JOIN
							[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] RPDP WITH(NOLOCK)
							ON
								RPD.IdUnifiedRouteSettlementDetail = RPDP.UnifiedRouteSettlementDetailId
								AND
								RPDP.RowStatus = 1
					WHERE
						RPA.RouteAssignmentId = @IdRouteAssignment
						AND
						RPA.DateSettlement = @DateRoute
						AND
						RPA.RowStatus = 1
					GROUP BY
						RPA.IdUnifiedRouteSettlement
				) RPA
					ON 
						RP.IdUnifiedRouteSettlement = RPA.IdUnifiedRouteSettlement
			WHERE
				RP.RouteAssignmentId = @IdRouteAssignment
				AND
				RP.DateSettlement = @DateRoute
				AND
				RP.RowStatus = 1
			------------------------------------
			SET @RESULT = 1; /* PROCESESO EXITOSO */
		COMMIT TRANSACTION
		
        END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @RESULT = 2; /* PROCESESO FALLIDO */
			END  CATCH
	END 
	 
	 SELECT @Result AS Result;				

END