-- =============================================
-- Author:		<Edelman Vasquez>
-- Create date: <2026-05-13>
-- Description:	<Agrega la columna PaymentGateway a la tabla dbo.PaymentZigi
--               para almacenar el nombre de la pasarela de pagos utilizada>
-- =============================================
ALTER TABLE [dbo].[PaymentZigi]
ADD [PaymentGateway] NVARCHAR(100) NULL;

GO

EXECUTE sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Nombre de la pasarela de pagos utilizada en la transacción.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'PaymentZigi',
    @level2type = N'COLUMN', @level2name = N'PaymentGateway';

GO
