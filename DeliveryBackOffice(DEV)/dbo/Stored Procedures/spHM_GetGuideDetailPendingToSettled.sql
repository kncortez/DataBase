-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <11-10-2022>
-- Description:	<Carga guías pendientes por liquidar en proceso de liquidación unificada>
-- =============================================
CREATE PROCEDURE spHM_GetGuideDetailPendingToSettled
	-- Add the parameters for the stored procedure here
	@CUI NVARCHAR(25),
	@Date AS DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @Date IS NULL
		SET @Date =GETDATE();

	DECLARE @IDCOURIER INT = (SELECT ID FROM DBO.SenderReceiver WHERE CUI=@CUI)

	DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPGetGuideDetailPendingToSettled
    ELSE  
		BEGIN TRANSACTION;  

	BEGIN TRY
		
		SELECT			  
			1 AS 'StatusCode',
			'Registros obtenidos' AS 'Description';
		SELECT 
			DOPD.GuideSerie 'GuideSerie',
			DOPD.GuideNumber 'GuideNumber',
			DOP.NoPiece 'NumberPiece',
			DOP.IsDry 'IsDry', 
			CONVERT(BIT,IIF(URSD.GuideNumber IS NOT NULL,1,0))  'GuideSettled',
			CONVERT(BIT,IIF(URSD.IsOpenProcess =1,1,0))  'OpenProcess', 
			CONVERT(BIT,IIF(URSDP.PieceNumber IS NOT NULL,1,0))  'PieceSettled'
		FROM DBO.RouteAssigment RA 
		INNER JOIN DBO.ServiceManagement SM 
			ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
			AND SM .RowStatus=1
		INNER JOIN DBO.ServiceManagementDetail SMD
			ON SMD.ServiceManagement=SM.IdServiceManagement
		INNER JOIN DBO.SubTypeServiceManagment STSM 
			ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
		INNER JOIN DBO.SchedulePickup SP
			ON SM.IdSchedulePickup= SP.SchedulePickupId
			AND SP.RowStatus=1
		INNER JOIN DBO.DeliveryOrderPaymentDetail DOPD
			ON DOPD.IdHeaderRecolection=SP.SchedulePickupId
		INNER JOIN DBO.DeliveryOrderPiece DOP WITH (NOLOCK)
			ON DOP.GuideSerie=DOPD.GuideSerie
			AND DOP.GuideNumber=DOPD.GuideNumber
		LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD ON 		
			URSD.GuideSerie=DOPD.GuideSerie
			AND URSD.GuideNumber=DOPD.GuideNumber
			AND URSD.RowStatus=1
		LEFT JOIN DBO.UnifiedRouteSettlementDetailPiece URSDP ON 		
			URSDP.UnifiedRouteSettlementDetailId=URSD.IdUnifiedRouteSettlementDetail
			AND URSDP.PieceNumber=DOP.NoPiece
			AND URSDP.RowStatus=1
		LEFT JOIN DBO.UnifiedRouteSettlement URS ON URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
		WHERE 
			RA.RowStatus=1		
			AND RA.IdVehicle IS NOT NULL
			AND RA.IdRoute IS NOT NULL		
			AND RA.IdCurrierMan=@IdCourier--@CUI
			AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
			AND RA.DateOfRoute =@Date

			AND  NOT(--FILTRANDO POR GUÍAS PENDIENTES DE LIQUIDAR
				URSDP.PieceNumber IS NOT NULL --LA PIEZA ESTA LIQUIDADA
				AND URSD.GuideNumber IS NOT NULL --LA GUIA ESTA LIQUIDADA
				AND URSD.IsOpenProcess=0  --LA GUIA ESTA NO ESTA EN PROCESO ABIERTO
			) 
		GROUP BY 
			DOPD.GuideSerie,
			DOPD.GuideNumber,
			DOP.NoPiece,
			URSD.GuideNumber,
			URSDP.PieceNumber,
			--URSD.RowStatus,
			URSD.IsOpenProcess,
			DOP.IsDry,				
			DOP.NoPiece
		UNION 
		SELECT 
					RPD.Guide_Serie 'GuideSerie',
					RPD.Guide_Number 'GuideNumber',
					DOP.NoPiece 'NumberPiece',
					DOP.IsDry 'IsDry', 
					CONVERT(BIT,IIF(URSD.GuideNumber IS NOT NULL,1,0))  'GuideSettled',
					CONVERT(BIT,IIF(URSD.IsOpenProcess =1,1,0))  'OpenProcess', 
					CONVERT(BIT,IIF(URSDP.PieceNumber IS NOT NULL,1,0))  'PieceSettled'
		FROM DBO.RouteAssigment RA 
		INNER JOIN DBO.ServiceManagement SM 
			ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
		INNER JOIN DBO.ServiceManagementDetail SMD 
			ON SMD.ServiceManagement=SM.IdServiceManagement		
		INNER JOIN DBO.SubTypeServiceManagment STSM 
			ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
		INNER JOIN DBO.RoutePreparationDetail RPD 
			ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
		INNER JOIN DBO.DeliveryOrderPiece DOP WITH (NOLOCK)
			ON DOP.GuideSerie=RPD.Guide_Serie
			AND DOP.GuideNumber=RPD.Guide_Number
		LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD ON 		
			URSD.GuideSerie=RPD.Guide_Serie
			AND URSD.GuideNumber=RPD.Guide_Number
			AND URSD.RowStatus=1
		LEFT JOIN DBO.UnifiedRouteSettlementDetailPiece URSDP ON 		
			URSDP.UnifiedRouteSettlementDetailId=URSD.IdUnifiedRouteSettlementDetail
			AND URSDP.RowStatus=1
		LEFT JOIN DBO.UnifiedRouteSettlement URS ON URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement
		LEFT JOIN DBO.DeliverySettlementDetail DSETTD ON 
			DSETTD.Guide_Serie=RPD.Guide_Serie
			AND DSETTD.Guide_Number=RPD.Guide_Number
		LEFT JOIN dbo.SettlementByPickup sbp ON
			sbp.RouteAssigmentId=RA.IdRouteAssigment
		WHERE 
			RA.RowStatus=1		
			AND RA.IdVehicle IS NOT NULL
			AND RA.IdRoute IS NOT NULL		
			AND RA.IdCurrierMan=@IdCourier--@CUI
			AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
			AND RA.DateOfRoute =@Date
			AND  NOT(--FILTRANDO POR GUÍAS PENDIENTES DE LIQUIDAR
				URSDP.PieceNumber IS NOT NULL --LA PIEZA ESTA LIQUIDADA
				AND URSD.GuideNumber IS NOT NULL --LA GUIA ESTA LIQUIDADA
				AND URSD.IsOpenProcess=0  --LA GUIA ESTA NO ESTA EN PROCESO ABIERTO
			) 
		GROUP BY 
			--STSM.IdSubTypeServiceManagment,
			--STSM.Name,
			RPD.Guide_Serie,
			RPD.Guide_Number,
			URSD.GuideNumber,
			URSDP.PieceNumber,
			DOP.IsDry, 
			URSD.IsOpenProcess,				
			DOP.NoPiece
				
		IF @TranCounter = 0  
			COMMIT TRANSACTION; 
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPGetGuideDetailPendingToSettled;  
		SELECT			  
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
	END CATCH
END