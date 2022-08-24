CREATE TABLE [dbo].[DeliveryOrderAlert] (
    [IdDeliveryOrderAlert] INT            IDENTITY (1, 1) NOT NULL,
    [GuideSerie]           VARCHAR (2)    NULL,
    [GuideNumber]          INT            NULL,
    [AlertDescription]     NVARCHAR (200) NOT NULL,
    [AlertTypeId]          INT            NULL,
    [RowStatus]            BIT            NOT NULL,
    [TokenCreated]         NVARCHAR (50)  NOT NULL,
    [DateCreated]          DATETIME       NOT NULL,
    [TokenUpdated]         NVARCHAR (50)  NULL,
    [DateUpdated]          DATETIME       NULL,
    [ServiceTypeId]        BIGINT         NULL,
    CONSTRAINT [PK_DeliveryOrderAlert] PRIMARY KEY CLUSTERED ([IdDeliveryOrderAlert] ASC),
    CONSTRAINT [FK_DeliveryOrderAlert_SubTypeServiceManagment] FOREIGN KEY ([ServiceTypeId]) REFERENCES [dbo].[SubTypeServiceManagment] ([IdSubTypeServiceManagment]),
    CONSTRAINT [FK_DeliveryOrderAlert_TypeAlertId] FOREIGN KEY ([AlertTypeId]) REFERENCES [dbo].[CatTypeAlert] ([IdCatTypeAlert])
);








GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Notificaciónes de alertas de servicios/guías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifiacdor de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'IdDeliveryOrderAlert';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Numero de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la alerta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'AlertDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del tipo de alerta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'AlertTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderAlert', @level2type = N'COLUMN', @level2name = N'ServiceTypeId';


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220329-144352]
    ON [dbo].[DeliveryOrderAlert]([GuideSerie] ASC, [GuideNumber] ASC, [AlertTypeId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_GuideNumber_RowStatus_ServiceTypeId]
    ON [dbo].[DeliveryOrderAlert]([GuideNumber] ASC, [RowStatus] ASC, [ServiceTypeId] ASC);

