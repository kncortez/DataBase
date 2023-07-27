CREATE TABLE [dbo].[VehicleLocationLog] (
    [IdVehicleLocationLog] BIGINT        IDENTITY (1, 1) NOT NULL,
    [VehicleId]            INT           NOT NULL,
    [LocationAccuracy]     NVARCHAR (50) NULL,
    [LocationLatitude]     NVARCHAR (20) NOT NULL,
    [LocationLongitude]    NVARCHAR (20) NOT NULL,
    [RowStatus]            BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]          DATETIME      NOT NULL,
    [TokenCreated]         NVARCHAR (50) NOT NULL,
    [DateUpdated]          DATETIME      NULL,
    [TokenUpdated]         NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdVehicleLocationLog] ASC),
    CONSTRAINT [FK_VehicleLocation_Vehicle] FOREIGN KEY ([VehicleId]) REFERENCES [dbo].[CatVehicle] ([IdVehicle])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud de la ubicación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'LocationLongitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud de la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'LocationLatitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Precisión de la ubicación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'LocationAccuracy';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del vehículo de la tabla CatVehicle.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'VehicleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog', @level2type = N'COLUMN', @level2name = N'IdVehicleLocationLog';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Bitácora de ubicaciones de vehículos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'VehicleLocationLog';


GO
CREATE NONCLUSTERED INDEX [IDX_VehicleLocationLog_RowStatus_INCLUDE]
    ON [dbo].[VehicleLocationLog]([RowStatus] ASC)
    INCLUDE([VehicleId]);

