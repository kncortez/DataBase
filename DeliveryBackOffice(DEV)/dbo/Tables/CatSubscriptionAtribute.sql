CREATE TABLE [dbo].[CatSubscriptionAtribute] (
    [IdCatSubscriptionAttribute]           INT            IDENTITY (1, 1) NOT NULL,
    [CatSubscriptionId]                    INT            NOT NULL,
    [CatAttributeId]                       INT            NOT NULL,
    [SubscriptionAttributeValue]           NVARCHAR (50)  NOT NULL,
    [SubscriptionAttributeDescription]     NVARCHAR (300) NOT NULL,
    [SubscriptionAttributePosition]        INT            NOT NULL,
    [RowStatus]                            BIT            CONSTRAINT [DF_CatSubscriptionAtribute_RowStatus] DEFAULT ((1)) NOT NULL,
    [TokenCreated]                         NVARCHAR (50)  NOT NULL,
    [DateCreated]                          DATETIME       NOT NULL,
    [TokenUpdated]                         NVARCHAR (50)  NULL,
    [DateUpdated]                          DATETIME       NULL,
    [SubscriptionAttributeDescriptionLong] NVARCHAR (500) NULL,
    [CatSubscriptionAttributeIcon]         NVARCHAR (200) NULL,
    CONSTRAINT [PK_CatSubscriptionAtribute] PRIMARY KEY CLUSTERED ([IdCatSubscriptionAttribute] ASC),
    CONSTRAINT [FK_CatSubscriptionAtribute_IdCatAttribute] FOREIGN KEY ([CatAttributeId]) REFERENCES [dbo].[CatAttribute] ([IdCatAttribute]) ON DELETE CASCADE,
    CONSTRAINT [FK_CatSubscriptionAtribute_IdCatSubscription] FOREIGN KEY ([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription]) ON DELETE CASCADE
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción larga deatributo de una suscripción ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'SubscriptionAttributeDescriptionLong';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'valor del atributo de la suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'SubscriptionAttributeValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Posición del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'SubscriptionAttributePosition';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripcón del atributo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'SubscriptionAttributeDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'inidcador del estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de registro de catalogo de atributos de suscripciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'IdCatSubscriptionAttribute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Idintificador de tabla de catalogo de suscripciones y productos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'CatSubscriptionId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Icono del atributo de una suscripción', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'CatSubscriptionAttributeIcon';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Idintificador de tabla de catalogo de atributos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionAtribute', @level2type = N'COLUMN', @level2name = N'CatAttributeId';

