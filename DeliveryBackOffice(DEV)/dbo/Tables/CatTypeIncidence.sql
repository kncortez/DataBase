CREATE TABLE [dbo].[CatTypeIncidence] (
    [IdIncidenceType]          INT           IDENTITY (1, 1) NOT NULL,
    [NameIncidence]            VARCHAR (200) NULL,
    [DescriptionIncidence]     VARCHAR (200) NULL,
    [RowStatus]                BIT           NOT NULL,
    [TokenCreated]             VARCHAR (50)  NOT NULL,
    [DateCreated]              DATETIME      NOT NULL,
    [TokenUpdated]             VARCHAR (50)  NULL,
    [DateUpdated]              DATETIME      NULL,
    [ServiceType]              NVARCHAR (25) NULL,
    [OrderId]                  INT           NULL,
    [Code]                     INT           NULL,
    [IncidenceClasificationId] INT           NULL,
    PRIMARY KEY CLUSTERED ([IdIncidenceType] ASC),
    CONSTRAINT [FKCatTypeIncidence] FOREIGN KEY ([IncidenceClasificationId]) REFERENCES [dbo].[CatIncidenceClasification] ([IdCatIncidenceClasification])
);








GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'toke de actualziacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'tipo de servicio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'ServiceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificacion de orden', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'OrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de la incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'NameIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'IncidenceClasificationId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificacion de tipod e incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'IdIncidenceType';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descripcion de incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'DescriptionIncidence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de actualizacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creacion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'codigo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeIncidence', @level2type = N'COLUMN', @level2name = N'Code';

