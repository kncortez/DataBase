/* =================================================
   SP:        [dbo].[SPHW_GetCheckout]
   Propósito: Obtener la información del link completado, para poder finalizar el proceso de envio de paquetes por medio del portal de Link de Entrega
   Autor:     Walter Orozco
   Historia:  hpw-1565
   Fecha:     2024-09-25
============================================
=== CHANGELOG ================================
2026-03-11 | Historia/épica: FDAPI-5791 | Autor: Brenda Echeverria |
-----
2024-11-19 | Historia/épica: Se agrego devolucion de poblado de direccion de origen | Autor: Oscar Rodriguez |
-----
2024-10-31 | Historia/épica: hpw-1671 | Autor: Brandon Pedroza |
-----
=========================================== */

CREATE PROCEDURE [dbo].[SPHW_GetCheckout]
@Token NVARCHAR(100),
@OnlyProducts INT, --0 checkout, 1 mis links
@IdAccount INT 
AS
BEGIN
BEGIN TRY

	--PRODUCTOS
	SELECT
		PRD.Name AS 'Nombre'
		, PRD.Description AS 'Descripcion'
		, DLP.Quantity AS 'Cantidad'
		, ISNULL(DLP.Price * DLP.Quantity,0) AS 'Precio' 
		, ISNULL(CCC.Symbol,'Q') AS 'Moneda' 
		, ISNULL(PI.Url,'') AS 'Imagen'
		, ISNULL(SUM(DLP.Price * DLP.Quantity) OVER (PARTITION BY DLP.DeliveryLinkId),0) AS 'MontoTotal'
	FROM  DeliveryBackOffice.dbo.DeliveryLinkProducts DLP WITH(NOLOCK)
		INNER JOIN DeliveryBackOffice.dbo.Product PRD WITH(NOLOCK)
			ON DLP.ProductId = PRD.IdProduct
		INNER JOIN DeliveryBackOffice.dbo.DeliveryLink DL WITH(NOLOCK)
			ON DL.IdDeliveryLink = DLP.DeliveryLinkId
		INNER JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
			ON PRD.CatCurrencyCODId = CCC.IdCatCurrencyCOD
		LEFT JOIN DeliveryBackOffice.dbo.ProductImages PI WITH(NOLOCK)
			ON PRD.IdProduct = PI.ProductId
	WHERE DL.Token  = @Token
		AND PRD.RowStatus = 1 
		AND PI.Position = 1 
		AND PI.RowStatus = 1

	IF(@OnlyProducts = 0)
	BEGIN
		--RESUMEN DE ENVIO
		SELECT 
			--DE
			  RU.UsrNickName AS 'Nombre remitente'
			, CONCAT(
				ISNULL(	CONCAT('+',(SELECT [Value] FROM DeliveryBackOffice.dbo.ConfigParams WHERE [Name] = 'AreaCode' AND IdCountry = ISNULL(VPC.CountryId,'GT'))),'+502'),
				RIGHT(VPC.Phone,8)
			) AS 'Telefono remitente'
			, CONCAT(TWR.TownshipName , ' , ' , PRVR.ProvinceName)  AS 'Direccion remitente'
			, VPC.Email AS 'Correo remitente'
			, VPC.IdSettlement AS 'SenderSettlement'
			, ISNULL(SETR.Settlement,'') AS 'SenderSettlementName'
			--PARA
			, DL.ReceiverName AS 'Nombre destinatario'
			, CONCAT( DL.NirPhone , DL.ReceiverPhone) AS 'Telefono destinatario'
			, CONCAT(TWD.TownshipName , ' , ' , PRVD.ProvinceName) AS 'Direccion destinatario'
			, DL.ReceiverEmail AS 'Correo destinatario'
			--DATOS PARA COTIZADOR
			, DL.OriginCodeOfReference AS 'CodeOfReferenceSource' 
			, ISNULL(DL.DestinyCodeOfReference,'0') AS 'CodeOfReferenceDestiny'
			, ISNULL(TWR.HeaderCode,'0') AS 'HeaderCodeSource'
			, ISNULL(TWD.HeaderCode,'0') AS 'HeaderCodeDestiny'
			, RU.UsrEmail AS 'SenderEmail'
			, RU.Phone AS 'SenderPhone'
			, VPC.Address AS 'SenderAddress'
			, VPC.Longitude AS 'SenderLongitude'
			, VPC.Latitude AS 'SenderLatitude'
			, VPC.DescriptionOfClient AS 'SenderContact'
			, CONCAT( PRVR.ProvinceName , ' / ' , TWR.TownshipName )  AS 'SenderCity'
			, DL.ReceiverSettlementId AS 'ReceiverSettlement'
			, DL.ReceiverAddress AS 'ReceiverAddress'
			, CONCAT( PRVD.ProvinceName , ' / ' , TWD.TownshipName) AS 'ReceiverCity'
			--COD
			, CTS.CtsShortName AS 'TypeService'
			, CPT.PayTypeName AS 'PaymentType'
			, ISNULL(DL.CollectOnDelivery,0.00) AS'AmountCOD'
			, DFCOD.TypeAccountFavCOD AS 'TypeAccount'
			, ISNULL(DFCOD.IdBank,0) AS 'IdBank'
			, DFCOD.DocumentIdFavCOD AS 'DocumentId'
			, DFCOD.NumberAccFavCOD AS 'NumberAcc'
			, ISNULL(DL.DeliveryFacCODId,0) AS 'IdNumberAcc'
			, DB.[Name] AS 'NameBank'
			, DFCOD.NameAccountFavCOD AS 'NameAcc'
			, ISNULL(CCC.CodeISO,'GTQ') AS 'CurrencyISO'
			, IIF( DL.GuideNumber > 0, 'true', 'false') AS 'IsGuide'
			, DL.IdDeliveryLink AS 'IdDeliveryLink'
		FROM DeliveryBackOffice.dbo.DeliveryLink DL WITH(NOLOCK)
			LEFT JOIN DeliveryBackOffice.dbo.Settlement SETD WITH(NOLOCK)
				ON DL.ReceiverSettlementId = SETD.IdSettlement
			LEFT JOIN DeliveryBackOffice.dbo.Province PRVD WITH(NOLOCK)
				ON SETD.IdProvince = PRVD.IdProvince
			LEFT JOIN DeliveryBackOffice.dbo.Township TWD WITH(NOLOCK)
				ON SETD.IdTownship = TWD.IdTownship
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryCurrency DC WITH(NOLOCK)
				ON SETD.IdCountry = DC.Currency_IdCountry 
				AND DefaultPerCountry = 1
			LEFT JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
				ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD
			INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
				ON DL.OriginCodeOfReference = VPC.CodeOfReference
			LEFT JOIN DeliveryBackOffice.dbo.Township TWR WITH(NOLOCK)
				ON VPC.IdTownship = TWR.IdTownship
			LEFT JOIN DeliveryBackOffice.dbo.Province PRVR WITH(NOLOCK)
				ON TWR.IdProvince = PRVR.IdProvince
			LEFT JOIN DeliveryBackOffice.dbo.Settlement SETR WITH (NOLOCK)
				ON SETR.IdSettlement = VPC.IdSettlement
			INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount RBUBA WITH(NOLOCK)
				ON DL.AccountId = RBUBA.RuaIdAccount
			INNER JOIN DeliveryBackOffice.dbo.RegisterUser RU WITH(NOLOCK)
				ON RBUBA.RuaIdUser = RU.UsrIdUser
			LEFT JOIN DeliveryBackOffice.dbo.CatTypeService CTS WITH(NOLOCK)
				ON DL.CatTypeServiceId = CTS.CtsId
			LEFT JOIN DeliveryBackOffice.dbo.CatPaymentType CPT WITH(NOLOCK)
				ON DL.CatPaymentTypeId = CPT.PayTypeId
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryFavCOD DFCOD WITH(NOLOCK)
				ON DL.DeliveryFacCODId = DFCOD.IdDeliveryFavCOD
			LEFT JOIN DeliveryBackOffice.dbo.DeliveryBank DB WITH(NOLOCK)
				ON DFCOD.IdBank = DB.Id_bank
		WHERE DL.Token = @Token
			AND DL.AccountId = @IdAccount
	END;

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;