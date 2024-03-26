CREATE TABLE [dbo].[CatTypeVehicle] (
    [IdTypeVehicle] INT           IDENTITY (1, 1) NOT NULL,
    [Name]          VARCHAR (100) NOT NULL,
    [Description]   VARCHAR (200) NOT NULL,
    [RowStatus]     BIT           NOT NULL,
    [TokenCreated]  VARCHAR (50)  NOT NULL,
    [DateCreated]   DATETIME      NOT NULL,
    [TokenUpdated]  VARCHAR (50)  NULL,
    [DateUpdated]   DATETIME      NULL,
    [PackageSize] VARCHAR(100) NULL, 
    PRIMARY KEY CLUSTERED ([IdTypeVehicle] ASC)
);

