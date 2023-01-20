CREATE TABLE [dbo].[CatSubscriptionDescription] (
    [IdCatSubscriptionDescription] INT            IDENTITY (1, 1) NOT NULL,
    [Title]                        NVARCHAR (100) NOT NULL,
    [Description]                  NVARCHAR (500) NOT NULL,
    [Position]                     INT            NOT NULL,
    [Type]                         NVARCHAR (50)  NOT NULL,
    [CatSubscriptionId]            INT            NOT NULL,
    [RowStatus]                    BIT            NOT NULL,
    [DateCreated]                  DATETIME       NOT NULL,
    [TokenCreated]                 NVARCHAR (50)  NOT NULL,
    [DateUpdated]                  DATETIME       NULL,
    [TokenUpdated]                 NVARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([IdCatSubscriptionDescription] ASC),
    CONSTRAINT [FK_CatSubscription_CatSubscriptionDescription] FOREIGN KEY ([CatSubscriptionId]) REFERENCES [dbo].[CatSubscription] ([IdCatSubscription])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo para agrupar los registros en listado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'Type';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Título del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'Title';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden para mostrar el registro en listado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'Position';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'IdCatSubscriptionDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la suscripción a la que hace referencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatSubscriptionDescription', @level2type = N'COLUMN', @level2name = N'CatSubscriptionId';

