CREATE TABLE [dbo].[ConfigWarehouseByRouteAssignment] (
    [IdConfigWarehouseByRouteAssignment] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [RouteAssignmentId]                  INT           NOT NULL,
    [WarehouseLocation]                  NVARCHAR (30) NOT NULL,
    [WarehouseLocationServiceType]       NVARCHAR (50) NOT NULL,
    [RowStatus]                          BIT           DEFAULT ((1)) NOT NULL,
    [TokenCreated]                       NVARCHAR (50) NOT NULL,
    [DateCreated]                        DATETIME      NOT NULL,
    [TokenUpdated]                       NVARCHAR (50) NULL,
    [DateUpdated]                        DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdConfigWarehouseByRouteAssignment] ASC),
    CONSTRAINT [FK_ConfigWarehouseByRouteAssignment_RouteAssignment] FOREIGN KEY ([RouteAssignmentId]) REFERENCES [dbo].[RouteAssigment] ([IdRouteAssigment])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Flujo al que pertenece la configuración de ubicación. Ej: Retorno a forza, linehauls, etc.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'WarehouseLocationServiceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Texto de ubicación de inventario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'WarehouseLocation';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la asignación de ruta de al tabla RouteAssigment.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'RouteAssignmentId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment', @level2type = N'COLUMN', @level2name = N'IdConfigWarehouseByRouteAssignment';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de configuración de ubicaciones de inventario para liquidación de rutas unificadas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigWarehouseByRouteAssignment';

