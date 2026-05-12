BEGIN TRY
BEGIN TRANSACTION

DECLARE @IdSegmentMetro    INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'MES'), --26
        @IdSegmentNacional INT = (SELECT CrsId FROM CatRateSegment WITH(NOLOCK) WHERE CrsShortName = 'NAS'); --31

DECLARE @IdRate          INT = (SELECT RheId FROM RateHeader WITH(NOLOCK) WHERE RheName ='Tarifario de servicio estandar' AND CountryId = 'SV'),
        @TypeServiceSTD  INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'STD'), --5
        @TypeServiceCOD  INT = (SELECT CtsId FROM CatTypeService WITH(NOLOCK) WHERE CtsShortName = 'COD'); --6

DECLARE @IdPeq   INT = (SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Pequeño' and IdCountry = 'SV') AND Code = 'EXPSV076'),
        @IdMed   INT = (SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Mediano' and IdCountry = 'SV') AND Code ='EXPSV077'),
        @IdGrand INT = (SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Grande' and IdCountry = 'SV') AND Code ='EXPSV078'),
        @IdExt   INT = (SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Extra Grande' and IdCountry = 'SV') AND Code ='EXPSV079'),
        @IdSob   INT = (SELECT AbcId FROM ArticleByCustomer WITH(NOLOCK) WHERE AbcIdArticle =(SELECT ArtId FROM CatArticle WITH(NOLOCK) WHERE ArtName = 'Paquete Sobredimensionado' and IdCountry = 'SV') AND Code ='EXPSV080');


 --*********************  ESTANDAR  *********************

--INHABILITAR TARIFAS ANTIGUAS (ESTANDAR)
UPDATE RateData
SET RowStatus = 0,
    TokenUpdated = 'SYS-BPEDROZA',
    DateUpdated = GETDATE()
WHERE RateId = @IdRate AND RowStatus = 1 AND TypeServiceId IS NOT NULL AND TypeServiceId = @TypeServiceSTD;

--COBERTURA METRO
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdPeq,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdMed,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdGrand,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdExt,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentMetro,NULL,NULL,@IdSob,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--COBERTURA NACIONAL
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdPeq,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdMed,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdGrand,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdExt,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceSTD,@IdSegmentNacional,NULL,NULL,@IdSob,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

 --*********************  COD  *********************

--INHABILITAR TARIFAS ANTIGUAS (COD)
UPDATE RateData
SET RowStatus = 0,
    TokenUpdated = 'SYS-BPEDROZA',
    DateUpdated = GETDATE()
WHERE RateId = @IdRate AND RowStatus = 1 AND TypeServiceId IS NOT NULL AND TypeServiceId = @TypeServiceCOD;

--COBERTURA METRO
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdPeq,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdMed,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdGrand,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdExt,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentMetro,NULL,NULL,@IdSob,2.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

--COBERTURA NACIONAL
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdPeq,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdMed,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdGrand,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdExt,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
INSERT INTO dbo.RateData (RateId,TypeServiceId,TypeSegmentId,HubSourceId,HubDestinyId,ArticleId,RateValue,RowStatus,TokenCreated,DateCreated,TokenUpdated,DateUpdated,LimitHourDelivery,LimitHourPickup,WeightFrom,WeightTo,PackagesFrom,PackagesTo) VALUES ( @IdRate,@TypeServiceCOD,@IdSegmentNacional,NULL,NULL,@IdSob,3.5,1,'SYS-BPEDROZA',GETDATE(),NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);

COMMIT TRANSACTION

    PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH






