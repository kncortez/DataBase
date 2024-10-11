-- =============================================
-- Author:		<Brandon Pedroza>
-- Create date: <2024-10-10>
-- Description:	<Link de entregas - Obtener el resumen de la información para realizar envío sin login>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetCheckoutWithoutLogin]
	@Token VARCHAR(200)
AS
BEGIN
    BEGIN TRY

        DECLARE @IdDeliveryLink INT = (
                                          SELECT IdDeliveryLink FROM DeliveryLink WITH (NOLOCK) WHERE Token = @Token
                                      )
        --PRODUCTOS
        SELECT P.[Name] AS 'Nombre',
               P.[Description] AS 'Descripcion',
               DLP.Quantity AS 'Cantidad',
               ISNULL(DLP.Price * DLP.Quantity, 0) AS 'Precio',
               ISNULL(CCC.Symbol, 'Q') AS 'Moneda',
               ISNULL(P2.Url, '') AS 'Imagen',
               ISNULL(SUM(DLP.Price * DLP.Quantity) OVER (PARTITION BY DLP.DeliveryLinkId), 0) AS 'MontoTotal'
        FROM DeliveryBackOffice.dbo.DeliveryLinkProducts DLP WITH (NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.Product P WITH (NOLOCK)
                ON DLP.ProductId = P.IdProduct
            INNER JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH (NOLOCK)
                ON P.CatCurrencyCODId = CCC.IdCatCurrencyCOD
            LEFT JOIN DeliveryBackOffice.dbo.ProductImages P2 WITH (NOLOCK)
                ON P.IdProduct = P2.ProductId
        WHERE DeliveryLinkId = @IdDeliveryLink
              AND P.RowStatus = 1
              AND P2.Position = 1
              AND P2.RowStatus = 1


        --RESUMEN DE ENVIO
        SELECT
            --DE
            RU.UsrNickName AS 'Nombre remitente',
            VPC.Phone AS 'Telefono remitente',
            T2.TownshipName + ' , ' + P2.ProvinceName AS 'Direccion remitente',
            VPC.Email AS 'Correo remitente',
            --PARA
            DL.ReceiverName AS 'Nombre destinatario',
            DL.ReceiverPhone AS 'Telefono destinatario',
            T.TownshipName + ' , ' + P.ProvinceName AS 'Direccion destinatario',
            DL.ReceiverEmail AS 'Correo destinatario',
            --DATOS PARA COTIZADOR
            ISNULL(DL.OriginCodeOfReference, '0') AS 'CodeOfReferenceSource',
            ISNULL(DL.DestinyCodeOfReference, '0') AS 'CodeOfReferenceDestiny',
            ISNULL(T2.HeaderCode, '0') AS 'HeaderCodeSource',
            ISNULL(T.HeaderCode, '0') AS 'HeaderCodeDestiny',
            RU.UsrEmail AS 'SenderEmail',
            RU.Phone AS 'SenderPhone',
            VPC.Address AS 'SenderAddress',
            VPC.Longitude AS 'SenderLongitude',
            VPC.Latitude AS 'SenderLatitude',
            VPC.DescriptionOfClient AS 'SenderContact',
            P2.ProvinceName + ' / ' + T2.TownshipName AS 'SenderCity',
            DL.ReceiverSettlementId AS 'ReceiverSettlement',
            DL.ReceiverAddress AS 'ReceiverAddress',
            P.ProvinceName + ' / ' + T.TownshipName AS 'ReceiverCity',
            --COD
            CTS.CtsShortName AS 'TypeService',
            CPT.PayTypeName AS 'PaymentType',
            ISNULL(DL.CollectOnDelivery, 0.00) AS 'AmountCOD',
            DFCOD.TypeAccountFavCOD AS 'TypeAccount',
            ISNULL(DFCOD.IdBank, 0) AS 'IdBank',
            DFCOD.DocumentIdFavCOD AS 'DocumentId',
            DFCOD.NumberAccFavCOD AS 'NumberAcc',
            ISNULL(DL.DeliveryFacCODId, 0) AS 'IdNumberAcc',
            DB.[Name] AS 'NameBank',
            DFCOD.NameAccountFavCOD AS 'NameAcc',
            ISNULL(CCC.CodeISO, 'GTQ') AS 'CurrencyISO'
        FROM DeliveryBackOffice.dbo.DeliveryLink DL WITH (NOLOCK)
            LEFT JOIN DeliveryBackOffice.dbo.Settlement S WITH (NOLOCK)
                ON DL.ReceiverSettlementId = S.IdSettlement
            LEFT JOIN DeliveryBackOffice.dbo.Province P WITH (NOLOCK)
                ON S.IdProvince = P.IdProvince
            LEFT JOIN DeliveryBackOffice.dbo.Township T WITH (NOLOCK)
                ON S.IdTownship = T.IdTownship
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH (NOLOCK)
                ON S.IdCountry = DC.Currency_IdCountry
                   AND DefaultPerCountry = 1
            LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH (NOLOCK)
                ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
            INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH (NOLOCK)
                ON DL.OriginCodeOfReference = VPC.CodeOfReference
            LEFT JOIN DeliveryBackOffice.dbo.Township T2 WITH (NOLOCK)
                ON VPC.IdTownship = T2.IdTownship
            LEFT JOIN DeliveryBackOffice.dbo.Province P2 WITH (NOLOCK)
                ON T2.IdProvince = P2.IdProvince
            INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount RBUBA WITH (NOLOCK)
                ON DL.AccountId = RBUBA.RuaIdAccount
            INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH (NOLOCK)
                ON RBUBA.RuaIdUser = RU.UsrIdUser
            LEFT JOIN DeliveryBackOffice.dbo.CatTypeService CTS WITH (NOLOCK)
                ON DL.CatTypeServiceId = CTS.CtsId
            LEFT JOIN DeliveryBackOffice.dbo.CatPaymentType CPT WITH (NOLOCK)
                ON DL.CatPaymentTypeId = CPT.PayTypeId
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryFavCOD DFCOD WITH (NOLOCK)
                ON DL.DeliveryFacCODId = DFCOD.IdDeliveryFavCOD
            LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank DB WITH (NOLOCK)
                ON DFCOD.IdBank = DB.Id_bank
        WHERE DL.IdDeliveryLink = @IdDeliveryLink

    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000);
        SELECT @ErrorMessage = ERROR_MESSAGE();
        PRINT 'Error: ' + @ErrorMessage;
    END CATCH;
END;
