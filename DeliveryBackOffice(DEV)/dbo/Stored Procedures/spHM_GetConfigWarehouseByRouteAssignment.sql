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

				-- Table 1 - Tabla de configuraciones
				SELECT
				DISTINCT
					RouteAssignmentId
				   ,WarehouseLocationServiceType
				FROM (SELECT
					DISTINCT
						X.IdRouteAssignment RouteAssignmentId
					   ,CASE
							WHEN X.Attemps > X.FailedAttempt THEN 'Retorno'
							ELSE 'Devolución local'
						END WarehouseLocationServiceType
					FROM (SELECT
							(SELECT
									COUNT(1)
								FROM IncidenceServices [is]
								INNER JOIN ServiceManagement sm WITH (NOLOCK)
									ON sm.IdServiceManagement = [is].ServiceManagementId
									AND sm.RowStatus = 1
								INNER JOIN ServiceManagementDetail smd WITH (NOLOCK)
									ON smd.ServiceManagement = sm.IdServiceManagement
									AND smd.RowStatus = 1
								INNER JOIN RoutePreparationDetail rpd WITH (NOLOCK)
									ON rpd.ServiceManagementDetailId = smd.IdServiceManagementDetail
									AND rpd.RowStatus = 1
								WHERE [is].RowStatus = 1
								AND rpd.Guide_Serie = do.Guide_Serie
								AND rpd.Guide_Number = do.Guide_Number)
							FailedAttempt
						   ,ISNULL((SELECT
									rh.Attempt
								FROM RateHeader rh WITH (NOLOCK)
								LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
									ON vpc.CodeOfReference = do.Sender_ID
								INNER JOIN RatebyCustomer rc WITH (NOLOCK)
									ON rc.RbcIdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
								WHERE rh.RheId = rc.RbcIdRate)
							, 2)
							Attemps
						   ,ra.IdRouteAssignment
						FROM @RouteAssignment ra
						INNER JOIN ServiceManagement sm WITH (NOLOCK)
							ON sm.IdPuRouteAssigment = ra.IdRouteAssignment
							AND sm.RowStatus = 1
						INNER JOIN ServiceManagementDetail smd WITH (NOLOCK)
							ON smd.ServiceManagement = sm.IdServiceManagement
							AND smd.RowStatus = 1
						INNER JOIN RoutePreparationDetail rpd WITH (NOLOCK)
							ON rpd.ServiceManagementDetailId = smd.IdServiceManagementDetail
						INNER JOIN DeliveryOrder do WITH (NOLOCK)
							ON do.Guide_Serie = rpd.Guide_Serie
							AND do.Guide_Number = rpd.Guide_Number
							AND do.StatusOrderId NOT IN (SELECT
									so.StatusOrderId
								FROM StatusOrder so WITH (NOLOCK)
								WHERE so.OrderDescription IN ('Entregado', 'Entregado En Express Center', 'COD liquidado', 'COD pagado'))
							AND rpd.RowStatus = 1
						WHERE do.IsLastMileReturn IS NULL
						OR do.IsLastMileReturn = 0) X
					UNION
					SELECT
					DISTINCT
						X.IdRouteAssignment RouteAssignmentId
					   ,CASE
							WHEN X.Attemps > X.FailedAttempt THEN 'Devolución local'
							ELSE 'Bazar'
						END WarehouseLocationServiceType
					FROM (SELECT
							(SELECT
									COUNT(1)
								FROM IncidenceServices [is]
								INNER JOIN ServiceManagement sm WITH (NOLOCK)
									ON sm.IdServiceManagement = [is].ServiceManagementId
									AND sm.RowStatus = 1
								INNER JOIN ServiceManagementDetail smd WITH (NOLOCK)
									ON smd.ServiceManagement = sm.IdServiceManagement
									AND smd.RowStatus = 1
								INNER JOIN RoutePreparationDetail rpd WITH (NOLOCK)
									ON rpd.ServiceManagementDetailId = smd.IdServiceManagementDetail
									AND rpd.RowStatus = 1
								WHERE [is].RowStatus = 1
								AND rpd.Guide_Serie = do.Guide_Serie
								AND rpd.Guide_Number = do.Guide_Number)
							FailedAttempt
						   ,(SELECT
									ISNULL(rh.Attempt, 2) + rh.AttemptReturn
								FROM RateHeader rh WITH (NOLOCK)
								LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
									ON vpc.CodeOfReference = do.Sender_ID
								INNER JOIN RatebyCustomer rc WITH (NOLOCK)
									ON rc.RbcIdCustomer = ISNULL(do.IdCustomer, vpc.CustomerID)
								WHERE rh.RheId = rc.RbcIdRate)
							Attemps
						   ,ra.IdRouteAssignment
						FROM @RouteAssignment ra
						INNER JOIN ServiceManagement sm WITH (NOLOCK)
							ON sm.IdPuRouteAssigment = ra.IdRouteAssignment
							AND sm.RowStatus = 1
						INNER JOIN ServiceManagementDetail smd WITH (NOLOCK)
							ON smd.ServiceManagement = sm.IdServiceManagement
							AND smd.RowStatus = 1
						INNER JOIN RoutePreparationDetail rpd WITH (NOLOCK)
							ON rpd.ServiceManagementDetailId = smd.IdServiceManagementDetail
						INNER JOIN DeliveryOrder do WITH (NOLOCK)
							ON do.Guide_Serie = rpd.Guide_Serie
							AND do.Guide_Number = rpd.Guide_Number
							AND do.StatusOrderId NOT IN (SELECT
									so.StatusOrderId
								FROM StatusOrder so WITH (NOLOCK)
								WHERE so.OrderDescription IN ('Entregado', 'Entregado En Express Center', 'COD liquidado', 'COD pagado', 'Devuelto', 'Devuelto en Express Center'))
							AND rpd.RowStatus = 1
						WHERE do.IsLastMileReturn = 1) X
					UNION
					SELECT
					DISTINCT
						ra.IdRouteAssignment RouteAssignmentId
					   ,IIF(ISNULL(sp.IdHubLogistics, (SELECT TOP 1
								hl.IdHubLogistic
							FROM DumpServiceCoverage dsc WITH (NOLOCK)
							INNER JOIN Township t WITH (NOLOCK)
								ON t.IdTownship = do.ReceiverIdTownship
								OR t.TownshipName = do.Receiver_Town
							INNER JOIN HubLogistics hl WITH (NOLOCK)
								ON hl.HubAbbreviation = dsc.Hub
							WHERE dsc.HeaderCode = t.HeaderCode
							AND dsc.RowStatus = 1)
						) = cs.HubLogisticId, 'Recolección local', 'Linehaul') WarehouseLocationServiceType
					FROM @RouteAssignment ra
					INNER JOIN ServiceManagement sm WITH (NOLOCK)
						ON sm.IdPuRouteAssigment = ra.IdRouteAssignment
						AND sm.ServiceStatusId = (SELECT
								css.IdServiceStatus
							FROM CatServiceStatus css
							WHERE css.Name = 'Recolectado')
						AND sm.RowStatus = 1
					INNER JOIN SchedulePickup sp WITH (NOLOCK)
						ON sp.SchedulePickupId = sm.IdSchedulePickup
						AND sp.RowStatus = 1
					INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
						ON dopd.IdHeaderRecolection = sp.SchedulePickupId
					INNER JOIN DeliveryOrder do WITH (NOLOCK)
						ON dopd.GuideSerie = do.Guide_Serie
						AND dopd.GuideNumber = do.Guide_Number
					INNER JOIN CatStation cs WITH (NOLOCK)
						ON cs.IdStation = @StationId
						AND cs.RowStatus = 1) xy

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