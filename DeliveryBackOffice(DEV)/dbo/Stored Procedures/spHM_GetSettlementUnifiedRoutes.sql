-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <30-09-2022>
-- Description:	<Carga de detalle de manifiestos de liquidación de rutas unificadas>
-- =============================================
CREATE PROCEDURE spHM_GetSettlementUnifiedRoutes
	@IdRoute INT
	--@Date DATE
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION SPStartServiceRecolection
    ELSE  
        BEGIN TRANSACTION;  

	BEGIN TRY			
		DECLARE @IdSubTypeDelivery INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Entrega');
		DECLARE @IdSubTypeReturn INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Devolución');
		DECLARE @IdSubTypePickup INT=(SELECT IdSubTypeServiceManagment from dbo.SubTypeServiceManagment where [Name] =  'Recolección');
		SELECT			  
			1 AS 'StatusCode',
			'Registros obtenidos' AS 'Description';

		SELECT 
			DOPD.GuideSerie 'GuideSerie',
			DOPD.GuideNumber 'GuideNumber',
			COUNT(DO.Pieces_Cold) 'PiecesCold',
			COUNT(DO.Pieces_Dry) 'Pieces_Dry',
			COUNT(DO.Pieces_Dry)+COUNT(DO.Pieces_Dry) 'TotalPieces',
			CONCAT(DOPD.GuideSerie,CAST(DOPD.GuideNumber AS NVARCHAR(100))) 'Guide',
			STSM.IdSubTypeServiceManagment 'IdTypeService',
			STSM.[Name] 'NameTypeService',
			SMD.ServiceManagement 'IdServiceManagement',
			IIF(URSD.RowStatus=1 AND URSD.IsOpenProcess=1,1,0) 'Settlement'
			
		FROM 
			DBO.RouteAssigment RA 
			LEFT JOIN DBO.ServiceManagement SM
				ON RA.IdRouteAssigment=SM.IdPuRouteAssigment
			LEFT JOIN DBO.ServiceManagementDetail SMD 
				ON SMD.ServiceManagement=SM.IdServiceManagement		
			LEFT JOIN DBO.SchedulePickup SP 
				ON SM.IdSchedulePickup=SP.SchedulePickupId
			LEFT JOIN DBO.DeliveryOrderPaymentDetail DOPD 
				ON DOPD.IdHeaderRecolection = SP.SchedulePickupId
			INNER JOIN DBO.SubTypeServiceManagment STSM 
				ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
			LEFT JOIN DBO.DeliveryOrder DO 
				ON DO.Guide_Serie=DOPD.GuideSerie AND DO.Guide_Number=DOPD.GuideNumber
			LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD 
				ON URSD.GuideSerie=DO.Guide_Serie AND URSD.GuideNumber=DO.Guide_Number
		WHERE 
			STSM.IdSubTypeServiceManagment =@IdSubTypePickup
			AND RA.IdRoute=@IdRoute--FILTRO POR RUTA
		GROUP BY 
			STSM.IdSubTypeServiceManagment,
			STSM.Name,
			DOPD.GuideSerie,
			DOPD.GuideNumber,
			SMD.ServiceManagement,
			URSD.RowStatus,
			URSD.IsOpenProcess
		UNION
		SELECT 
			RPD.Guide_Serie 'GuideSerie',
			RPD.Guide_Number 'GuideNumber',
			COUNT(DO.Pieces_Cold) 'PiecesCold',
			COUNT(DO.Pieces_Dry) 'Pieces_Dry',
			COUNT(DO.Pieces_Dry)+COUNT(DO.Pieces_Dry) 'TotalPieces',
			CONCAT(RPD.Guide_Serie,CAST(RPD.Guide_Number AS NVARCHAR(100))) 'Guide',
			STSM.IdSubTypeServiceManagment 'IdTypeService',
			STSM.[Name] 'NameTypeService',
			SMD.ServiceManagement 'IdServiceManagement',
			IIF(URSD.RowStatus=1 AND URSD.IsOpenProcess=1,1,0) 'Settlement'
		FROM 
			DBO.RouteAssigment RA 
			LEFT JOIN DBO.ServiceManagement SM
				ON RA.IdRouteAssigment=SM.IdPuRouteAssigment
			--LEFT JOIN DBO.SchedulePickup SP 
				--ON SM.IdSchedulePickup=SP.SchedulePickupId
			LEFT JOIN DBO.ServiceManagementDetail SMD 
				ON SMD.ServiceManagement=SM.IdServiceManagement		
			LEFT JOIN DBO.RoutePreparationDetail RPD 
				ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
			LEFT JOIN DBO.RoutePreparation RP 
				ON RPD.RoutePreparationId=RP.IdRoutePreparation
			LEFT JOIN DBO.RoutePreparationDetailPiece RPDP 
				ON RPDP.RoutePreparationDetailId=RPD.IdRoutePreparationDetail
			INNER JOIN DBO.SubTypeServiceManagment STSM 
				ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
			LEFT JOIN DBO.DeliveryOrder DO 
				ON DO.Guide_Serie=RPD.Guide_Serie AND DO.Guide_Number=RPD.Guide_Number
			LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD 
				ON URSD.GuideSerie=DO.Guide_Serie AND URSD.GuideNumber=DO.Guide_Number
		WHERE 
			STSM.IdSubTypeServiceManagment =@IdSubTypePickup
			OR  (
				STSM.IdSubTypeServiceManagment  in (@IdSubTypeReturn,@IdSubTypeDelivery)
				AND RP.DeliveryOrderBySettlementId IS NOT NULL--FILTRANDO POR GUÍAS CON MANIFIESTO
			)			
		AND RA.IdRoute=@IdRoute--FILTRO POR RUTA
		GROUP BY 
			STSM.IdSubTypeServiceManagment,
			STSM.Name,
			RPD.Guide_Serie,
			RPD.Guide_Number,
			SMD.ServiceManagement,
			URSD.RowStatus,
			URSD.IsOpenProcess;


		
	END TRY
	BEGIN CATCH
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
                ROLLBACK TRANSACTION SPStartServiceRecolection;  
		SELECT			  
			0 AS 'StatusCode',
			ERROR_MESSAGE() AS 'Description';
	END CATCH




END