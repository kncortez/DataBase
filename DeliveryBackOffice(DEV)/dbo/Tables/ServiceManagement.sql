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
    [PuSignaturePath]           NVARCHAR (150)  NULL,
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

