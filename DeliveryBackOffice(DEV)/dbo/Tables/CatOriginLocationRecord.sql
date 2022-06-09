CREATE TABLE [dbo].[CatOriginLocationRecord] (
    [IdCatOriginLocationRecord] INT            IDENTITY (1, 1) NOT NULL,
    [OriginDescription]         NVARCHAR (100) NOT NULL,
    [RowStatus]                 BIT            NOT NULL,
    [TokenCreated]              VARCHAR (50)   NOT NULL,
    [DateCreated]               DATETIME       NOT NULL,
    [TokenUpdated]              VARCHAR (50)   NULL,
    [DateUpdated]               DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdCatOriginLocationRecord] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catalogo de origenes de ubicaciónes (Latitud y longitud)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatOriginLocationRecord';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatOriginLocationRecord', @level2type = N'COLUMN', @level2name = N'IdCatOriginLocationRecord';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del origen de la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatOriginLocationRecord', @level2type = N'COLUMN', @level2name = N'OriginDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatOriginLocationRecord', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatOriginLocationRecord', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatOriginLocationRecord', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatOriginLocationRecord', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatOriginLocationRecord', @level2type = N'COLUMN', @level2name = N'DateUpdated';

