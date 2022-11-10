-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-10-04>
-- Description:	<Cálculo de configuración de datos para liquidación de rutas unificadas>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_GetConfigWarehouseByRouteAssignment]
	-- Add the parameters for the stored procedure here
	@StationId INT,
	@CUI NVARCHAR(25)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SenderReceiverId INT 
	DECLARE @SenderReceiverName NVARCHAR(201)

	DECLARE @TotalSettlementPieces INT = 0
	DECLARE @TotalServicesPending INT = 0


	DECLARE @RouteAssignment TABLE (
		IdRouteAssignment INT NOT NULL
	   ,IdRoute INT NULL
	   ,IdVehicle INT NULL
	   PRIMARY KEY(IdRouteAssignment)
	)

	BEGIN TRANSACTION
	BEGIN TRY

		-- Se buscar courier
		SELECT
			@SenderReceiverId = sr.ID
			,@SenderReceiverName = CONCAT(sr.First_Name, ' ', sr.Last_Name)
		FROM SenderReceiver sr WITH (NOLOCK)
		WHERE sr.CUI = @CUI

		IF @SenderReceiverId IS NOT NULL
		BEGIN
		
			-- Si existen asignaciones en el día
			INSERT INTO @RouteAssignment
				SELECT
					ra.IdRouteAssigment
				   ,ra.IdRoute
				   ,ra.IdVehicle
				FROM RouteAssigment ra WITH (NOLOCK)
				WHERE ra.IdCurrierMan = @SenderReceiverId
				AND ra.RowStatus = 1
				AND ra.DateOfRoute = CAST(GETDATE() AS DATE)

			IF EXISTS (SELECT
						1
					FROM @RouteAssignment)
			BEGIN
				COMMIT TRANSACTION

				SELECT
					1 'StatusCode'
				   ,'Datos cálculados correctamente.' 'Description'

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
							SUM( URSDPreal.RealPieces) 'TotalSettled',
							SUM( URSDPmiss.MissingPieces) 'TotalMissing'
						FROM
							@RouteAssignment RA
							INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlement]  URS WITH (NOLOCK)
							ON URS.RouteAssignmentId = RA.IdRouteAssignment
							INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
							ON URS.IdUnifiedRouteSettlement =URSD.UnifiedRouteSettlementId
							AND URSD.RowStatus = 1
							OUTER APPLY
							(
								SELECT
									COUNT(DISTINCT URSDPreal.PieceNumber) 'RealPieces'
								FROM
									[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDPreal WITH(NOLOCK)
								WHERE
									URSD.IdUnifiedRouteSettlementDetail = URSDPreal.UnifiedRouteSettlementDetailId
									AND URSDPreal.RowStatus = 1
									AND URSDPreal.ActCode IS NULL
							) URSDPreal
							OUTER APPLY
							(
								SELECT
									COUNT(DISTINCT URSDPmiss.PieceNumber) 'MissingPieces'
								FROM
									[DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDPmiss WITH(NOLOCK)
								WHERE
									URSD.IdUnifiedRouteSettlementDetail = URSDPmiss.UnifiedRouteSettlementDetailId
									AND URSDPmiss.RowStatus = 1
									AND URSDPmiss.ActCode IS NOT NULL
							) URSDPmiss
						GROUP BY
							URS.IdUnifiedRouteSettlement
					) TotalPieces
					ON
						URS.IdUnifiedRouteSettlement = TotalPieces.IdUnifiedRouteSettlement

				SELECT 
					@TotalSettlementPieces = SUM(urs.TotalPiecesSettled)
				FROM UnifiedRouteSettlement urs WITH (NOLOCK)
				INNER JOIN @RouteAssignment ra
				ON urs.RouteAssignmentId = ra.IdRouteAssignment
				WHERE urs.RowStatus = 1
				and urs.UserSettlement is null

				SELECT
					@TotalServicesPending = COUNT(DISTINCT sm.IdServiceManagement)
				FROM @RouteAssignment ra
				INNER JOIN ServiceManagement sm WITH (NOLOCK)
					ON ra.IdRouteAssignment = sm.IdPuRouteAssigment
				INNER JOIN CatServiceStatus css WITH (NOLOCK)
					ON sm.ServiceStatusId = css.IdServiceStatus
				LEFT JOIN SubTypeServiceManagment stsm WITH (NOLOCK)
					ON sm.SubTypeServiceManagmentId = stsm.IdSubTypeServiceManagment
				LEFT JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
					ON sm.IdSchedulePickup = dopd.IdHeaderRecolection
				LEFT JOIN DBO.UnifiedRouteSettlement URS
					ON URS.RouteAssignmentId=RA.IdRouteAssignment
				WHERE sm.RowStatus = 1 
				AND (stsm.IdSubTypeServiceManagment IS NULL OR stsm.[Name] = 'Recolección')
				AND dopd.DopId IS NULL
				AND css.[Name] = 'Asignado a Ruta'
				AND URS.UserSettlement IS NULL

				-- Table 0 - Contadores de piezas
				SELECT
					ISNULL(SUM(IIF(stsm.[Name] IN ('Entrega', 'Devolución') AND
					so.OrderDescription IN ('Entregado', 'Entregado En Express Center', 'COD liquidado', 'COD pagado', 'Devuelto', 'Devuelto en Express Center', 'Traslado a Express Center')
					, do.Pieces_Dry + do.Pieces_Cold, 0)), 0) TotalDelivery
				   ,ISNULL(SUM(IIF((stsm.IdSubTypeServiceManagment IS NULL OR stsm.[Name] = 'Recolección') AND
					so.OrderDescription NOT IN ('Generado', 'Solicitado', 'Anulado', 'Programado para recolección')
					, do.Pieces_Dry + do.Pieces_Cold, 0)), 0) TotalPickup
				   ,ISNULL(SUM(IIF(((URS.UserSettlement IS NULL AND (stsm.IdSubTypeServiceManagment IS NULL OR stsm.[Name] = 'Recolección') AND
					so.OrderDescription NOT IN ('Generado', 'Solicitado', 'Anulado', 'Programado para recolección')) OR
					(URS.UserSettlement IS NULL AND stsm.[Name] IN ('Entrega', 'Devolución') AND
					so.OrderDescription NOT IN ('Entregado', 'Entregado En Express Center', 'COD liquidado', 'COD pagado', 'Devuelto', 'Devuelto en Express Center', 'Anulado', 'Entrega parcial', 'Traslado a Express Center')))
					, do.Pieces_Dry + do.Pieces_Cold, 0)), 0) TotalPhysicalPieces
				   ,ISNULL(SUM(IIF(URS.UserSettlement IS NULL AND (stsm.IdSubTypeServiceManagment IS NULL OR stsm.[Name] = 'Recolección') AND
					so.OrderDescription IN ('Generado', 'Solicitado', 'Programado para recolección')
					, do.Pieces_Dry + do.Pieces_Cold, 0)), 0)
					+ ISNULL(SUM(IIF(URS.UserSettlement IS NULL AND stsm.[Name] IN ('Entrega', 'Devolución') AND
					so.OrderDescription NOT IN ('Entregado', 'Entregado En Express Center', 'COD liquidado', 'COD pagado', 'Devuelto', 'Devuelto en Express Center', 'Intento de entrega fallida', 'Traslado a Express Center')
					, 1, 0)), 0) + @TotalServicesPending TotalPendingSettlement
				   ,ISNULL(@TotalSettlementPieces, 0) TotalSettlementPieces
				   ,ISNULL(SUM(IIF(URS.UserSettlement IS NULL AND stsm.[Name] IN ('Entrega', 'Devolución') AND
					so.OrderDescription IN ('Entregado', 'COD liquidado', 'COD pagado', 'Devuelto')
					, IIF(do.IsCollect = 1, do.PriceShippment, 0) + ISNULL(do.Collect_OnDelivery, 0), 0)), 0) TotalCOD
				FROM @RouteAssignment ra
				INNER JOIN ServiceManagement sm WITH (NOLOCK)
					ON ra.IdRouteAssignment = sm.IdPuRouteAssigment
						AND sm.RowStatus = 1
				INNER JOIN CatServiceStatus css WITH (NOLOCK)
					ON sm.ServiceStatusId = css.IdServiceStatus
				LEFT JOIN SubTypeServiceManagment stsm WITH (NOLOCK)
					ON sm.SubTypeServiceManagmentId = stsm.IdSubTypeServiceManagment
				LEFT JOIN ServiceManagementDetail smd WITH (NOLOCK)
					ON sm.IdServiceManagement = smd.ServiceManagement
						AND smd.RowStatus = 1
				LEFT JOIN RoutePreparationDetail rpd WITH (NOLOCK)
					ON smd.IdServiceManagementDetail = rpd.ServiceManagementDetailId
						AND rpd.RowStatus = 1
				LEFT JOIN SchedulePickup sp WITH (NOLOCK)
					ON sm.IdSchedulePickup = sp.SchedulePickupId
						AND sp.RowStatus = 1
						AND (sp.SchedulePickupStatus IS NULL
							OR sp.SchedulePickupStatus = 1)
				LEFT JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
					ON sp.SchedulePickupId = dopd.IdHeaderRecolection
				INNER JOIN DeliveryOrder do WITH (NOLOCK)
					ON ISNULL(dopd.GuideSerie, rpd.Guide_Serie) = do.Guide_Serie
						AND ISNULL(dopd.GuideNumber, rpd.Guide_Number) = do.Guide_Number
				INNER JOIN StatusOrder so WITH (NOLOCK)
					ON do.StatusOrderId = so.StatusOrderId
				LEFT JOIN UnifiedRouteSettlement URS
					ON URS.RouteAssignmentId=RA.IdRouteAssignment
				LEFT JOIN UnifiedRouteSettlementDetail URSD
					ON URSD.GuideNumber=DO.Guide_Number
					AND URSD.GuideSerie=DO.Guide_Serie
					AND URSD.RowStatus=1
					AND URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement	
				WHERE 
					(css.[Name] <> 'Cancelado' OR css.IdServiceStatus IS NULL)

				-- Table 2 - Información Courier
				SELECT
					@SenderReceiverId CourierId
				   ,@SenderReceiverName CourierName

				-- Table 3 - Tabla de rutas y vehículos
				SELECT DISTINCT
					ra.IdRouteAssignment RouteAssignmentId
				   ,cr.IdRoute RouteId
				   ,cr.CodeRoute RouteCode
				   ,cv.IdVehicle VehicleId
				   ,cv.UnitNumber VehicleUnitNumber
				   ,cv.Plate VehiclePlate
				FROM @RouteAssignment ra
				LEFT JOIN CatRoute cr WITH (NOLOCK)
					ON cr.IdRoute = ra.IdRoute
				LEFT JOIN CatVehicle cv WITH (NOLOCK)
					ON cv.IdVehicle = ra.IdVehicle

				-- Table 4 - Tabla de manifiestos pendientes
				SELECT DISTINCT
					dobs.ID ManifestId
				   ,stsm.[Name] TypeName
				   ,ISNULL(dobs.Guides_Dispatched, 0) TotalGuides
				   ,ISNULL(dobs.Pieces_Dry_Dispatched, 0) + ISNULL(dobs.Pieces_Cold_Received, 0) TotalPieces
				   ,ISNULL(dobs.Pieces_Dry_Dispatched, 0) TotalPiecesDry
				   ,ISNULL(dobs.Pieces_Cold_Received, 0) TotalPiecesCold
				FROM @RouteAssignment ra
				INNER JOIN ServiceManagement sm WITH (NOLOCK)
					ON sm.IdPuRouteAssigment = ra.IdRouteAssignment
				INNER JOIN SubTypeServiceManagment stsm WITH (NOLOCK)
					ON stsm.IdSubTypeServiceManagment = sm.SubTypeServiceManagmentId
				INNER JOIN ServiceManagementDetail smd WITH (NOLOCK)
					ON smd.ServiceManagement = sm.IdServiceManagement
				INNER JOIN RoutePreparationDetail rpd WITH (NOLOCK)
					ON rpd.ServiceManagementDetailId = smd.IdServiceManagementDetail
				INNER JOIN RoutePreparation rp WITH (NOLOCK)
					ON rp.IdRoutePreparation = rpd.RoutePreparationId
				INNER JOIN DeliveryOrderBySettlement dobs WITH (NOLOCK)
					ON dobs.ID = rp.DeliveryOrderBySettlementId
				INNER JOIN DeliverySettlementDetail dsd WITH (NOLOCK)
					ON dsd.ID_DeliveryOrderBySettlement = dobs.ID
				WHERE dsd.Guide_Settlement IS NULL
				OR dsd.Guide_Settlement = 0

			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION

				SELECT
					3 'StatusCode'
				   ,'No se encontró ningúna ruta asignada al Courier.' 'Description'
			END
		END
		ELSE
		BEGIN
			ROLLBACK TRANSACTION

			SELECT
				2 'StatusCode'
			   ,'No se encontró información del Courier.' 'Description'
		END
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SELECT
				0 'StatusCode'
			   ,ERROR_MESSAGE() 'Description'
	END CATCH
END