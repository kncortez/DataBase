CREATE TABLE [dbo].[SettlementMapping] (
    [IdSettlementMapping]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SettlementForzaId]     BIGINT        NOT NULL,
    [SettlementUEId]        BIGINT        NOT NULL,
    [RowStatus]             BIT           NOT NULL,
    [TokenCreated]          NVARCHAR (50) NOT NULL,
    [DateCreated]           DATETIME      NOT NULL,
    [TokenUpdated]          NVARCHAR (50) NULL,
    [DateUpdated]           DATETIME      NULL,
    CONSTRAINT [PK_SettlementMapping] PRIMARY KEY CLUSTERED ([IdSettlementMapping] ASC),
    CONSTRAINT [FK_SettlementMapping_Settlement] FOREIGN KEY ([SettlementForzaId]) REFERENCES [dbo].[Settlement] ([IdSettlement])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del mapeo de los poblados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementMapping', @level2type = N'COLUMN', @level2name = N'IdSettlementMapping';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Poblado de Forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementMapping', @level2type = N'COLUMN', @level2name = N'SettlementForzaId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Poblado de Ultra Entregas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementMapping', @level2type = N'COLUMN', @level2name = N'SettlementUEId';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el registro está vigente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementMapping', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementMapping', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementMapping', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementMapping', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementMapping', @level2type = N'COLUMN', @level2name = N'DateUpdated';
