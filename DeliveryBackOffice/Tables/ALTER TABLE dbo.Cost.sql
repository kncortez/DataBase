-- Ejectuar por partes


ALTER TABLE dbo.Cost
ADD ReturnAmount decimal (12,2)
, ReturnPaid decimal (12,2)

DECLARE @v sql_variant
SET @v = N'Valor que se debe pagar por devolución'
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Cost', N'COLUMN', N'ReturnAmount'

DECLARE @w sql_variant
SET @w = N'Valor Pagado por devolución '
EXECUTE sp_addextendedproperty N'MS_Description', @v, N'SCHEMA', N'dbo', N'TABLE', N'Cost', N'COLUMN', N'ReturnPaid'

select * from dbo.Cost