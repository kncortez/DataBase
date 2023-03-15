
-- =============================================
-- Author:		<Oscar, Morales>
-- Create date: <2021-12-27>
-- Description:	<Obtiene información de la preparación de entregas en base a una ruta y una fecha.>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-04>
-- Description:	<Modificación para uso de id de vehiculo sobre id de ruta.>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-01-19>
-- Description:	<Modificación para manejo a nivel de pieza.>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-02-02>
-- Description:	< Cambio para uso de Ruta sobre Unidad .>
-- =============================================
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-08-05>
-- Description:	< Cambio para uso de orden como decimal .>
-- =============================================
CREATE PROCEDURE [dbo].[GetRoutePreparation]
	@IdRoute INT,
	@Date DATE
AS
BEGIN

	DECLARE @RouteAssignmentExists BIT;

	SET @RouteAssignmentExists = (
										SELECT 1
										FROM [DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
										WHERE
										RP.CatRouteId = @IdRoute
										AND
										RP.DateRoutePreparation = @Date
										AND
										RP.RowStatus = 1
									)

	IF (@RouteAssignmentExists IS NOT NULL)
	BEGIN
		BEGIN TRANSACTION
		BEGIN TRY

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
				RP.DateRoutePreparation = @Date
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
						RPA.DateRoutePreparation = @Date
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
				RP.DateRoutePreparation = @Date
				AND
				RP.RowStatus = 1

			COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH
	END

	--TABLE 0 Información de la preparación de la ruta
	SELECT rp.IdRoutePreparation, rp.GuidesQuantity, rp.PiecesDry, rp.PiecesCold, rp.DeliveryOrderBySettlementId,
		dobs.CatRouteId, dobs.StartingKilometers, sr.CUI, dobs.CatRouteId, rp.IsSimpliRoute, rp.CatVehicleId VehicleId
	FROM RoutePreparation rp WITH(NOLOCK)
	LEFT JOIN DeliveryOrderBySettlement dobs WITH(NOLOCK)
		ON rp.DeliveryOrderBySettlementId = dobs.ID
	LEFT JOIN SenderReceiver sr WITH(NOLOCK)
		ON dobs.ID_Courier = sr.ID
	WHERE rp.CatRouteId = @IdRoute AND rp.DateRoutePreparation = @Date
		AND rp.RowStatus = 1

	--TABLE 1 Información de las guías en preparación de la ruta
	SELECT RPD.Guide_Serie 'Guide_Serie'
		, RPD.Guide_Number 'Guide_Number'
		, RPDP.PieceNumber 'Guide_Piece'
		, COALESCE(do.Pieces_Dry,0) + COALESCE(do.Pieces_Cold,0) 'Pieces'
		, (CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Department] ELSE do.[Receiver_Department] END) 'Department'
		, (CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Town] ELSE do.[Receiver_Town] END) 'Town'
		, (CASE WHEN [do].[IsLastMileReturn] = 1 THEN do.[Sender_Address] ELSE do.[Receiver_Address] END) 'Address'
		, do.Pieces_Dry 'Pieces_Dry'
		, do.Pieces_Cold 'Pieces_Cold'
		, do.Collect_OnDelivery 'COD'
		, ISNULL(do.IsCollect, 0) 'IsCollect'
		, rpd.GuideOrder 'GuideOrder'
		, RPDP.PieceType 'Piece_Type'
		, CAST(IIF(DOP.StatusOrderId = 3, 1 ,0) AS BIT) 'IsProgrammed'
		, cu.Abbreviation 'CustomerAbbreviation' 
		, RPD.ETAGuide 'GuideETA'
	FROM RoutePreparation RP WITH(NOLOCK)
	LEFT JOIN RoutePreparationDetail RPD WITH(NOLOCK)
		ON
			RPD.RoutePreparationId = RP.IdRoutePreparation
			AND
			RPD.RowStatus = 1
	LEFT JOIN RoutePreparationDetailPiece RPDP WITH(NOLOCK)
		ON 
			RPDP.RoutePreparationDetailId = RPD.IdRoutePreparationDetail
			AND 
			RPDP.RowStatus = 1
	inner JOIN DeliveryOrder do WITH(NOLOCK)
		ON do.Guide_Serie = rpd.Guide_Serie AND do.Guide_Number = rpd.Guide_Number
	LEFT JOIN
		DeliveryOrderPiece DOP WITH(NOLOCK)
		ON
			do.Guide_Serie = DOP.GuideSerie
			AND
			do.Guide_Number = DOP.GuideNumber
			AND
			RPDP.PieceNumber = DOP.NoPiece
	LEFT JOIN VisitPointClient vpc
		ON vpc.CodeOfReference = do.Sender_ID
	LEFT JOIN Customer cu
		ON cu.IdCustomer = COALESCE(do.IdCustomer, vpc.CustomerID)
	WHERE rp.CatRouteId = @IdRoute AND rp.DateRoutePreparation = @Date
		AND rp.RowStatus = 1
	ORDER BY COALESCE(rpd.GuideOrder, 999999) ASC
END