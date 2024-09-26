-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-09-25>
-- Description:	<Link de entregas - Obtener el resumen de la información para realizar envío.>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetCheckout]
@IdDeliveryLink NVARCHAR(100)
AS
BEGIN
BEGIN TRY

	--RESUMEN DE ENVIO
	SELECT 
		--DE
		  C.Name AS 'Nombre remitente'
		, VPC.Phone AS 'Telefono remitente'
		, T2.TownshipName + ' , ' + P2.ProvinceName  AS 'Direccion remitente'
		, VPC.Email AS 'Correo remitente'
		--PARA
		, DL.ReceiverName AS 'Nombre destinatario'
		, DL.ReceiverPhone AS 'Telefono destinatario'
		, T.TownshipName + ' , ' + P.ProvinceName AS 'Direccion destinatario'
		, DL.ReceiverEmail AS 'Correo destinatario'
	FROM DeliveryBackOffice.dbo.DeliveryLink DL WITH(NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.Settlement S WITH(NOLOCK)
		ON DL.ReceiverSettlementId = S.IdSettlement
	LEFT JOIN DeliveryBackOffice.dbo.Province P WITH(NOLOCK)
		ON S.IdProvince = P.IdProvince
	LEFT JOIN DeliveryBackOffice.dbo.Township T WITH(NOLOCK)
		ON S.IdTownship = T.IdTownship
	INNER JOIN DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
		ON DL.OriginCodeOfReference = VPC.CodeOfReference
	LEFT JOIN DeliveryBackOffice.dbo.Settlement S2 WITH(NOLOCK)
		ON VPC.IdSettlement = S2.IdSettlement
	LEFT JOIN DeliveryBackOffice.dbo.Province P2 WITH(NOLOCK)
		ON S2.IdProvince = P2.IdProvince
	LEFT JOIN DeliveryBackOffice.dbo.Township T2 WITH(NOLOCK)
		ON S2.IdTownship = T2.IdTownship
	INNER JOIN DeliveryBackOffice.dbo.Account A WITH(NOLOCK)
		ON DL.AccountId = A.AccIdAccount
	INNER JOIN DeliveryBackOffice.dbo.Customer C WITH(NOLOCK)
		ON A.IdCustomer = C.IdCustomer
	WHERE DL.IdDeliveryLink = @IdDeliveryLink

	--PRODUCTOS
	SELECT
		  P.Name AS 'Nombre'
		, P.Description AS 'Descripcion'
		, DLP.Quantity AS 'Cantidad'
		, DLP.Price AS 'Precio'
		, ISNULL(CCC.Symbol,'Q') AS 'Moneda'
		, ISNULL(P2.Url,'') AS 'Imagen'
		, ISNULL(SUM(DLP.Price) OVER (PARTITION BY DLP.DeliveryLinkId),0) AS 'MontoTotal'
	FROM  DeliveryBackOffice.dbo.DeliveryLinkProducts DLP WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.Product P WITH(NOLOCK)
		ON DLP.ProductId = P.IdProduct
	INNER JOIN DeliveryBackOffice.dbo.CatCurrencyCOD CCC WITH(NOLOCK)
		ON P.CatCurrencyCODId = CCC.IdCatCurrencyCOD
	LEFT JOIN DeliveryBackOffice.dbo.ProductImages P2 WITH(NOLOCK)
		ON P.IdProduct = P2.ProductId
	WHERE DeliveryLinkId = @IdDeliveryLink AND P.RowStatus = 1 
		AND P2.Position = 1 AND P2.RowStatus = 1

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;