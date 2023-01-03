
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-06>
-- Description:	<SP finalizar un proceso abierto de un proceso de liquidación de ruta unificada>
-- =============================================
CREATE PROCEDURE [dbo].[spHM_finalizeUnifiedRouteSettlementProcess]
@GuideSerie  AS NVARCHAR(2),
@GuideNumber AS INT,
@DateRoute AS DATETIME,
@IdCourier AS INT,
@Token AS NVARCHAR(50)

AS  
BEGIN


   
	SET NOCOUNT ON;
	 DECLARE @Result AS INT = 0; 
	 DECLARE @IsPickup BIT = 0;
	 DECLARE @ServiceManagementId INT
	 DECLARE @SchedulePickupId BIGINT
	DECLARE @StatusOrderId TINYINT = ( SELECT
		so.StatusOrderId
	FROM StatusOrder so WITH (NOLOCK)
	WHERE so.OrderDescription = 'Recolectado')
	DECLARE @ServiceStatus INT =
    (
        SELECT IdServiceStatus FROM CatServiceStatus WHERE [Name] = 'Recolectado'
    );


			SELECT TOP 1
				--@RouteAssignmentId = ra.IdRouteAssigment
			 --  ,@RouteAssignmentCourierId = ra.IdCurrierMan
			   @ServiceManagementId = sm.IdServiceManagement,
			   @SchedulePickupId = sm.IdSchedulePickup,
			 --  ,@ServiceStatusId = sm.ServiceStatusId
			   --,
			   @IsPickup = IIF(stsm.IdSubTypeServiceManagment IS NULL OR stsm.[Name] = 'Recolección', 1, 0)
			FROM RouteAssigment ra WITH (NOLOCK)
			INNER JOIN ServiceManagement sm WITH (NOLOCK)
				ON ra.IdRouteAssigment = sm.IdPuRouteAssigment
					AND sm.RowStatus = 1
			LEFT JOIN CatServiceStatus css WITH (NOLOCK)
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
			WHERE 
			--(css.[Name] <> 'Cancelado' OR css.IdServiceStatus IS NULL)
			--AND 
			ra.DateOfRoute = CAST(GETDATE() AS DATE)
			AND
			ISNULL(dopd.GuideSerie, rpd.Guide_Serie) = @GuideSerie
			AND ISNULL(dopd.GuideNumber, rpd.Guide_Number) = @GuideNumber
			ORDER BY ra.DateCreated DESC 

IF (EXISTS(SELECT TOP 1 1 FROM dbo.UnifiedRouteSettlementDetail WHERE GuideSerie=@GuideSerie AND GuideNumber=@GuideNumber AND IsOpenProcess = 1 AND UserProcess = @Token))
BEGIN	
	BEGIN TRANSACTION
	BEGIN TRY
			----------actualizar estado de piezas piezas 
			UPDATE  URSDP
			SET     
					RowStatus= 1,
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

			------------------------------- Actualizar estado del detalle de la guia
			UPDATE  URSD
			SET     UserProcess   = NULL, 
					IsOpenProcess = 0,
					RowStatus= 1,
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

			--- Actualizar los tipos de pieza del detalle de la preparación de ruta segun lo almacenado
			UPDATE URSDP
			SET URSDP.IsDryPiece = (CASE WHEN DOP.IsDry = 1 THEN 1 ELSE 0 END)
			FROM
				[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
				INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlement]  URS WITH (NOLOCK)
				ON URS.RouteAssignmentId = RA.IdRouteAssigment
				INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetail] URSD WITH(NOLOCK)
				ON URS.IdUnifiedRouteSettlement =URSD.UnifiedRouteSettlementId
				AND URSD.GuideSerie = @GuideSerie
				AND URSD.GuideNumber = @GuideNumber
				INNER JOIN [DeliveryBackOffice].[dbo].[UnifiedRouteSettlementDetailPiece] URSDP WITH(NOLOCK)
				ON URSD.IdUnifiedRouteSettlementDetail = URSDP.UnifiedRouteSettlementDetailId
				AND URSDP.RowStatus = 1
				INNER JOIN  [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
				ON URSD.GuideSerie = DOP.GuideSerie
				AND URSD.GuideNumber = DOP.GuideNumber
				AND URSDP.PieceNumber = DOP.NoPiece
						
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


			--- Actualizar la liquidación de ruta en base a los datos almacenados
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


			--//ACTUALIZANDO GUÍAS DE RECOLECCIÓN--------------------------------------------------------------------------------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
					IF @IsPickup = 1
					BEGIN
						
						--Actualiza estado de la guía
						UPDATE DeliveryOrder
						SET StatusOrderId = @StatusOrderId
						WHERE Guide_Serie = @GuideSerie
						AND Guide_Number = @GuideNumber

						IF (NOT EXISTS (SELECT TOP 1
								1
							FROM DeliveryOrderDetail WITH (NOLOCK)
							WHERE Guide_Serie = @GuideSerie
							AND Guide_Number = @GuideNumber
							AND StatusOrderId = @StatusOrderId)
						)
						BEGIN
							--Inserta checkpoint de recolectado
							INSERT INTO DeliveryOrderDetail (Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, Observations, Temperature_Celsius, PieceId, RowStatus)
								VALUES (@GuideSerie, @GuideNumber, @StatusOrderId, @Token, GETDATE(), GETDATE(), NULL, NULL, NULL, 1);
						END

						 --Se marca como recolectado
						UPDATE sm
						SET ServiceStatusId = @ServiceStatus,
							TokenUpdated = @Token,
							DateUpdated = GETDATE()
						FROM ServiceManagement sm
						WHERE sm.IdSchedulePickup = @SchedulePickupId;


						UPDATE SchedulePickup
						SET AssigmentStatus = 1
							,TokenUpdated = @Token
							,DateUpdated = GETDATE()
						WHERE SchedulePickupId = @SchedulePickupId;

						 --Insertar EventService si no existe
						IF NOT EXISTS (SELECT
								1
							FROM EventService es
							WHERE es.ServiceManagementId = @ServiceManagementId
							AND es.ServiceStatusId = @ServiceStatus
							AND es.RowStauts = 1)
						BEGIN
							INSERT INTO EventService (ServiceManagementId,
							ServiceStatusId,
							RowStauts,
							TokenCreated,
							DateCreated,
							Observations)
								VALUES (@ServiceManagementId, @ServiceStatus, 1, @Token, GETDATE(), NULL);
						END
					END
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------
			--------------------------------------------------------------------------------------------------------------------------------------------------------------------
 			SET @Result = 1; /* PROCESESO EXITOSO */
		COMMIT TRANSACTION

		
	        SELECT @Result AS Result;
        END TRY
			BEGIN CATCH
				ROLLBACK TRANSACTION
				SET @Result = 2; /* PROCESESO FALLIDO */
				 				 
	        SELECT @Result AS Result
					
			END  CATCH
		 
END
	ELSE
		BEGIN
			 SELECT @Result AS Result
		END

	END