CREATE TABLE [dbo].[TSERoutePreparationHeader] (
    [IDTSERoutePreparationHeader] INT           IDENTITY (1, 1) NOT NULL,
    [IdCatRoute]                  INT           NOT NULL,
    [IdCatVehicle]                INT           NOT NULL,
    [IdCatRouteCluster]           INT           NOT NULL,
    [IdRouteSupervisor]           INT           NOT NULL,
    [IdRouteLeader]               INT           NOT NULL,
    [RowStatus]                   BIT           CONSTRAINT [DF_TSERoutePreparationHeader_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]                 DATETIME      NOT NULL,
    [TokenCreated]                NVARCHAR (50) NOT NULL,
    [DateUpdated]                 DATETIME      NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    [SenderReceiverId]            INT           NOT NULL,
    [TSECustomsMark]              NVARCHAR (50) NULL,
    [HasFirstPickupProcess]       BIT           DEFAULT ((0)) NOT NULL,
    [HasFirstArrivalProcess]      BIT           DEFAULT ((0)) NOT NULL,
    [HasFirstDispatchProcess]     BIT           DEFAULT ((0)) NOT NULL,
    [HasFirstDeliveryProccess]    BIT           DEFAULT ((0)) NOT NULL,
    [HasLastDeliveryProccess]     BIT           DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_TSERoutePreparationHeader] PRIMARY KEY CLUSTERED ([IDTSERoutePreparationHeader] ASC),
    CONSTRAINT [FK_TSERoutePreparationHeader_Boss] FOREIGN KEY ([IdRouteLeader]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FK_TSERoutePreparationHeader_Courier] FOREIGN KEY ([SenderReceiverId]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FK_TSERoutePreparationHeader_Route] FOREIGN KEY ([IdCatRoute]) REFERENCES [dbo].[CatRoute] ([IdRoute]),
    CONSTRAINT [FK_TSERoutePreparationHeader_Supervisor] FOREIGN KEY ([IdRouteSupervisor]) REFERENCES [dbo].[SenderReceiver] ([ID]),
    CONSTRAINT [FK_TSERoutePreparationHeader_Vehicle] FOREIGN KEY ([IdCatVehicle]) REFERENCES [dbo].[CatVehicle] ([IdVehicle])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_TSERoutePreparationHeader_CustomsMark]
    ON [dbo].[TSERoutePreparationHeader]([TSECustomsMark] ASC) WHERE ([TSECustomsMark] IS NOT NULL);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la ruta ya fue procesada en su última entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'HasLastDeliveryProccess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la ruta ya fue procesada en su primera liquidación de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'HasFirstDeliveryProccess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la ruta ya fue procesada en su primer despacho a ruta de entrega', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'HasFirstDispatchProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la ruta ya fue procesada en su primer arribo a instalaciones', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'HasFirstArrivalProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si la ruta ya fue procesada en su primera recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'HasFirstPickupProcess';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Primer marchamo de cajas', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'TSECustomsMark';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'usaurio que actualiza el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de registr', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de lider de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'IdRouteLeader';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identidicador de supervisor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'IdRouteSupervisor';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de cluster', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'IdCatRouteCluster';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de vehículo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'IdCatVehicle';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de ruta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'IdCatRoute';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'IDTSERoutePreparationHeader';

