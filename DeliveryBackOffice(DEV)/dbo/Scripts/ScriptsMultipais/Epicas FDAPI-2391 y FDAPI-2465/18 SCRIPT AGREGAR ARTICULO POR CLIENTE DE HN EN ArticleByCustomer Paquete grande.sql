SELECT * FROM DeliveryBackOffice.dbo.ArticleByCustomer
WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
WHERE  ArtName = 'Paquete grande' AND IdCountry IS NULL)

--SCRIPT AGREGAR ARTICULO POR CLIENTE DE HN EN ArticleByCustomer Paquete grande
INSERT INTO [dbo].[ArticleByCustomer]
    ([AbcIdArticle]
    ,[AbcIdCustomer]
    ,[AbcRowStatus]
    ,[AbcTokenCreated]
    ,[AbcDateCreated]
    ,[AbcTokenUpdated]
    ,[AbcDateUpdated]
    ,[Code]
    ,[PriceDefault]
    ,[Height]
    ,[Width]
    ,[Length]
    ,[MassWeight]
    ,[VolumetricWeight]
    ,[ShowDefault]
    ,[IdCurrency])
VALUES
    (494
    ,NULL
    ,1
    ,'SYS-WOROZCO'
    ,GETDATE()
    ,NULL
    ,NULL
    ,'EXPHN078'
    ,0.0
    ,45.00
    ,45.00
    ,45.00
    ,40.00
    ,NULL
    ,NULL
    ,4)

DECLARE @NewArticle INT;

SELECT @NewArticle = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer
WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
WHERE  ArtName = 'Paquete grande' AND IdCountry = 'HN')

--SCRIPT AGREGAR DATA PARA ARTICULOS DE HN EN RateData Paquete mediano
INSERT INTO [dbo].[RateData]
    ([RateId]
    ,[TypeServiceId]
    ,[TypeSegmentId]
    ,[HubSourceId]
    ,[HubDestinyId]
    ,[ArticleId]
    ,[RateValue]
    ,[RowStatus]
    ,[TokenCreated]
    ,[DateCreated]
    ,[TokenUpdated]
    ,[DateUpdated]
    ,[LimitHourDelivery]
    ,[LimitHourPickup]
    ,[WeightFrom]
    ,[WeightTo]
    ,[PackagesFrom]
    ,[PackagesTo])
SELECT 
    [RateId]
    ,[TypeServiceId]
    ,[TypeSegmentId]
    ,[HubSourceId]
    ,[HubDestinyId]
    ,@NewArticle AS [ArticleId]
    ,[RateValue]
    ,[RowStatus]
    ,'SYS-WOROZCO' AS [TokenCreated]
    ,GETDATE() AS [DateCreated]
    ,NULL AS [TokenUpdated]
    ,NULL AS [DateUpdated]
    ,[LimitHourDelivery]
    ,[LimitHourPickup]
    ,[WeightFrom]
    ,[WeightTo]
    ,[PackagesFrom]
    ,[PackagesTo]
FROM DeliveryBackOffice.dbo.RateData
WHERE ArticleId = 533 AND RateId = 3675;

