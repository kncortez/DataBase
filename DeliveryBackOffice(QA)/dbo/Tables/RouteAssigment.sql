CREATE TABLE [dbo].[RouteAssigment] (
    [IdRouteAssigment] INT          IDENTITY (1, 1) NOT NULL,
    [IdRoute]          INT          NULL,
    [IdCurrierMan]     INT          NULL,
    [IdVehicle]        INT          NULL,
    [DateOfRoute]      DATE         NULL,
    [RowStatus]        BIT          NOT NULL,
    [TokenCreated]     VARCHAR (50) NOT NULL,
    [DateCreated]      DATETIME     NOT NULL,
    [TokenUpdated]     VARCHAR (50) NULL,
    [DateUpdated]      DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([IdRouteAssigment] ASC),
    CONSTRAINT [FKRoute_Currierman] FOREIGN KEY ([IdCurrierMan]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FKRoute_Route] FOREIGN KEY ([IdRoute]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FKRoute_Vehicle] FOREIGN KEY ([IdVehicle]) REFERENCES [dbo].[CatVehicle] ([IdVehicle])
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220329-145059]
    ON [dbo].[RouteAssigment]([IdCurrierMan] ASC, [DateOfRoute] ASC);

