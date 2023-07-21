CREATE TABLE [dbo].[CatTypeSubscription] (
    [IdCatTypeSubscription]    INT         NOT NULL,
    [CatTypeSubscriptionName]  NCHAR (100) NOT NULL,
    [DescriptionTSubscription] NCHAR (200) NOT NULL,
    [RowStatus]                BIT         NOT NULL,
    [DateCreated]              NCHAR (10)  NOT NULL,
    [TokenCreated]             NCHAR (10)  NOT NULL,
    [DateUpdated]              NCHAR (10)  NULL,
    [TokenUpdated]             NCHAR (10)  NULL,
    CONSTRAINT [PK_CatTypeSubscription] PRIMARY KEY CLUSTERED ([IdCatTypeSubscription] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSubscription', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha que actualiza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSubscription', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSubscription', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSubscription', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de susbscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSubscription', @level2type = N'COLUMN', @level2name = N'DescriptionTSubscription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de susbscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSubscription', @level2type = N'COLUMN', @level2name = N'CatTypeSubscriptionName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla CatTypeSubscription', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeSubscription', @level2type = N'COLUMN', @level2name = N'IdCatTypeSubscription';

