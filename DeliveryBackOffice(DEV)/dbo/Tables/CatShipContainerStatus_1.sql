CREATE TABLE [dbo].[CatShipContainerStatus] (
    [IdCatStatus]  INT            IDENTITY (1, 1) NOT NULL,
    [Name]         NVARCHAR (100) NOT NULL,
    [Description]  NVARCHAR (200) NULL,
    [RowStatus]    BIT            DEFAULT ((1)) NOT NULL,
    [UserCreated]  NVARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [TokenCreated] NVARCHAR (50)  NOT NULL,
    [UserUpdated]  NVARCHAR (50)  NULL,
    [DateUpdated]  DATETIME       NULL,
    [TokenUpdated] NVARCHAR (50)  NULL,
    CONSTRAINT [PK_CatShipContainerStatus] PRIMARY KEY CLUSTERED ([IdCatStatus] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que realizó la actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'UserUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que realizó la creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'UserCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del estado del contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatShipContainerStatus', @level2type = N'COLUMN', @level2name = N'IdCatStatus';

