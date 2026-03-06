-- =============================================
-- Author:		<Author,Erick Guerra>
-- Create date: <Create Date,2026-02-27>
-- Description:	<Description, Obtain data from several guides, for printing in ZPL format using the reference number (OrderNUmber)>
-- =============================================

DROP PROCEDURE SPHW_GetManyShippingGuideDataInZPLFormat

-- Tabla temporal, formato de respuesta
CREATE TYPE dbo.TblTicketList AS TABLE
(
	[IdCustomer]            INT NOT NULL,
    [TicketNumber] NVARCHAR(150) NOT NULL
);
GO

CREATE PROCEDURE [dbo].[SPHW_GetManyShippingGuideDataInZPLFormat]
(
    @Tickets dbo.TblTicketList READONLY
)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY

		IF NOT EXISTS (SELECT 1 FROM @Tickets)
        BEGIN
            SELECT
                204 AS ResponseCode,
                'No se recibieron tickets para procesar.' AS ResponseMessage;

            -- Tabla de datos vacía
            SELECT
                CAST(NULL AS NVARCHAR(50)) AS Ticket_Number
            WHERE 1 = 0;

            RETURN;
        END;

		DECLARE @StatusGenerated INT,
			@StatusRequested INT,
			@StatusCollected INT,
			@IndividualWebSys INT,
			@ExpressWebSys INT,
			@CorporateWebSys INT,
			@ParserSys INT;
	
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

		SELECT
            200 AS ResponseCode,
            'Proceso realizado exitosamente.' AS ResponseMessage;

		SELECT
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
					IIF(
						DOP.PiecePhysicalWeight >= DOP.PieceWeight, 
						CAST(ROUND(DOP.PiecePhysicalWeight,0) AS INT),
						CAST(ROUND(DOP.PieceWeight,0) AS INT)
					)
				ELSE CAST(ROUND(RH.AdditionalWeightRate,0)AS INT) 
			 END 'WeightLB',

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
					ELSE 'CRÉDITO'
				END
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
			INNER JOIN @Tickets T
				ON DO.Ticket_Number = T.TicketNumber and DO.IdCustomer = T.IdCustomer
			INNER JOIN [DeliveryBackOffice].[dbo].[Customer] CTM WITH (NOLOCK)
			   ON   DO.IdCustomer= CTM.IdCustomer
			INNER JOIN [DeliveryBackOffice].[dbo].[CatBusinessSegment] CBS WITH (NOLOCK)
			   ON CTM.BusinessSegmentID = CBS.IdBusinessSegment 
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatDeliveryOptions] CDO WITH(NOLOCK)
			   ON DO.IdDeliveryOption = CDO.IdDeliveryOption
			LEFT JOIN [DeliveryBackOffice].[dbo].[RatebyCustomer] RC WITH(NOLOCK)
			   ON DO.IdCustomer = RC.RbcIdCustomer  AND RC.RbcRowStatus = 1
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
		WHERE DO.StatusOrderId IN (@StatusGenerated, @StatusRequested, @StatusCollected) 
			AND (DO.Sender_ID = RC.RbcCodeOfReference OR RC.RbcCodeOfReference IS NULL)
		ORDER BY DO.DateCreated DESC;

	END TRY
	BEGIN CATCH
		SELECT
            500 AS ResponseCode,
            ERROR_MESSAGE() AS ResponseMessage;

        -- Tabla de datos vacía
        SELECT
            CAST(NULL AS NVARCHAR(50)) AS Ticket_Number
        WHERE 1 = 0;
	
	END CATCH
END
GO