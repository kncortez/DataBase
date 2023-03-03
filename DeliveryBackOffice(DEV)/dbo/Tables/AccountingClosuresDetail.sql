CREATE TABLE [dbo].[AccountingClosuresDetail] (
    [IdAccountingClosuresDetail] INT            IDENTITY (1, 1) NOT NULL,
    [AccountingClosuresHeaderId] INT            NOT NULL,
    [GuideSerie]                 NVARCHAR (2)   NULL,
    [GuideNumber]                INT            NULL,
    [RowStatus]                  BIT            NOT NULL,
    [TokenCreated]               NVARCHAR (50)  NOT NULL,
    [DateCreated]                DATETIME       NOT NULL,
    [TokenUpdated]               NVARCHAR (50)  NULL,
    [DateUpdated]                DATETIME       NULL,
    [Fel]                        NVARCHAR (MAX) NULL,
    [DopId]                      BIGINT         CONSTRAINT [ACD_DopId] DEFAULT (NULL) NULL,
    CONSTRAINT [PK_AccountingClosuresDetail] PRIMARY KEY CLUSTERED ([IdAccountingClosuresDetail] ASC),
    FOREIGN KEY ([DopId]) REFERENCES [dbo].[DeliveryOrderPaymentTransaction] ([DopId]),
    CONSTRAINT [FK_AccountingClosuresDetail_AccountingClosuresHeader] FOREIGN KEY ([AccountingClosuresHeaderId]) REFERENCES [dbo].[AccountingClosuresHeader] ([IdAccountingClosuresHeader]),
    CONSTRAINT [FK_AccountingClosuresDetail_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'IdAccountingClosuresDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del lote de cierre', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'AccountingClosuresHeaderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de modificación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de factura de la transacción para los servicios sin guías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'Fel';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la transacción que registra el pago de una guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountingClosuresDetail', @level2type = N'COLUMN', @level2name = N'DopId';




GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus]
    ON [dbo].[AccountingClosuresDetail]([RowStatus] ASC)
    INCLUDE([GuideSerie], [GuideNumber], [DopId]);


GO
CREATE NONCLUSTERED INDEX [idx_GuideSerie_GuideNumber_RowStatus_DopId]
    ON [dbo].[AccountingClosuresDetail]([GuideSerie] ASC, [GuideNumber] ASC, [RowStatus] ASC, [DopId] ASC);

