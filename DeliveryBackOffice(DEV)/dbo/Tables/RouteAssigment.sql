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
    [ManifestId]       BIGINT       NULL,
    [ExtPlatRouteId]   INT          NULL,
    PRIMARY KEY CLUSTERED ([IdRouteAssigment] ASC),
    CONSTRAINT [FK_RouteAssigment_DeliverySettlement] FOREIGN KEY ([ManifestId]) REFERENCES [dbo].[DeliveryOrderBySettlement] ([ID]),
    CONSTRAINT [FK_RouteAssigment_ExtPlatRoute] FOREIGN KEY ([ExtPlatRouteId]) REFERENCES [dbo].[ExtPlatRoute] ([IdExtPlatRoute]),
    CONSTRAINT [FKRoute_Currierman] FOREIGN KEY ([IdCurrierMan]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FKRoute_Route] FOREIGN KEY ([IdRoute]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FKRoute_Vehicle] FOREIGN KEY ([IdVehicle]) REFERENCES [dbo].[CatVehicle] ([IdVehicle])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de manifiesto al que corresponde la asignacion (entregas)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssigment', @level2type = N'COLUMN', @level2name = N'ManifestId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la ruta a la que pertenece visto desde una plataforma external', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RouteAssigment', @level2type = N'COLUMN', @level2name = N'ExtPlatRouteId';

