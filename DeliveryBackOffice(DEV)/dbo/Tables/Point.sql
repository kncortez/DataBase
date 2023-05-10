CREATE TABLE [dbo].[Point] (
    [IdPoint]          INT             IDENTITY (1, 1) NOT NULL,
    [PointDescription] NVARCHAR (100)  NULL,
    [PointLatitude]    DECIMAL (10, 8) NOT NULL,
    [PointLongitude]   DECIMAL (10, 8) NOT NULL,
    [RowStatus]        BIT             NOT NULL,
    [TokenCreated]     NVARCHAR (50)   NOT NULL,
    [DateCreated]      DATETIME        NOT NULL,
    [TokenUpdated]     NVARCHAR (50)   NULL,
    [DateUpdated]      DATETIME        NULL,
    [PointFlag]        BIT             DEFAULT ((0)) NULL,
    PRIMARY KEY CLUSTERED ([IdPoint] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que guarda ubicaciones en forma de puntos', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'IdPoint';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del punto de ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'PointDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Latitud de la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'PointLatitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Longitud de la ubicación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'PointLongitude';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para indicar que pertenece a una geocerca no actualizable.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Point', @level2type = N'COLUMN', @level2name = N'PointFlag';

