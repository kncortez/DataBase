CREATE TABLE [dbo].[APGuidesControl] (
    [IdAPGuidesControl]         BIGINT          IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [ReferenceNumber]           NVARCHAR(50)    NOT NULL,
    [TrackingCode]              NVARCHAR(50)    NOT NULL,
    [Phone]                     NVARCHAR(20)    NULL,
    [FirstName]                 NVARCHAR(100)   NOT NULL,
    [LastName]                  NVARCHAR(100)   NOT NULL,
    [City]                      NVARCHAR(100)   NOT NULL,   
    [Address]                   NVARCHAR(500)   NOT NULL,
    [AddressExtra]              NVARCHAR(500)   NULL,
    [CountryCode]               CHAR(2)         NOT NULL,
    [PostalCode]                NVARCHAR(20)    NULL,
    [DeliveryInstructions]      NVARCHAR(500)   NULL,
    [GuideCreatedDate]          DATETIME        NULL,
    [GuideSerie]                NVARCHAR (2)    NULL,
    [GuideNumber]               INT             NULL,
    [APServiceDate]             DATE            NOT NULL,
    [Status]                    NVARCHAR(10)    NOT NULL,
    [APExecutionScheduleId]   BIGINT          NOT NULL,
    [RowStatus]                 BIT             DEFAULT ((1)) NOT NULL,
    [TokenCreated]              NVARCHAR (50)   NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [TokenUpdated]              NVARCHAR (50)   NULL,
    [DateUpdated]               DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([IdAPGuidesControl] ASC),
    CONSTRAINT [FK_APGuidesControl_DeliveryOrder] FOREIGN KEY ([GuideSerie], [GuideNumber]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_APGuidesControl_APExecutionSchedule] FOREIGN KEY ([APExecutionScheduleId]) REFERENCES [dbo].[APExecutionSchedule] ([IdAPExecutionSchedule])
);

GO
CREATE NONCLUSTERED INDEX [IDX_APGuidesControl_TrackingCode]
    ON [dbo].[APGuidesControl]([TrackingCode] ASC);
GO
CREATE NONCLUSTERED INDEX [IDX_APGuidesControl_GuideCreatedDate]
    ON [dbo].[APGuidesControl]([GuideCreatedDate] ASC);  
GO
CREATE NONCLUSTERED INDEX [IDX_APGuidesControl_GuideSerie_GuideNumber] 
    ON [dbo].[APGuidesControl]([GuideSerie] ASC, [GuideNumber] ASC);

GO
CREATE NONCLUSTERED INDEX [IX_APGuidesControl_TrackingCode_CountryCode_APServiceDate] 
ON [dbo].[APGuidesControl] 
(
    [TrackingCode] ASC,
    [CountryCode] ASC,
    [APServiceDate] ASC
)
INCLUDE ([RowStatus])
WHERE [RowStatus] = 1;

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que almacena los servicios requeridos por Aeropost, lleva el control de las guías creadas en Hermes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'IdAPGuidesControl';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de referencia para Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'ReferenceNumber';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de tracking de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'TrackingCode';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Teléfono del destinatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Phone';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del destinatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'FirstName';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Apellido del destinatario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'LastName';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Ciudad de destino', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'City';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Dirección de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Address';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Información adicional de la dirección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'AddressExtra';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de país (ej: HN)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'CountryCode';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código postal', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'PostalCode';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Instrucciones especiales de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'DeliveryInstructions';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación de la guía en Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'GuideCreatedDate';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía (relacionada con DeliveryOrder)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'GuideSerie';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía (relacionada con DeliveryOrder)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'APServiceDate';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha del servicio de Aeropost', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Status';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si la guía fue creada en Hermes. (Pending, Processing, Processed,Failed)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'Status';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro (1=Activo, 0=Inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro en el sistema', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de última actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'APGuidesControl', @level2type = N'COLUMN', @level2name = N'DateUpdated';