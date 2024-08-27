SELECT * FROM DeliveryBackOffice.dbo.ArticleByCustomer
WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
WHERE  ArtName = 'Paquete mediano' AND IdCountry IS NULL)

--SCRIPT AGREGAR ARTICULO POR CLIENTE DE HN EN ArticleByCustomer Paquete mediano
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
    (493
    ,NULL
    ,1
    ,'SYS-WOROZCO'
    ,GETDATE()
    ,NULL
    ,NULL
    ,'EXPHN077'
    ,0.0
    ,35.00
    ,35.00
    ,35.00
    ,20.00
    ,NULL
    ,NULL
    ,4)

DECLARE @NewArticle INT;

SELECT @NewArticle = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer
WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
WHERE  ArtName = 'Paquete mediano' AND IdCountry = 'HN')

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
WHERE ArticleId = 532 AND RateId = 3675;

