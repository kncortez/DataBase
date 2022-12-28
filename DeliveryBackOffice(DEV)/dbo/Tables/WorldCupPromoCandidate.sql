CREATE TABLE [dbo].[WorldCupPromoCandidate] (
    [IdWorldCupPromoCandidate] INT            IDENTITY (1, 1) NOT NULL,
    [WorldCupCandidateName]    NVARCHAR (100) NOT NULL,
    [WorldCupYear]             INT            NOT NULL,
    [RowStatus]                BIT            CONSTRAINT [DF__WorldCupP__RowSt__1ED04268] DEFAULT ((1)) NOT NULL,
    [TokenCreated]             NVARCHAR (50)  NOT NULL,
    [DateCreated]              DATETIME       NOT NULL,
    [TokenUpdated]             NVARCHAR (50)  NULL,
    [DateUpdated]              DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdWorldCupPromoCandidate] ASC),
    UNIQUE NONCLUSTERED ([WorldCupCandidateName] ASC, [WorldCupYear] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ültimo token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Año del mundial de football.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate', @level2type = N'COLUMN', @level2name = N'WorldCupYear';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del equipo candidato.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate', @level2type = N'COLUMN', @level2name = N'WorldCupCandidateName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate', @level2type = N'COLUMN', @level2name = N'IdWorldCupPromoCandidate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de equipos candidatos para el mundial de football para un año.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'WorldCupPromoCandidate';

