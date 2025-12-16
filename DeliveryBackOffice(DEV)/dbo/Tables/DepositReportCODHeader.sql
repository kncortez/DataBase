CREATE TABLE [dbo].[DepositReportCODHeader]
(
	[IdDepositReportCODHeader]  BIGINT IDENTITY(1,1)	NOT NULL PRIMARY KEY,
	[Batch_COD_Id]              INT						NOT NULL,   
	[Customer_Id]               INT						NOT NULL,   
	[Customer_Name]             NVARCHAR(200)			NOT NULL,	
	[Customer_Email]            NVARCHAR(200)			NOT NULL,	
	[Sender_Email]              NVARCHAR(400)			NOT NULL,	
	[Bank_Id]                   INT						NOT NULL,	
	[BankName]                  NVARCHAR(100)			NOT NULL,	
	[AccountNumber]             NVARCHAR(100)			NOT NULL,	
	[Currency_Symbol]           NVARCHAR(5)				NOT NULL,	
	[Country_Id]                NVARCHAR(2)				NOT NULL,	
	[AuthorizationNumber]       NVARCHAR(100)			NOT NULL,	
	[AuthorizationDate]         DATETIME				NOT NULL,	
	[Notificated]               TINYINT					NOT NULL,	
	[SalePipeLineId]            INT						NULL,
	[IdKindOfVPClient]          INT						NULL,
	[SaleChannelId]             INT						NULL,
	[RowStatus]                 BIT						NOT NULL,
	[TokenCreated]              NVARCHAR(100)			NOT NULL,
	[DateCreated]               DATETIME				NOT NULL,
	[TokenUpdated]              NVARCHAR(100)			NULL,
	[DateUpdated]               DATETIME				NULL,
	CONSTRAINT [FK_DepositReportCODHeader_BatchCOD]		FOREIGN KEY ([Batch_COD_Id]) REFERENCES [dbo].[BatchCOD] ([IdBatchCOD]),
	CONSTRAINT [FK_DepositReportCODHeader_Customer]		FOREIGN KEY ([Customer_Id])  REFERENCES [dbo].[Customer] ([IdCustomer]),
	CONSTRAINT [FK_DepositReportCODHeader_DeliveryBank]	FOREIGN KEY ([Bank_Id])      REFERENCES [dbo].[DeliveryBank] ([Id_bank])
)

GO
CREATE NONCLUSTERED INDEX IX_DRCH_Customer_AuthDate
ON dbo.DepositReportCODHeader (Customer_Id, AuthorizationDate)
INCLUDE (Bank_Id, Customer_Name, Customer_Email, BankName, AccountNumber, AuthorizationNumber, Currency_Symbol, Sender_Email);

GO
CREATE NONCLUSTERED INDEX IX_DRCH_Customer_Bank_AuthDate
ON dbo.DepositReportCODHeader (Customer_Id, Bank_Id, AuthorizationDate)
INCLUDE (Customer_Name, Customer_Email, BankName, AccountNumber, AuthorizationNumber, Currency_Symbol, Sender_Email);

GO
CREATE NONCLUSTERED INDEX IX_DRCH_SenderEmail_AuthDate
ON dbo.DepositReportCODHeader (Sender_Email, AuthorizationDate)
INCLUDE (Customer_Id, Customer_Name, Bank_Id, BankName, AccountNumber, AuthorizationNumber, Currency_Symbol);

GO
CREATE NONCLUSTERED INDEX IX_DRCH_SenderEmail_Bank_AuthDate
ON dbo.DepositReportCODHeader (Sender_Email, Bank_Id, AuthorizationDate)
INCLUDE (Customer_Id, Customer_Name, BankName, AccountNumber, AuthorizationNumber, Currency_Symbol);

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Encabezado de reporte de depósitos COD por lote.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador único del encabezado de reporte de depósito COD.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'IdDepositReportCODHeader';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador del lote COD asociado al reporte (BatchCOD.IdBatchCOD).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Batch_COD_Id';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador del cliente asociado al reporte (Customer.IdCustomer).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Customer_Id';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Nombre del cliente que recibe el reporte (Customer.Name o Sender_FirstName según el caso).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Customer_Name';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Correo principal del cliente para notificación de depósitos (CODContactEmail o RegexEmail).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Customer_Email';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Correo de remitente configurado en la DeliveryOrder (Sender_Mail).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Sender_Email';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador del banco en el que se realizó el depósito (BatchDetailCOD.BankId / DeliveryBank.Id_bank).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Bank_Id';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Nombre del banco utilizado en el depósito COD (BatchDetailCOD.BankName).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'BankName';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Número de cuenta bancaria donde se acreditan los depósitos COD (BatchDetailCOD.AccountNumber).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'AccountNumber';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Símbolo de la moneda utilizada en el depósito (CatCurrencyCOD.Symbol).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Currency_Symbol';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Código de país asociado al depósito (ReceiverCountryId o DeliveryBank.Id_country).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Country_Id';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Número de autorización del depósito COD (BatchDetailCOD.AuthorizationNumber).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'AuthorizationNumber';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Fecha y hora en que se registró la autorización del depósito COD (BatchDetailCOD.AuthorizationDate).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'AuthorizationDate';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Indicador de notificación de depósito COD (0 = pendiente, 1 = notificado).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'Notificated';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Pipeline de la guía según configuración (DeliveryOrder.SalePipeLineId).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'SalePipeLineId';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Tipo de punto de venta asociado al cliente (VisitPointClient.IdKindOfVPClient).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'IdKindOfVPClient';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Canal de venta asociado al punto de venta del cliente (VisitPointClient.SaleChannelId).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'SaleChannelId';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Estado lógico del registro (1 = activo, 0 = inactivo).',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador o usuario que creó el registro del encabezado de reporte COD.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Fecha y hora de creación del registro del encabezado de reporte COD.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Identificador o usuario que realizó la última actualización del registro del encabezado.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sys.sp_addextendedproperty 
	@name = N'MS_Description',
	@value = N'Fecha y hora de la última actualización del registro del encabezado.',
	@level0type = N'SCHEMA', @level0name = N'dbo',
	@level1type = N'TABLE',  @level1name = N'DepositReportCODHeader',
	@level2type = N'COLUMN', @level2name = N'DateUpdated';

GO