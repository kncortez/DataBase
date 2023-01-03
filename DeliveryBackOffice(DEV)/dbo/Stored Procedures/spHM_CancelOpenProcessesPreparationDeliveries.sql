
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-09>
-- Description:	<Método para Cancelar procesos abiertos en preparación de entregas en hermes mobile>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_CancelOpenProcessesPreparationDeliveries] 
	@GuideSerie AS NVARCHAR(2),
	@GuideNumber AS INT,
	@Token AS NVARCHAR(50),
	@IdRoute AS INT,
	@DateRoute AS DATETIME

AS
BEGIN
      DECLARE @IdDetail AS INT;
	  DECLARE @Result AS INT = 0; /* 0 GUÍA SIN PROCESO ABIERTO */
	  
		SET NOCOUNT ON;
		SELECT @IdDetail = ISNULL(LRPCD.IdRoutePreparationDetail,0)
					FROM [DeliveryBackOffice].[dbo].[RoutePreparationDetail] LRPCD WITH (NOLOCK)
					WHERE LRPCD.Guide_Serie  = @GuideSerie   AND 
						  LRPCD.Guide_Number = @GuideNumber  AND 
						  LRPCD.UserProcess  = @Token        AND 
						  LRPCD.IsOpenProcess = 1

   IF (@IdDetail > 0 OR  @IdDetail IS NOT NULL)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

			UPDATE [DeliveryBackOffice].[dbo].[RoutePreparationDetail] 
			SET    UserProcess = NULL,
				   IsOpenProcess = 0,
				   RowStatus = 0
			WHERE  Guide_Serie   =  @GuideSerie   AND 
				   Guide_Number  =  @GuideNumber  AND 
				   UserProcess   =  @Token        AND 
				   IsOpenProcess = 1;
           
		   UPDATE [DeliveryBackOffice].[dbo].[RoutePreparationDetailPiece]
		   SET RowStatus =0
		   WHERE RoutePreparationDetailId = @IdDetail;

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
				RP.DateRoutePreparation = @DateRoute
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
						RPA.DateRoutePreparation = @DateRoute
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
				RP.DateRoutePreparation = @DateRoute
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