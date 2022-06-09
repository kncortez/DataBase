CREATE TABLE [dbo].[CatVehicleBrand] (
    [IdCatVehicleBrand] INT            IDENTITY (1, 1) NOT NULL,
    [Name]              NVARCHAR (200) NULL,
    [RowStatus]         BIT            NOT NULL,
    [TokenCreated]      VARCHAR (50)   NOT NULL,
    [DateCreated]       DATETIME       NOT NULL,
    [TokenUpdated]      VARCHAR (50)   NULL,
    [DateUpdated]       DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatVehicleBrand] ASC)
);

