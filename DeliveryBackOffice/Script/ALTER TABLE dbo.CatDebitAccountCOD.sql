USE DeliveryBackOffice

ALTER TABLE CatDebitAccountCOD
ADD CatAccountTypeCODId INT NULL

ALTER TABLE CatDebitAccountCOD
ADD FOREIGN KEY (CatAccountTypeCODId) REFERENCES CatAccountTypeCOD(IdCatAccountTypeCOD);

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de cuenta.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatDebitAccountCOD', @level2type=N'COLUMN',@level2name=N'CatAccountTypeCODId'

