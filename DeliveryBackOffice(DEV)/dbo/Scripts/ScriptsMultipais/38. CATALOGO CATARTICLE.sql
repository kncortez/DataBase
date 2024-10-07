INSERT INTO CatArticle
(
    ArtIdTypeArticle,
    ArtName,
    ArtShowDefault,
    ArtRowStatus,
    ArtTokenCreated,
    ArtDateCreated,
    ArtTokenUpdated,
    ArtDateUpdated,
    ArtHeight,
    ArtWidth,
    ArtLength,
    ArtMassWeight,
    IdCountry
)
SELECT ArtIdTypeArticle,
       ArtName,
       ArtShowDefault,
       ArtRowStatus,
       ArtTokenCreated,
       GETDATE(),
       NULL,
       NULL,
       ArtHeight,
       ArtWidth,
       ArtLength,
       ArtMassWeight,
       'HN'
FROM DeliveryBackOffice.dbo.CatArticle
