USE [DeliveryBackOffice]
GO
CREATE TABLE [dbo].[CreditCardTransaction](
	[IdTransaction] [bigint] IDENTITY(1,1) NOT NULL,
	[System] [tinyint] NOT NULL,
	[CardNumber] [nvarchar](20) NOT NULL,
	[TypeCardNumber] [nvarchar](50) NOT NULL,
	[Ammount] [decimal](18, 2) NULL,
	[Currency] [int] NOT NULL,
	[OrderNumber] [nvarchar](38) NULL,
	[Signature] [nvarchar](100) NULL,
	[CustomerReference] [nvarchar](50) NULL,
	[ReferenceNumber] [nvarchar](50) NULL,
	[ECIIndicator] [nvarchar](2) NULL,
	[Authenticationresult] [nvarchar](1) NULL,
	[TransactionStain] [nvarchar](50) NULL,
	[CAVV] [nvarchar](50) NULL,
	[DatetimeCreated] [datetime] NOT NULL,
	[DatetimeUpdated] [datetime] NULL,
	[ReasonCode] [nvarchar](100) NULL,
	[ReasonCodeDescription] [nvarchar](100) NULL,
 CONSTRAINT [PK_CreditCardTransaction] PRIMARY KEY CLUSTERED 
(
	[IdTransaction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identity, identificador del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'IdTransaction'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1. App android
2. App IOS
3. Sitio Web' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'System'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Número de tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'CardNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Tipo de tarjeta, visa, master card, american express' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'TypeCardNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Monto de transacción' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'Ammount'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código ISO del país de divisa' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'Currency'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'firma generada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'Signature'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador del cliente al que pertenece la tarjeta' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'CustomerReference'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador FAC al finalizar una transacción' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'ReferenceNumber'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Requerido para autorización una transacción 3DS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'ECIIndicator'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Respuesta de una validación de código 3DS para

tarjetas Visa y Master Card' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'Authenticationresult'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Una versión “hash” del número de identificación de la transacción
(XID). Permite el reenvío de la misma.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'TransactionStain'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Este es un valor criptográfico que se deriva del emisor durante la
autenticación del pago' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'CAVV'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creación del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'DatetimeCreated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualización del registro' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'DatetimeUpdated'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Código Respuesta FAC' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'ReasonCode'
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Descripción Respuesta FAC' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CreditCardTransaction', @level2type=N'COLUMN',@level2name=N'ReasonCodeDescription'
GO