CREATE TABLE [dbo].[PaymentZigi]
(
	[ZigiPaymentId]		INT IDENTITY(1,1),
    [GuideNumber]		INT NOT NULL,
	[GuideSerie] 		NVARCHAR(2) NOT NULL,
    [ZigiLinkStatus] 	NVARCHAR(20) NOT NULL,
    [ZigiLink] 			NVARCHAR(MAX),               
    [ZigiTransactionId]	NVARCHAR(100),      
    [ZigiReference] 	NVARCHAR(100),      
	[ZigiPaymentLinkId] NVARCHAR(100),
    [PaidAmount] 		DECIMAL(10, 2),
	[CollectValue] 		DECIMAL(10, 2),
	[CODValue] 			DECIMAL(10, 2),
	[PaymentId]			NVARCHAR(100),
	[DateTimeStamp]		DATETIME,
	[RowStatus]			BIT	CONSTRAINT [DF_PaymentZigi_RowStatus] DEFAULT ((1)) NOT NULL,
	[DateCreated] 		DATETIME not null,
	[TokenCreated] 		NVARCHAR(50) not null,
	[DateUpdated]		DATETIME null,
	[TokenUpdated] 		NVARCHAR(50) null,
	CONSTRAINT [PK_PaymentZigi] PRIMARY KEY CLUSTERED ([ZigiPaymentId] ASC),
    CONSTRAINT [FK_PaymentZigi_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
)

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Registro de pagos realizados a través de la plataforma Zigi.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi';

-- Columnas
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Identificador único del registro de pago en Zigi.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'ZigiPaymentId';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Número de guía asociado al pago.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'GuideNumber';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Serie de la guía asociada al pago.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'GuideSerie';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Estado del vínculo generado por Zigi (ej. pendiente, pagado, expirado).',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'ZigiLinkStatus';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Enlace de pago generado por la plataforma Zigi.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'ZigiLink';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'ID de la transacción proporcionado por Zigi(AuthorizationCode)',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'ZigiTransactionId';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Referencia generada el pago en Zigi. Forma parte del link',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'ZigiReference';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Identificador del enlace de pago generado en Zigi.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'ZigiPaymentLinkId';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Monto pagado a través del enlace de Zigi.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'PaidAmount';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Valor a recaudar asociado al envío.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'CollectValue';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Valor COD correspondiente al pedido.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'CODValue';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Estado (1 Activo, 0 inactivo)',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'RowStatus';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Fecha de creación del registro.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'DateCreated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Token que creó el registro.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'TokenCreated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Fecha de la última modificación del registro.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'DateUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Token que actualizó el registro.',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'TokenUpdated';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Identificador de pago realizado con link',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'PaymentId';

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
 @value = N'Fecha en la que cambio el estado del link',
 @level0type = N'SCHEMA',
 @level0name = N'dbo',
 @level1type = N'TABLE',
 @level1name = N'PaymentZigi',
 @level2type = N'COLUMN',
 @level2name = N'DateTimeStamp';