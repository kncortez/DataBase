--FDAPI- 2302: Agregar columna para tablas que soporten multipais

--CatRegion 
ALTER TABLE CatRegion 
  ADD IdCountry VARCHAR(2) NULL;

--SenderReceiver
ALTER TABLE SenderReceiver 
  ADD IdCountry VARCHAR(2) NULL;

--CatTypeSenderReceiver
ALTER TABLE CatTypeSenderReceiver
  ADD IdCountry VARCHAR(2) NULL;