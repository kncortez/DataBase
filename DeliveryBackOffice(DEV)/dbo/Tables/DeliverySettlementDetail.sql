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
    [GuideOrder]                     DECIMAL (5, 2)  NULL,
    [RowStatus]                      BIT             CONSTRAINT [df_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]                   NVARCHAR (50)   NULL,
    [DateCreated]                    DATETIME        NULL,
    [TokenUpdated]                   NVARCHAR (50)   NULL,
    [DateUpdated]                    DATETIME        NULL,
    [GuideETA]                       TIME (7)        NULL,
    CONSTRAINT [PK_DeliverySettlementDetail] PRIMARY KEY CLUSTERED ([ID] ASC),
    CONSTRAINT [FK_DeliverySettlementDetail_DeliveryOrder] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_DeliverySettlementDetail_DeliveryOrderBySettlement] FOREIGN KEY ([ID_DeliveryOrderBySettlement]) REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID])
	
	CREATE NONCLUSTERED INDEX [idx_Guide_Settlement_RowStatus] ON [dbo].[DeliverySettlementDetail] ([Guide_Serie],[Guide_Number],[Guide_Settlement],[RowStatus]) INCLUDE ([DateCreated],[ID_DeliveryORderBYSettlement])

);














GO
CREATE NONCLUSTERED INDEX [IDX_PBI_SETTLEMENT]
    ON [dbo].[DeliverySettlementDetail]([Guide_Serie] ASC, [Guide_Number] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden o secuencia a realizar el servicio (si se le es asigando)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'GuideOrder';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de actualización de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora de creación de la fila', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
CREATE NONCLUSTERED INDEX [idx_ID_DeliveryOrderBySettlement_Guide_Settlement_Guide_Discharged_RowStatus]
    ON [dbo].[DeliverySettlementDetail]([ID_DeliveryOrderBySettlement] ASC, [Guide_Settlement] ASC, [Guide_Discharged] ASC, [RowStatus] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token quien realizo la liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'SettlementCollect_TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha cuando se realizo la liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'SettlementCollect_DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto de COD de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'Settlement_Collect_OnDelivery';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del manifiesto de la tabla DeliveryOrderBySettlement.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'ID_DeliveryOrderBySettlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'ID';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token quien realizo la liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'GuideDischarged_TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha cuando se realizo la liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'GuideDischarged_DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía paso por liquidación de paquetes.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'Guide_Settlement';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'Guide_Serie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía fue marcada como retorno a Forza.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'Guide_Returned';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía de la tabla DeliveryOrder.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'Guide_Number';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía paso por liquidación de COD.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'Guide_Discharged';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía fue entregada exitosamente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'Guide_Delivered';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora posible de arribo al servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliverySettlementDetail', @level2type = N'COLUMN', @level2name = N'GuideETA';


GO
CREATE NONCLUSTERED INDEX [IDX_Guide_Number]
    ON [dbo].[DeliverySettlementDetail]([Guide_Number] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_ID_DeliveryOrderBySettlement_RowStatus_include]
    ON [dbo].[DeliverySettlementDetail]([ID_DeliveryOrderBySettlement] ASC, [RowStatus] ASC)
    INCLUDE([Guide_Serie], [Guide_Number], [DateCreated]);

CREATE NONCLUSTERED INDEX [idx_ID_DeliverySettlementDetail_DateCreated]
    ON [dbo].[DeliverySettlementDetail]([DateCreated] ASC);

