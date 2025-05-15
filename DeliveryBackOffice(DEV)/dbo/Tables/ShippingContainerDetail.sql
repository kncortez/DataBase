CREATE TABLE [ShippingContainerDetail] (
    IdContainerDetail       BIGINT IDENTITY(1,1) NOT NULL,
    IdContainer             BIGINT NOT NULL,
    GuideSerie              NVARCHAR(2) NOT NULL,
    GuideNumber             INT NOT NULL,
    TicketNumber            NVARCHAR(150) NULL,
    RowStatus               BIT NOT NULL DEFAULT 1,
    UserCreated             NVARCHAR(50) NOT NULL,
    DateCreated             DATETIME NOT NULL,
    TokenCreated            NVARCHAR(50) NOT NULL,
    UserUpdated             NVARCHAR(50) NULL,
    DateUpdated             DATETIME NULL,
    TokenUpdated            NVARCHAR(50) NULL,
    CONSTRAINT [PK_ShippingContainerDetail] PRIMARY KEY CLUSTERED ([IdContainerDetail] ASC),
    CONSTRAINT FK_ShippingContainerDetail_Container FOREIGN KEY (IdContainer) REFERENCES [dbo].[ShippingContainer] (IdContainer),
    CONSTRAINT FK_ShippingContainerDetail_Guide FOREIGN KEY (GuideSerie, GuideNumber) REFERENCES [dbo].[DeliveryOrder] (Guide_Serie, Guide_Number)
);

CREATE NONCLUSTERED INDEX [IDX_ShippingContainerDetail_GuideNumber_GuideSerie]
    ON [dbo].[ShippingContainerDetail]([GuideNumber] ASC, [GuideSerie] ASC);
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del detalle del contenedor', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'IdContainerDetail'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del contenedor', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'IdContainer'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Serie de la guía de la tabla DeliveryOrder', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'GuideSerie'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Número de la guía de la tabla DeliveryOrder', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'GuideNumber'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'RowStatus'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'UserCreated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'DateCreated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'TokenCreated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'UserUpdated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'DateUpdated'
GO

EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'ShippingContainerDetail', N'COLUMN', N'TokenUpdated'
GO