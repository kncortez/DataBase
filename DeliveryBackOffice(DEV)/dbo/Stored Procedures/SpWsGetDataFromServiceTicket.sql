
-- =============================================
-- Author:		<Edelman,Vasquez>
-- Create date: <2022-06-07>
-- Description:	< Agregar data de servicios y detalle para tabla dinamica en comprobante de pago, revalorizar guía si no contiene valor >
-- =============================================
-- =============================================
-- Author:		<Walter,Orozco>
-- Create date: <2024-06-24>
-- Description:	< Agregar moneda, correo y telefono multipais. >
-- Create date: <2025-04-03>
-- Description:	< Agregar nombre de país. >
-- =============================================
CREATE PROCEDURE [dbo].[SpWsGetDataFromServiceTicket]
    @IdAccount INT = 37,
    @TrackingNumber VARCHAR(100) = 'FD138358',
    @Token VARCHAR(100) = 'C6A98D3AB3A005C0023D634A6ECD1E5B'
AS
BEGIN

    BEGIN TRY

        DECLARE @TotalWeight AS DECIMAL(18, 2);
        DECLARE @TotalValue AS DECIMAL(18, 2);
        DECLARE @ContentDescription AS VARCHAR(200);
        DECLARE @IdCost AS INT;
        DECLARE @Serie AS VARCHAR(2) = SUBSTRING(@TrackingNumber, 1, 2);
        DECLARE @NUMBER AS VARCHAR(20) = SUBSTRING(@TrackingNumber, 3, LEN(@TrackingNumber));
        DECLARE @COD AS DECIMAL(18, 2);
        DECLARE @CODCurrency AS NVARCHAR(6);
        DECLARE @COLLECT AS BIT;

        SELECT @TotalWeight = SUM(DOP.PieceWeight),
               @TotalValue = SUM(DOP.Amount)
        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
        WHERE DOP.GuideSerie = SUBSTRING(@TrackingNumber, 1, 2)
              AND DOP.GuideNumber = SUBSTRING(@TrackingNumber, 3, LEN(@TrackingNumber));

        SELECT TOP 1
               @ContentDescription = DOP.Detail
        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece DOP WITH (NOLOCK)
        WHERE DOP.GuideSerie = SUBSTRING(@TrackingNumber, 1, 2)
              AND DOP.GuideNumber = SUBSTRING(@TrackingNumber, 3, LEN(@TrackingNumber));

        SELECT TOP 1
               @IdCost = C.IdCost
        FROM dbo.Cost C WITH (NOLOCK)
        WHERE C.ProductNumber = @TrackingNumber
        ORDER BY DateCreated DESC;

        SELECT @COD = ISNULL(do.Collect_OnDelivery, 0),
               @COLLECT = do.IsCollect,
			   @CODCurrency = CC.Symbol
        FROM dbo.DeliveryOrder do WITH (NOLOCK)
        LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH (NOLOCK)
			ON do.ReceiverCountryId = DC.Currency_IdCountry
		LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CC WITH (NOLOCK)
			ON DC.IdCurrencyCOD = CC.IdCatCurrencyCOD
        WHERE do.Collect_OnDelivery > 0
              AND DC.DefaultPerCountry = 1
              AND Guide_Serie = @Serie
              AND Guide_Number = @NUMBER;

        DECLARE @IsCard AS BIT =
                (
                    SELECT TOP 1
                           1
                    FROM dbo.CreditCardTransactionByCustomer WITH (NOLOCK)
                    WHERE OrderNumber = @TrackingNumber
                          AND ReasonCode = 1
                );


        IF (@COLLECT = 1)
        BEGIN
            EXEC [dbo].[spws_revalue_guide] @GuideSerie = @Serie,
                                            @GuideNumber = @NUMBER,
                                            @CodeApp = '',
                                            @Format = '',
                                            @CalculateTaxes = 'true', -- Dado a nuevas tarifas, no cálcular impuestos
                                            @IdModule = 1,
                                            @SetUpdate = 'true',      -- Actualizar registros
                                            @Token = @Token;


            SELECT TOP 1
                   @IdCost = C.IdCost
            FROM dbo.Cost C WITH (NOLOCK)
            WHERE C.ProductNumber = @TrackingNumber
            ORDER BY DateCreated DESC;
        END;



        IF (@IdCost IS NULL)
        BEGIN

            IF (@IsCard = 1)
            BEGIN
                EXEC [dbo].[spws_revalue_guide] @GuideSerie = @Serie,
                                                @GuideNumber = @NUMBER,
                                                @CodeApp = '',
                                                @Format = '',
                                                @CalculateTaxes = 'true', -- Dado a nuevas tarifas, no cálcular impuestos
                                                @IdModule = 1,
                                                @SetUpdate = 'true',      -- Actualizar registros
                                                @Token = @Token,
                                                @ParIsCreditCard = 1;

                SELECT TOP 1
                       @IdCost = C.IdCost
                FROM dbo.Cost C WITH (NOLOCK)
                WHERE C.ProductNumber = @TrackingNumber
                      AND C.IdModule <> 1
                ORDER BY DateCreated DESC;
            END;
            ELSE
            BEGIN
                EXEC [dbo].[spws_revalue_guide] @GuideSerie = @Serie,
                                                @GuideNumber = @NUMBER,
                                                @CodeApp = '',
                                                @Format = '',
                                                @CalculateTaxes = 'true', -- Dado a nuevas tarifas, no cálcular impuestos
                                                @IdModule = 1,
                                                @SetUpdate = 'true',      -- Actualizar registros
                                                @Token = @Token;


                SELECT TOP 1
                       @IdCost = C.IdCost
                FROM dbo.Cost C WITH (NOLOCK)
                WHERE C.ProductNumber = @TrackingNumber
                      AND C.IdModule <> 1
                ORDER BY DateCreated DESC;
            END;
        END;


        --

        IF (@IdAccount > 0 AND @IdCost > 0)
        BEGIN

            SELECT PRV.IdCountry IdCountry,
                   ISNULL(CC.CountryNameES,'') CountryName,
                   DOR.Pieces_Cold + DOR.Pieces_Dry CountPieces,
                   @TotalWeight TotalWeight,
                   COALESCE(Collect_OnDelivery, 0) TotalValue,
                   DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) TrackingNumber,
                   REPLACE(CONVERT(NVARCHAR, DOR.Delivery_Max_Date, 103), ' ', '/') DeliveryDate,
                   DOR.PriceShippment Price,
                   DOR.IsCollect Collected,
                   @ContentDescription ContentDescription,
                   IVH.inv_cli_nit TaxPayerNumber,
                   IVH.inv_pk_id idInvoice,
                   '' VPDescriptionOfClient,
                   '' PriviceVisitPoint, -- ????
                   '' CountryVisitPoint,
                   '' VPAdress,
                   ISNULL(rgu.UsrEmail, 'N/A') Mail,
                   COALESCE(Receiver_FirstName, '') + ' ' + COALESCE(Receiver_LastName, '') FromName,
                   Receiver_Phone FromPhone,
                   COALESCE(Receiver_Email, '') FromEmail,
                   Receiver_Address FromAddress,
                   PRV2.ProvinceDescription FromCity,
                   COALESCE(Sender_FirstName, '') + ' ' + COALESCE(Sender_LastName, '') ToName,
                   Sender_Phone ToPhone,
                   COALESCE(rgu.UsrEmail, '') ToEmail,
                   Sender_Address ToAddress,
                   (SELECT Value FROM DeliveryBackOffice.dbo.ConfigParams
					WHERE Name = 'VoucherEmail' AND IdCountry = PRV.IdCountry ) AS VoucherEmail,
				   (SELECT Value FROM DeliveryBackOffice.dbo.ConfigParams
					WHERE Name = 'VoucherPhone' AND IdCountry = PRV.IdCountry ) AS VoucherPhone,
                   PRV.ProvinceDescription ToCity
            FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
                LEFT JOIN DeliveryBackOffice.dbo.Account ACC WITH (NOLOCK)
                    ON ACC.IdCustomer = DOR.IdCustomer
                LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount rbu WITH (NOLOCK)
                    ON rbu.RuaIdAccount = ACC.AccIdAccount
                LEFT JOIN DeliveryBackOffice.dbo.RegisterUser rgu WITH (NOLOCK)
                    ON rgu.UsrIdUser = rbu.RuaIdUser
                LEFT JOIN DeliveryBackOffice.dbo.Township TOW WITH (NOLOCK)
                    ON TOW.IdTownship = DOR.SenderIdTownship
                LEFT JOIN DeliveryBackOffice.dbo.Province PRV WITH (NOLOCK)
                    ON PRV.IdProvince = TOW.IdProvince
                LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IVD WITH (NOLOCK)
                    ON IVD.dti_fk_orderSerie = DOR.Guide_Serie
                       AND IVD.dti_fk_orderNumber = DOR.Guide_Number
                LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader IVH WITH (NOLOCK)
                    ON IVH.inv_pk_id = IVD.dti_fk_header
                LEFT JOIN DeliveryBackOffice.dbo.Township TOW2 WITH (NOLOCK)
                    ON TOW2.IdTownship = DOR.ReceiverIdTownship
                LEFT JOIN DeliveryBackOffice.dbo.Province PRV2 WITH (NOLOCK)
                    ON PRV2.IdProvince = TOW2.IdProvince
                LEFT JOIN DeliveryBackOffice.dbo.CatCountry CC WITH(NOLOCK)
					ON CC.IdCountry = PRV.IdCountry
            WHERE DOR.Guide_Serie = SUBSTRING(@TrackingNumber, 1, 2)
                  AND DOR.Guide_Number = SUBSTRING(@TrackingNumber, 3, LEN(@TrackingNumber))
                  AND ACC.AccIdAccount = @IdAccount;

            IF (@COD > 0) ---- VALIDA QUE TIENE COD PARA AGREGAR A EL DETALLE
            BEGIN
                SELECT C.ProductNumber,
                       BOP.Description,
                       BOP.Amount,
					   ISNULL(DC.Symbol,'Q') [Symbol]
                FROM dbo.Cost C WITH (NOLOCK)
                    INNER JOIN dbo.BreakdownOfPayment BOP WITH (NOLOCK)
                        ON C.IdCost = BOP.IdCost
                    INNER JOIN dbo.CatCurrencyCOD DC WITH (NOLOCK)
						ON C.ShippingCurrency = DC.IdCatCurrencyCOD
                WHERE BOP.RowStatus = 1
                      AND BOP.Amount <> 0
                      AND C.ProductNumber = @TrackingNumber
                      AND BOP.IdCost = @IdCost
                UNION ALL
                SELECT @TrackingNumber AS ProductNumber,
                       'Valor de Mercaderia' AS Description,
                       @COD AS Amount,
					   @CODCurrency [Symbol];
            END;
            ELSE
            BEGIN
                SELECT C.ProductNumber,
                       BOP.Description,
                       BOP.Amount,
					   ISNULL(DC.Symbol,'Q') [Symbol]
                FROM dbo.Cost C WITH (NOLOCK)
                    INNER JOIN dbo.BreakdownOfPayment BOP WITH (NOLOCK)
                        ON C.IdCost = BOP.IdCost
                    INNER JOIN dbo.CatCurrencyCOD DC WITH (NOLOCK)
						ON C.ShippingCurrency = DC.IdCatCurrencyCOD
                WHERE BOP.RowStatus = 1
                      AND BOP.Amount <> 0
                      AND C.ProductNumber = @TrackingNumber
                      AND BOP.IdCost = @IdCost;

            END;

        END;

        ELSE

        --Genera informacion para comprobante cuando para flujo impersonar Portal Web Express Center
        BEGIN

            SELECT PRV.IdCountry IdCountry,
                   ISNULL(CC.CountryNameES,'') CountryName,
                   DOR.Pieces_Cold + DOR.Pieces_Dry CountPieces,
                   @TotalWeight TotalWeight,
                   COALESCE(DOR.Collect_OnDelivery, 0) TotalValue,
                   DOR.Guide_Serie + CONVERT(VARCHAR, DOR.Guide_Number) TrackingNumber,
                   REPLACE(CONVERT(NVARCHAR, DOR.Delivery_Max_Date, 103), ' ', '/') DeliveryDate,
                   DOR.PriceShippment Price,
                   DOR.IsCollect Collected,
                   @ContentDescription ContentDescription,
                   IVH.inv_cli_nit TaxPayerNumber,
                   IVH.inv_pk_id idInvoice,
                   '' VPDescriptionOfClient,
                   '' PriviceVisitPoint, -- ????
                   '' CountryVisitPoint,
                   '' VPAdress,
                   ISNULL(DOR.Receiver_Email, 'N/A') Mail,
                   COALESCE(Receiver_FirstName, '') + ' ' + COALESCE(Receiver_LastName, '') FromName,
                   Receiver_Phone FromPhone,
                   COALESCE(Receiver_Email, '') FromEmail,
                   Receiver_Address FromAddress,
                   PRV2.ProvinceDescription FromCity,
                   CASE
                       WHEN cu.IdCustomerType = 1 THEN
                           CASE
                               WHEN DOR.IsReturn = 1 THEN
                                   COALESCE(DOR.Sender_FirstName, '')
                               ELSE
                                   COALESCE(vpc.DescriptionOfClient, '') + ' ' + COALESCE(Sender_LastName, '')
                           END
                       ELSE
                           CASE
                               WHEN DOR.IsReturn = 1 THEN
                                   COALESCE(DOR.Sender_FirstName, '')
                               ELSE
                                   COALESCE(cu.Name, '')
                           END
                   END ToName,
                   Sender_Phone ToPhone,
                   COALESCE(DOR.Sender_Mail, '') ToEmail,
                   Sender_Address ToAddress,
                   (SELECT Value FROM DeliveryBackOffice.dbo.ConfigParams
				    WHERE Name = 'VoucherEmail' AND IdCountry = PRV.IdCountry ) AS VoucherEmail,
				   (SELECT Value FROM DeliveryBackOffice.dbo.ConfigParams
					WHERE Name = 'VoucherPhone' AND IdCountry = PRV.IdCountry ) AS VoucherPhone,
                   PRV.ProvinceDescription ToCity
            FROM DeliveryBackOffice.dbo.DeliveryOrder DOR WITH (NOLOCK)
                LEFT JOIN DeliveryBackOffice.dbo.Township TOW WITH (NOLOCK)
                    ON TOW.IdTownship = DOR.SenderIdTownship
                LEFT JOIN DeliveryBackOffice.dbo.Province PRV WITH (NOLOCK)
                    ON PRV.IdProvince = TOW.IdProvince
                LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IVD WITH (NOLOCK)
                    ON IVD.dti_fk_orderSerie = DOR.Guide_Serie
                       AND IVD.dti_fk_orderNumber = DOR.Guide_Number
                LEFT JOIN DeliveryBackOffice.dbo.invoiceHeader IVH WITH (NOLOCK)
                    ON IVH.inv_pk_id = IVD.dti_fk_header
                LEFT JOIN DeliveryBackOffice.dbo.Township TOW2 WITH (NOLOCK)
                    ON TOW2.IdTownship = DOR.ReceiverIdTownship
                LEFT JOIN DeliveryBackOffice.dbo.Province PRV2 WITH (NOLOCK)
                    ON PRV2.IdProvince = TOW2.IdProvince
                LEFT JOIN VisitPointClient vpc WITH (NOLOCK)
                    ON vpc.CodeOfReference = DOR.Sender_ID
                LEFT JOIN DeliveryBackOffice.dbo.Customer cu WITH (NOLOCK)
                    ON vpc.CustomerID = cu.IdCustomer
                LEFT JOIN DeliveryBackOffice.dbo.CatCountry CC WITH(NOLOCK)
					ON CC.IdCountry = PRV.IdCountry
            WHERE DOR.Guide_Serie = SUBSTRING(@TrackingNumber, 1, 2)
                  AND DOR.Guide_Number = SUBSTRING(@TrackingNumber, 3, LEN(@TrackingNumber));


            IF (@COD > 0) ---- VALIDA QUE TIENE COD PARA AGREGAR A EL DETALLE
            BEGIN
                SELECT C.ProductNumber,
                       BOP.Description,
                       BOP.Amount,
					   ISNULL(DC.Symbol,'Q') [Symbol]
                FROM dbo.Cost C WITH (NOLOCK)
                    INNER JOIN dbo.BreakdownOfPayment BOP WITH (NOLOCK)
                        ON C.IdCost = BOP.IdCost
                    INNER JOIN dbo.CatCurrencyCOD DC WITH (NOLOCK)
						ON C.ShippingCurrency = DC.IdCatCurrencyCOD
                WHERE BOP.RowStatus = 1
                      AND BOP.Amount <> 0
                      AND C.ProductNumber = @TrackingNumber
                      AND BOP.IdCost = @IdCost
                UNION ALL
                SELECT @TrackingNumber AS ProductNumber,
                       'Valor de Mercaderia' AS Description,
                       @COD AS Amount,
					   @CODCurrency [Symbol];
            END;
            ELSE
            BEGIN
                SELECT C.ProductNumber,
                       BOP.Description,
                       BOP.Amount,
					   ISNULL(DC.Symbol,'Q') [Symbol]
                FROM dbo.Cost C WITH (NOLOCK)
                    INNER JOIN dbo.BreakdownOfPayment BOP WITH (NOLOCK)
                        ON C.IdCost = BOP.IdCost
                    INNER JOIN dbo.CatCurrencyCOD DC WITH (NOLOCK)
						ON C.ShippingCurrency = DC.IdCatCurrencyCOD
                WHERE BOP.RowStatus = 1
                      AND BOP.Amount <> 0
                      AND C.ProductNumber = @TrackingNumber
                      AND BOP.IdCost = @IdCost;


            END;

        END;




    END TRY
    BEGIN CATCH

        SELECT 0 AS 'StatusCode',
               ERROR_MESSAGE() AS 'Description';

    END CATCH;
END;
