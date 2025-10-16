CREATE TABLE [dbo].[InvoiceBatchHeader] (
    [Id_Lote]                        INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RTN]                            NVARCHAR (50)  NOT NULL,
    [NoDeclaracion]                  NVARCHAR (50)  NOT NULL,
    [CAI]                            NVARCHAR (50)  NOT NULL,
    [LimitDateEmision]               DATETIME       NOT NULL,
    [Emision_Point]                  INT            NULL,
    [Establishment]                  INT            NULL,
    [TypeDocument]                   INT            NOT NULL,
    [RecepcionDate]                  DATETIME       NULL,
    [Administration_Code]            INT            NOT NULL,
    [Status]                         BIT            NOT NULL,
    [Enable]                         BIT            NULL,
    [InitialRange]                   BIGINT         NOT NULL,
    [FinalRange]                     BIGINT         NOT NULL,
    [Last_Process]                   BIGINT         NOT NULL,
    [AmountGranted]                  BIGINT         NULL,
    [EmailNotification]              NVARCHAR (50)  NULL,
    [DaysLeftNotifycation]           INT            NULL,
    [PercentInvoiceLeftNotifycation] INT            NULL,
    [RowStatus]                      BIT            NOT NULL,
    [TokenCreated]                   NVARCHAR (50)  NOT NULL,
    [DateCreated]                    DATETIME       NOT NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL,
    [AmountRequested]                BIGINT         NULL,
    [companyName]                    NVARCHAR (300) NULL,
    CONSTRAINT [PK_InvoiceLoteHeader] PRIMARY KEY CLUSTERED ([Id_Lote] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Porcentaje procesado para notificar que esta llegano al límite', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'PercentInvoiceLeftNotifycation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Días faltantes para llegar al límite y notificar', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'DaysLeftNotifycation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Cantidad de documentos asignados', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'AmountGranted';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última factura procesada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'Last_Process';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si el lote esta concluido o no', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'Enable';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última factura procesada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'Status';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última factura procesada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'Administration_Code';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica el tipo de doumento: factura, nota de credito, rentencion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'TypeDocument';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Establecimiento que emite la facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'Establishment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Punto de emisión sobre el establecimiento que emite la facturación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'Emision_Point';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de identificación del lote proporcionado por el SAR', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'CAI';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Equivalente a NIT, aplica para Honduras', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader', @level2type = N'COLUMN', @level2name = N'RTN';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Manejo de lotes solicitados a Entidad Fiscal Correspondiente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'InvoiceBatchHeader';

