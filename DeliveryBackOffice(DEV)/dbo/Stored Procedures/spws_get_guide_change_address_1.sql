-- =============================================
-- Author:		<Aylinne Recinos>
-- Create date: <2025-02-12>
-- Description:	<Obtener la información para realizar la actualización de la dirección>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_guide_change_address]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	SELECT 	do.Sender_FirstName AS [Name], 
			do.PriceShippment AS [Price], 
			(
				CASE
				WHEN [dopd].[TimePlaId] = 1 THEN 'PREPAGO'
				WHEN [dopd].[TimePlaId] = 2 THEN 'PICKUP'
				WHEN [dopd].[TimePlaId] = 3 THEN 'COLLECT'
				WHEN [dopd].[TimePlaId] = 4 THEN 'CRÉDITO'
				ELSE 'CRÉDITO'
				END
			) AS [PaymentMethod],
			(do.Pieces_Dry + do.Pieces_Cold) AS [Pieces],
			so.OrderDescription AS [Status],
			(
				CASE
				WHEN [do].[SenderCountryId] = 'GT' THEN 'Q'
				WHEN [do].[SenderCountryId] = 'HN' THEN 'L'
				ELSE 'Q'
				END
			) AS [Currency],
			ISNULL(S.Settlement,'')    AS [Poblado],
			IIF(T.TownshipName IS NOT NULL,T.TownshipName,ISNULL(T2.TownshipName,'')) AS [Municipio],
			IIF(P.ProvinceName IS NOT NULL,P.ProvinceName,ISNULL(P2.ProvinceName,'')) AS [Departamento],
			ISNULL(DO.Receiver_Address,'') AS [AddressDestiny],
			ISNULL(CONVERT(VARCHAR,DO.DateCreated, 103),'') AS [DateCreated]
	FROM DeliveryOrder do
	INNER JOIN DeliveryOrderPaymentDetail dopd ON do.Guide_Serie = dopd.GuideSerie AND do.Guide_Number = dopd.GuideNumber
	INNER JOIN StatusOrder so ON do.StatusOrderId = so.StatusOrderId
	LEFT JOIN DeliveryBackOffice.dbo.Settlement S WITH(NOLOCK)  
	ON do.ReceiverIdSettlement = S.IdSettlement  
	LEFT JOIN DeliveryBackOffice.dbo.Township T WITH(NOLOCK)  
	ON S.IdTownship = T.IdTownship  
	LEFT JOIN DeliveryBackOffice.dbo.Province P WITH(NOLOCK)  
	ON S.IdProvince = P.IdProvince  
	LEFT JOIN DeliveryBackOffice.dbo.Township T2 WITH(NOLOCK)  
	ON do.ReceiverIdTownship = T2.IdTownship  
	LEFT JOIN DeliveryBackOffice.dbo.Province P2 WITH(NOLOCK)  
	ON T2.IdProvince = P2.IdProvince  
	WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber
END