ALTER TABLE [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]
ADD ClientConfirmsReturn BIT NULL DEFAULT 0

EXECUTE sp_addextendedproperty N'MS_Description', N'Confirmación del lado de cliente indicando que solicita devolución del paquete al origen.', N'SCHEMA', N'dbo', N'TABLE', N'ConfirmationOfIncidence', N'COLUMN', N'ClientConfirmsReturn'
GO