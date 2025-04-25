-- Stored Procedure

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-05-20>
-- Description:	<Devuelve ordenes de entrega por rango fecha>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-01-26>
-- Description:	<Se Agregaron a las consultas los campos de receptor Alterante>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-04-25>
-- Description:	<Mejoras de multimoneda.>
-- Create date: <2025-05-02>
-- Description:	<Filtrado por país cuando se solicitan las guías de todos los clientes.>
-- =============================================
CREATE PROCEDURE [dbo].[spw_get_geliveryorders_track]
    -- Add the parameters for the stored procedure here
    @Token AS VARCHAR(50) = '08cc0ffe737713a57ce17ad4997156a0', --'f16ec23a337713eb710aa07a0c98b9b6',
    @Rol AS BIGINT = 874,
    @BeginDate AS VARCHAR(50) = '23/09/2021',
    @EndDate AS VARCHAR(50) = '23/09/2021',
    @IdCustomer AS INT = -1,
    @GuideSerie AS VARCHAR(2) = 'FD',
    @GuideNumber AS INT = 0 ,                                    --509517--509508
	@IdCountry AS NVARCHAR(2) = 'GT'

AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @IdToken AS VARCHAR(50);
    DECLARE @IdRol AS BIGINT;

    DECLARE @DateIni AS DATE;
    DECLARE @DateFin AS DATE;
    DECLARE @CustomerId AS INT;

    SET DATEFORMAT DMY;
    SET @IdToken = @Token;
    SET @IdRol = @Rol;
    SET @DateIni = CONVERT(DATE, @BeginDate);
    SET @DateFin = CONVERT(DATE, @EndDate);
    SET @CustomerId = @IdCustomer;

    DECLARE @IdSystem AS INT;

    SELECT @IdSystem = ROL.LGN_IdSystem
    FROM DenariusUser_Dev.dbo.LGN_Rol ROL WITH (NOLOCK)
    WHERE ROL.LGN_IdRol = @IdRol;

    IF
    (
        SELECT COUNT(logtoken.SSN_IdToken) SSN_IdToken
        FROM DenariusUser_Dev.dbo.LGN_LogByToken logtoken WITH (NOLOCK)
        WHERE logtoken.SSN_IdToken = @IdToken
              AND logtoken.SSN_IdSystem = @IdSystem
              AND logtoken.SSN_TokenStatus = 1
    ) > 0
    BEGIN

        IF (@CustomerId = -1)
        BEGIN
            IF (@GuideNumber = 0)
            BEGIN
                PRINT 'ENTRO CUSTOMER -1 Y GUIDENUMBER = 0';
                SELECT   CAST(serv.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(serv.Sender_FirstName), '') + ' '
                       + ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
                       ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                       ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                       CONVERT(VARCHAR, serv.DateCreated, 103) [PickUpDateTime],
                       CONVERT(VARCHAR, serv.Shipping_Date, 103) [ScheduledDeliveryDate],
                       ISNULL(CONVERT(   VARCHAR,
                              (
                                  SELECT TOP 1
                                         dod.DateCreated
                                  FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH (NOLOCK)
                                  WHERE dod.Guide_Number = serv.Guide_Number
                                    AND dod.Guide_Serie = serv.Guide_Serie
                                        AND dod.StatusOrderId = 5
                              ),
                                         103
                                     ),
                              ''
                             ) AS [RealDeliveryDate],
                       serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
                       so.OrderDescription AS OrderStatus,
                       serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) [ManifestNumber],
                       ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                       ISNULL(serv.Ticket_Number, '') [IdOrderReference],
                       ISNULL(invHead.inv_certificationFEL, '') [CertificationFEL],
                       CASE
                           WHEN
                           (
                               SELECT TOP (1)
                                      ACC.IdCustomer
                               FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                               WHERE ACC.IdCustomer = cs.IdCustomer
                                     AND ACC.AccRowStatus = 'TRUE'
                               ORDER BY ACC.AccDateCreated DESC
                           ) IS NOT NULL THEN
                               'Portal Web'
                           WHEN cs.IdCustomerType = 2 THEN
                               'Express Center'
                           WHEN cs.IdCustomerType = 1 THEN
                               'Corporativo'
                           WHEN cs.IdCustomerType = 3 THEN
                               'Individual'
                           WHEN
                           (
                               SELECT COUNT(1)
                               FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                               WHERE ACC.IdCustomer = serv.IdCustomer
                           ) >= 1 THEN
                               'Portal Web'
                           ELSE
                               'Otros'
                       END [SourceGuide],
                       CAST((ISNULL(serv.Pieces_Cold, 0) + ISNULL(serv.Pieces_Dry, 0)) AS VARCHAR(50)) [Pieces],
					   IIF(ccCOD.Symbol IS NULL, 'Q.', ccCOD.Symbol + '.') [Symbol],
                       CAST(ISNULL(serv.IsCollect, 0) AS VARCHAR(50)) [IsCollect],
                       CASE serv.IsCollect
                           WHEN 'true' THEN
                               CAST(serv.PriceShippment AS VARCHAR(50))
                           ELSE
                               '0.00'
                       END [AmountShipment],
                       CAST(serv.[Collect_OnDelivery] AS VARCHAR(50)) [AmmountCOD],
                       ISNULL(UPPER(vpc.DescriptionOfClient), '') [VPSource],
                       ISNULL(UPPER(cs.Name), '') [Customer],
                       ISNULL(serv.Order_Number, '') [OrderNumber],
                       ISNULL(serv.Receiver_Address, '') ReceiverAddress,
                       ISNULL(serv.Receiver_Alternant_SocialSecurity_ID, '') SocialSecurityId,
                       ISNULL(serv.Receiver_CUI, '') CUI,
                       ISNULL(serv.Receiver_Alternant_FullName, '') NameOfReceiverAlternante,
                       ISNULL(serv.Receiver_Alternant_CUI, '') CUIAlternante,
                       ISNULL(serv.Receiver_Alternant_SocialSecurity_ID, '') SocialSecurityAlternante,
                       ISNULL(serv.Receiver_Alternant_Phone, '') PhoneAlternante
                FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                        ON serv.StatusOrderId = so.StatusOrderId
                    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                        ON serv.Sender_ID = vpc.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer cs WITH (NOLOCK)
                        ON cs.IdCustomer = vpc.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail invDet WITH (NOLOCK)
                        ON dti_fk_orderNumber = serv.Guide_Number
                           AND dti_fk_orderSerie = serv.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader invHead WITH (NOLOCK)
                        ON invHead.inv_pk_id = invDet.dti_fk_header
                           AND invHead.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
                           AND invHead.inv_certificationFEL IS NOT NULL
                           AND invHead.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost c WITH (NOLOCK)
                        ON serv.Guide_Serie = c.GuideSerie
                           AND serv.Guide_Number = c.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD ccCOD WITH (NOLOCK)
                        ON ccCOD.IdCatCurrencyCOD = ISNULL(c.CodCurrency,c.ShippingCurrency)
                WHERE CONVERT(DATE, serv.DateCreated)
                      BETWEEN @DateIni AND @DateFin
					  AND (serv.SenderCountryId = @IdCountry OR serv.ReceiverCountryId = @IdCountry)
                      AND serv.StatusOrderId <> 7 -- No guías anuladas
                      AND serv.StatusOrderId <> 15; -- No guías generadas
            END;
            ELSE
            BEGIN
                PRINT 'ENTRO CUSTOMER -1 Y GUIDENUMBER <> 0  ';
                SELECT CAST(serv.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(serv.Sender_FirstName), '') + ' '
                       + ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
                       ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                       ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                       CONVERT(VARCHAR, serv.DateCreated, 103) [PickUpDateTime],
                       CONVERT(VARCHAR, serv.Shipping_Date, 103) [ScheduledDeliveryDate],
                       ISNULL(CONVERT(   VARCHAR,
                              (
                                  SELECT TOP 1
                                         dod.DateCreated
                                  FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH (NOLOCK)
                                  WHERE dod.Guide_Number = serv.Guide_Number
                                    AND dod.Guide_Serie = serv.Guide_Serie
                                        AND dod.StatusOrderId = 5
                              ),
                                         103
                                     ),
                              ''
                             ) AS [RealDeliveryDate],
                       serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
                       so.OrderDescription AS OrderStatus,
                       serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) [ManifestNumber],
                       ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                       ISNULL(serv.Ticket_Number, '') [IdOrderReference],
                       ISNULL(invHead.inv_certificationFEL, '') [CertificationFEL],
                       CASE
                           WHEN
                           (
                               SELECT TOP (1)
                                      ACC.IdCustomer
                               FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                               WHERE ACC.IdCustomer = cs.IdCustomer
                                     AND ACC.AccRowStatus = 'TRUE'
                               ORDER BY ACC.AccDateCreated DESC
                           ) IS NOT NULL THEN
                               'Portal Web'
                           WHEN cs.IdCustomerType = 2 THEN
                               'Express Center'
                           WHEN cs.IdCustomerType = 1 THEN
                               'Corporativo'
                           WHEN cs.IdCustomerType = 3 THEN
                               'Individual'
                           WHEN
                           (
                               SELECT COUNT(1)
                               FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                               WHERE ACC.IdCustomer = serv.IdCustomer
                           ) >= 1 THEN
                               'Portal Web'
                           ELSE
                               'Otros'
                       END [SourceGuide],
                       CAST((ISNULL(serv.Pieces_Cold, 0) + ISNULL(serv.Pieces_Dry, 0)) AS VARCHAR(50)) [Pieces],
					   IIF(ccCOD.Symbol IS NULL, 'Q.', ccCOD.Symbol + '.') [Symbol],
                       CAST(ISNULL(serv.IsCollect, 0) AS VARCHAR(50)) [IsCollect],
                       CASE serv.IsCollect
                           WHEN 'true' THEN
                               CAST(serv.PriceShippment AS VARCHAR(50))
                           ELSE
                               '0.00'
                       END [AmountShipment],
                       CAST(serv.[Collect_OnDelivery] AS VARCHAR(50)) [AmmountCOD],
                       ISNULL(UPPER(vpc.DescriptionOfClient), '') [VPSource],
                       ISNULL(UPPER(cs.Name), '') [Customer],
                       ISNULL(serv.Order_Number, '') [OrderNumber],
                       ISNULL(serv.Receiver_Address, '') ReceiverAddress,
                       ISNULL(serv.Receiver_Alternant_SocialSecurity_ID, '') SocialSecurityId,
                       ISNULL(serv.Receiver_CUI, '') CUI,
                       ISNULL(serv.Receiver_Alternant_FullName, '') NameOfReceiverAlternante,
                       ISNULL(serv.Receiver_Alternant_CUI, '') CUIAlternante,
                       ISNULL(serv.Receiver_Alternant_SocialSecurity_ID, '') SocialSecurityAlternante,
                       ISNULL(serv.Receiver_Alternant_Phone, '') PhoneAlternante
                FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                        ON serv.StatusOrderId = so.StatusOrderId
                    LEFT JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
                        ON serv.Sender_ID = vpc.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.Customer cs WITH (NOLOCK)
                        ON cs.IdCustomer = vpc.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail invDet WITH (NOLOCK)
                        ON dti_fk_orderNumber = serv.Guide_Number
                           AND dti_fk_orderSerie = serv.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader invHead WITH (NOLOCK)
                        ON invHead.inv_pk_id = invDet.dti_fk_header
                           AND invHead.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
                           AND invHead.inv_certificationFEL IS NOT NULL
                           AND invHead.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost c WITH (NOLOCK)
                        ON serv.Guide_Serie = c.GuideSerie
                           AND serv.Guide_Number = c.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD ccCOD WITH (NOLOCK)
                        ON ccCOD.IdCatCurrencyCOD = ISNULL(c.CodCurrency,c.ShippingCurrency)
                WHERE serv.Guide_Serie = @GuideSerie
                      AND serv.Guide_Number = @GuideNumber
					  AND (serv.SenderCountryId = @IdCountry OR serv.ReceiverCountryId = @IdCountry)
                      AND serv.StatusOrderId <> 7 -- No guías anuladas
                      AND serv.StatusOrderId <> 15; -- No guías generadas
            END;
        END;
        ELSE
        BEGIN
            IF (@GuideNumber = 0)
            BEGIN
                PRINT 'ENTRO CUSTOMER <> -1 Y GUIDENUMBER = 0';
                SELECT  TOP 10000  CAST(serv.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(serv.Sender_FirstName), '') + ' '
                       + ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
                       ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                       ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                       CONVERT(VARCHAR, serv.DateCreated, 103) [PickUpDateTime],
                       CONVERT(VARCHAR, serv.Shipping_Date, 103) [ScheduledDeliveryDate],
                       ISNULL(CONVERT(   VARCHAR,
                              (
                                  SELECT TOP 1
                                         dod.DateCreated
                                  FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH (NOLOCK)
                                  WHERE dod.Guide_Number = serv.Guide_Number
                                    AND dod.Guide_Serie = serv.Guide_Serie
                                        AND dod.StatusOrderId = 5
                              ),
                                         103
                                     ),
                              ''
                             ) AS [RealDeliveryDate],
                       serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
                       so.OrderDescription AS OrderStatus,
                       serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) [ManifestNumber],
                       ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                       ISNULL(serv.Ticket_Number, '') [IdOrderReference],
                       ISNULL(invHead.inv_certificationFEL, '') [CertificationFEL],
                       CASE
                           WHEN
                           (
                               SELECT TOP (1)
                                      ACC.IdCustomer
                               FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                               WHERE ACC.IdCustomer = cs.IdCustomer
                                     AND ACC.AccRowStatus = 'TRUE'
                               ORDER BY ACC.AccDateCreated DESC
                           ) IS NOT NULL THEN
                               'Portal Web'
                           WHEN cs.IdCustomerType = 2 THEN
                               'Express Center'
                           WHEN cs.IdCustomerType = 1 THEN
                               'Corporativo'
                           WHEN cs.IdCustomerType = 3 THEN
                               'Individual'
                           WHEN
                           (
                               SELECT COUNT(1)
                               FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                               WHERE ACC.IdCustomer = serv.IdCustomer
                           ) >= 1 THEN
                               'Portal Web'
                           ELSE
                               'Otros'
                       END [SourceGuide],
                       CAST((ISNULL(serv.Pieces_Cold, 0) + ISNULL(serv.Pieces_Dry, 0)) AS VARCHAR(50)) [Pieces],
					   IIF(ccCOD.Symbol IS NULL, 'Q.', ccCOD.Symbol + '.') [Symbol],
                       CAST(ISNULL(serv.IsCollect, 0) AS VARCHAR(50)) [IsCollect],
                       CASE serv.IsCollect
                           WHEN 'true' THEN
                               CAST(serv.PriceShippment AS VARCHAR(50))
                           ELSE
                               '0.00'
                       END [AmountShipment],
                       CAST(serv.[Collect_OnDelivery] AS VARCHAR(50)) [AmmountCOD],
                       ISNULL(UPPER(vpclient.DescriptionOfClient), '') [VPSource],
                       ISNULL(UPPER(cs.Name), '') [Customer],
                       ISNULL(serv.Order_Number, '') [OrderNumber],
                       ISNULL(serv.Receiver_Address, '') ReceiverAddress,
                       ISNULL(serv.Receiver_Alternant_SocialSecurity_ID, '') SocialSecurityId,
                       ISNULL(serv.Receiver_CUI, '') CUI,
                       ISNULL(serv.Receiver_Alternant_FullName, '') NameOfReceiverAlternante,
                       ISNULL(serv.Receiver_Alternant_CUI, '') CUIAlternante,
                       ISNULL(serv.Receiver_Alternant_SocialSecurity_ID, '') SocialSecurityAlternante,
                       ISNULL(serv.Receiver_Alternant_Phone, '') PhoneAlternante
                FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpclient WITH (NOLOCK)
                        ON serv.Sender_ID = vpclient.CodeOfReference
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                        ON serv.StatusOrderId = so.StatusOrderId
                    LEFT JOIN DeliveryBackOffice.dbo.Customer cs WITH (NOLOCK)
                        ON cs.IdCustomer = vpclient.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail invDet WITH (NOLOCK)
                        ON dti_fk_orderNumber = serv.Guide_Number
                           AND dti_fk_orderSerie = serv.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader invHead WITH (NOLOCK)
                        ON invHead.inv_pk_id = invDet.dti_fk_header
                           AND invHead.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
                           AND invHead.inv_certificationFEL IS NOT NULL
                           AND invHead.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost c WITH (NOLOCK)
                        ON serv.Guide_Serie = c.GuideSerie
                           AND serv.Guide_Number = c.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD ccCOD WITH (NOLOCK)
                        ON ccCOD.IdCatCurrencyCOD = ISNULL(c.CodCurrency,c.ShippingCurrency)
                WHERE (
                          (
                              serv.Sender_ID = 0
                              AND @CustomerId = serv.IdCustomer
                          )
                          OR
                          (
                              vpclient.CustomerID = @CustomerId
                              AND serv.Sender_ID > 0
                          )
                      )
                      AND (CONVERT(DATE, serv.DateCreated)
                      BETWEEN @DateIni AND @DateFin
                          )
					  AND (serv.SenderCountryId = @IdCountry OR serv.ReceiverCountryId = @IdCountry)
                      AND serv.StatusOrderId <> 7 -- No guías anuladas
                      AND serv.StatusOrderId <> 15; -- No guías generadas
            END;
            ELSE
            BEGIN
                PRINT 'ENTRO CUSTOMER <> -1 Y GUIDENUMBER <> 0';
                SELECT CAST(serv.Sender_ID AS VARCHAR) + ' - ' + ISNULL(UPPER(serv.Sender_FirstName), '') + ' '
                       + ISNULL(UPPER(serv.Sender_LastName), '') [NameOfSender],
                       ISNULL(UPPER(serv.Receiver_FirstName), '') + ' ' + ISNULL(UPPER(serv.Receiver_LastName), '') [NameOfReceiver],
                       ISNULL(UPPER(NameOfReceiver), '') AS [ReceiverName],
                       CONVERT(VARCHAR, serv.DateCreated, 103) [PickUpDateTime],
                       CONVERT(VARCHAR, serv.Shipping_Date, 103) [ScheduledDeliveryDate],
                       ISNULL(CONVERT(   VARCHAR,
                              (
                                  SELECT TOP 1
                                         dod.DateCreated
                                  FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH (NOLOCK)
                                  WHERE dod.Guide_Number = serv.Guide_Number
                                    AND dod.Guide_Serie = serv.Guide_Serie
                                        AND dod.StatusOrderId = 5
                              ),
                                         103
                                     ),
                              ''
                             ) AS [RealDeliveryDate],
                       serv.Guide_Serie + CAST(serv.Guide_Number AS VARCHAR) [GuideNumber],
                       so.OrderDescription AS OrderStatus,
                       serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) [ManifestNumber],
                       ISNULL(serv.Receiver_Department, '') [ReceiverDepartment],
                       ISNULL(serv.Ticket_Number, '') [IdOrderReference],
                       ISNULL(invHead.inv_certificationFEL, '') [CertificationFEL],
                       CASE
                           WHEN
                           (
                               SELECT TOP (1)
                                      ACC.IdCustomer
                               FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                               WHERE ACC.IdCustomer = cs.IdCustomer
                                     AND ACC.AccRowStatus = 'TRUE'
                               ORDER BY ACC.AccDateCreated DESC
                           ) IS NOT NULL THEN
                               'Portal Web'
                           WHEN cs.IdCustomerType = 2 THEN
                               'Express Center'
                           WHEN cs.IdCustomerType = 1 THEN
                               'Corporativo'
                           WHEN cs.IdCustomerType = 3 THEN
                               'Individual'
                           WHEN
                           (
                               SELECT COUNT(1)
                               FROM DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                               WHERE ACC.IdCustomer = serv.IdCustomer
                           ) >= 1 THEN
                               'Portal Web'
                           ELSE
                               'Otros'
                       END [SourceGuide],
                       CAST((ISNULL(serv.Pieces_Cold, 0) + ISNULL(serv.Pieces_Dry, 0)) AS VARCHAR(50)) [Pieces],
					   IIF(ccCOD.Symbol IS NULL, 'Q.', ccCOD.Symbol + '.') [Symbol],
                       CAST(serv.IsCollect AS VARCHAR(50)) [IsCollect],
                       CASE serv.IsCollect
                           WHEN 'true' THEN
                               CAST(serv.PriceShippment AS VARCHAR(50))
                           ELSE
                               '0.00'
                       END [AmountShipment],
                       CAST(serv.[Collect_OnDelivery] AS VARCHAR(50)) [AmmountCOD],
                       ISNULL(UPPER(vpclient.DescriptionOfClient), '') [VPSource],
                       ISNULL(UPPER(cs.Name), '') [Customer],
                       ISNULL(serv.Order_Number, '') [OrderNumber],
                       ISNULL(serv.Receiver_Address, '') ReceiverAddress,
                       ISNULL(serv.Receiver_Alternant_SocialSecurity_ID, '') SocialSecurityId,
                       ISNULL(serv.Receiver_CUI, '') CUI,
                       ISNULL(serv.Receiver_Alternant_FullName, '') NameOfReceiverAlternante,
                       ISNULL(serv.Receiver_Alternant_CUI, '') CUIAlternante,
                       ISNULL(serv.Receiver_Alternant_SocialSecurity_ID, '') SocialSecurityAlternante,
                       ISNULL(serv.Receiver_Alternant_Phone, '') PhoneAlternante
                FROM DeliveryBackOffice.dbo.DeliveryOrder serv WITH (NOLOCK)
                    inner JOIN DeliveryBackOffice.dbo.VisitPointClient vpclient WITH (NOLOCK)
                        ON serv.Sender_ID = vpclient.CodeOfReference 
                    LEFT JOIN DeliveryBackOffice.dbo.StatusOrder so WITH (NOLOCK)
                        ON serv.StatusOrderId = so.StatusOrderId
                    LEFT JOIN DeliveryBackOffice.dbo.Customer cs WITH (NOLOCK)
                        ON cs.IdCustomer = vpclient.CustomerID
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail invDet WITH (NOLOCK)
                        ON dti_fk_orderNumber = serv.Guide_Number
                           AND dti_fk_orderSerie = serv.Guide_Serie
                    LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader invHead WITH (NOLOCK)
                        ON invHead.inv_pk_id = invDet.dti_fk_header
                           AND invHead.inv_status IN ( 2, 3 ) -- Firmado Fel o enviado a SAP
                           AND invHead.inv_certificationFEL IS NOT NULL
                           AND invHead.inv_serieFEL IS NOT NULL
                    LEFT JOIN DeliveryBackOffice.dbo.Cost c WITH (NOLOCK)
                        ON serv.Guide_Serie = c.GuideSerie
                           AND serv.Guide_Number = c.GuideNumber
                    LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD ccCOD WITH (NOLOCK)
                        ON ccCOD.IdCatCurrencyCOD = ISNULL(c.CodCurrency,c.ShippingCurrency)
                WHERE (
                          (
                              serv.Sender_ID = 0
                              AND @CustomerId = serv.IdCustomer
                          )
                          OR
                          (
                              vpclient.CustomerID = @CustomerId
                              AND serv.Sender_ID > 0
                          )
                      )
                      AND serv.Guide_Serie = @GuideSerie
                      AND serv.Guide_Number = @GuideNumber
					  AND (serv.SenderCountryId = @IdCountry OR serv.ReceiverCountryId = @IdCountry)
                      AND serv.StatusOrderId <> 7 -- No guías anuladas
                      AND serv.StatusOrderId <> 15; -- No guías generadas
            END;
        END;


    END;
    ELSE
    BEGIN
        SELECT NULL [NameOfSender],
               '' [NameOfReceiver],
               '' [ReceiverName],
               '' [PickUpDateTime],
               '' [ScheduledDeliveryDate],
               '' [RealDeliveryDate],
               '' [GuideNumber],
               'INACTIVE TOKEN ' [OrderStatus],
               '' [ManifestNumber],
               '' [ReceiverDepartment],
               '' [IdOrderReference];
    END;
END;

