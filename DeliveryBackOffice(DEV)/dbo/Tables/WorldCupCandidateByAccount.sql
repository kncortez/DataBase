CREATE TABLE [dbo].[WorldCupCandidateByAccount] (
    [IdWorldCupCandidateByAccount] INT           IDENTITY (1, 1) NOT NULL,
    [AccountId]                    BIGINT        NOT NULL,
    [WorldCupCandidateId]          INT           NOT NULL,
    [RowStatus]                    BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                 NVARCHAR (50) NOT NULL,
    [DateCreated]                  DATETIME      NOT NULL,
    [TokenUpdated]                 NVARCHAR (50) NULL,
    [DateUpdated]                  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdWorldCupCandidateByAccount] ASC),
    CONSTRAINT [FK_WorldCupCandidateByAccount_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_WorldCupCandidateByAccount_WorldCupCandidate] FOREIGN KEY ([WorldCupCandidateId]) REFERENCES [dbo].[WorldCupPromoCandidate] ([IdWorldCupPromoCandidate])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del candidato de la tabla WorldCupPromoCandidate.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount', @level2type = N'COLUMN', @level2name = N'WorldCupCandidateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la cuenta del usuario de la tabla Account.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount', @level2type = N'COLUMN', @level2name = N'IdWorldCupCandidateByAccount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para relacionar cuentas de usuario con candidatos del mundial de football.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupCandidateByAccount';

