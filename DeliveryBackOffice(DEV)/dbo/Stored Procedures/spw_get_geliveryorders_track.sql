-- Stored Procedure
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-05-20>
-- Description:	<Devuelve ordenes de entrega por rango fecha>
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-01-26>
-- Description:	<Se Agregaron a las consultas los campos de receptor Alterante>
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-04-25>
-- Description:	<Mejoras de multimoneda.>
-- Create date: <2025-05-02>
-- Description:	<Filtrado por país cuando se solicitan las guías de todos los clientes.>
-- Create date: <2025-08-01>
-- Description:	<Mejoras de rendimiento y reestructura.>
-- =============================================
CREATE PROCEDURE [dbo].[spw_get_geliveryorders_track]
    -- Add the parameters for the stored procedure here
    @Token AS VARCHAR(50)		= '08cc0ffe737713a57ce17ad4997156a0',
    @Rol AS BIGINT				= 874,
    @BeginDate AS VARCHAR(50)	= '23/09/2021',
    @EndDate AS VARCHAR(50)		= '23/09/2021',
    @IdCustomer AS INT			= -1,
    @GuideSerie AS VARCHAR(2)	= 'FD',
    @GuideNumber AS INT			= 0 ,
	@IdCountry AS NVARCHAR(2)	= 'GT'
