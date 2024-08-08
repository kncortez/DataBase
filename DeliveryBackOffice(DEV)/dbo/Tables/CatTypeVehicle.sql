CREATE TABLE [dbo].[CatTypeVehicle] (
    [IdTypeVehicle] INT           IDENTITY (1, 1) NOT NULL,
    [Name]          VARCHAR (100) NOT NULL,
    [Description]   VARCHAR (200) NOT NULL,
    [RowStatus]     BIT           NOT NULL,
    [TokenCreated]  VARCHAR (50)  NOT NULL,
    [DateCreated]   DATETIME      NOT NULL,
    [TokenUpdated]  VARCHAR (50)  NULL,
    [DateUpdated]   DATETIME      NULL,
    [PackageSize]   VARCHAR (100) NULL,
    [IdCountry]     VARCHAR (2)   NULL,
    PRIMARY KEY CLUSTERED ([IdTypeVehicle] ASC),
    CONSTRAINT [FK_CatTypeVehicle_IdCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);




GO

GO

GO

GO

GO

GO

GO

GO

GO

GO
