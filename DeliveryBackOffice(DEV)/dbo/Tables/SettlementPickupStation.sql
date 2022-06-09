CREATE TABLE [dbo].[SettlementPickupStation] (
    [IdSettlementPickupStation] BIGINT        IDENTITY (1, 1) NOT NULL,
    [CouriermanId]              VARCHAR (50)  NULL,
    [RouteId]                   VARCHAR (250) NOT NULL,
    [TransactionDate]           DATE          NOT NULL,
    [RowStatus]                 BIT           NOT NULL,
    [TokenCreated]              VARCHAR (50)  NOT NULL,
    [DateCreated]               DATETIME      NOT NULL,
    [TokenUpdated]              VARCHAR (50)  NULL,
    [DateUpdated]               DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdSettlementPickupStation] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Manifiesto de recolección asociado a cada courier.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único de manifiesto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'IdSettlementPickupStation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Couierman relacionado al manifiesto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'CouriermanId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de ruta del manifiesto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'RouteId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha del despacho.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'TransactionDate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si el registro está vigente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'SettlementPickupStation', @level2type = N'COLUMN', @level2name = N'DateUpdated';

