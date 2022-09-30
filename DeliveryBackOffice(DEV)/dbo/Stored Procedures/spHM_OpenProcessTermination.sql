-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-09-09>
-- Description:	<SP Finalización de procesos abiertos en preparación de entrega de hermes mobile>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_OpenProcessTermination]
@GuideSerie  AS NVARCHAR(2),
@GuideNumber AS INT,
@DateRoute AS DATETIME,
@IdRoute AS INT,
@Token AS NVARCHAR(50)

AS  
BEGIN


   DECLARE @StatusOrder AS INT
	SET NOCOUNT ON;
	 DECLARE @Result AS INT = 0; 

	BEGIN TRANSACTION
	BEGIN TRY
	
	SELECT TOP 1 @StatusOrder = so.StatusOrderId
	FROM [DeliveryBackOffice].[dbo].[StatusOrder] so WITH(NOLOCK) 
	WHERE so.OrderDescription = 'Programado para entrega' COLLATE Latin1_General_CI_AI
	
 ----------actualizar estado de piezas piezas 
    UPDATE  RPDP
	SET     
			RowStatus= 1,
			TokenUpdated= @Token,
			DateUpdated=GETDATE()
			FROM [DeliveryBackOffice].[dbo].[RoutePreparation]  RP WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
			ON RP.IdRoutePreparation =RPD.RoutePreparationId
			INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
			ON RPD.IdRoutePreparationDetail =RPDP.RoutePreparationDetailId
	WHERE  RPD.Guide_Serie  = @GuideSerie AND 
	       RPD.Guide_Number = @GuideNumber AND
		   RP.CatRouteId = @IdRoute AND
		   FORMAT(RP.DateRoutePreparation, 'yyyy-mm-dd' ) = FORMAT(@DateRoute, 'yyyy-mm-dd')
		   AND RPD.IsOpenProcess = 1


	------------------------------- Actualizar estado del detalle de la guia
	UPDATE  RPD
	SET     UserProcess   = NULL, 
	        IsOpenProcess = 0,
			RowStatus= 1,
			TokenUpdated= @Token,
			DateUpdated=GETDATE()
			FROM [DeliveryBackOffice].[dbo].[RoutePreparation]  RP WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
			ON RP.IdRoutePreparation =RPD.RoutePreparationId
	WHERE  RPD.Guide_Serie  = @GuideSerie AND 
	       RPD.Guide_Number = @GuideNumber AND
		   RP.CatRouteId = @IdRoute AND
		   FORMAT(RP.DateRoutePreparation, 'yyyy-mm-dd' ) = FORMAT(@DateRoute, 'yyyy-mm-dd')
		   AND RPD.IsOpenProcess = 1
		   
			--- Actualizar los tipos de pieza del detalle de la preparación de ruta segun lo almacenado
			UPDATE RPDP
			SET RPDP.PieceType = (CASE WHEN DOP.IsDry = 1 THEN 1 ELSE 0 END)
			FROM
				[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
				inner JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
					ON
						RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
						AND
						RPD.RowStatus = 1
				inner JOIN
					[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
					ON
						RPD.RoutePreparationId = RP.IdRoutePreparation
						AND
						RP.RowStatus = 1
				inner JOIN 
					[DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
					ON
						RPD.Guide_Serie = DOP.GuideSerie
						AND
						RPD.Guide_Number = DOP.GuideNumber
						AND
						RPDP.PieceNumber = DOP.GuideNumber
			WHERE
				RP.CatRouteId = @IdRoute
				AND
				RP.DateRoutePreparation = CAST(@DateRoute AS DATE)
				AND
				RPDP.RowStatus = 1

			--- Actualizar la preparación de ruta en base a los datos almacenados
			UPDATE RP
			SET
				RP.GuidesQuantity = ISNULL(RPA.RealGuideQuantity,0),
				RP.PiecesDry = ISNULL(RPA.RealPiecesDry,0),
				RP.PiecesCold = ISNULL(RealPiecesCold,0)
			FROM 
				[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
				LEFT JOIN
				(
					SELECT
						RPA.IdRoutePreparation,
						COUNT (DISTINCT RPD.IdRoutePreparationDetail) 'RealGuideQuantity',
						SUM (CASE WHEN RPDP.PieceType = 1 THEN 1 ELSE 0 END) 'RealPiecesDry',
						SUM (CASE WHEN RPDP.PieceType = 0 THEN 1 ELSE 0 END) 'RealPiecesCold'
					FROM
						[DeliveryBackOffice].[dbo].[RoutePreparation] RPA WITH(NOLOCK)
						inner JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
							ON
								RPA.IdRoutePreparation = RPD.RoutePreparationId
								AND
								RPD.RowStatus = 1
						inner JOIN
							[DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece] RPDP WITH(NOLOCK)
							ON
								RPD.IdRoutePreparationDetail = RPDP.RoutePreparationDetailId
								AND
								RPDP.RowStatus = 1
					WHERE
						RPA.CatRouteId = @IdRoute
						AND
						RPA.DateRoutePreparation = CAST(@DateRoute AS DATE)
						AND
						RPA.RowStatus = 1
					GROUP BY
						RPA.IdRoutePreparation
				) RPA
					ON 
						RP.IdRoutePreparation = RPA.IdRoutePreparation
			WHERE
				RP.CatRouteId = @IdRoute
				AND
				RP.DateRoutePreparation = CAST(@DateRoute AS DATE)
				AND
				RP.RowStatus = 1

	UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder] SET StatusOrderId = @StatusOrder
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber 


	INSERT INTO dbo.DeliveryOrderDetail 
	           (Guide_Serie, 
			    Guide_Number,
				StatusOrderId, 
				UserCreated,
				DateCreated,
				DateCreatedInSystem,
				RowStatus
				) 
	     VALUES (@GuideSerie,
		         @GuideNumber,
				 @StatusOrder,
				 @Token,
				 GETDATE(),
				 GETDATE(),
				 1
		         )

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
	
    
GO


