--Script para crear id system Hermes Desktop
USE [DeliveryBackOffice]
GO

  INSERT INTO CatExternalPlatform(NameEP, RowStatus, TokenCreated, DateCreated)
  VALUES ('Tookan',0,'SYS-ARUIZ',GETDATE())
  INSERT INTO CatExternalPlatform(NameEP, RowStatus, TokenCreated, DateCreated)
  VALUES ('Simpliroute',1,'SYS-ARUIZ',GETDATE())

GO