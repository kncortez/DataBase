-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <2022-10-28>
-- Description:	<Actualiza la bandera IsLastMileReturn a aquellas guías que estan marcadas como devolución o que ya no tienen intentos de entrega fallida>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_UpdateReturnStatementGuides]
	-- Add the parameters for the stored procedure here
	@IdCourier INT,
	@Token NVARCHAR(50),
	@Date DATE=NULL
AS
BEGIN
	IF @Date IS NULL
		SET @Date= GETDATE()
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @STATUSFAILED_DO INT = (SELECT StatusOrderId FROM dbo.StatusOrder WITH (NOLOCK) WHERE OrderDescription = 'Intento de entrega fallida');
	DECLARE @STATUSDELIVERED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Entregado');
	DECLARE @STATUSRETURNED_DO INT = (SELECT StatusOrderId FROM DBO.StatusOrder WHERE OrderDescription = 'Devuelto');
	DECLARE @STATUSDECLAREDRETURNED_DO INT = (SELECT TOP 1 SO.StatusOrderId FROM DBO.StatusOrder SO WITH(NOLOCK) WHERE OrderDescription = 'Declarado para Devolución');

	--
    
		DECLARE @UpdateGuides TABLE (
			GuideSerie NVARCHAR(2),
			GuideNumber INT,
			NoAttempts BIT,
			MarkedAsReturn BIT
		);

	--listando guias de entrega sin intentos de entrega fallida
		
		--seteae el campo IsLastMileReturn=1

	BEGIN TRANSACTION
	BEGIN TRY

		INSERT INTO @UpdateGuides (GuideSerie,GuideNumber,NoAttempts,MarkedAsReturn)
		SELECT 
			DO.Guide_Serie,
			DO.Guide_Number,
			1,
			0
		FROM DBO.RouteAssigment RA  WITH(NOLOCK) 
		INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
			ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
		INNER JOIN DBO.ServiceManagementDetail SMD  WITH(NOLOCK) 
			ON SMD.ServiceManagement=SM.IdServiceManagement		
		INNER JOIN DBO.SubTypeServiceManagment STSM  WITH(NOLOCK) 
			ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
		INNER JOIN DBO.RoutePreparationDetail RPD  WITH(NOLOCK) 
			ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
		INNER JOIN DBO.DeliveryOrder DO  WITH(NOLOCK) 
			ON DO.Guide_Serie=RPD.Guide_Serie
			AND DO.Guide_Number=RPD.Guide_Number
		LEFT JOIN DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) 
			ON URS.RouteAssignmentId=RA.IdRouteAssigment
		LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD  WITH(NOLOCK) ON 		
			URSD.GuideSerie=RPD.Guide_Serie
			AND URSD.GuideNumber=RPD.Guide_Number
			AND URSD.RowStatus=1
			AND URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement


		LEFT JOIN DBO.DeliveryOrderDetail DORD WITH(NOLOCK) ON 
			DO.Guide_Serie=DORD.Guide_Serie AND 
			DO.Guide_Number=DORD.Guide_Number
			AND DORD.StatusOrderId= @STATUSFAILED_DO
		LEFT JOIN DBO.Customer CU WITH(NOLOCK) ON DO.IdCustomer=CU.IdCustomer
						LEFT JOIN DBO.RatebyCustomer RC WITH(NOLOCK) ON CU.IdCustomer=RC.RbcIdCustomer
						LEFT JOIN RateHeader RH WITH(NOLOCK) ON RC.RbcIdRate=RH.RheId								
		WHERE 
			RA.RowStatus=1		
			AND RA.IdVehicle IS NOT NULL
			AND RA.IdRoute IS NOT NULL		
			AND RA.IdCurrierMan=@IdCourier--@CUI
			--AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
			AND RA.DateOfRoute =@Date
			AND DO.IsLastMileReturn=0
			AND (URSD.RowStatus=1 AND URSD.IsOpenProcess=0)--FILTRO PARA GUIAS LIQUIDADAS
		GROUP BY DO.Guide_Serie,DO.Guide_Number,CU.IdCustomer,RH.Attempt,DORD.StatusOrderId
		HAVING COUNT(DISTINCT CHECKSUM(DORD.Guide_Serie,DORD.Guide_Number,DORD.DateCreated))>=(case when RH.Attempt is NULL then 2 else RH.Attempt end)--FILTRANDO GUIAS SIN INTENTOS DE ENTREGAS


		--LISTANDO TODAS LAS GUÍAS MARCADAS COMO DEVOLUCIÓN Y QUE NO ESTAN CON IsLastMileReturn=1 para actualizar dicho campo
		INSERT INTO @UpdateGuides (GuideSerie,GuideNumber,NoAttempts,MarkedAsReturn)
		SELECT 
			DO.Guide_Serie,
			DO.Guide_Number,
			0,
			1
		FROM DBO.RouteAssigment RA  WITH(NOLOCK) 
		INNER JOIN DBO.ServiceManagement SM  WITH(NOLOCK) 
			ON SM.IdPuRouteAssigment=RA.IdRouteAssigment
		INNER JOIN DBO.ServiceManagementDetail SMD  WITH(NOLOCK) 
			ON SMD.ServiceManagement=SM.IdServiceManagement		
		INNER JOIN DBO.SubTypeServiceManagment STSM  WITH(NOLOCK) 
			ON SMD.SubTypeServiceManagmentId=STSM.IdSubTypeServiceManagment
		INNER JOIN DBO.RoutePreparationDetail RPD  WITH(NOLOCK) 
			ON RPD.ServiceManagementDetailId=SMD.IdServiceManagementDetail
		INNER JOIN DBO.DeliveryOrder DO  WITH(NOLOCK) 
			ON DO.Guide_Serie=RPD.Guide_Serie
			AND DO.Guide_Number=RPD.Guide_Number
		LEFT JOIN DBO.UnifiedRouteSettlement URS  WITH(NOLOCK) 
			ON URS.RouteAssignmentId=RA.IdRouteAssigment
		LEFT JOIN DBO.UnifiedRouteSettlementDetail URSD WITH(NOLOCK)  ON 		
			URSD.GuideSerie=RPD.Guide_Serie
			AND URSD.GuideNumber=RPD.Guide_Number
			AND URSD.RowStatus=1
			AND URSD.UnifiedRouteSettlementId=URS.IdUnifiedRouteSettlement

		WHERE 
			RA.RowStatus=1		
			AND RA.IdVehicle IS NOT NULL
			AND RA.IdRoute IS NOT NULL		
			AND RA.IdCurrierMan=@IdCourier--@CUI
			AND URS.UserSettlement IS NULL --FILTRO PARA LIQUIDACIONES PENDIENTES DE CERRAR
			AND RA.DateOfRoute =@Date
			AND DO.StatusOrderId =@STATUSRETURNED_DO
			AND DO.IsLastMileReturn=0
			AND (URSD.RowStatus=1 AND URSD.IsOpenProcess=0)--FILTRO PARA GUIAS LIQUIDADAS
		


		UPDATE DO SET
			DO.IsLastMileReturn=1,
			DO.StatusOrderId= @STATUSDECLAREDRETURNED_DO, -- Declarado para devolución
			DO.TokenUpdated=@Token,
			DO.DateUpdated=GETDATE()
		FROM DBO.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN @UpdateGuides UG ON 
			DO.Guide_Serie=UG.GuideSerie
			AND DO.Guide_Number=UG.GuideNumber
		WHERE NoAttempts=1;
	
		UPDATE DO SET
			DO.IsLastMileReturn=1,
			DO.StatusOrderId = @STATUSDECLAREDRETURNED_DO, -- Declarado para devolución
			DO.TokenUpdated=@Token,
			DO.DateUpdated=GETDATE()
		FROM DBO.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN @UpdateGuides UG ON 
			DO.Guide_Serie=UG.GuideSerie
			AND DO.Guide_Number=UG.GuideNumber
		WHERE MarkedAsReturn=1;

		INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
			(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, RowStatus)
		SELECT
			DISTINCT
				UG.GuideSerie, UG.GuideNumber, @STATUSDECLAREDRETURNED_DO, @Token, GETDATE(), GETDATE(), 1
		FROM DBO.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN @UpdateGuides UG ON 
			DO.Guide_Serie=UG.GuideSerie
			AND DO.Guide_Number=UG.GuideNumber
		WHERE NoAttempts=1;
		
		INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
			(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, RowStatus)
		SELECT
			DISTINCT
				UG.GuideSerie, UG.GuideNumber, @STATUSDECLAREDRETURNED_DO, @Token, GETDATE(), GETDATE(), 1
		FROM DBO.DeliveryOrder DO WITH(NOLOCK)
		INNER JOIN @UpdateGuides UG ON 
			DO.Guide_Serie=UG.GuideSerie
			AND DO.Guide_Number=UG.GuideNumber
		WHERE MarkedAsReturn=1;

		
		-- registrar checkpoint histórico de devolución
		INSERT INTO [dbo].[DeliveryOrderDetail] ([Guide_Serie]
		, [Guide_Number]
		, [StatusOrderId]
		, [UserCreated]
		, [DateCreated]
		, [DateCreatedInSystem]
		, [Observations]
		, [Temperature_Celsius])
			SELECT
				GuideSerie
			   ,GuideNumber
			   ,@STATUSDECLAREDRETURNED_DO
			   ,@Token
			   ,GETDATE()
			   ,GETDATE()
			   ,NULL
			   ,NULL
			FROM @UpdateGuides
			WHERE NoAttempts = 1;

		SELECT 
			GuideSerie,
			GuideNumber,
			NoAttempts,
			MarkedAsReturn
		FROM @UpdateGuides;

		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION;

		-- Revisar con Author: <Alberto Ixchop> Que casos harían que falle y que debe responser

	END CATCH

END