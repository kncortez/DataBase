-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2025-12-01>
-- Description:	<Description,Obtener data de guía para impresión en formato ZPL por medio de ña refernecia (OrderNUmber)>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetShippingGuideDataInZPLFormat]
@Reference INT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @StatusGenerated INT, @StatusRequested INT, @StatusCollected INT;
	DECLARE @IndividualWebSys INT,@ExpressWebSys INT,@CorporateWebSys INT,@ParserSys INT;
	
	SELECT
		@StatusGenerated = MAX(CASE WHEN SO.OrderDescription = 'Generado' THEN SO.StatusOrderId END),
		@StatusRequested = MAX(CASE WHEN SO.OrderDescription = 'Solicitado' THEN SO.StatusOrderId END),
		@StatusCollected = MAX(CASE WHEN SO.OrderDescription = 'Recolectado' THEN SO.StatusOrderId END)
	FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
	WHERE SO.OrderDescription IN ('Generado','Solicitado','Recolectado');

	SELECT
		@IndividualWebSys = MAX(CASE WHEN SysNameSystem = 'Hermes Web' THEN SysIdSystem END),
		@ExpressWebSys    = MAX(CASE WHEN SysNameSystem = 'Hermes Web-ExpressCenter' THEN SysIdSystem END),
		@CorporateWebSys  = MAX(CASE WHEN SysNameSystem = 'Hermes Web-Corporativo' THEN SysIdSystem END),
		@ParserSys        = MAX(CASE WHEN SysNameSystem = 'Parser' THEN SysIdSystem END)
	FROM [DeliveryBackOffice].[dbo].[CatSystem] WITH (NOLOCK)
	WHERE SysNameSystem IN (
		'Hermes Web',
		'Hermes Web-ExpressCenter',
		'Hermes Web-Corporativo',
		'Parser'
	);

	SELECT TOP 1
        DO.Ticket_Number,
        DO.Order_Number,
        DO.Sender_ID,
        DO.Sender_FirstName,
        DO.Sender_LastName,
        DO.Sender_Address,
        DO.Sender_Zone,
        DO.Receiver_ID,
        DO.Receiver_FirstName,
        DO.Receiver_LastName,
        DO.Receiver_Address,
        DO.Sender_Town,
        DO.Sender_Department,
        DO.Sender_Phone,
        DO.Receiver_Zone,
        DO.Receiver_Town,
        DO.Receiver_Department,
        DO.Receiver_Phone,
        DO.Receiver_Email,
        DO.Receiver_Alternant_ID,
        DO.Receiver_Alternant_FullName,
        DO.Guide_Serie,
        DO.Guide_Number,
        DO.DateCreated,
        DO.StatusOrderId,
        DO.Collect_OnDelivery,
        DO.Guide_Collected,
        DO.SenderIdTownship,
        DO.ReceiverIdTownship,
        DO.IdCustomer,
        DO.TypeService,
        DO.Sender_Mail,
        DO.IdDeliveryOption,
		CDO.[Name] [DeliveryDescription],
        DO.ReceiverIdSettlement,
        DO.HubOriginId,
        DO.HubDestinationId,
        DO.OriginSenderId,
        DO.VisitpointClientPortfolioId,
        DO.Segment,
        DO.CatSystemId,
        DO.CatModuleId,
        DO.IsLastMileReturn,
        DO.DeliveryETA,
        DO.SenderCountryId,
        DO.ReceiverCountryId,
        DO.GuideType,
        DO.SenderIdSettlement,
		CASE 
			WHEN DO.IsLastMileReturn   =  1 THEN 'D'
			WHEN CBS.BusinessSegmentName   = 'B2B'  THEN 'B'
			ELSE 'E'
		END AS [Priority],
		CASE
			WHEN DOP.PiecePhysicalWeight > 0 THEN 
				IIF(DOP.PiecePhysicalWeight >= DOP.PieceWeight, CAST(ROUND(DOP.PiecePhysicalWeight,0) AS INT),CAST(ROUND(DOP.PieceWeight,0) AS INT))
					ELSE 
						CAST(ROUND(RH.AdditionalWeightRate,0)AS INT) END 'WeightLB',
		 CAST(ROUND(RH.WeightLimit,0) AS INT) AS 'WeightOf',
		 DOP.Detail AS [Description],
		 DO.IndicationsToSendDestination AS [Service_Ref1],
		 (
			CASE
				WHEN ISNULL([DO].[IsCollect], 0) = 1 THEN 'COLLECT'
				WHEN [DOPD].[TimePlaId] = 1 THEN 'PREPAGO'
			    WHEN [DOPD].[TimePlaId] = 2 THEN 'PICKUP'
				WHEN [DOPD].[TimePlaId] = 3 THEN 'COLLECT'
				WHEN [DOPD].[TimePlaId] = 4 THEN 'CRÉDITO'
			ELSE 'CRÉDITO'END
		) [WayToPayDescription],
		DO.SenderCountryId AS [IdCountry],
		P.ProvinceAbbreviation [Receiver_Department_Abbrv],
	    CASE 
		    WHEN HL.HubAbbreviation ='' THEN DSC.Hub
			WHEN HL.HubAbbreviation IS NULL THEN DSC.Hub
			WHEN DSC.Hub IS NULL THEN DSC2.Hub
			ELSE HL.HubAbbreviation END
			AS [HubDestiny],
		CASE
			WHEN [vp].[IdKindOfVPClient] = [KOVPC].[IdKindOfVPClient] AND 
			     [KOVPC].[KindOfVPName] = 'Concesionario' AND [KOVPC].IdCountry = DO.SenderCountryId  THEN 'CNC'
			WHEN [vp].[IdKindOfVPClient] = [KOVPC].[IdKindOfVPClient] AND 
			     [KOVPC].[KindOfVPName] = 'Express Center' THEN 'EXC'
			WHEN [DO].[CatSystemId] = @IndividualWebSys THEN 'WEB'
			WHEN [DO].[CatSystemId] = @ExpressWebSys THEN 'EXC'
			WHEN [DO].[CatSystemId] = @CorporateWebSys THEN 'COR'
			WHEN [DO].[CatSystemId] = @ParserSys THEN 'PAR'
			WHEN [DO].[CatSystemId] IS NULL THEN 'API'
		ELSE 'API' END [GuideOrigin],
		CASE 
			WHEN ISNULL(DO.IsLastMileReturn, 0) = 1 THEN ISNULL(DSC2.RouteCode,'') 
				ELSE ISNULL(DSC.RouteCode,'') END AS 'Route_Code'
    FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[Customer] CTM WITH (NOLOCK)
		   ON   DO.IdCustomer= CTM.IdCustomer
		INNER JOIN [DeliveryBackOffice].[dbo].[CatBusinessSegment] CBS WITH (NOLOCK)
		   ON CTM.BusinessSegmentID = CBS.IdBusinessSegment 
		LEFT JOIN [DeliveryBackOffice].[dbo].[CatDeliveryOptions] CDO WITH(NOLOCK)
		   ON DO.IdDeliveryOption = CDO.IdDeliveryOption
		LEFT JOIN [DeliveryBackOffice].[dbo].[RatebyCustomer] RC WITH(NOLOCK)
		   ON DO.IdCustomer = RC.RbcIdCustomer  AND RC.RbcRowStatus = 1 AND
			 (DO.Sender_ID = RC.RbcCodeOfReference OR RC.RbcCodeOfReference IS NULL)
		LEFT JOIN  [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK)
		   ON RC.RbcIdRate= RH.RheId
		INNER JOIN  [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOP WITH(NOLOCK)
		   ON DO.Guide_Serie = DOP.GuideSerie AND
		      DO.Guide_Number = DOP.GuideNumber
		LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
           ON  DOPD.GuideSerie = DO.Guide_Serie AND  
		       DOPD.GuideNumber = DO.Guide_Number
		LEFT JOIN [DeliveryBackOffice].[dbo].[HubLogistics] HL WITH(NOLOCK)
		   ON DO.HubDestinationId = HL.IdHubLogistic
		LEFT JOIN [DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
		   ON DSC.IdSettlement = DO.ReceiverIdSettlement
		LEFT JOIN [DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC2 WITH(NOLOCK)
		   ON DSC2.IdSettlement = DO.SenderIdSettlement
		INNER JOIN [DeliveryBackOffice].[dbo].[Province] P WITH(NOLOCK)
		   ON P.ProvinceName = DO.Receiver_Department
		LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vp WITH (NOLOCK)
           ON vp.CodeOfReference = DO.Sender_ID
		LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointClient] vpori  WITH(NOLOCK) 
		   ON [vpori].[CodeOfReference] = [DO].[OriginSenderId]
		LEFT JOIN [DeliveryBackOffice].[dbo].[KindOfVPClient] KOVPC  WITH(NOLOCK)
		   ON vp.IdKindOfVPClient = KOVPC.IdKindOfVPClient
    WHERE DO.Ticket_Number = @Reference
	      AND DO.StatusOrderId IN (@StatusGenerated, @StatusRequested, @StatusCollected) 
    ORDER BY DO.DateCreated DESC

END
GO