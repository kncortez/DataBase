BEGIN TRANSACTION;

-- Agregar nuevos campos
ALTER TABLE [dbo].[CustomerPaymentValue]
ADD 
    [FirstName] NVARCHAR(50) NULL,
    [LastName] NVARCHAR(50) NULL,
    [Nirphone] NVARCHAR(5) NULL,
    [Address] NVARCHAR(150) NULL,
    [Phone] NVARCHAR(15) NULL,
    [IsoCode] NVARCHAR(3) NULL,
    [PaymentGateway] NVARCHAR(25) NULL;

-- Agregar comentarios de los campos
EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de tarjeta para pasarela de pago PayWayOne', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'FirstName';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Apellido de tarjeta para pasarela de pago PayWayOne', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'LastName';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Área de teléfono', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'Nirphone';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Dirección para campo obligatorio de pasarela de pago', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'Address';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Teléfono de tarjeta de crédito', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'Phone';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Código de país', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'IsoCode';

EXEC sp_addextendedproperty @name=N'MS_Description', @value=N'Pasarela de pago que se utiliza', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CustomerPaymentValue', @level2type=N'COLUMN',@level2name=N'PaymentGateway';

COMMIT TRANSACTION;
