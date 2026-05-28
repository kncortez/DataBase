/* =============================================
   Agregar columnas
============================================= */

ALTER TABLE [dbo].[CostDetail]
ADD 
    [IdTypeOfMoneyCOD] INT NULL,
    [IdTypeOfMoneyCollect] INT NULL;

/* =============================================
   Crear llaves foráneas
============================================= */

ALTER TABLE [dbo].[CostDetail]
ADD CONSTRAINT FK_CostDetail_TypeOfMoneyCOD
FOREIGN KEY ([IdTypeOfMoneyCOD])
REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id]);

ALTER TABLE [dbo].[CostDetail]
ADD CONSTRAINT FK_CostDetail_TypeOfMoneyCollect
FOREIGN KEY ([IdTypeOfMoneyCollect])
REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id]);

/* =============================================
   Agregar descripciones
============================================= */

EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador de medio de pago de COD',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'CostDetail',
    @level2type = N'COLUMN', @level2name = N'IdTypeOfMoneyCOD';


EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador de medio de pago de collect',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'CostDetail',
    @level2type = N'COLUMN', @level2name = N'IdTypeOfMoneyCollect';

