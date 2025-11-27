CREATE TABLE [dbo].[ShippingContainerDetail] (
    [IdContainerDetail] BIGINT         IDENTITY (1, 1) NOT NULL,
    [IdContainer]       BIGINT         NOT NULL,
    [GuideSerie]        NVARCHAR (2)   NOT NULL,
    [GuideNumber]       INT            NOT NULL,
    [TicketNumber]      NVARCHAR (150) NULL,
    [RowStatus]         BIT            DEFAULT ((1)) NOT NULL,
    [UserCreated]       NVARCHAR (50)  NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenCreated]      NVARCHAR (50)  NOT NULL,
    [UserUpdated]       NVARCHAR (50)  NULL,
    [DateUpdated]       DATETIME       NULL,
    [TokenUpdated]      NVARCHAR (50)  NULL,
    CONSTRAINT [PK_ShippingContainerDetail] PRIMARY KEY CLUSTERED ([IdContainerDetail] ASC),
    CONSTRAINT [FK_ShippingContainerDetail_Container] FOREIGN KEY ([IdContainer]) REFERENCES [dbo].[ShippingContainer] ([IdContainer]),
    CONSTRAINT [FK_ShippingContainerDetail_Guide] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);


GO
CREATE NONCLUSTERED INDEX [IDX_ShippingContainerDetail_GuideNumber_GuideSerie]
    ON [dbo].[ShippingContainerDetail]([GuideNumber] ASC, [GuideSerie] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que realizó la actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'UserUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que realizó la creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'UserCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía de la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía de la tabla DeliveryOrder', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'IdContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del detalle del contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ShippingContainerDetail', @level2type = N'COLUMN', @level2name = N'IdContainerDetail';

