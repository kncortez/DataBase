CREATE TABLE [dbo].[DeliveryFavCOD] (
    [IdDeliveryFavCOD]                INT           IDENTITY (1, 1) NOT NULL,
    [AliasFavCOD]                     VARCHAR (50)  NULL,
    [NameAccountFavCOD]               VARCHAR (50)  NULL,
    [TypeAccountFavCOD]               VARCHAR (50)  NULL,
    [DocumentIdFavCOD]                VARCHAR (50)  NULL,
    [StatusFavCOD]                    INT           NULL,
    [IdAccountFavCOD]                 INT           NULL,
    [TokenCreated]                    VARCHAR (50)  NULL,
    [DateCreated]                     DATETIME      NULL,
    [TokenUpdate]                     VARCHAR (50)  NULL,
    [DateUpdate]                      DATETIME      NULL,
    [IdBank]                          INT           NULL,
    [NumberAccFavCOD]                 VARCHAR (50)  NULL,
    [VisitPointByClientPortfolioId]   INT           NULL,
    [IsDefault]                       BIT           CONSTRAINT [DF_DeliveryFavCOD_IsDefault] DEFAULT ((0)) NOT NULL,
    [PhoneNumber]                     INT           NULL,
    [NIT]                             NVARCHAR (15) NULL,
    [FlagInstantDeposits]             BIT           NULL,
    [FlagApprovalofCODPaymentsWithTC] BIT           NULL,
    [depositPreviously]               BIT           NULL,
    CONSTRAINT [PK_DeliveryFavCOD] PRIMARY KEY CLUSTERED ([IdDeliveryFavCOD] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IX_DeliveryFavCOD_LoadList]
    ON [dbo].[DeliveryFavCOD]([VisitPointByClientPortfolioId] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryFavCOD_BankStatusList]
    ON [dbo].[DeliveryFavCOD]([StatusFavCOD] ASC, [IdBank] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de teléfono', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryFavCOD', @level2type = N'COLUMN', @level2name = N'PhoneNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de identificación tributaria', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryFavCOD', @level2type = N'COLUMN', @level2name = N'NIT';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para identificar la cuenta que se seleccionó como favorita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryFavCOD', @level2type = N'COLUMN', @level2name = N'IsDefault';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag de depósitos inmediatos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryFavCOD', @level2type = N'COLUMN', @level2name = N'FlagInstantDeposits';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag de aprobación de pagos  COD con TC', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryFavCOD', @level2type = N'COLUMN', @level2name = N'FlagApprovalofCODPaymentsWithTC';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de verificación de cuentas bancarias (si ya se hizo un depósito previamente)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryFavCOD', @level2type = N'COLUMN', @level2name = N'depositPreviously';

