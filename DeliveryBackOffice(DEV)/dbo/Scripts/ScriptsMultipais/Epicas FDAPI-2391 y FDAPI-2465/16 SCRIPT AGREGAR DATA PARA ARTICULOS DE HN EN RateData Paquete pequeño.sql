SELECT * FROM DeliveryBackOffice.dbo.ArticleByCustomer
WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
WHERE  ArtName = 'Paquete pequeño' AND IdCountry IS NULL)

--SCRIPT AGREGAR ARTICULO POR CLIENTE DE HN EN ArticleByCustomer Paquete mediano
INSERT INTO [dbo].[ArticleByCustomer] --ESTE INSERT NO LO HICE
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
    (492
    ,NULL
    ,1
    ,'MTI2MDYyMDI0MTQ1NjM1MzkxNTQ4'
    ,GETDATE()
    ,NULL
    ,NULL
    ,'EXPHN076'
    ,0.0
    ,28.00
    ,28.00
    ,28.00
    ,10.00
    ,NULL
    ,NULL
    ,4)

DECLARE @NewArticle INT;

SELECT TOP 1 @NewArticle = AbcId FROM DeliveryBackOffice.dbo.ArticleByCustomer
WHERE  AbcIdArticle = (SELECT ArtId FROM DeliveryBackOffice.dbo.CatArticle
WHERE  ArtName = 'Paquete pequeño' AND IdCountry = 'HN')

--SCRIPT AGREGAR DATA PARA ARTICULOS DE HN EN RateData Paquete pequeño
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
WHERE ArticleId = 531 AND RateId = 3675;

