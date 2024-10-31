
  -- Se elimina debido a que no es correcta la llave
  -- Un lote, puede tener mas de una vez el mismo codeOfReference registrado, debido a la alta/bajas de las relaciones que se agregaran
  ALTER TABLE [InvoiceBatchRelationships]
  DROP CONSTRAINT PK_InvoiceBatchRelationships;
