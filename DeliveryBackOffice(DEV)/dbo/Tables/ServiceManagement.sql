CREATE TABLE [dbo].[ServiceManagement] (
    [IdServiceManagement]       INT             IDENTITY (1, 1) NOT NULL,
    [IdPuCourrier]              INT             NULL,
    [IdDlCourrier]              INT             NULL,
    [CiPuDate]                  DATETIME        NULL,
    [CoPuDate]                  DATETIME        NULL,
    [CiDlDate]                  DATE            NULL,
    [CoDlDate]                  DATE            NULL,
    [IdPuRouteAssigment]        INT             NULL,
    [IdDlRouteAssigment]        INT             NULL,
    [IdSchedulePickup]          BIGINT          NULL,
    [IdProofOnDelivery]         INT             NULL,
    [RowStatus]                 BIT             NOT NULL,
    [TokenCreated]              VARCHAR (50)    NOT NULL,
    [DateCreated]               DATETIME        NOT NULL,
    [TokenUpdated]              VARCHAR (50)    NULL,
    [DateUpdated]               DATETIME        NULL,
    [ServiceStatusId]           INT             NULL,
    [PuSignaturePath]           NVARCHAR (500)  NULL,
    [DiSignaturePath]           NVARCHAR (150)  NULL,
    [SubTypeServiceManagmentId] INT             NULL,
    [IdHubDestination]          INT             NULL,
    [Order]                     SMALLINT        DEFAULT ((1)) NOT NULL,
    [Amount]                    DECIMAL (16, 2) NULL,
    [CatPaymentTimeId]          INT             NULL,
    [IsActiveService]           BIT             NULL,
    PRIMARY KEY CLUSTERED ([IdServiceManagement] ASC),
    CONSTRAINT [FK_ServiceManagement_CatPaymentTimeId] FOREIGN KEY ([CatPaymentTimeId]) REFERENCES [dbo].[CatPaymentTime] ([TimePlaId]),
    CONSTRAINT [fk_ServiceStatus] FOREIGN KEY ([ServiceStatusId]) REFERENCES [dbo].[CatServiceStatus] ([IdServiceStatus]),
    CONSTRAINT [FKService_CurrierIn] FOREIGN KEY ([IdPuCourrier]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FKService_CurrierOut] FOREIGN KEY ([IdDlCourrier]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FKService_Pickup] FOREIGN KEY ([IdSchedulePickup]) REFERENCES [dbo].[SchedulePickup] ([SchedulePickupId]),
    CONSTRAINT [FKService_Proof] FOREIGN KEY ([IdProofOnDelivery]) REFERENCES [dbo].[DeliveryProof] ([ID]),
    CONSTRAINT [FKService_RouteIn] FOREIGN KEY ([IdPuRouteAssigment]) REFERENCES [dbo].[RouteAssigment] ([IdRouteAssigment]),
    CONSTRAINT [FKService_RoutOut] FOREIGN KEY ([IdDlRouteAssigment]) REFERENCES [dbo].[RouteAssigment] ([IdRouteAssigment])
);










GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total de un servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagement', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tiempo de pago del servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagement', @level2type = N'COLUMN', @level2name = N'CatPaymentTimeId';


GO
CREATE NONCLUSTERED INDEX [IDX_SubTypeServiceManagmentId]
    ON [dbo].[ServiceManagement]([SubTypeServiceManagmentId] ASC)
    INCLUDE([ServiceStatusId]);


GO
CREATE NONCLUSTERED INDEX [idx_idpurrouteassigment]
    ON [dbo].[ServiceManagement]([IdPuRouteAssigment] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para ordenar el reporte de preparación de ruta.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagement', @level2type = N'COLUMN', @level2name = N'Order';


GO
CREATE NONCLUSTERED INDEX [idx_IdSchedulePickup]
    ON [dbo].[ServiceManagement]([IdSchedulePickup] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si el servicio esta siendo realizado por el courier asignado actualmente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ServiceManagement', @level2type = N'COLUMN', @level2name = N'IsActiveService';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'IdServiceManagement'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id courier entrante(Referencia a tabla SenderReceiver)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'IdPuCourrier'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id courier saliente(Referencia a tabla SenderReceiver)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'IdDlCourrier'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de llegada del courier entrante',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'CiPuDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de salida del courier entrante',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'CoPuDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de llegada de courier saliente',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'CiDlDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de salida de courier saliente',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'CoDlDate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de la ruta entrante asignada(Referencia tabla RouteAssigment)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'IdPuRouteAssigment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de ruta asignada saliente asignada (Referencia tabla RouteAssigment)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'IdDlRouteAssigment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de la recogida programada(Referencia tabla SchedulePickup)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'IdSchedulePickup'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del comprobante de entrega(Referencia tabla DeliveryProof)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'IdProofOnDelivery'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de Creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado del servicio(Referencia tabla CatServiceStatus)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'ServiceStatusId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ruta de firma de courier entrante',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'PuSignaturePath'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ruta de firma de courier saliente',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'DiSignaturePath'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Subtipo de servicio(Referencia a SubTypeServiceManagment)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'SubTypeServiceManagmentId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id hub destino',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = N'COLUMN',
    @level2name = N'IdHubDestination'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tabla de informacion de servicios realizados',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'ServiceManagement',
    @level2type = NULL,
    @level2name = NULL