CREATE TABLE [dbo].[Warehouse] (
    [Id]            BIGINT        IDENTITY (1, 1) NOT NULL,
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
    CONSTRAINT [FK_Warehouse_DeliveryOrder] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);






GO
CREATE CLUSTERED INDEX [GuideRackClusteredIndex]
    ON [dbo].[Warehouse]([Rack_Position] ASC, [Guide_Serie] ASC, [Guide_Number] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_warehouse_active]
    ON [dbo].[Warehouse]([Guide_Serie] ASC, [Guide_Number] ASC, [Active] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_Id]
    ON [dbo].[Warehouse]([Id] ASC);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse', @level2type = N'COLUMN', @level2name = N'UserUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Hora y fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Si pertenece al inventario de devoluciones.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Warehouse', @level2type = N'COLUMN', @level2name = N'IsReturn';


GO
CREATE NONCLUSTERED INDEX [IDX_Guide_Number_Guide_Serie]
    ON [dbo].[Warehouse]([Guide_Number] ASC, [Guide_Serie] ASC);

