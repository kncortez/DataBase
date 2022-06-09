CREATE TABLE [dbo].[ProcessedGuideCOD] (
    [IdProcessedGuideCOD]    INT          IDENTITY (1, 1) NOT NULL,
    [GuideSerie]             NVARCHAR (2) NOT NULL,
    [GuideNumber]            INT          NOT NULL,
    [CourierManId]           INT          NULL,
    [Date]                   DATETIME     CONSTRAINT [DF_ProcessedGuideCOD_Date] DEFAULT (getdate()) NOT NULL,
    [BatchCODId]             INT          NULL,
    [BatchCODIdCommission]   INT          NULL,
    [DataOriginId]           INT          NOT NULL,
    [Notificated]            BIT          CONSTRAINT [DF_ProcessedGuideCOD_Notificated] DEFAULT ('FALSE') NOT NULL,
    [Token]                  VARCHAR (50) NOT NULL,
    [BatchNotified]          BIT          NULL,
    [DeliveryReportNotified] BIT          NULL,
    [DateUpdated]            DATETIME     NULL,
    [TokenUpdated]           VARCHAR (50) NULL,
    [RowStatus]              BIT          CONSTRAINT [DF_ProcessedGuideCOD_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [CustomerId]             INT          NULL,
    [RecolectionBatchId]     BIGINT       NULL,
    [CollectBatchId]         BIGINT       NULL,
    [CollectBatch]           BIT          NULL,
    [RecolectionBatch]       BIT          NULL,
    [CODBatch]               BIT          NULL,
    CONSTRAINT [PK_ProcessedGuideCOD_IdProcessedGuideCOD] PRIMARY KEY CLUSTERED ([IdProcessedGuideCOD] ASC),
    CONSTRAINT [FK_ProcessedGuideCOD_BatchCOD] FOREIGN KEY ([BatchCODId]) REFERENCES [dbo].[BatchCOD] ([IdBatchCOD]),
    CONSTRAINT [FK_ProcessedGuideCOD_BatchCOD_BatchCODIdCommission] FOREIGN KEY ([BatchCODIdCommission]) REFERENCES [dbo].[BatchCOD] ([IdBatchCOD]),
    CONSTRAINT [FK_ProcessedGuideCOD_CatModule] FOREIGN KEY ([DataOriginId]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_ProcessedGuideCOD_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_ProcessedGuideCOD_SenderReceiver] FOREIGN KEY ([CourierManId]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [UK_SERIE_GUIA] UNIQUE NONCLUSTERED ([GuideSerie] ASC, [GuideNumber] ASC)
);


GO
CREATE NONCLUSTERED INDEX [idx_Notificated_BatchCODId]
    ON [dbo].[ProcessedGuideCOD]([Notificated] ASC, [BatchCODId] ASC)
    INCLUDE([GuideSerie], [GuideNumber]);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag para poder saber cuando el correo de lote fue enviado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideCOD', @level2type = N'COLUMN', @level2name = N'BatchNotified';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag para poder saber cuando el correo con el reporte de depósito fue enviado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideCOD', @level2type = N'COLUMN', @level2name = N'DeliveryReportNotified';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del Cliente al que le pertenece la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideCOD', @level2type = N'COLUMN', @level2name = N'CustomerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'En esta columna se asigna el ID de lote que pertenece al proceso de Recolección ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideCOD', @level2type = N'COLUMN', @level2name = N'RecolectionBatchId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'En esta columna se asigna el ID de lote que pertenece al proceso de  Collect ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideCOD', @level2type = N'COLUMN', @level2name = N'CollectBatchId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica los lotes que son de COLLECT', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideCOD', @level2type = N'COLUMN', @level2name = N'CollectBatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica los lotes que son de pagos en Recolección ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideCOD', @level2type = N'COLUMN', @level2name = N'RecolectionBatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica los lotes que son de pagos de COD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideCOD', @level2type = N'COLUMN', @level2name = N'CODBatch';

