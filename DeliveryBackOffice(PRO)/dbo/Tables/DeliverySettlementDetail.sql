CREATE TABLE [dbo].[DeliverySettlementDetail] (
    [ID]                             INT             IDENTITY (1, 1) NOT NULL,
    [ID_DeliveryOrderBySettlement]   BIGINT          NOT NULL,
    [Guide_Serie]                    NVARCHAR (2)    NOT NULL,
    [Guide_Number]                   INT             NOT NULL,
    [Settlement_Collect_OnDelivery]  DECIMAL (14, 2) NULL,
    [Guide_Settlement]               BIT             NULL,
    [Guide_Discharged]               BIT             NULL,
    [SettlementCollect_TokenCreated] NVARCHAR (50)   NULL,
    [SettlementCollect_DateCreated]  DATETIME        NULL,
    [GuideDischarged_TokenCreated]   NVARCHAR (50)   NULL,
    [GuideDischarged_DateCreated]    DATETIME        NULL,
    [Guide_Returned]                 BIT             NULL,
    [Guide_Delivered]                BIT             NULL,
    [GuideOrder]                     INT             NULL,
    [RowStatus]                      BIT             CONSTRAINT [df_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]                   NVARCHAR (50)   NULL,
    [DateCreated]                    DATETIME        NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    CONSTRAINT [FK_DeliverySettlementDetail_DeliveryOrder] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_DeliverySettlementDetail_DeliveryOrderBySettlement] FOREIGN KEY ([ID_DeliveryOrderBySettlement]) REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID])
);




GO
CREATE NONCLUSTERED INDEX [IDX_PBI_SETTLEMENT]
    ON [dbo].[DeliverySettlementDetail]([Guide_Serie] ASC, [Guide_Number] ASC);


GO
CREATE NONCLUSTERED INDEX [ID]
    ON [dbo].[DeliverySettlementDetail]([ID] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden o secuencia a realizar el servicio (si se le es asigando)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'GuideOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de actualización de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
CREATE NONCLUSTERED INDEX [idx_ID_DeliveryOrderBySettlement_Guide_Settlement_Guide_Discharged_RowStatus]
    ON [dbo].[DeliverySettlementDetail]([ID_DeliveryOrderBySettlement] ASC, [Guide_Settlement] ASC, [Guide_Discharged] ASC, [RowStatus] ASC);

