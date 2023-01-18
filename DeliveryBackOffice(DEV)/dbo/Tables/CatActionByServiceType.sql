CREATE TABLE [dbo].[CatActionByServiceType] (
    [IdCatActionByServiceType] INT           IDENTITY (1, 1) NOT NULL,
    [ActionName]               NVARCHAR (50) NOT NULL,
    [ServiceType]              NVARCHAR (50) NOT NULL,
    [RowStatus]                BIT           DEFAULT ((1)) NOT NULL,
    [DateCreatead]             DATETIME      NOT NULL,
    [TokenCreated]             NVARCHAR (50) NOT NULL,
    [DateUpdated]              DATETIME      NULL,
    [TokenUpdated]             NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([IdCatActionByServiceType] ASC)
);




GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType', @level2type = N'COLUMN', @level2name = N'DateCreatead';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de tipo de servicio.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType', @level2type = N'COLUMN', @level2name = N'ServiceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la acción posible de realizar.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType', @level2type = N'COLUMN', @level2name = N'ActionName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType', @level2type = N'COLUMN', @level2name = N'IdCatActionByServiceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de acciones permitidas bajo tipo de servicio para liquidación de rutas unificadas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatActionByServiceType';

