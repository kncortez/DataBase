CREATE TABLE [dbo].[Warehouse] (
    [Id]            BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Rack_Position] NVARCHAR (30) NOT NULL,
    [Guide_Serie]   NVARCHAR (2)  NOT NULL,
    [Guide_Number]  INT           NOT NULL,
    [Dry]           BIT           NOT NULL,
    [Cold]          BIT           NOT NULL,
    [Active]        BIT           NOT NULL,
    [UserCreated]   NVARCHAR (50) NOT NULL,
    [DateCreated]   DATETIME      NOT NULL,
    [Guide_Piece]   SMALLINT      NULL,
    [UserUpdated]   NVARCHAR (50) NULL,
    [DateUpdated]   DATETIME      NULL,
    [IsReturn]      BIT           NULL,
    [HubExc]        NVARCHAR (10) NULL,
    [IdHubExc]      INT           DEFAULT ((0)) NOT NULL,
    [StatusOrderId] INT           DEFAULT ((0)) NOT NULL,
    [StationId]     INT           NULL,
    CONSTRAINT [PK_Warehouse] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [FK_Warehouse_DeliveryOrder] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);










GO
CREATE CLUSTERED INDEX [GuideRackClusteredIndex]
    ON [dbo].[Warehouse]([Rack_Position] ASC, [Guide_Serie] ASC, [Guide_Number] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_warehouse_active]
    ON [dbo].[Warehouse]([Guide_Serie] ASC, [Guide_Number] ASC, [Active] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si pertenece al inventario de devoluciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse', @level2type = N'COLUMN', @level2name = N'IsReturn';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse', @level2type = N'COLUMN', @level2name = N'UserUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora y fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para registro de guías a inventario.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse';


GO
CREATE NONCLUSTERED INDEX [IX_Warehouse_Active_Guide]
    ON [dbo].[Warehouse]([Guide_Serie] ASC, [Guide_Number] ASC, [Active] ASC) WHERE ([Active]=(1));


GO
CREATE NONCLUSTERED INDEX [idx_warehouse_statusorder_guide]
    ON [dbo].[Warehouse]([StatusOrderId] ASC, [Guide_Serie] ASC, [Guide_Number] ASC, [Rack_Position] ASC, [Active] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_warehouse_stationid_datecreated]
    ON [dbo].[Warehouse]([StationId] ASC, [DateCreated] DESC)
    INCLUDE([Guide_Serie], [Guide_Number], [Rack_Position]);


GO
CREATE NONCLUSTERED INDEX [idx_warehouse_stationid_active]
    ON [dbo].[Warehouse]([StationId] ASC, [Active] ASC) WHERE ([Active]=(1));


GO
CREATE NONCLUSTERED INDEX [idx_warehouse_stationid]
    ON [dbo].[Warehouse]([StationId] ASC)
    INCLUDE([Guide_Serie], [Guide_Number], [Rack_Position], [Active], [DateCreated]);


GO
CREATE NONCLUSTERED INDEX [idx_warehouse_idhubexc_active]
    ON [dbo].[Warehouse]([IdHubExc] ASC, [Active] ASC, [Guide_Serie] ASC, [Guide_Number] ASC) WHERE ([Active]=(1) AND [IdHubExc] IS NOT NULL);


GO
CREATE NONCLUSTERED INDEX [idx_warehouse_active_hubexc_date]
    ON [dbo].[Warehouse]([HubExc] ASC, [IdHubExc] ASC, [Active] ASC, [DateCreated] ASC, [Rack_Position] ASC, [Guide_Serie] ASC, [Guide_Number] ASC, [StatusOrderId] ASC) WHERE ([Active]=(1) AND [HubExc] IS NOT NULL);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la estación desde donde se radicó el inventario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse', @level2type = N'COLUMN', @level2name = N'StationId';

