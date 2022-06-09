CREATE TABLE [dbo].[ServiceBatchDetail] (
    [IdServiceBatchDetail] INT           IDENTITY (1, 1) NOT NULL,
    [ServiceBatchId]       INT           NOT NULL,
    [GuideSerie]           NVARCHAR (2)  NOT NULL,
    [GuideNumber]          INT           NOT NULL,
    [PieceNumber]          INT           NULL,
    [RowStatus]            BIT           NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    [DateUpdated]          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdServiceBatchDetail] ASC),
    CONSTRAINT [FK_ServiceBatchDetail_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_ServiceBatchDetail_ServiceBatch] FOREIGN KEY ([ServiceBatchId]) REFERENCES [dbo].[ServiceBatch] ([IdServiceBatch])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'IdServiceBatchDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del lote de servicio al que esta relacionado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'ServiceBatchId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guia a la que pertenece', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guia a la que pertenece', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de pieza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'PieceNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceBatchDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';

