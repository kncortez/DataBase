CREATE TABLE [dbo].[CatSubscription] (
    [IdCatSubscription]                INT             IDENTITY (1, 1) NOT NULL,
    [SubscriptionName]                 NVARCHAR (50)   NOT NULL,
    [SubscriptionDescription]          NVARCHAR (300)  NULL,
    [SubscriptionCost]                 DECIMAL (18, 2) NULL,
    [SubscriptionFixedValue]           INT             NOT NULL,
    [SubscriptionMaxServiceFixedValue] INT             NOT NULL,
    [SubscriptionValidity]             INT             NOT NULL,
    [SubscriptionWeight]               INT             NOT NULL,
    [RowStatus]                        BIT             CONSTRAINT [DF_CatSubscription_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                     NVARCHAR (50)   NOT NULL,
    [DateCreated]                      DATETIME        NOT NULL,
    [TokenUpdated]                     NVARCHAR (50)   NULL,
    [DateUpdated]                      DATETIME        NULL,
    [Icon]                             NVARCHAR (50)   NULL,
    [NextSalesPackageBanner]           NVARCHAR (200)  NULL,
    [RateHeaderId]                     INT             NULL,
    [AlternativeRateHeaderId]          INT             NULL,
    [IncludedMembershipId]             INT             NULL,
    [CatTypeSubscriptionId]            INT             NULL,
    [CatProductCategoryId]             INT             NULL,
    [Tag]                              NVARCHAR (100)  NULL,
    [Position]                         INT             NULL,
    CONSTRAINT [PK_CatSubscription] PRIMARY KEY CLUSTERED ([IdCatSubscription] ASC),
    CONSTRAINT [FK_CatSubscription_AlternativeRate] FOREIGN KEY ([AlternativeRateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FK_CatSubscription_CatMembership] FOREIGN KEY ([IncludedMembershipId]) REFERENCES [dbo].[CatMembership] ([IdCatMembership]),
    CONSTRAINT [FK_CatSubscription_CatProductCategory] FOREIGN KEY ([CatProductCategoryId]) REFERENCES [dbo].[CatProductCategory] ([IdCatProductCategory]),
    CONSTRAINT [FK_CatSubscription_CatTypeSubscription] FOREIGN KEY ([CatTypeSubscriptionId]) REFERENCES [dbo].[CatTypeSubscription] ([IdCatTypeSubscription]),
    CONSTRAINT [FK_CatSubscription_Rate] FOREIGN KEY ([RateHeaderId]) REFERENCES [dbo].[RateHeader] ([RheId])
);






















GO


GO



GO


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Nombre de banner a desplegar cuando servicios de monto fijo esten proximos a acabarse', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'NextSalesPackageBanner';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tarifario a utilizar cuando se usa suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'RateHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Tarifario alterno a utilizar cuando se usa suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'AlternativeRateHeaderId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si suscripci?n contiene una membres?a incluida y cual membres?a es de la tabla CatMembership', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'IncludedMembershipId';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id relacion con tabla CatTypeSubscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'CatTypeSubscriptionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id relacion con tabla CatProductCategory', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'CatProductCategoryId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'etiqueta de identificación del producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'Tag';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de actualización de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Peso de suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'SubscriptionWeight';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor de vigencia de la suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'SubscriptionValidity';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la suscripción o producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'SubscriptionName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor Fijo Máximo de Servicio de la Suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'SubscriptionMaxServiceFixedValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor Fijo de la Suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'SubscriptionFixedValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'SubscriptionDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Costo de la suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'SubscriptionCost';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de reistro de una susripción o proudcto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'IdCatSubscription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Icono de producto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'Icon';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'campo para el ordenamiento por  Posición ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscription', @level2type = N'COLUMN', @level2name = N'Position';

