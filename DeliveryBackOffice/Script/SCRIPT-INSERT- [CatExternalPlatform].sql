-- Ingresar plataformas externas a catalogo
USE [DeliveryBackOffice]
GO

  INSERT INTO CatExternalPlatform(NameExternalPlatform, RowStatus, TokenCreated, DateCreated)
  VALUES ('Tookan',0,'SYS-ARUIZ',GETDATE())
  INSERT INTO CatExternalPlatform(NameExternalPlatform, RowStatus, TokenCreated, DateCreated)
  VALUES ('Simpliroute',1,'SYS-ARUIZ',GETDATE())

GO