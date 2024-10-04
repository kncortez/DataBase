-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,2024-10-23>
-- Description:	<Description,Procedimiento para obtener información de un link de entrega>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_GetInformationFromDeliveryLink]
@Token NVARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON;
	--- Validar si es un token de link de compra o un token de link de producto, mandar data diferente, si existe mandar data de producto,  mandar bandera indicando que tipod e link es
	  DECLARE @NewStatusId INT =(SELECT TOP 1  IdDeliveryLinkStatus FROM [DeliveryBackOffice].[dbo].[DeliveryLinkStatus] WITH(NOLOCK) WHERE [Name]='Aperturado' );
	  DECLARE @StatusId    INT =(SELECT TOP 1  IdDeliveryLinkStatus FROM [DeliveryBackOffice].[dbo].[DeliveryLinkStatus] WITH(NOLOCK) WHERE [Name]='Enviado' );
	  DECLARE @Canceled    INT =(SELECT TOP 1  IdDeliveryLinkStatus FROM [DeliveryBackOffice].[dbo].[DeliveryLinkStatus] WITH(NOLOCK) WHERE [Name]='Anulado' );
	  DECLARE @IdProduct   INT =(SELECT TOP 1 IdProduct FROM [dbo].[Product] WHERE Token = @Token )
  BEGIN TRANSACTION
	BEGIN TRY


