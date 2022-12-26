CREATE TABLE [dbo].[RoutePreparationDetail] (
    [IdRoutePreparationDetail]  INT            IDENTITY (1, 1) NOT NULL,
    [RoutePreparationId]        INT            NOT NULL,
    [Guide_Serie]               NVARCHAR (2)   NOT NULL,
    [Guide_Number]              INT            NOT NULL,
    [RowStatus]                 BIT            CONSTRAINT [df_RoutePreparationDetail_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]              NVARCHAR (50)  NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenUpdated]              NVARCHAR (50)  NULL,
    [DateUpdated]               DATETIME       NULL,
    [GuideOrder]                DECIMAL (5, 2) NULL,
    [ETAGuide]                  TIME (7)       NULL,
    [UserProcess]               NVARCHAR (50)  NULL,
    [IsOpenProcess]             BIT            CONSTRAINT [DF_RoutePreparationDetail_IsOpenProcess] DEFAULT ((0)) NOT NULL,
    [ServiceManagementDetailId] BIGINT         NULL,
    [IsCustomerReschedule]      BIT            CONSTRAINT [DF_RoutePreparationDetail_IsCustomerReschedule] DEFAULT ((0)) NULL,
    CONSTRAINT [PK_RoutePreparationDetail_IdRoutePreparationDetail] PRIMARY KEY CLUSTERED ([IdRoutePreparationDetail] ASC),
    CONSTRAINT [FK_RoutePreparationDetail_DeliveryOrder] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number]),
    CONSTRAINT [FK_RoutePreparationDetail_RoutePreparationId] FOREIGN KEY ([RoutePreparationId]) REFERENCES [dbo].[RoutePreparation] ([IdRoutePreparation]),
    CONSTRAINT [FK_RoutePreparationDetail_ServiceManagementDetail] FOREIGN KEY ([ServiceManagementDetailId]) REFERENCES [dbo].[ServiceManagementDetail] ([IdServiceManagementDetail])
);






GO
CREATE NONCLUSTERED INDEX [idx_Guide_Serie_Guide_Number_RowStatus]
    ON [dbo].[RoutePreparationDetail]([Guide_Serie] ASC, [Guide_Number] ASC, [RowStatus] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX__Guide_Serie_Guide_Number_RowStatus]
    ON [dbo].[RoutePreparationDetail]([Guide_Serie] ASC, [Guide_Number] ASC, [RowStatus] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar el detalle de guías de la preparación de entregas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla IdRoutePreparationDetail.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'IdRoutePreparationDetail';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la tabla RoutePreparation.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'RoutePreparationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'Guide_Serie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de la guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'Guide_Number';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado de la fila, TRUE o FALSE.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que creó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token que modificó la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha y hora en la que se creo la fila.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Orden a realizar el servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'GuideOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora estimada de arribo al servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'ETAGuide';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que inició un proceso abierto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'UserProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id que víncula el detalle con un Servicio, Foránea ServiceManagementDetail', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'ServiceManagementDetailId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bandera para saber si la guía está en un proceso abierto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'IsOpenProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la guía fue reprogramada por el cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RoutePreparationDetail', @level2type = N'COLUMN', @level2name = N'IsCustomerReschedule';

