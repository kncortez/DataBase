CREATE TABLE [dbo].[GuideBatch] (
    [IdRow]                         BIGINT        IDENTITY (1, 1) NOT NULL,
    [IdBatch]                       BIGINT        NOT NULL,
    [IdUser]                        BIGINT        NOT NULL,
    [GuideSeries]                   VARCHAR (100) NOT NULL,
    [GuideNumber]                   VARCHAR (100) NOT NULL,
    [IdVisitPointByClientPortfolio] BIGINT        NOT NULL,
    [IdAddress]                     BIGINT        NOT NULL,
    [Status]                        INT           NOT NULL,
    [RowStatus]                     BIT           NOT NULL,
    [TokenCreated]                  VARCHAR (50)  NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [TokenUpdated]                  VARCHAR (50)  NULL,
    [DateUpdated]                   DATETIME      NULL,
    CONSTRAINT [PKGuideBatch] PRIMARY KEY CLUSTERED ([IdRow] ASC),
    CONSTRAINT [FKRegisterUserBatch] FOREIGN KEY ([IdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser]),
    CONSTRAINT [FKUserAddressBatch] FOREIGN KEY ([IdAddress]) REFERENCES [dbo].[UserAddress] ([UadIdAddress])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'IdRow';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'IdBatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'IdUser';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'GuideSeries';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'IdVisitPointByClientPortfolio';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'IdAddress';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Motivo por el que se excluye el registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideBatch', @level2type = N'COLUMN', @level2name = N'DateUpdated';

