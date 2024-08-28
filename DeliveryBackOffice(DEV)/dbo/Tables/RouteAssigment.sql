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



GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20220329-145059]
    ON [dbo].[RouteAssigment]([IdCurrierMan] ASC, [DateOfRoute] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_IdRoute_DateOfRoute]
    ON [dbo].[RouteAssigment]([IdRoute] ASC, [DateOfRoute] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_DateOfRoute]
    ON [dbo].[RouteAssigment]([DateOfRoute] ASC)
    INCLUDE([IdCurrierMan], [DateCreated]);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Informacion sobre asignación de ruta a los couriers',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'IdRouteAssigment'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id de la ruta(Referencia a IdRoute de la tabla CatRoute)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'IdRoute'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del corier-Mensajero(Referencia a ID de la tabla SenderReceiver)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'IdCurrierMan'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id del vehiculo (Referencia a IdVehiculo de la tabla CatVehicle)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'IdVehicle'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha en que se asigno la ruta',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'DateOfRoute'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'RouteAssigment',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'