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
    [Kms]                    INT             NULL,
    PRIMARY KEY CLUSTERED ([IdVehicle] ASC),
    FOREIGN KEY ([CatVehicleBrandId]) REFERENCES [dbo].[CatVehicleBrand] ([IdCatVehicleBrand]),
    FOREIGN KEY ([CatVehicleCategoriesId]) REFERENCES [dbo].[CatVehicleCategories] ([IdCatVehicleCategories]),
    CONSTRAINT [FD_CatVehicleHubLogistics] FOREIGN KEY ([HubLogisticId]) REFERENCES [dbo].[HubLogistics] ([IdHubLogistic]),
    CONSTRAINT [FKVehicleType] FOREIGN KEY ([IdTypeVehicle]) REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle]),
    CONSTRAINT [UK] UNIQUE NONCLUSTERED ([UnitNumber] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del hub al que pertenece', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatVehicle', @level2type = N'COLUMN', @level2name = N'HubLogisticId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'kilometraje de la unidad', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatVehicle', @level2type = N'COLUMN', @level2name = N'Kms';