AS
BEGIN

	-- SET NOCOUNT ON added to prevent extra result sets from
    SET NOCOUNT ON;

	-- Insert statements for procedure here
	DECLARE @IdSystem AS INT;
	DECLARE @DateIni AS DATE;
    DECLARE @DateFin AS DATE;

    SET DATEFORMAT DMY;
	SET @DateIni = CONVERT(DATE, @BeginDate);
    SET @DateFin = CONVERT(DATE, @EndDate);

	SELECT @IdSystem = ROL.LGN_IdSystem
    FROM DenariusUser_Dev.dbo.LGN_Rol ROL WITH (NOLOCK)
    WHERE ROL.LGN_IdRol = @Rol;

	IF EXISTS 
	  (	SELECT 1 FROM DenariusUser_Dev.dbo.LGN_LogByToken logtoken WITH (NOLOCK)
		WHERE logtoken.SSN_IdToken = @Token AND logtoken.SSN_IdSystem = @IdSystem
		AND logtoken.SSN_TokenStatus = 1 )
	BEGIN
		IF (@IdCustomer = -1)
		BEGIN
			IF (@GuideNumber = 0)
            BEGIN

				PRINT 'ENTRO CUSTOMER -1 Y GUIDENUMBER = 0';

                SELECT TOP 1000
					  CAST(DO.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(DO.Sender_FirstName), '') + ' '
                      + ISNULL(UPPER(DO.Sender_LastName), '')													[NameOfSender]
					, ISNULL(UPPER(DO.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(DO.Receiver_LastName), '')	[NameOfReceiver]
					, ISNULL(UPPER(DO.NameOfReceiver), '')														[ReceiverName]  
					, CONVERT(VARCHAR, DO.DateCreated, 103)														[PickUpDateTime]
					, CONVERT(VARCHAR, DO.Shipping_Date, 103)													[ScheduledDeliveryDate]
					, ISNULL(CONVERT(VARCHAR, DOD_REAL.RealDeliveryDate, 103), '')								[RealDeliveryDate]
					, DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR)											[GuideNumber]
					, SO.OrderDescription																		[OrderStatus]
					, DO.Manifest_Serie + CAST(DO.Manifest_Number AS VARCHAR)									[ManifestNumber]
					, ISNULL(DO.Receiver_Department, '')														[ReceiverDepartment]
                    , ISNULL(DO.Ticket_Number, '')																[IdOrderReference]
					, ISNULL(IH.inv_certificationFEL, '')														[CertificationFEL]
					, CASE 
						WHEN ACCF.IdCustomer IS NOT NULL	THEN 'Portal Web'
						WHEN cs.IdCustomerType		= 2		THEN 'Express Center'
						WHEN cs.IdCustomerType		= 1		THEN 'Corporativo'
						WHEN cs.IdCustomerType		= 3		THEN 'Individual'
						WHEN ACCF2.Acc				>= 1	THEN 'Portal Web'
						ELSE 'Otros'
					  END																						[SourceGuide]
					, CAST((ISNULL(DO.Pieces_Cold, 0) + ISNULL(DO.Pieces_Dry, 0)) AS VARCHAR)					[Pieces]
					, ISNULL(CCC.Symbol + '.', 'Q.')															[Symbol]
					, CAST(ISNULL(DO.IsCollect, 0) AS VARCHAR)													[IsCollect]
					, IIF(DO.IsCollect = 1, CAST(DO.PriceShippment AS VARCHAR), '0.00')							[AmountShipment]
					, CAST(DO.Collect_OnDelivery AS VARCHAR)													[AmmountCOD]
                    , ISNULL(UPPER(VPC.DescriptionOfClient), '')												[VPSource]
                    , ISNULL(UPPER(CS.[Name]), '')																[Customer]
					, ISNULL(DO.Order_Number, '')																[OrderNumber]
                    , ISNULL(DO.Receiver_Address, '')															[ReceiverAddress]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityId]
					, ISNULL(DO.Receiver_CUI, '')																[CUI]
                    , ISNULL(DO.Receiver_Alternant_FullName, '')												[NameOfReceiverAlternante]
                    , ISNULL(DO.Receiver_Alternant_CUI, '')														[CUIAlternante]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityAlternante]
                    , ISNULL(DO.Receiver_Alternant_Phone, '')													[PhoneAlternante]
                FROM DeliveryBackOffice.dbo.DeliveryOrder				DO		WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder		SO		WITH (NOLOCK)
                        ON DO.StatusOrderId = SO.StatusOrderId
                    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient	VPC		WITH (NOLOCK)
                        ON DO.Sender_ID = VPC.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer			CS		WITH (NOLOCK)
                        ON CS.IdCustomer = VPC.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail		ID		WITH (NOLOCK)
                        ON dti_fk_orderNumber = DO.Guide_Number
                        AND dti_fk_orderSerie = DO.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader		IH		WITH (NOLOCK)
                        ON IH.inv_pk_id = ID.dti_fk_header
						AND IH.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
						AND IH.inv_certificationFEL IS NOT NULL
						AND IH.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost				C		WITH (NOLOCK)
                        ON DO.Guide_Serie = C.GuideSerie 
						AND DO.Guide_Number = C.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD		CCC		WITH (NOLOCK)
                        ON CCC.IdCatCurrencyCOD = ISNULL(C.CodCurrency,C.ShippingCurrency)
					OUTER APPLY (
						SELECT TOP 1 DOD.DateCreated AS RealDeliveryDate
						FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD		WITH (NOLOCK)
						WHERE DOD.Guide_Number = DO.Guide_Number
						AND DOD.Guide_Serie = DO.Guide_Serie
						AND DOD.StatusOrderId = 5
						ORDER BY DOD.DateCreated ASC
					) DOD_REAL
					OUTER APPLY (
						SELECT TOP (1)
							ACC.IdCustomer
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = cs.IdCustomer
                        AND ACC.AccRowStatus = 'TRUE'
					) ACCF
					OUTER APPLY (
                        SELECT TOP 1 1 Acc
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = DO.IdCustomer
                    ) ACCF2
                WHERE 
					DO.DateCreated >= @DateIni AND DO.DateCreated < DATEADD(DAY, 1, @DateFin)
					AND DO.ReceiverCountryId = @IdCountry  --Filtrado por país
                    AND DO.StatusOrderId <> 7	-- No guías anuladas
                    AND DO.StatusOrderId <> 15  -- No guías generadas
				ORDER BY DO.DateCreated DESC
			END;
			ELSE
			BEGIN
				
				PRINT 'ENTRO CUSTOMER -1 Y GUIDENUMBER  <> 0';

                SELECT
					  CAST(DO.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(DO.Sender_FirstName), '') + ' '
                      + ISNULL(UPPER(DO.Sender_LastName), '')													[NameOfSender]
					, ISNULL(UPPER(DO.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(DO.Receiver_LastName), '')	[NameOfReceiver]
					, ISNULL(UPPER(DO.NameOfReceiver), '')														[ReceiverName]  
					, CONVERT(VARCHAR, DO.DateCreated, 103)														[PickUpDateTime]
					, CONVERT(VARCHAR, DO.Shipping_Date, 103)													[ScheduledDeliveryDate]
					, ISNULL(CONVERT(VARCHAR, DOD_REAL.RealDeliveryDate, 103), '')								[RealDeliveryDate]
					, DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR)											[GuideNumber]
					, SO.OrderDescription																		[OrderStatus]
					, DO.Manifest_Serie + CAST(DO.Manifest_Number AS VARCHAR)									[ManifestNumber]
					, ISNULL(DO.Receiver_Department, '')														[ReceiverDepartment]
                    , ISNULL(DO.Ticket_Number, '')																[IdOrderReference]
					, ISNULL(IH.inv_certificationFEL, '')														[CertificationFEL]
					, CASE 
						WHEN ACCF.IdCustomer IS NOT NULL	THEN 'Portal Web'
						WHEN cs.IdCustomerType		= 2		THEN 'Express Center'
						WHEN cs.IdCustomerType		= 1		THEN 'Corporativo'
						WHEN cs.IdCustomerType		= 3		THEN 'Individual'
						WHEN ACCF2.Acc				>= 1	THEN 'Portal Web'
						ELSE 'Otros'
					  END																						[SourceGuide]
					, CAST((ISNULL(DO.Pieces_Cold, 0) + ISNULL(DO.Pieces_Dry, 0)) AS VARCHAR)					[Pieces]
					, ISNULL(CCC.Symbol + '.', 'Q.')															[Symbol]
					, CAST(ISNULL(DO.IsCollect, 0) AS VARCHAR)													[IsCollect]
					, IIF(DO.IsCollect = 1, CAST(DO.PriceShippment AS VARCHAR), '0.00')							[AmountShipment]
					, CAST(DO.Collect_OnDelivery AS VARCHAR)													[AmmountCOD]
                    , ISNULL(UPPER(VPC.DescriptionOfClient), '')												[VPSource]
                    , ISNULL(UPPER(CS.[Name]), '')																[Customer]
					, ISNULL(DO.Order_Number, '')																[OrderNumber]
                    , ISNULL(DO.Receiver_Address, '')															[ReceiverAddress]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityId]
					, ISNULL(DO.Receiver_CUI, '')																[CUI]
                    , ISNULL(DO.Receiver_Alternant_FullName, '')												[NameOfReceiverAlternante]
                    , ISNULL(DO.Receiver_Alternant_CUI, '')														[CUIAlternante]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityAlternante]
                    , ISNULL(DO.Receiver_Alternant_Phone, '')													[PhoneAlternante]
                FROM DeliveryBackOffice.dbo.DeliveryOrder				DO		WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder		SO		WITH (NOLOCK)
                        ON DO.StatusOrderId = SO.StatusOrderId
                    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient	VPC		WITH (NOLOCK)
                        ON DO.Sender_ID = VPC.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer			CS		WITH (NOLOCK)
                        ON CS.IdCustomer = VPC.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail		ID		WITH (NOLOCK)
                        ON dti_fk_orderNumber = DO.Guide_Number
                        AND dti_fk_orderSerie = DO.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader		IH		WITH (NOLOCK)
                        ON IH.inv_pk_id = ID.dti_fk_header
						AND IH.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
						AND IH.inv_certificationFEL IS NOT NULL
						AND IH.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost				C		WITH (NOLOCK)
                        ON DO.Guide_Serie = C.GuideSerie 
						AND DO.Guide_Number = C.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD		CCC		WITH (NOLOCK)
                        ON CCC.IdCatCurrencyCOD = ISNULL(C.CodCurrency,C.ShippingCurrency)
					OUTER APPLY (
						SELECT TOP 1 DOD.DateCreated AS RealDeliveryDate
						FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD		WITH (NOLOCK)
						WHERE DOD.Guide_Number = DO.Guide_Number
						AND DOD.Guide_Serie = DO.Guide_Serie
						AND DOD.StatusOrderId = 5
						ORDER BY DOD.DateCreated ASC
					) DOD_REAL
					OUTER APPLY (
						SELECT TOP (1)
							ACC.IdCustomer
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = cs.IdCustomer
                        AND ACC.AccRowStatus = 'TRUE'
					) ACCF
					OUTER APPLY (
                        SELECT TOP 1 1 Acc
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = DO.IdCustomer
                    ) ACCF2
                WHERE 
					DO.Guide_Serie = @GuideSerie
                    AND DO.Guide_Number = @GuideNumber
					AND DO.ReceiverCountryId = @IdCountry  --Filtrado por país
                    AND DO.StatusOrderId <> 7	-- No guías anuladas
                    AND DO.StatusOrderId <> 15; -- No guías generadas
			END;
		END;
		ELSE
		BEGIN
			IF (@GuideNumber = 0)
            BEGIN

				PRINT 'ENTRO CUSTOMER <> -1 Y GUIDENUMBER = 0';

				SELECT TOP 500
					  CAST(DO.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(DO.Sender_FirstName), '') + ' '
                      + ISNULL(UPPER(DO.Sender_LastName), '')													[NameOfSender]
					, ISNULL(UPPER(DO.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(DO.Receiver_LastName), '')	[NameOfReceiver]
					, ISNULL(UPPER(DO.NameOfReceiver), '')														[ReceiverName]  
					, CONVERT(VARCHAR, DO.DateCreated, 103)														[PickUpDateTime]
					, CONVERT(VARCHAR, DO.Shipping_Date, 103)													[ScheduledDeliveryDate]
					, ISNULL(CONVERT(VARCHAR, DOD_REAL.RealDeliveryDate, 103), '')								[RealDeliveryDate]
					, DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR)											[GuideNumber]
					, SO.OrderDescription																		[OrderStatus]
					, DO.Manifest_Serie + CAST(DO.Manifest_Number AS VARCHAR)									[ManifestNumber]
					, ISNULL(DO.Receiver_Department, '')														[ReceiverDepartment]
                    , ISNULL(DO.Ticket_Number, '')																[IdOrderReference]
					, ISNULL(IH.inv_certificationFEL, '')														[CertificationFEL]
					, CASE 
						WHEN ACCF.IdCustomer IS NOT NULL	THEN 'Portal Web'
						WHEN cs.IdCustomerType		= 2		THEN 'Express Center'
						WHEN cs.IdCustomerType		= 1		THEN 'Corporativo'
						WHEN cs.IdCustomerType		= 3		THEN 'Individual'
						WHEN ACCF2.Acc				>= 1	THEN 'Portal Web'
						ELSE 'Otros'
					  END																						[SourceGuide]
					, CAST((ISNULL(DO.Pieces_Cold, 0) + ISNULL(DO.Pieces_Dry, 0)) AS VARCHAR)					[Pieces]
					, ISNULL(CCC.Symbol + '.', 'Q.')															[Symbol]
					, CAST(ISNULL(DO.IsCollect, 0) AS VARCHAR)													[IsCollect]
					, IIF(DO.IsCollect = 1, CAST(DO.PriceShippment AS VARCHAR), '0.00')							[AmountShipment]
					, CAST(DO.Collect_OnDelivery AS VARCHAR)													[AmmountCOD]
                    , ISNULL(UPPER(VPC.DescriptionOfClient), '')												[VPSource]
                    , ISNULL(UPPER(CS.[Name]), '')																[Customer]
					, ISNULL(DO.Order_Number, '')																[OrderNumber]
                    , ISNULL(DO.Receiver_Address, '')															[ReceiverAddress]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityId]
					, ISNULL(DO.Receiver_CUI, '')																[CUI]
                    , ISNULL(DO.Receiver_Alternant_FullName, '')												[NameOfReceiverAlternante]
                    , ISNULL(DO.Receiver_Alternant_CUI, '')														[CUIAlternante]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityAlternante]
                    , ISNULL(DO.Receiver_Alternant_Phone, '')													[PhoneAlternante]
                FROM DeliveryBackOffice.dbo.DeliveryOrder				DO		WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder		SO		WITH (NOLOCK)
                        ON DO.StatusOrderId = SO.StatusOrderId
                    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient	VPC		WITH (NOLOCK)
                        ON DO.Sender_ID = VPC.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer			CS		WITH (NOLOCK)
                        ON CS.IdCustomer = VPC.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail		ID		WITH (NOLOCK)
                        ON dti_fk_orderNumber = DO.Guide_Number
                        AND dti_fk_orderSerie = DO.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader		IH		WITH (NOLOCK)
                        ON IH.inv_pk_id = ID.dti_fk_header
						AND IH.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
						AND IH.inv_certificationFEL IS NOT NULL
						AND IH.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost				C		WITH (NOLOCK)
                        ON DO.Guide_Serie = C.GuideSerie 
						AND DO.Guide_Number = C.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD		CCC		WITH (NOLOCK)
                        ON CCC.IdCatCurrencyCOD = ISNULL(C.CodCurrency,C.ShippingCurrency)
					OUTER APPLY (
						SELECT TOP 1 DOD.DateCreated AS RealDeliveryDate
						FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD		WITH (NOLOCK)
						WHERE DOD.Guide_Number = DO.Guide_Number
						AND DOD.Guide_Serie = DO.Guide_Serie
						AND DOD.StatusOrderId = 5
						ORDER BY DOD.DateCreated ASC
					) DOD_REAL
					OUTER APPLY (
						SELECT TOP (1)
							ACC.IdCustomer
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = cs.IdCustomer
                        AND ACC.AccRowStatus = 'TRUE'
					) ACCF
					OUTER APPLY (
                        SELECT TOP 1 1 Acc
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = DO.IdCustomer
                    ) ACCF2
                WHERE 
                    VPC.CustomerID = @IdCustomer
                    AND DO.Sender_ID > 0
					AND DO.DateCreated >= @DateIni AND DO.DateCreated < DATEADD(DAY, 1, @DateFin)
					AND DO.ReceiverCountryId = @IdCountry  --Filtrado por país
                    AND DO.StatusOrderId <> 7	-- No guías anuladas
                    AND DO.StatusOrderId <> 15 -- No guías generadas

				UNION

				SELECT TOP 500
					  CAST(DO.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(DO.Sender_FirstName), '') + ' '
                      + ISNULL(UPPER(DO.Sender_LastName), '')													[NameOfSender]
					, ISNULL(UPPER(DO.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(DO.Receiver_LastName), '')	[NameOfReceiver]
					, ISNULL(UPPER(DO.NameOfReceiver), '')														[ReceiverName]  
					, CONVERT(VARCHAR, DO.DateCreated, 103)														[PickUpDateTime]
					, CONVERT(VARCHAR, DO.Shipping_Date, 103)													[ScheduledDeliveryDate]
					, ISNULL(CONVERT(VARCHAR, DOD_REAL.RealDeliveryDate, 103), '')								[RealDeliveryDate]
					, DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR)											[GuideNumber]
					, SO.OrderDescription																		[OrderStatus]
					, DO.Manifest_Serie + CAST(DO.Manifest_Number AS VARCHAR)									[ManifestNumber]
					, ISNULL(DO.Receiver_Department, '')														[ReceiverDepartment]
                    , ISNULL(DO.Ticket_Number, '')																[IdOrderReference]
					, ISNULL(IH.inv_certificationFEL, '')														[CertificationFEL]
					, CASE 
						WHEN ACCF.IdCustomer IS NOT NULL	THEN 'Portal Web'
						WHEN cs.IdCustomerType		= 2		THEN 'Express Center'
						WHEN cs.IdCustomerType		= 1		THEN 'Corporativo'
						WHEN cs.IdCustomerType		= 3		THEN 'Individual'
						WHEN ACCF2.Acc				>= 1	THEN 'Portal Web'
						ELSE 'Otros'
					  END																						[SourceGuide]
					, CAST((ISNULL(DO.Pieces_Cold, 0) + ISNULL(DO.Pieces_Dry, 0)) AS VARCHAR)					[Pieces]
					, ISNULL(CCC.Symbol + '.', 'Q.')															[Symbol]
					, CAST(ISNULL(DO.IsCollect, 0) AS VARCHAR)													[IsCollect]
					, IIF(DO.IsCollect = 1, CAST(DO.PriceShippment AS VARCHAR), '0.00')							[AmountShipment]
					, CAST(DO.Collect_OnDelivery AS VARCHAR)													[AmmountCOD]
                    , ISNULL(UPPER(VPC.DescriptionOfClient), '')												[VPSource]
                    , ISNULL(UPPER(CS.[Name]), '')																[Customer]
					, ISNULL(DO.Order_Number, '')																[OrderNumber]
                    , ISNULL(DO.Receiver_Address, '')															[ReceiverAddress]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityId]
					, ISNULL(DO.Receiver_CUI, '')																[CUI]
                    , ISNULL(DO.Receiver_Alternant_FullName, '')												[NameOfReceiverAlternante]
                    , ISNULL(DO.Receiver_Alternant_CUI, '')														[CUIAlternante]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityAlternante]
                    , ISNULL(DO.Receiver_Alternant_Phone, '')													[PhoneAlternante]
                FROM DeliveryBackOffice.dbo.DeliveryOrder				DO		WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder		SO		WITH (NOLOCK)
                        ON DO.StatusOrderId = SO.StatusOrderId
                    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient	VPC		WITH (NOLOCK)
                        ON DO.Sender_ID = VPC.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer			CS		WITH (NOLOCK)
                        ON CS.IdCustomer = VPC.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail		ID		WITH (NOLOCK)
                        ON dti_fk_orderNumber = DO.Guide_Number
                        AND dti_fk_orderSerie = DO.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader		IH		WITH (NOLOCK)
                        ON IH.inv_pk_id = ID.dti_fk_header
						AND IH.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
						AND IH.inv_certificationFEL IS NOT NULL
						AND IH.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost				C		WITH (NOLOCK)
                        ON DO.Guide_Serie = C.GuideSerie 
						AND DO.Guide_Number = C.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD		CCC		WITH (NOLOCK)
                        ON CCC.IdCatCurrencyCOD = ISNULL(C.CodCurrency,C.ShippingCurrency)
					OUTER APPLY (
						SELECT TOP 1 DOD.DateCreated AS RealDeliveryDate
						FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD		WITH (NOLOCK)
						WHERE DOD.Guide_Number = DO.Guide_Number
						AND DOD.Guide_Serie = DO.Guide_Serie
						AND DOD.StatusOrderId = 5
						ORDER BY DOD.DateCreated ASC
					) DOD_REAL
					OUTER APPLY (
						SELECT TOP (1)
							ACC.IdCustomer
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = cs.IdCustomer
                        AND ACC.AccRowStatus = 'TRUE'
					) ACCF
					OUTER APPLY (
                        SELECT TOP 1 1 Acc
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = DO.IdCustomer
                    ) ACCF2
                WHERE 
					DO.Sender_ID = 0
                    AND DO.IdCustomer = @IdCustomer
					AND DO.DateCreated >= @DateIni AND DO.DateCreated < DATEADD(DAY, 1, @DateFin)
					AND DO.ReceiverCountryId = @IdCountry  --Filtrado por país
                    AND DO.StatusOrderId <> 7	-- No guías anuladas
                    AND DO.StatusOrderId <> 15 -- No guías generadas
				
			END;
			ELSE
			BEGIN

				PRINT 'ENTRO CUSTOMER <> -1 Y GUIDENUMBER <> 0';
				SELECT
					  CAST(DO.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(DO.Sender_FirstName), '') + ' '
                      + ISNULL(UPPER(DO.Sender_LastName), '')													[NameOfSender]
					, ISNULL(UPPER(DO.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(DO.Receiver_LastName), '')	[NameOfReceiver]
					, ISNULL(UPPER(DO.NameOfReceiver), '')														[ReceiverName]  
					, CONVERT(VARCHAR, DO.DateCreated, 103)														[PickUpDateTime]
					, CONVERT(VARCHAR, DO.Shipping_Date, 103)													[ScheduledDeliveryDate]
					, ISNULL(CONVERT(VARCHAR, DOD_REAL.RealDeliveryDate, 103), '')								[RealDeliveryDate]
					, DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR)											[GuideNumber]
					, SO.OrderDescription																		[OrderStatus]
					, DO.Manifest_Serie + CAST(DO.Manifest_Number AS VARCHAR)									[ManifestNumber]
					, ISNULL(DO.Receiver_Department, '')														[ReceiverDepartment]
                    , ISNULL(DO.Ticket_Number, '')																[IdOrderReference]
					, ISNULL(IH.inv_certificationFEL, '')														[CertificationFEL]
					, CASE 
						WHEN ACCF.IdCustomer IS NOT NULL	THEN 'Portal Web'
						WHEN cs.IdCustomerType		= 2		THEN 'Express Center'
						WHEN cs.IdCustomerType		= 1		THEN 'Corporativo'
						WHEN cs.IdCustomerType		= 3		THEN 'Individual'
						WHEN ACCF2.Acc				>= 1	THEN 'Portal Web'
						ELSE 'Otros'
					  END																						[SourceGuide]
					, CAST((ISNULL(DO.Pieces_Cold, 0) + ISNULL(DO.Pieces_Dry, 0)) AS VARCHAR)					[Pieces]
					, ISNULL(CCC.Symbol + '.', 'Q.')															[Symbol]
					, CAST(ISNULL(DO.IsCollect, 0) AS VARCHAR)													[IsCollect]
					, IIF(DO.IsCollect = 1, CAST(DO.PriceShippment AS VARCHAR), '0.00')							[AmountShipment]
					, CAST(DO.Collect_OnDelivery AS VARCHAR)													[AmmountCOD]
                    , ISNULL(UPPER(VPC.DescriptionOfClient), '')												[VPSource]
                    , ISNULL(UPPER(CS.[Name]), '')																[Customer]
					, ISNULL(DO.Order_Number, '')																[OrderNumber]
                    , ISNULL(DO.Receiver_Address, '')															[ReceiverAddress]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityId]
					, ISNULL(DO.Receiver_CUI, '')																[CUI]
                    , ISNULL(DO.Receiver_Alternant_FullName, '')												[NameOfReceiverAlternante]
                    , ISNULL(DO.Receiver_Alternant_CUI, '')														[CUIAlternante]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityAlternante]
                    , ISNULL(DO.Receiver_Alternant_Phone, '')													[PhoneAlternante]
                FROM DeliveryBackOffice.dbo.DeliveryOrder				DO		WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder		SO		WITH (NOLOCK)
                        ON DO.StatusOrderId = SO.StatusOrderId
                    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient	VPC		WITH (NOLOCK)
                        ON DO.Sender_ID = VPC.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer			CS		WITH (NOLOCK)
                        ON CS.IdCustomer = VPC.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail		ID		WITH (NOLOCK)
                        ON dti_fk_orderNumber = DO.Guide_Number
                        AND dti_fk_orderSerie = DO.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader		IH		WITH (NOLOCK)
                        ON IH.inv_pk_id = ID.dti_fk_header
						AND IH.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
						AND IH.inv_certificationFEL IS NOT NULL
						AND IH.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost				C		WITH (NOLOCK)
                        ON DO.Guide_Serie = C.GuideSerie 
						AND DO.Guide_Number = C.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD		CCC		WITH (NOLOCK)
                        ON CCC.IdCatCurrencyCOD = ISNULL(C.CodCurrency,C.ShippingCurrency)
					OUTER APPLY (
						SELECT TOP 1 DOD.DateCreated AS RealDeliveryDate
						FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD		WITH (NOLOCK)
						WHERE DOD.Guide_Number = DO.Guide_Number
						AND DOD.Guide_Serie = DO.Guide_Serie
						AND DOD.StatusOrderId = 5
						ORDER BY DOD.DateCreated ASC
					) DOD_REAL
					OUTER APPLY (
						SELECT TOP (1)
							ACC.IdCustomer
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = cs.IdCustomer
                        AND ACC.AccRowStatus = 'TRUE'
					) ACCF
					OUTER APPLY (
                        SELECT TOP 1 1 Acc
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = DO.IdCustomer
                    ) ACCF2
                WHERE 
                    VPC.CustomerID = @IdCustomer
                    AND DO.Sender_ID > 0
					AND DO.Guide_Serie = @GuideSerie
                    AND DO.Guide_Number = @GuideNumber
					AND DO.ReceiverCountryId = @IdCountry  --Filtrado por país
                    AND DO.StatusOrderId <> 7	-- No guías anuladas
                    AND DO.StatusOrderId <> 15 -- No guías generadas

				UNION

				SELECT
					  CAST(DO.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(DO.Sender_FirstName), '') + ' '
                      + ISNULL(UPPER(DO.Sender_LastName), '')													[NameOfSender]
					, ISNULL(UPPER(DO.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(DO.Receiver_LastName), '')	[NameOfReceiver]
					, ISNULL(UPPER(DO.NameOfReceiver), '')														[ReceiverName]  
					, CONVERT(VARCHAR, DO.DateCreated, 103)														[PickUpDateTime]
					, CONVERT(VARCHAR, DO.Shipping_Date, 103)													[ScheduledDeliveryDate]
					, ISNULL(CONVERT(VARCHAR, DOD_REAL.RealDeliveryDate, 103), '')								[RealDeliveryDate]
					, DO.Guide_Serie + CAST(DO.Guide_Number AS VARCHAR)											[GuideNumber]
					, SO.OrderDescription																		[OrderStatus]
					, DO.Manifest_Serie + CAST(DO.Manifest_Number AS VARCHAR)									[ManifestNumber]
					, ISNULL(DO.Receiver_Department, '')														[ReceiverDepartment]
                    , ISNULL(DO.Ticket_Number, '')																[IdOrderReference]
					, ISNULL(IH.inv_certificationFEL, '')														[CertificationFEL]
					, CASE 
						WHEN ACCF.IdCustomer IS NOT NULL	THEN 'Portal Web'
						WHEN cs.IdCustomerType		= 2		THEN 'Express Center'
						WHEN cs.IdCustomerType		= 1		THEN 'Corporativo'
						WHEN cs.IdCustomerType		= 3		THEN 'Individual'
						WHEN ACCF2.Acc				>= 1	THEN 'Portal Web'
						ELSE 'Otros'
					  END																						[SourceGuide]
					, CAST((ISNULL(DO.Pieces_Cold, 0) + ISNULL(DO.Pieces_Dry, 0)) AS VARCHAR)					[Pieces]
					, ISNULL(CCC.Symbol + '.', 'Q.')															[Symbol]
					, CAST(ISNULL(DO.IsCollect, 0) AS VARCHAR)													[IsCollect]
					, IIF(DO.IsCollect = 1, CAST(DO.PriceShippment AS VARCHAR), '0.00')							[AmountShipment]
					, CAST(DO.Collect_OnDelivery AS VARCHAR)													[AmmountCOD]
                    , ISNULL(UPPER(VPC.DescriptionOfClient), '')												[VPSource]
                    , ISNULL(UPPER(CS.[Name]), '')																[Customer]
					, ISNULL(DO.Order_Number, '')																[OrderNumber]
                    , ISNULL(DO.Receiver_Address, '')															[ReceiverAddress]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityId]
					, ISNULL(DO.Receiver_CUI, '')																[CUI]
                    , ISNULL(DO.Receiver_Alternant_FullName, '')												[NameOfReceiverAlternante]
                    , ISNULL(DO.Receiver_Alternant_CUI, '')														[CUIAlternante]
                    , ISNULL(DO.Receiver_Alternant_SocialSecurity_ID, '')										[SocialSecurityAlternante]
                    , ISNULL(DO.Receiver_Alternant_Phone, '')													[PhoneAlternante]
                FROM DeliveryBackOffice.dbo.DeliveryOrder				DO		WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder		SO		WITH (NOLOCK)
                        ON DO.StatusOrderId = SO.StatusOrderId
                    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient	VPC		WITH (NOLOCK)
                        ON DO.Sender_ID = VPC.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer			CS		WITH (NOLOCK)
                        ON CS.IdCustomer = VPC.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail		ID		WITH (NOLOCK)
                        ON dti_fk_orderNumber = DO.Guide_Number
                        AND dti_fk_orderSerie = DO.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader		IH		WITH (NOLOCK)
                        ON IH.inv_pk_id = ID.dti_fk_header
						AND IH.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
						AND IH.inv_certificationFEL IS NOT NULL
						AND IH.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost				C		WITH (NOLOCK)
                        ON DO.Guide_Serie = C.GuideSerie 
						AND DO.Guide_Number = C.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD		CCC		WITH (NOLOCK)
                        ON CCC.IdCatCurrencyCOD = ISNULL(C.CodCurrency,C.ShippingCurrency)
					OUTER APPLY (
						SELECT TOP 1 DOD.DateCreated AS RealDeliveryDate
						FROM DeliveryBackOffice.dbo.DeliveryOrderDetail DOD		WITH (NOLOCK)
						WHERE DOD.Guide_Number = DO.Guide_Number
						AND DOD.Guide_Serie = DO.Guide_Serie
						AND DOD.StatusOrderId = 5
						ORDER BY DOD.DateCreated ASC
					) DOD_REAL
					OUTER APPLY (
						SELECT TOP (1)
							ACC.IdCustomer
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = cs.IdCustomer
                        AND ACC.AccRowStatus = 'TRUE'
					) ACCF
					OUTER APPLY (
                        SELECT TOP 1 1 Acc
                        FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                        WHERE ACC.IdCustomer = DO.IdCustomer
                    ) ACCF2
                WHERE 
					DO.Sender_ID = 0
                    AND DO.IdCustomer = @IdCustomer
					AND DO.Guide_Serie = @GuideSerie
                    AND DO.Guide_Number = @GuideNumber
					AND DO.ReceiverCountryId = @IdCountry  --Filtrado por país
                    AND DO.StatusOrderId <> 7	-- No guías anuladas
                    AND DO.StatusOrderId <> 15 -- No guías generadas
			END;
		END;
	END;
	ELSE
	BEGIN
		SELECT 
			NULL				[NameOfSender],
			''					[NameOfReceiver],
			''					[ReceiverName],
			''					[PickUpDateTime],
			''					[ScheduledDeliveryDate],
			''					[RealDeliveryDate],
			''					[GuideNumber],
			'INACTIVE TOKEN '	[OrderStatus],
			''					[ManifestNumber],
			''					[ReceiverDepartment],
			''					[IdOrderReference];
	END;
END;