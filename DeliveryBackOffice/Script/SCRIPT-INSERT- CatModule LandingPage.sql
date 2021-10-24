-- Ingresar plataformas externas a catalogo
USE [DeliveryBackOffice]
GO

  INSERT INTO CatModule(
      [ModName]
      ,[ModIdModuleParent]
      ,[ModPath]
      ,[ModDescription]
      ,[ModOrder]
      ,[ModMetadata]
      ,[ModVisible]
      ,[ModRowStatus]
      ,[ModTokenCreated]
      ,[ModDateCreated])
  VALUES (
      'Landing Delivery Page'
      ,NULL,
      '/landing-delivery',
      'Pagina para recoleccion de datos de guias a entregar'
      ,1
      ,NULL
      ,0
      ,1
      ,'SYS-ARUIZ'
      ,'2021-09-01 09:30')

GO