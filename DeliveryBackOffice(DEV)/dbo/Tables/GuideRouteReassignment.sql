CREATE TABLE [dbo].[GuideRouteReassignment] (
    [IdGuideRouteReassignment] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [NoGuia]                   NVARCHAR (50)  NOT NULL,
    [RouteCode]                    NVARCHAR (50)  NOT NULL,
    [IdCountry]                VARCHAR (2)    NOT NULL,
    [RowStatus]                BIT            NOT NULL DEFAULT 1,
    [TokenCreated]             NVARCHAR (100)     NULL,
    [DateCreated]              DATETIME           NULL DEFAULT GETDATE(),
    [TokenUpdated]             NVARCHAR (100)     NULL,
    [DateUpdated]              DATETIME           NULL,
    CONSTRAINT [PK_GuideRouteReassignment] PRIMARY KEY CLUSTERED ([IdGuideRouteReassignment] ASC),
    CONSTRAINT [FK_GuideRouteReassignment_CatCountry] FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para almacenar la reasignación de guías a rutas por país', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del registro de reasignación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'IdGuideRouteReassignment';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número de guía completo (serie + número, ej: FD27434794)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'NoGuia';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Código de ruta asignada', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'RouteCode';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del país (2 caracteres ISO)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'IdCountry';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro: 1=Activo, 0=Inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'RowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'TokenCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'DateCreated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'TokenUpdated';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'GuideRouteReassignment', @level2type = N'COLUMN', @level2name = N'DateUpdated';

IF NOT EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'TblGuideRouteItemType')
BEGIN
    CREATE TYPE [dbo].[TblGuideRouteItemType] AS TABLE
    (
        [RowIndex] INT          NOT NULL,
        [Guide]    NVARCHAR(50) NOT NULL,
        [RouteCode]    NVARCHAR(50) NOT NULL
    );
END
GO