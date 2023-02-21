CREATE TABLE [dbo].[AccountServiceCartDetail] (
    [IdAccountServiceCartDetail] INT           IDENTITY (1, 1) NOT NULL,
    [AccountServiceCartId]       INT           NOT NULL,
    [GuideSerie]                 NVARCHAR (2)  NOT NULL,
    [GuideNumber]                INT           NOT NULL,
    [RowStatus]                  BIT           CONSTRAINT [DF__AccountSe__RowSt__33EA8F88] DEFAULT ((1)) NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    [DateUpdated]                DATETIME      NULL,
    CONSTRAINT [PK__AccountS__5DD5CB1397D28F1C] PRIMARY KEY CLUSTERED ([IdAccountServiceCartDetail] ASC),
    CONSTRAINT [FK_AccountServiceCartDetail_AccountServiceCart] FOREIGN KEY ([AccountServiceCartId]) REFERENCES [dbo].[AccountServiceCart] ([IdAccountServiceCart]),
    CONSTRAINT [FK_AccountServiceCartDetail_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del carrito de la tabla AccountServiceCart.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'AccountServiceCartId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail', @level2type = N'COLUMN', @level2name = N'IdAccountServiceCartDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de detalle de carrito de compras de guías.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AccountServiceCartDetail';


GO
CREATE NONCLUSTERED INDEX [IDX_RowStatus_INCLUDED]
    ON [dbo].[AccountServiceCartDetail]([RowStatus] ASC)
    INCLUDE([IdAccountServiceCartDetail], [GuideSerie], [GuideNumber]);


GO
CREATE NONCLUSTERED INDEX [IX_AccountServiceCartDetail_Guide]
    ON [dbo].[AccountServiceCartDetail]([GuideSerie] ASC, [GuideNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_AccountServiceCartId_RowStatus]
    ON [dbo].[AccountServiceCartDetail]([AccountServiceCartId] ASC, [RowStatus] ASC);

