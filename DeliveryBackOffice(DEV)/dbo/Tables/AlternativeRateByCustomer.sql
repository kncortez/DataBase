CREATE TABLE [dbo].[AlternativeRateByCustomer] (
    [IdAlternativeRatebyCustomer] BIGINT       IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RateId]                      INT          NOT NULL,
    [CustomerId]                  INT          NOT NULL,
    [VisitPointClientId]          INT          NULL,
    [RowStatus]                   BIT          NOT NULL,
    [TokenCreated]                VARCHAR (50) NOT NULL,
    [DateCreated]                 DATETIME     NOT NULL,
    [TokenUpdated]                VARCHAR (50) NULL,
    [DateUpdated]                 DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdAlternativeRatebyCustomer] ASC),
    CONSTRAINT [FK_AlternativeRates_Customer] FOREIGN KEY ([CustomerId]) REFERENCES [dbo].[Customer] ([IdCustomer]),
    CONSTRAINT [FK_AlternativeRates_Rate] FOREIGN KEY ([RateId]) REFERENCES [dbo].[RateHeader] ([RheId]),
    CONSTRAINT [FK_AlternativeRates_VPC] FOREIGN KEY ([VisitPointClientId]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para vincular tarifario con un punto de visita.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'VisitPointClientId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del cliente de la tabla Customer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tarifario de la tabla RateHeader.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'RateId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer', @level2type = N'COLUMN', @level2name = N'IdAlternativeRatebyCustomer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de tarifas alternativas por cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AlternativeRateByCustomer';


GO
CREATE NONCLUSTERED INDEX [idx_VisitPointClientId_RowStatus]
    ON [dbo].[AlternativeRateByCustomer]([VisitPointClientId] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_CustomerId_VisitPointClientId_RowStatus]
    ON [dbo].[AlternativeRateByCustomer]([CustomerId] ASC, [VisitPointClientId] ASC, [RowStatus] ASC);

