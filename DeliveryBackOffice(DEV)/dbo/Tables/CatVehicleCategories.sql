CREATE TABLE [dbo].[CatVehicleCategories] (
    [IdCatVehicleCategories] INT             IDENTITY (1, 1) NOT NULL,
    [Name]                   NVARCHAR (200)  NULL,
    [RowStatus]              BIT             NOT NULL,
    [TokenCreated]           VARCHAR (50)    NOT NULL,
    [DateCreated]            DATETIME        NOT NULL,
    [TokenUpdated]           VARCHAR (50)    NULL,
    [DateUpdated]            DATETIME        NULL,
    [Length]                 DECIMAL (14, 2) NULL,
    [Width]                  DECIMAL (14, 2) NULL,
    [High]                   DECIMAL (14, 2) NULL,
    [UnitType]               INT             NULL,
    PRIMARY KEY CLUSTERED ([IdCatVehicleCategories] ASC),
    CONSTRAINT [FK_CatVehicleCategories_Unit] FOREIGN KEY ([UnitType]) REFERENCES [dbo].[Unit] ([IdUnit])
);

