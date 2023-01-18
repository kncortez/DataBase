CREATE TABLE [dbo].[Township] (
    [IdTownship]          INT            IDENTITY (1, 1) NOT NULL,
    [TownshipName]        NVARCHAR (50)  NULL,
    [TownshipDescription] NVARCHAR (50)  NULL,
    [TownshipLatitud]     DECIMAL (9, 6) NULL,
    [TownshipLongitud]    DECIMAL (9, 6) NULL,
    [PostalCode]          NVARCHAR (5)   NULL,
    [TownshipStatus]      BIT            NULL,
    [IdProvince]          INT            NULL,
    [TokenCreated]        NVARCHAR (50)  NULL,
    [DateCreated]         DATETIME       NULL,
    [TokenUpdated]        NVARCHAR (50)  NULL,
    [DatedUpdated]        DATETIME       NULL,
    [HeaderCode]          VARCHAR (10)   NULL,
    CONSTRAINT [PK_Township] PRIMARY KEY CLUSTERED ([IdTownship] ASC),
    CONSTRAINT [FK_Township_Province] FOREIGN KEY ([IdProvince]) REFERENCES [dbo].[Province] ([IdProvince])
);






GO


