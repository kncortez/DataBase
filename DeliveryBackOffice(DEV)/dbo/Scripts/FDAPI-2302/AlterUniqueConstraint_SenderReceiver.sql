--Script para modificar la llave unica para la tabla SenderReceiver
--Por si existe un DPI o DNI igual, que permita siempre que sea de diferente pais GT/HN.
ALTER TABLE SenderReceiver 
 DROP CONSTRAINT [UC_CUI];

ALTER TABLE SenderReceiver 
  ADD CONSTRAINT [UC_CUI_Country] UNIQUE NONCLUSTERED ([CUI] ASC,[idCountry]);