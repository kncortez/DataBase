CREATE TABLE [dbo].[ExternalPlatformServicePendingActionLog] (
    [IdExternalPlatformServiceXLog] INT           IDENTITY (1, 1) NOT NULL,
    [ExternalPlatformId]            INT           NOT NULL,
    [GuideSerie]                    NVARCHAR (2)  NOT NULL,
    [GuideNumber]                   INT           NOT NULL,
    [IsPendingInsert]               BIT           NULL,
    [IsPendingUpdate]               BIT           NULL,
    [IsPendingDelete]               BIT           NULL,
    [RowStatus]                     BIT           NOT NULL,
    [TokenCreated]                  NVARCHAR (50) NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [TokenUpdated]                  NVARCHAR (50) NULL,
    [DateUpdated]                   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdExternalPlatformServiceXLog] ASC),
    CONSTRAINT [CHK_ExternalPlatformServicePendingActionLog_Action] CHECK (isnull([IsPendingInsert],(0))>(0) AND isnull([IsPendingUpdate],(0))=(0) AND isnull([IsPendingDelete],(0))=(0) OR isnull([IsPendingInsert],(0))=(0) AND isnull([IsPendingUpdate],(0))>(0) AND isnull([IsPendingDelete],(0))=(0) OR isnull([IsPendingInsert],(0))=(0) AND isnull([IsPendingUpdate],(0))=(0) AND isnull([IsPendingDelete],(0))>(0)),
    CONSTRAINT [FK_ExternalPlatformServicePendingActionLog_CatExternalPlatform] FOREIGN KEY ([ExternalPlatformId]) REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de guías que quedan pendientes de realizar una acción bajo la plataforma externa correspondiente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'IdExternalPlatformServiceXLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID que hace referencia a la tabla CatExternalPlatform', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'ExternalPlatformId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía referenciando a la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía referenciando a la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el registro esta pendiente de ser ingresado a la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'IsPendingInsert';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el registro esta pendiente de ser actualizado en la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'IsPendingUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el registro esta pendiente de ser eliminado en la plataforma externa', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'IsPendingDelete';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ExternalPlatformServicePendingActionLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';

