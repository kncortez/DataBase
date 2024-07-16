CREATE TABLE [dbo].[DeliveryOrderDetail] (
    [Guide_Serie]         NVARCHAR (2)   NOT NULL,
    [Guide_Number]        INT            NOT NULL,
    [StatusOrderId]       TINYINT        NOT NULL,
    [UserCreated]         NVARCHAR (50)  NOT NULL,
    [DateCreated]         DATETIME       NOT NULL,
    [DateCreatedInSystem] DATETIME       NULL,
    [Observations]        NVARCHAR (200) NULL,
    [Temperature_Celsius] DECIMAL (5, 2) NULL,
    [PieceId]             INT            NULL,
    [RowStatus]           BIT            DEFAULT ((1)) NOT NULL,
    [DeliveryAttemptId]   BIGINT         NULL,
    [SystemOrigin]        INT            NULL,
    CONSTRAINT [FK_DeliveryOrderDetail_DeliveryAttempt] FOREIGN KEY ([DeliveryAttemptId]) REFERENCES [dbo].[DeliveryAttempt] ([ID]),
    CONSTRAINT [FK_DeliveryOrderDetail_DeliveryOrder] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_DeliveryOrderDetail_StatusOrder] FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId]),
    CONSTRAINT [FK_DeliveryOrderDetail_SystemOrigin] FOREIGN KEY ([SystemOrigin]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])

);










GO
CREATE CLUSTERED INDEX [ClusteredIndex-GuideSerie-Number-Status]
    ON [dbo].[DeliveryOrderDetail]([Guide_Serie] ASC, [Guide_Number] ASC, [StatusOrderId] ASC);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-GuideSerie-Number]
    ON [dbo].[DeliveryOrderDetail]([Guide_Serie] ASC, [Guide_Number] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_deliveryorderdetail_statusorderid]
    ON [dbo].[DeliveryOrderDetail]([StatusOrderId] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_GuideandStatus]
    ON [dbo].[DeliveryOrderDetail]([Guide_Number] ASC, [StatusOrderId] ASC)
    INCLUDE([DateCreated]);


GO
CREATE NONCLUSTERED INDEX [IDX_GuideandStatusDate]
    ON [dbo].[DeliveryOrderDetail]([Guide_Number] ASC, [StatusOrderId] ASC, [DateCreated] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderDetail', @level2type = N'COLUMN', @level2name = N'Guide_Serie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderDetail', @level2type = N'COLUMN', @level2name = N'Guide_Number';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderDetail', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Reason for failure for checkpoints: 6. Return to the origin and 8. Return to forza', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderDetail', @level2type = N'COLUMN', @level2name = N'Observations';


GO
CREATE NONCLUSTERED INDEX [IX_DeliveryOrderDetailRLDReport]
    ON [dbo].[DeliveryOrderDetail]([Guide_Serie] ASC, [Guide_Number] ASC, [StatusOrderId] ASC, [DateCreated] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para validar el estado del registro 1 para activo 0 inactivo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del sistema de origen de la tabla CatSystem.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderDetail', @level2type = N'COLUMN', @level2name = N'SystemOrigin';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del intento de entrega de la tabla DelvieryAttempt.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderDetail', @level2type = N'COLUMN', @level2name = N'DeliveryAttemptId';


GO
CREATE NONCLUSTERED INDEX [IDX_DeliveryOrderDetail_QualityControl]
    ON [dbo].[DeliveryOrderDetail]([Guide_Serie] ASC, [Guide_Number] ASC, [StatusOrderId] ASC, [DateCreatedInSystem] ASC, [SystemOrigin] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_StatusOrderId_DateCreatedInSystem_INCLUDE]
    ON [dbo].[DeliveryOrderDetail]([DateCreatedInSystem] ASC, [StatusOrderId] ASC)
    INCLUDE([RowStatus]);

GO
CREATE NONCLUSTERED INDEX [IDX_DeliveryOrderDetail_QualityControl2]
    ON [dbo].[DeliveryOrderDetail]([SystemOrigin] ASC)
    INCLUDE([Guide_Serie],[Guide_Number]);

GO
CREATE NONCLUSTERED INDEX [idx_StatusOrderId_DateCreated]
	ON [dbo].[DeliveryOrderDetail] ([StatusOrderId],[DateCreated],[rowstatus])
	INCLUDE ([Guide_Serie],[Guide_Number],DateCreatedInSystem,SystemOrigin,DeliveryAttemptId,UserCreated);
