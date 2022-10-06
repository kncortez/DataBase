
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-06>
-- Description:	<SP finalizar un proceso abierto de un proceso de liquidación de ruta unificada>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_finalizeUnifiedRouteSettlementProcess]
@GuideSerie  AS NVARCHAR(2),
@GuideNumber AS INT,
@DateRoute AS DATETIME,
@IdRoute AS INT,
@Token AS NVARCHAR(50)

AS  
BEGIN


   
	SET NOCOUNT ON;
	 DECLARE @Result AS INT = 0; 
	 DECLARE @IdRouteAssignment AS INT
	 DECLARE @TotalPiecesMissing AS INT
	 DECLARE @TotalPiecesSettled AS INT

	BEGIN TRANSACTION
	BEGIN TRY
	


	  SELECT @IdRouteAssignment=IdRouteAssigment 
	  FROM dbo.RouteAssigment RA WITH (NOLOCK) 
	  WHERE RA.IdRoute=@IdRoute AND RA.DateOfRoute=FORMAT(@DateRoute,'yyyy-MM-dd')

	    
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
	
 ----------actualizar estado de piezas piezas 
    UPDATE  RPDP
	SET     
			RowStatus= 1,
			TokenUpdated= @Token,
			DateUpdated=GETDATE()
			FROM [DeliveryBackOffice].[dbo].[UnifiedRouteSettlement]  RP WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] RPD WITH(NOLOCK)
			ON RP.IdUnifiedRouteSettlement =RPD.UnifiedRouteSettlementId
			INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] RPDP WITH(NOLOCK)
			ON RPD.IdUnifiedRouteSettlementDetail =RPDP.UnifiedRouteSettlementDetailId
	WHERE  RPD.GuideSerie  = @GuideSerie AND 
	       RPD.GuideNumber = @GuideNumber AND
		   RP.RouteAssignmentId = @IdRouteAssignment AND
		   FORMAT(RP.DateSettlement, 'yyyy-mm-dd' ) = FORMAT(@DateRoute, 'yyyy-mm-dd')
		   AND RPD.IsOpenProcess = 1


	------------------------------- Actualizar estado del detalle de la guia
	UPDATE  RPD
	SET     UserProcess   = NULL, 
	        IsOpenProcess = 0,
			RowStatus= 1,
			TokenUpdated= @Token,
			DateUpdated=GETDATE()
			FROM [DeliveryBackOffice].[dbo].[UnifiedRouteSettlement]  RP WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] RPD WITH(NOLOCK)
			ON RP.IdUnifiedRouteSettlement =RPD.UnifiedRouteSettlementId
	WHERE  RPD.GuideSerie  = @GuideSerie AND 
	       RPD.GuideNumber = @GuideNumber AND
		   RP.RouteAssignmentId = @IdRouteAssignment AND
		   FORMAT(RP.DateSettlement, 'yyyy-mm-dd' ) = FORMAT(@DateRoute, 'yyyy-mm-dd')
		   AND RPD.IsOpenProcess = 1
		   
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
						RPD.UnifiedRouteSettlementId = RP.IdUnifiedRouteSettlement
						AND
						RP.RowStatus = 1
				INNER JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
					ON
						RPD.GuideSerie = DOP.GuideSerie
						AND
						RPD.GuideNumber = DOP.GuideNumber
						
			WHERE
				RP.RouteAssignmentId = @IdRouteAssignment
				AND
				RP.DateSettlement = CAST(@DateRoute AS DATE)
				AND
				RPDP.RowStatus = 1

			--- Actualizar la preparación de ruta en base a los datos almacenados
			UPDATE RP
			SET
				RP.TotalGuidesSettled = ISNULL(RPA.RealGuideQuantity,0),
				RP.TotalPiecesSettled= ISNULL(@TotalPiecesSettled,0),
				RP.TotalPiecesMissing= ISNULL(@TotalPiecesMissing,0)
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
							[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
							ON
								RPD.IdUnifiedRouteSettlementDetail = RPDP.RoutePreparationDetailId
								AND
								RPDP.RowStatus = 1
					WHERE
						RPA.RouteAssignmentId = @IdRouteAssignment
						AND
						RPA.DateSettlement = CAST(@DateRoute AS DATE)
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
				RP.DateSettlement = CAST(@DateRoute AS DATE)
				AND
				RP.RowStatus = 1



 			SET @RESULT = 1; /* PROCESESO EXITOSO */
		COMMIT TRANSACTION
		 
	        SELECT @Result AS Result;
        END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @RESULT = 2; /* PROCESESO FALLIDO */
				 				 
	        SELECT @Result AS Result
					
			END  CATCH
	END