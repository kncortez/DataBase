CREATE TABLE [dbo].[TypeVehicleGroup] (
    [IdTypeVehicleGroup] INT           IDENTITY (1, 1) NOT NULL,
    [TypeVehicleOrigin]  INT           NOT NULL,
    [TypeVehicleValid]   INT           NOT NULL,
    [RowStatus]          BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]        DATETIME      NOT NULL,
    [TokenCreated]       NVARCHAR (50) NOT NULL,
    [DateUpdated]        DATETIME      NULL,
    [TokenUpdated]       NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdTypeVehicleGroup] ASC),
    CONSTRAINT [FK_TypeVehicleGroup_CatTypeVehicleOrigin] FOREIGN KEY ([TypeVehicleOrigin]) REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle]),
    CONSTRAINT [FK_TypeVehicleGroup_CatTypeVehicleValid] FOREIGN KEY ([TypeVehicleValid]) REFERENCES [dbo].[CatTypeVehicle] ([IdTypeVehicle])
);

