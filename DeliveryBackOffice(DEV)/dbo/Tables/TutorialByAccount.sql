CREATE TABLE [dbo].[TutorialByAccount] (
    [IdTutorialByAccount] BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TutorialId]          INT           NOT NULL,
    [AccountId]           BIGINT        NOT NULL,
    [ToDisplay]           BIT           DEFAULT ((1)) NOT NULL,
    [RowStatus]           BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]         DATETIME      NOT NULL,
    [TokenCreated]        NVARCHAR (50) NOT NULL,
    [DateUpdated]         DATETIME      NULL,
    [TokenUpdated]        NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdTutorialByAccount] ASC),
    CONSTRAINT [FK_TutorialByAccount_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_TutorialByAccount_Tutorial] FOREIGN KEY ([TutorialId]) REFERENCES [dbo].[Tutorial] ([IdTutorial])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador si el tutorial debe ser desplegado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount', @level2type = N'COLUMN', @level2name = N'ToDisplay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cuenta de usuario de la tabla Account.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tutorial de la tabla Tutorial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount', @level2type = N'COLUMN', @level2name = N'TutorialId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount', @level2type = N'COLUMN', @level2name = N'IdTutorialByAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que relaciona cuentas de usuarios con tutoriales.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TutorialByAccount';


GO
CREATE NONCLUSTERED INDEX [IDX_AccountId_ToDisplay_RowStatus]
    ON [dbo].[TutorialByAccount]([AccountId] ASC, [ToDisplay] ASC, [RowStatus] ASC);

