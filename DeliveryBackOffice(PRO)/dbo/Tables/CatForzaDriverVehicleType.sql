CREATE TABLE [dbo].[CatForzaDriverVehicleType] (
    [IdCatForzaDriverVehicleType]   INT           IDENTITY (1, 1) NOT NULL,
    [ForzaDriverVehicleTypeId]      INT           NOT NULL,
    [ForzaDriverVehicleDescription] NVARCHAR (50) NOT NULL,
    [CatTypeVehicleId]              INT           NULL,
    [RowStatus]                     BIT           NOT NULL,
    [TokenCreated]                  NVARCHAR (50) NOT NULL,
    [DateCreated]                   DATETIME      NOT NULL,
    [TokenUpdated]                  NVARCHAR (50) NULL,
    [DateUpdated]                   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdCatForzaDriverVehicleType] ASC),
    CONSTRAINT [FK_CatForzaDriverVehicleType_CatTypeVehicle] FOREIGN KEY ([IdCatForzaDriverVehicleType]) REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para mapear los tipos de vehículo existentes en la plataforma de ForzaDriver con los tipos de vehículo existentes en DeliveryBackOffice.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'IdCatForzaDriverVehicleType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de vehículo en la plataforma de ForzaDriver', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'ForzaDriverVehicleTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de vehículo en la plataforma de ForzaDriver', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'ForzaDriverVehicleDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de tipo de vehículo de la tabla CatTypeVehicle', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'CatTypeVehicleId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatForzaDriverVehicleType', @level2type = N'COLUMN', @level2name = N'DateUpdated';

