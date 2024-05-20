--Script para modificar la llave unica para la tabla SenderReceiver
--Por si existe un DPI o DNI igual, que permita siempre que sea de diferente pais GT/HN.

--[SenderReceiver]
--Eliminar constraint actual 
ALTER TABLE [DeliveryBackOffice].[dbo].[SenderReceiver]
 DROP CONSTRAINT [UC_CUI];

--Agregar nueva version
ALTER TABLE [DeliveryBackOffice].[dbo].[SenderReceiver]
  ADD CONSTRAINT [UC_CUI_Country] UNIQUE NONCLUSTERED ([CUI] ASC,[idCountry]);

--[hublogistics]
  ALTER TABLE [DeliveryBackOffice].[dbo].[hublogistics]
    ADD CONSTRAINT [FK_CatCountry_hublogistics]
FOREIGN KEY (idCountry) REFERENCES [dbo].[CatCountry] (IdCountry);

--[Person]
  ALTER TABLE [DeliveryBackOffice].[dbo].[Person]
    ADD CONSTRAINT [FK_Person_CatCountry]
FOREIGN KEY([PerCountryOrigin]) REFERENCES [dbo].[CatCountry] ([IdCountry]);