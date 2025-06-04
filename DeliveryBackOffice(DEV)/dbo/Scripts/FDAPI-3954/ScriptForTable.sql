--Script
ALTER TABLE DefaultValuesPerCountry
  ADD CodeOfReferenceCorpForInvoice NVARCHAR(10) NULL;

GO

ALTER TABLE DefaultValuesPerCountry
  ADD TaxPercentage NVARCHAR(10) NULL;

GO