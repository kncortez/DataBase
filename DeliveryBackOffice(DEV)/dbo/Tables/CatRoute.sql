CREATE TABLE [dbo].[CatRoute] (
    [IdRoute]      INT           IDENTITY (1, 1) NOT NULL,
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
    PRIMARY KEY CLUSTERED ([IdRoute] ASC),
    CONSTRAINT [FKRouteTownship] FOREIGN KEY ([IdTownship]) REFERENCES [dbo].[Township] ([IdTownship]),
    CONSTRAINT [FKRouteTypeR] FOREIGN KEY ([IdTypeRoute]) REFERENCES [dbo].[CatTypeRoute] ([IdTypeRoute])
);




GO
CREATE NONCLUSTERED INDEX [IX_IdCatRoute_RPT]
    ON [dbo].[CatRoute]([IdRoute] ASC)
    INCLUDE([CodeRoute]);

