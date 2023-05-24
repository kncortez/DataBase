CREATE TABLE [dbo].[TSERoutePreparationHeader] (
    [IDTSERoutePreparationHeader] INT            IDENTITY (1, 1) NOT NULL,
    [IdCatRoute]                  INT            NOT NULL,
    [IdCatVehicle]                INT            NOT NULL,
    [IdCatRouteCluster]           INT            NOT NULL,
    [IdRouteSupervisor]           INT            NOT NULL,
    [IdRouteLeader]               INT            NOT NULL,
    [Coordinator]                 NVARCHAR (150) NOT NULL,
    [RowStatus]                   BIT            CONSTRAINT [DF_TSERoutePreparationHeader_RowStatus] DEFAULT ((1)) NOT NULL,
    [DateCreated]                 DATETIME       NOT NULL,
    [TokenCreated]                NVARCHAR (50)  NOT NULL,
    [DateUpdated]                 DATETIME       NULL,
    [TokenUpdated]                NVARCHAR (50)  NULL,
    [SenderReceiverId]            INT            NOT NULL,
    CONSTRAINT [PK_TSERoutePreparationHeader] PRIMARY KEY CLUSTERED ([IDTSERoutePreparationHeader] ASC)
);


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
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nombre de coordinador', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'TSERoutePreparationHeader', @level2type = N'COLUMN', @level2name = N'Coordinator';


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

