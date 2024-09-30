-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-10-23>
-- Description:	<Description,Procedimiento para obtener información de un link de entrega>
-- =============================================
ALTER PROCEDURE [dbo].[SPHW_GetInformationFromDeliveryLink]
@Token NVARCHAR(250)
AS
BEGIN


	
	SET NOCOUNT ON;
	--- Validar si es un token de link de compra o un token de link de producto, mandar data diferente, si existe mandar data de producto,  mandar bandera indicando que tipod e link es
	
IF(EXISTS(SELECT TOP 1 1 FROM [dbo].[DeliveryLink] WHERE Token = @Token))
   
   BEGIN

	SELECT Top 1 
	       DL.IdDeliveryLink,
	       DL.Token,
		   DL.AccountId,
		   DL.OriginCodeOfReference,
		   DL.DestinyCodeOfReference,
		   DL.ReceiverName,
		   DL.ReceiverPhone,
		   DL.ReceiverSettlementId,
		   DL.ReceiverEmail,
		   DL.ReceiverCatCityPlaceId,
		   DL.ReceiverZone,
		   DL.ReceiverNeighborhood,
		   DL.ReceiverAddress,
		   DL.ReceiverAdditionalInstuctions,
		   DL.ReceiverLatitude,
		   DL.ReceiverLongitude,
		   DL.WhatsappId,
		   DL.CatPaymentTypeId,
		   DL.CatTypeServiceId,
		   DL.IsInsurance,	
		   DL.InsuranceAmount,
		   DL.DeliveryFacCODId,
		   DL.CollectOnDelivery,
		   DL.DeliveryLinkStatusId,
		   DL.ExpirationDate, [ExpirationDate], --- Formato DD/MM/YYYY
		   DL.SubscriptionId,
		   DL.GuideSerie,
		   DL.GuideNumber,
		   C.CountryID,
		   S.Settlement,
		   T.[TownshipName],
		   P.[ProvinceName],
		   'true' AS [IsDeliveryLink],
		    CASE WHEN DL.ExpirationDate <= GETDATE() AND DLS.[Name] = 'Envíado' THEN  1 --- INDICA QUE EL TOKEN ESTA VIGENTE
			        ELSE 0 END AS [StatusCode], -- INDICA QUE EL tOKEN VENCIO
			CASE WHEN DL.ExpirationDate <= GETDATE() AND DLS.[Name] = 'Envíado' THEN 'Token vigente'  --- iNDICA QUE EL tOKEN ESTA VIGENTE
			        ELSE 'Token No vigente' END AS [MessageResponse] -- INDICA QUE EL tOKEN VENCIO
	FROM [DeliveryBackOffice].[dbo].[DeliveryLink] DL WITH(NOLOCK)
	        INNER JOIN  
		  [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
		  ON DL.AccountId=A.AccIdAccount
		     INNER JOIN 
		  [DeliveryBackOffice].[dbo].[Customer] C WITH(NOLOCK)
		  ON A.IdCustomer = C.IdCustomer
		      INNER JOIN 
		  [DeliveryBackOffice].[dbo].[Settlement] S WITH(NOLOCK)
		  ON DL.ReceiverSettlementId = S.IdSettlement
		      INNER JOIN 
		  [DeliveryBackOffice].[dbo].[Township] T WITH(NOLOCK)
		  ON S.IdTownship = T.IdTownship
		      INNER JOIN 
		  [DeliveryBackOffice].[dbo].[Province] P WITH(NOLOCK)
		  ON T.IdProvince = P.IdProvince
		      INNER JOIN 
		  [DeliveryBackOffice].[dbo].[DeliveryLinkStatus] DLS WITH(NOLOCK)
		  ON  DL.DeliveryLinkStatusId = DLS.IdDeliveryLinkStatus
     WHERE DL.Token =  @Token
	 ORDER BY DL.DateCreated DESC

	 -- Arreglo de Productos
	    
       SELECT
	          P.IdProduct,
	          DLP.Price,
	          DLP.Quantity,
			  P.AccountId,
			  P.[Name] NameProduct,
			  P.[Description] DescriptionProduct,
			  P.Sku, 
			  P.Stock,
		      C.[Name],
			  C.CustomerPhone,
			  DLP.DateCreated,
			  C.CountryID,
			  P.IdOriginAddress,
					   P.Token,
					   P.CatProductSubCategoryId,
					   P.IsPublic,
					   P.CatStatusStoreId,
					   P.CatProductConditionId,
					   P.StockRequired,
					   P.CatCurrencyCODId,
					   P.Brand,
					   P.AverageRating,
					   P.NameSale,
					   P.StartDateSale,
					   P.EndDateSale,
					   P.PercentageSale,
					   P.IdOriginAddress,
					   [PI].[Url],
					   'false' AS [IsDeliveryLink],
					    P.RowStatus AS [StatusCode], -- INDICA QUE EL tOKEN VENCIO
			          CASE WHEN P.RowStatus=1 THEN 'Token vigente'  --- iNDICA QUE EL tOKEN ESTA VIGENTE
			                 ELSE 'Token No vigente' END AS [MessageResponse] -- INDICA QUE EL tOKEN VENCIO
	  FROM [DeliveryBackOffice].[dbo].[DeliveryLinkProducts] DLP WITH(NOLOCK)
	          INNER JOIN 
		   [DeliveryBackOffice].[dbo].[Product] P WITH(NOLOCK)
				ON DLP.ProductId = P.IdProduct
			  INNER JOIN 
		   [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
		       ON P.AccountId = A.AccIdAccount
			  INNER JOIN
			[DeliveryBackOffice].[dbo].[Customer] C WITH(NOLOCK)
			  ON A.IdCustomer = C.IdCustomer
			INNER JOIN 
           [DeliveryBackOffice].[dbo].[ProductImages] [PI] WITH(NOLOCK)
		     ON DLP.ProductId =[PI].ProductId
	   WHERE 
	   DLP.DeliveryLinkId = (SELECT Top 1  IdDeliveryLink FROM [DeliveryBackOffice].[dbo].[DeliveryLink] DL WITH(NOLOCK) WHERE DL.Token =  @Token)
	    

	END
	   ELSE
	       BEGIN


			SELECT 
			  P.IdProduct,
	          DLP.Price,
	          DLP.Quantity,
			  P.AccountId,
			  P.[Name] NameProduct,
			  P.[Description] DescriptionProduct,
			  P.Sku, 
			  P.Stock,
		      C.[Name],
			  C.CustomerPhone,
			  DLP.DateCreated,
			  C.CountryID,
			  P.IdOriginAddress,
					   P.Token,
					   P.CatProductSubCategoryId,
					   P.IsPublic,
					   P.CatStatusStoreId,
					   P.CatProductConditionId,
					   P.StockRequired,
					   P.CatCurrencyCODId,
					   P.Brand,
					   P.AverageRating,
					   P.NameSale,
					   P.StartDateSale,
					   P.EndDateSale,
					   P.PercentageSale,
					   P.IdOriginAddress,
					    [PI].[Url],
					   'false' AS [IsDeliveryLink],
					    P.RowStatus AS [StatusCode], -- INDICA QUE EL tOKEN VENCIO
			          CASE WHEN P.RowStatus=1 THEN 'Token vigente'  --- iNDICA QUE EL tOKEN ESTA VIGENTE
			                 ELSE 'Token No vigente' END AS [MessageResponse] -- INDICA QUE EL tOKEN VENCIO
	  FROM [DeliveryBackOffice].[dbo].[DeliveryLinkProducts] DLP WITH(NOLOCK)
	          INNER JOIN 
		   [DeliveryBackOffice].[dbo].[Product] P WITH(NOLOCK)
				ON DLP.ProductId = P.IdProduct
			  INNER JOIN 
		   [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
		       ON P.AccountId = A.AccIdAccount
			  INNER JOIN
			[DeliveryBackOffice].[dbo].[Customer] C WITH(NOLOCK)
			  ON A.IdCustomer = C.IdCustomer
			INNER JOIN 
           [DeliveryBackOffice].[dbo].[ProductImages] [PI] WITH(NOLOCK)
		     ON DLP.ProductId =[PI].ProductId
	  WHERE Token = @Token
			ORDER BY P.DateCreated DESC


		   END
END




