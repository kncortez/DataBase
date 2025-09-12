CREATE TABLE [dbo].[BillingProfile] (
    [BlpIdBilling]                   BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [BlpIdAccount]                   BIGINT        NOT NULL,
    [BlpName]                        VARCHAR (100) NOT NULL,
    [BlpAddress]                     VARCHAR (200) NOT NULL,
    [BlpTaxId]                       VARCHAR (50)  NULL,
    [BlpRowStatus]                   BIT           NOT NULL,
    [BlpTokenCreated]                VARCHAR (50)  NOT NULL,
    [BlpDateCreated]                 DATETIME      NOT NULL,
    [BlpTokenUpdated]                VARCHAR (50)  NULL,
    [BlpDateUpdated]                 DATETIME      NULL,
    [VisitPointByClientPortfolioId]  INT           NULL,
    [IsDefault]                      BIT           CONSTRAINT [DF_BillingProfile_IsDefault] DEFAULT ((0)) NOT NULL,
    [NRC]                            NVARCHAR(200) NULL,
	[TypeIdentificationDocumentCode] NVARCHAR(100) NULL,
	[IdDocument]                     NVARCHAR(20)  NULL,
	[DistrictId]                     INT           NULL,
	[StateId]                        INT           NULL,
	[ActivityCode]                   NVARCHAR(100) NULL,
	[Inv_type]                       INT           NULL,
    PRIMARY KEY CLUSTERED ([BlpIdBilling] ASC),
    CONSTRAINT [FKBillingAccount] FOREIGN KEY ([BlpIdAccount]) REFERENCES [dbo].[Account] ([AccIdAccount])
);

GO
CREATE NONCLUSTERED INDEX [IX_BillingProfile_LoadList]
    ON [dbo].[BillingProfile]([VisitPointByClientPortfolioId] ASC);

GO
CREATE NONCLUSTERED INDEX [IDX_BillingProfile_GetInvoicePaymentCommissionCOD] ON [BillingProfile] ([BlpIdAccount], [BlpRowStatus])
INCLUDE ([BlpName], [BlpAddress], [BlpTaxId], [IsDefault])

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena información datos de facturación favoritos, clientes individuales', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para identificar el perfil que se seleccionó como favorito.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'BillingProfile', @level2type = N'COLUMN', @level2name = N'IsDefault';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Número de Registro del Contribuyente (NRC)', @level2type = N'COLUMN', @level2name = 'NRC',@level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de documento de identificación del comprador', @level2type = N'COLUMN', @level2name = 'TypeIdentificationDocumentCode', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Número de identificación', @level2type = N'COLUMN', @level2name = 'IdDocument', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del distrito', @level2type = N'COLUMN', @level2name = 'DistrictId', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del estado', @level2type = N'COLUMN', @level2name = 'StateId',@level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Actividad económica del comprador', @level2type = N'COLUMN', @level2name = 'ActivityCode', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';

GO
EXEC sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de factura electrónica', @level2type = N'COLUMN', @level2name = 'ActivityCode', @level0type = N'SCHEMA', @level0name = 'dbo', @level1type = N'TABLE',  @level1name = 'BillingProfile';