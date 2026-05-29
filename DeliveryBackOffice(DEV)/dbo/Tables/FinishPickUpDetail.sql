CREATE TABLE [dbo].[FinishPickUpDetail] (
    [IdFinishPickUpDetail] BIGINT         IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [SchedulePickupId]     BIGINT         NULL,
    [GuideSerie]           NVARCHAR (2)   NOT NULL,
    [GuideNumber]          INT            NOT NULL,
    [GuidePiece]           INT            NULL,
    [RowStatus]            BIT            NULL,
    [TokenCreated]         NVARCHAR (200) NULL,
    [DateCreated]          DATETIME       DEFAULT (getdate()) NULL,
    [TokenUpdated]         NVARCHAR (200) NULL,
    [DateUpdated]          DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdFinishPickUpDetail] ASC),
    CONSTRAINT [FK_FinishPickUpDetail_Guides] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_PickupDetail_PickupHeader] FOREIGN KEY ([SchedulePickupId]) REFERENCES [dbo].[FinishPickUpHeader] ([SchedulePickupId])
);




GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de piezas de la guía de recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'GuidePiece';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía de recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del servicio de recolección relacionado a la tabla FinishPickUpHeader', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'SchedulePickupId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del detalle de recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail', @level2type = N'COLUMN', @level2name = N'IdFinishPickUpDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Detalle de tabla para guardar los registros del request para recolecciones SetFinishPickUp', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'FinishPickUpDetail';


GO
CREATE NONCLUSTERED INDEX [IDX_SchedulePickupId]
    ON [dbo].[FinishPickUpDetail]([SchedulePickupId] ASC);

