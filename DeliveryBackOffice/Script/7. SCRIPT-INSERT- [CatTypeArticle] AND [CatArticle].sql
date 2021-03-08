USE [DeliveryBackOffice]
GO

INSERT INTO DeliveryBackOffice.dbo.CatTypeArticle (TarIdPackage,TarName,TarRowStatus,TarTokenCreated,TarDateCreated)
VALUES(3,'Caja',1,'SYS-AJUAREZ',GETDATE())
INSERT INTO DeliveryBackOffice.dbo.CatTypeArticle (TarIdPackage,TarName,TarRowStatus,TarTokenCreated,TarDateCreated)
VALUES(3,'Sobre',1,'SYS-AJUAREZ',GETDATE())

INSERT INTO DeliveryBackOffice.dbo.CatArticle (ArtIdTypeArticle,ArtName,ArtShowDefault,ArtRowStatus,ArtTokenCreated,ArtDateCreated)
VALUES(9,'Caja estándar 30x30x30',0,1,'SYS-AJUAREZ',GETDATE())
INSERT INTO DeliveryBackOffice.dbo.CatArticle (ArtIdTypeArticle,ArtName,ArtShowDefault,ArtRowStatus,ArtTokenCreated,ArtDateCreated)
VALUES(10,'Sobre',0,1,'SYS-AJUAREZ',GETDATE())

UPDATE DeliveryBackOffice.dbo.CatArticle SET ArtName = 'Pieza Irregular' WHERE ArtId=4