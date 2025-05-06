CREATE TABLE [dbo].[CatRoute] (
    [IdRoute]      INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CodeRoute]    VARCHAR (100) NOT NULL,
    [Description]  VARCHAR (200) NOT NULL,
    [IdTownship]   INT           NULL,
    [IdTypeRoute]  INT           NULL,
    [Zone]         VARCHAR (50)  NULL,
    [RowStatus]    BIT           NOT NULL,
    [TokenCreated] VARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdated] VARCHAR (50)  NULL,
    [DateUpdated]  DATETIME      NULL,
    [CountryId]    VARCHAR (2)   NULL,
    PRIMARY KEY CLUSTERED ([IdRoute] ASC),
    CONSTRAINT [FKRouteTownship] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FKRouteTypeR] FOREIGN KEY ([IdTypeRoute]) REFERENCES [dbo].[CatTypeRoute] ([IdTypeRoute])
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


GO


GO


GO


GO
CREATE NONCLUSTERED INDEX [IDX_CodeRoute]
    ON [dbo].[CatRoute]([CodeRoute] ASC);

