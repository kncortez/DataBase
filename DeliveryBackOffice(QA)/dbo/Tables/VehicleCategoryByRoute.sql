CREATE TABLE [dbo].[VehicleCategoryByRoute] (
    [IdVehicleCatByRoute]    INT            IDENTITY (1, 1) NOT NULL,
    [RouteId]                INT            NOT NULL,
    [CatVehicleCategoriesId] INT            NOT NULL,
    [RowStauts]              BIT            NOT NULL,
    [TokenCreated]           NVARCHAR (200) NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdated]           NVARCHAR (200) NULL,
    [DateUpdated]            DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdVehicleCatByRoute] ASC),
    CONSTRAINT [FKCatVehicleCategories] FOREIGN KEY ([CatVehicleCategoriesId]) REFERENCES [dbo].[CatVehicleCategories] ([IdCatVehicleCategories]),
    CONSTRAINT [FKRoutes] FOREIGN KEY ([RouteId]) REFERENCES [dbo].[CatRoute] ([IdRoute])
);

