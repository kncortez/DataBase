
--Script para actualizar valores
UPDATE DefaultValuesPerCountry
   SET CodeOfReferenceCorpForInvoice = 999,
       TaxPercentage = '1.12'
 WHERE IdCountry ='GT';

GO

UPDATE DefaultValuesPerCountry
   SET CodeOfReferenceCorpForInvoice = 948850,
       TaxPercentage = '1.15'
 WHERE IdCountry ='HN';

GO

UPDATE DefaultValuesPerCountry
   SET CodeOfReferenceCorpForInvoice = 1162393,
       TaxPercentage = '1.13'
 WHERE IdCountry ='SV';

GO
