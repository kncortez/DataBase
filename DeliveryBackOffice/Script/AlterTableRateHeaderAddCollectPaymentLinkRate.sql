-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2026-05-28>
-- Description:	<Agrega la columna CollectPaymentLinkRate a la tabla dbo.RateHeader
--               para almacenar el porcentaje de comisión por collect
--               en pagos realizados mediante link de pago>
-- =============================================

ALTER TABLE [dbo].[RateHeader]
ADD [CollectPaymentLinkRate] DECIMAL(12, 2) NULL;

GO

EXECUTE sp_addextendedproperty
    @name       = N'MS_Description',
    @value      = N'Porcentaje de comisión 5% por collect por uso de link de paggo.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE',  @level1name = N'RateHeader',
    @level2type = N'COLUMN', @level2name = N'CollectPaymentLinkRate';

GO
