CREATE TABLE [dbo].[ProcessedGuideBatch] (
    [IdProcessedGuideBatch]  INT          IDENTITY (1, 1) NOT NULL,
    [GuideSerie]             NVARCHAR (2) NOT NULL,
    [GuideNumber]            INT          NOT NULL,
    [CourierManId]           INT          NULL,
    [Date]                   DATETIME     CONSTRAINT [DF_ProcessedGuideBatch_Date] DEFAULT (getdate()) NOT NULL,
    [BatchId]                INT          NULL,
    [CatBatchId]             INT          NULL,
    [DataOriginId]           INT          NOT NULL,
    [Notificated]            BIT          CONSTRAINT [DF_ProcessedGuideBatch_Notificated] DEFAULT ('FALSE') NOT NULL,
    [Token]                  VARCHAR (50) NOT NULL,
    [BatchNotified]          BIT          NULL,
    [DeliveryReportNotified] BIT          NULL,
    [DateUpdated]            DATETIME     NULL,
    [TokenUpdated]           VARCHAR (50) NULL,
    [RowStatus]              BIT          CONSTRAINT [DF_ProcessedGuideBatch_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [CustomerId]             INT          NULL,
    CONSTRAINT [PK_ProcessedGuideBatch_ProcessedGuideBatch] PRIMARY KEY CLUSTERED ([IdProcessedGuideBatch] ASC),
    CONSTRAINT [FK_ProcessedGuideBatch_CatBatchId] FOREIGN KEY ([CatBatchId]) REFERENCES [dbo].[CatBatch] ([IdCatBatch]),
    CONSTRAINT [FK_ProcessedGuideBatch_CatModule] FOREIGN KEY ([DataOriginId]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FK_ProcessedGuideBatch_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_ProcessedGuideBatch_SenderReceiver] FOREIGN KEY ([CourierManId]) REFERENCES [dbo].[SenderReceiver] ([ID])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificación de la guía procesada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'IdProcessedGuideBatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del Courierman', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'CourierManId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha en la que se recaudó la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'Date';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del lote en el que se procesó el registro ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'BatchId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifica el tipo de lote', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'CatBatchId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del módulo de origen en dónde se crea el registro de la guía en esta tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'DataOriginId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para saber si ya se realizó la notificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'Notificated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de la persona que crea el registro en esta tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'Token';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag para poder saber cuando el correo de lote fue enviado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'BatchNotified';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flag para poder saber cuando el correo de pago al cliente fue enviado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'DeliveryReportNotified';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro en base de datos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del Cliente al que le pertenece la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ProcessedGuideBatch', @level2type = N'COLUMN', @level2name = N'CustomerId';

