CREATE TABLE [dbo].[CatTypeOfImage] (
    [IdTypeOfImage]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TypeOfImageName]        NVARCHAR (50)  NOT NULL,
    [TypeOfImageDescription] NVARCHAR (200) NULL,
    [RowStatus]              BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]           NVARCHAR (50)  NOT NULL,
    [DateCreated]            DATETIME       NOT NULL,
    [TokenUpdated]           NVARCHAR (50)  NULL,
    [DateUpdated]            DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdTypeOfImage] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catálogo de imagenes y descripción de las mismas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage', @level2type = N'COLUMN', @level2name = N'IdTypeOfImage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la imagen.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage', @level2type = N'COLUMN', @level2name = N'TypeOfImageName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de la imagen.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage', @level2type = N'COLUMN', @level2name = N'TypeOfImageDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeOfImage', @level2type = N'COLUMN', @level2name = N'DateUpdated';