IF(EXISTS(SELECT TOP 1 1 FROM [dbo].[DeliveryLink] WHERE Token = @Token))
   
   BEGIN

	SELECT Top 1 
	       DL.IdDeliveryLink,
	       DL.Token,
		   DL.AccountId,
		   ISNULL(DL.OriginCodeOfReference,0) OriginCodeOfReference,
		   ISNULL(DL.DestinyCodeOfReference,0) DestinyCodeOfReference ,
		   DL.ReceiverName,
			  CASE  
				   WHEN  ISNULL(C.CountryID,'GT') = 'GT' THEN  '+502'
				   ELSE  '+504' END NirPhone,
		   RIGHT(DL.ReceiverPhone,8) [ReceiverPhone],
		   DL.ReceiverSettlementId,
		   DL.ReceiverEmail,
		   ISNULL(DL.ReceiverCatCityPlaceId,0) ReceiverCatCityPlaceId ,
		   ISNULL(DL.ReceiverZone,'') ReceiverZone,
		   ISNULL(DL.ReceiverNeighborhood,'') ReceiverNeighborhood,
		   ISNULL(DL.ReceiverAddress,'') ReceiverAddress,
		   ISNULL(DL.ReceiverAdditionalInstuctions,'')  ReceiverAdditionalInstuctions ,
		   ISNULL(DL.ReceiverLatitude,'') ReceiverLatitude,
		   ISNULL( DL.ReceiverLongitude,'') ReceiverLongitude,
		   ISNULL( DL.WhatsappId,0) WhatsappId,
		   ISNULL( DL.CatPaymentTypeId,0) CatPaymentTypeId,
		   ISNULL( DL.CatTypeServiceId,0) CatTypeServiceId,
		   ISNULL( DL.IsInsurance,0) IsInsurance,	
		   ISNULL( DL.InsuranceAmount,0.0) InsuranceAmount,
		   ISNULL( DL.DeliveryFacCODId,0) DeliveryFacCODId,
		   ISNULL( DL.CollectOnDelivery,0.0) CollectOnDelivery,
		   ISNULL( DL.DeliveryLinkStatusId,0) DeliveryLinkStatusId,
		   ISNULL(LEFT(FORMAT(ExpirationDate, 'dd/MM/yyyy'),10),'-') [ExpirationDate], --- Formato DD/MM/YYYY
		   ISNULL( DL.SubscriptionId,0) SubscriptionId,
		   ISNULL( DL.GuideSerie,'') GuideSerie,
		   ISNULL(DL.GuideNumber,0) GuideNumber,
		   ISNULL(C.CountryID,'GT') CountryID,
		   S.Settlement,
		   T.[TownshipName],
		   P.[ProvinceName],
		   'true' AS [IsDeliveryLink],
		    CASE WHEN DL.ExpirationDate >= GETDATE() AND DLS.[Name] = 'Enviado' OR DLS.[Name] = 'Aperturado' THEN  1 --- INDICA QUE EL TOKEN ESTA VIGENTE
			     WHEN DLS.[Name] = @Canceled   THEN 3
			        ELSE 0 END AS [StatusCode], -- INDICA QUE EL tOKEN VENCIO
			CASE WHEN DL.ExpirationDate >= GETDATE() AND DLS.[Name] = 'Enviado' OR DLS.[Name] = 'Aperturado' THEN 'Token vigente'  --- iNDICA QUE EL tOKEN ESTA VIGENTE
			     WHEN DLS.[Name] = @Canceled   THEN 'Link de entrega anulado'
			        ELSE 'Token No vigente' END AS [MessageResponse], -- INDICA QUE EL tOKEN VENCIO
           DataOrigin.AccName,
		   DataOrigin.UsrNickName AS [CommercialName],
		   DataOrigin.[Name]
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
		  	LEFT JOIN (
						SELECT  VPC.CodeOfReference,
								A.AccName,
								Cu.[Name],
								Cu.CommercialName,
								RU.UsrNickName
							 FROM 
							     [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
								Inner Join 
								 [DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
									ON VPC.CustomerId= Cu.IdCustomer
								Inner Join 
								  [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
								    ON Cu.IdCustomer = A.IdCustomer
								INNER JOIN 
								  [DeliveryBackOffice].[dbo].[RolByUserByAccount] RUBA WITH(NOLOCK)
								    ON  RUBA.RuaIdAccount = A.AccIdAccount
								INNER JOIN 
								  [DeliveryBackOffice].[dbo].RegisterUser RU WITH(NOLOCK)
								     ON RU.UsrIdUser = RUBA.RuaIdUser
			) DataOrigin
			ON DL.OriginCodeOfReference = DataOrigin.CodeOfReference
			LEFT JOIN 
			 [DeliveryBackOffice].[dbo].[RegisterUser] RU WITH(NOLOCK)
			 ON RU.UsrEmail = DL.ReceiverEmail
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
			  ISNULL(C.CustomerPhone,'') CustomerPhone,
			  DLP.DateCreated,
			  ISNULL(C.CountryID,'GT') CountryID,
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
					  ISNULL(P.StartDateSale,'') StartDateSale,
					  ISNULL(P.EndDateSale,'') EndDateSale,
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
			  INNER JOIN 
		    [DeliveryBackOffice].[dbo].[TagByProduct] TBP WITH(NOLOCK)
		       ON P.IdProduct = TBP.ProductId
			  INNER JOIN 
			[DeliveryBackOffice].[dbo].[CatProductTag] CPT WITH(NOLOCK)
			   ON TBP.TagId = CPT.IdCatProductTag
	   WHERE 
	   DLP.DeliveryLinkId = (SELECT Top 1  IdDeliveryLink FROM [DeliveryBackOffice].[dbo].[DeliveryLink] DL WITH(NOLOCK) WHERE DL.Token =  @Token)
	    

	END
	   ELSE
	       BEGIN


			SELECT DISTINCT
			  P.IdProduct,
	          P.Price,
	          0 Quantity,
			  P.AccountId,
			  P.[Name] NameProduct,
			  P.[Description] DescriptionProduct,
			  P.Sku, 
			  P.Stock,
		      C.[Name],
			  C.CustomerPhone,
			 ISNULL(C.CountryID,'GT') IdCountry,
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
					   LEFT(FORMAT(P.StartDateSale,'dd/MM/yyyy)'),10) StartDateSale,
					   LEFT(FORMAT( P.EndDateSale,'dd/MM/yyyy)'),10) EndDateSale,
					   P.PercentageSale,
					   P.IdOriginAddress,
					    [PI].[Url],
					   'false' AS [IsDeliveryLink] ,
					   ISNULL(C.CountryID,'GT') CountryId,
					     RU.UsrNickName AS [CommercialName],
						 C.[Name],
						CASE 
						     WHEN PrefixCallingCode IS NULL AND  ISNULL(C.CountryID,'GT')='GT' THEN '+502' 
							 WHEN PrefixCallingCode IS NULL AND  ISNULL(C.CountryID,'GT')='HN' THEN '+504' 
							 ELSE  PrefixCallingCode END [NirPhone]  ,	
						 RU.Phone,
					    CASE  
						     WHEN  P.RowStatus = 1 THEN 1
							 ELSE 0 END AS [StatusCode] , -- INDICA QUE EL tOKEN VENCIO
			            CASE WHEN P.RowStatus=1 THEN 'Token vigente'  --- iNDICA QUE EL tOKEN ESTA VIGENTE
			                 ELSE 'Token No vigente' END AS [MessageResponse] -- INDICA QUE EL tOKEN VENCIO
	  FROM 
		   [DeliveryBackOffice].[dbo].[Product] P WITH(NOLOCK)
		    
			  INNER JOIN 
		   [DeliveryBackOffice].[dbo].[Account] A WITH(NOLOCK)
		       ON P.AccountId = A.AccIdAccount
			  INNER JOIN
			[DeliveryBackOffice].[dbo].[Customer] C WITH(NOLOCK)
			  ON A.IdCustomer = C.IdCustomer
			  LEFT JOIN 
           [DeliveryBackOffice].[dbo].[ProductImages] [PI] WITH(NOLOCK)
		     ON  [PI].ProductId = P.IdProduct
			  INNER  JOIN 
				[DeliveryBackOffice].[dbo].[RolByUserByAccount] RUBA WITH(NOLOCK)
				ON  RUBA.RuaIdAccount = A.AccIdAccount
			  INNER JOIN 
				[DeliveryBackOffice].[dbo].RegisterUser RU WITH(NOLOCK)
				ON RU.UsrIdUser = RUBA.RuaIdUser
		
	  WHERE Token =   @Token
	        AND [PI].[RowStatus] = 'TRUE'

		--OBTENER TAGS DEL PRODUCTO
		SELECT C.[IdCatProductTag] [IdTag],
               C.[Description] [Description]
        FROM [dbo].[CatProductTag] C WITH(NOLOCK)
		INNER JOIN [dbo].[TagByProduct] T WITH(NOLOCK)
			ON C.IdCatProductTag = T.TagId
		INNER JOIN [dbo].[Product] P WITH(NOLOCK)
			ON T.[ProductId] = P.[IdProduct]
        WHERE P.[IdProduct] = @IdProduct
		AND C.[RowStatus] = 'TRUE'




		   END

   
IF(EXISTS(SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[DeliveryLink] WHERE Token = @Token AND DeliveryLinkStatusId = @StatusId))
   BEGIN

	  UPDATE [DeliveryBackOffice].[dbo].[DeliveryLInk]
	     SET DeliveryLinkStatusId = @NewStatusId 
	  WHERE TOKEN = @Token



	END

		   	  
	COMMIT TRANSACTION;


	END TRY
	
		BEGIN CATCH
		
			ROLLBACK TRANSACTION;

			SELECT 0 AS [StatusCode], 'No es posible obtener datos' AS[MessageResponse]

		 END CATCH
END



	
	