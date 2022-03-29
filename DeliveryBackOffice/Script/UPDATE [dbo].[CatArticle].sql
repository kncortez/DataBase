USE [DeliveryBackOffice]
GO

UPDATE [dbo].[CatArticle] SET ArtIdTypeArticle = (SELECT TarId FROM CatTypeArticle WHERE TarName = 'Cama') WHERE ArtName = 'Cama imperial/unipersonal'
UPDATE [dbo].[CatArticle] SET ArtIdTypeArticle = (SELECT TarId FROM CatTypeArticle WHERE TarName = 'Cama') WHERE ArtName = 'Cama King'
UPDATE [dbo].[CatArticle] SET ArtIdTypeArticle = (SELECT TarId FROM CatTypeArticle WHERE TarName = 'Cama') WHERE ArtName = 'Cama matrimonial'
UPDATE [dbo].[CatArticle] SET ArtIdTypeArticle = (SELECT TarId FROM CatTypeArticle WHERE TarName = 'Cama') WHERE ArtName = 'Cama Queen'
UPDATE [dbo].[CatArticle] SET ArtIdTypeArticle = (SELECT TarId FROM CatTypeArticle WHERE TarName = 'Electrodomésticos') WHERE ArtName = 'Lavadoras'
UPDATE [dbo].[CatArticle] SET ArtIdTypeArticle = (SELECT TarId FROM CatTypeArticle WHERE TarName = 'Repuestos Carro') WHERE ArtName = 'Llantas de camión'
UPDATE [dbo].[CatArticle] SET ArtIdTypeArticle = (SELECT TarId FROM CatTypeArticle WHERE TarName = 'Mueble') WHERE ArtName = 'Juego de sala'
