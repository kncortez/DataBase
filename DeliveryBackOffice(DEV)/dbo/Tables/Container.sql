CREATE TABLE [dbo].[Container] (
    [IdContainer]          INT            IDENTITY (1, 1) NOT NULL,
    [CatTypeContainerId]   INT            NOT NULL,
    [ContainerNumber]      NVARCHAR (50)  NOT NULL,
    [ContainerDescription] NVARCHAR (200) NULL,
    [RowStatus]            BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]         NVARCHAR (50)  NOT NULL,
    [DateCreated]          DATETIME       NOT NULL,
    [TokenUpdated]         NVARCHAR (50)  NULL,
    [DateUpdated]          DATETIME       NULL,
    [CountryId]            VARCHAR (2)    NULL,
    PRIMARY KEY CLUSTERED ([IdContainer] ASC),
    CONSTRAINT [FK_Container_CatCountry] FOREIGN KEY ([CountryId]) REFERENCES [dbo].[CatCountry] ([IdCountry]),
    CONSTRAINT [FK_Container_TypeContainer] FOREIGN KEY ([CatTypeContainerId]) REFERENCES [dbo].[CatTypeContainer] ([IdCatTypeContainer])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'ContainerDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de contenedor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'ContainerNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tipo de contendor | Tabla CatTypeContainer.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'CatTypeContainerId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container', @level2type = N'COLUMN', @level2name = N'IdContainer';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de registro de contenedores.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Container';

