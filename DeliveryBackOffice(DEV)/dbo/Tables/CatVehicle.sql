CREATE TABLE [dbo].[CatVehicle] (
    [IdVehicle]              INT             IDENTITY (1, 1) NOT NULL,
    [UnitNumber]             VARCHAR (10)    NOT NULL,
    [CodeName]               VARCHAR (200)   NOT NULL,
    [IdTypeVehicle]          INT             NULL,
    [Plate]                  VARCHAR (20)    NULL,
    [Year]                   INT             NULL,
    [Capacity]               DECIMAL (12, 2) NULL,
    [WhiteLineCapacity]      DECIMAL (12, 2) NULL,
    [IrregularCapacity]      DECIMAL (12, 2) NULL,
    [RowStatus]              BIT             NOT NULL,
    [TokenCreated]           VARCHAR (50)    NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [TokenUpdated]           VARCHAR (50)    NULL,
    [DateUpdated]            DATETIME        NULL,
    [CatVehicleCategoriesId] INT             NULL,
    [CatVehicleBrandId]      INT             NULL,
    [Long]                   DECIMAL (14, 2) NULL,
    [Width]                  DECIMAL (14, 2) NULL,
    [High]                   DECIMAL (14, 2) NULL,
    [CubicMeters]            DECIMAL (14, 2) NULL,
    [CapabilityEcomerce]     DECIMAL (14, 2) NULL,
    [HubLogisticId]          INT             NULL,
    [LastLatitude]           NVARCHAR (20)   NULL,
    [LastLongitude]          NVARCHAR (20)   NULL,
    [IdCountry]              varchar(2)      NULL
    PRIMARY KEY CLUSTERED ([IdVehicle] ASC),
    FOREIGN KEY ([CatVehicleBrandId]) REFERENCES [dbo].[CatVehicleBrand] ([IdCatVehicleBrand]),
    FOREIGN KEY ([CatVehicleCategoriesId]) REFERENCES [dbo].[CatVehicleCategories] ([IdCatVehicleCategories]),
    CONSTRAINT [FD_CatVehicleHubLogistics] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKVehicleType] FOREIGN KEY ([IdTypeVehicle]) REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle]),
    CONSTRAINT [UK] UNIQUE NONCLUSTERED ([UnitNumber] ASC),
    CONSTRAINT [FK_IdCountry] FOREIGN KEY([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del hub al que pertenece', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatVehicle', @level2type = N'COLUMN', @level2name = N'HubLogisticId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última ubicación, longitud, registrada del vehículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatVehicle', @level2type = N'COLUMN', @level2name = N'LastLongitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última ubicación, latitud, registrada del vehículo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatVehicle', @level2type = N'COLUMN', @level2name = N'LastLatitude';



EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'País del vehiculo ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatVehicle', @level2type=N'COLUMN',@level2name=N'IdCountry'
GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'IdVehicle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Número de unidad',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'UnitNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'CodeName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Tipo de vehículo(Referencia a IdTypeVehicle de la tabla CatTypeVehicle)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'IdTypeVehicle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Número de placa',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'Plate'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Año del vehículo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'Year'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Capacidad',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'Capacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Capacidad linea blanca',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'WhiteLineCapacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Capacidad irregular',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'IrregularCapacity'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creo el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de categoria de vehiculo(Referencia a idCatVehicleCategories de la tabla CatVehicleCategories)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'CatVehicleCategoriesId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de marca de vehiculo(Referencia a idCatVehicleBrand de la tabla CatVehicleBrand)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'CatVehicleBrandId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Largo(m)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'Long'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Ancho(m)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'Width'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Altura(m)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'High'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Volumen(m cúbicos)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'CubicMeters'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Capacidad eCommerce',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = N'COLUMN',
    @level2name = N'CapabilityEcomerce'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Catalogo de vehículos registrados en el sistema',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatVehicle',
    @level2type = NULL,
    @level2name = NULL