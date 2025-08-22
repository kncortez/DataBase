CREATE TABLE [dbo].[CatTypeRate] (
    [IdTypeRate]   INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]         VARCHAR (100) NOT NULL,
    [Description]  VARCHAR (50)  NULL,
    [RowStatus]    BIT           NOT NULL,
    [TokenCreated] VARCHAR (50)  NOT NULL,
    [DateCreated]  DATETIME      NOT NULL,
    [TokenUpdated] VARCHAR (50)  NULL,
    [DateUpdated]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([IdTypeRate] ASC)
);



GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de los tipos de tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate', @level2type=N'COLUMN',@level2name=N'IdTypeRate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Nombre de los tipos de tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate', @level2type=N'COLUMN',@level2name=N'Name'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Descripcion de los tipos de tarifario' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate', @level2type=N'COLUMN',@level2name=N'Description'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'1 activo, 0 inactivo' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate', @level2type=N'COLUMN',@level2name=N'RowStatus'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de creación de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate', @level2type=N'COLUMN',@level2name=N'TokenCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de creacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate', @level2type=N'COLUMN',@level2name=N'DateCreated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Token de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate', @level2type=N'COLUMN',@level2name=N'TokenUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de actualizacion de fila' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate', @level2type=N'COLUMN',@level2name=N'DateUpdated'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que contiene la informacion de los diferentes tipos de tarifarios' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatTypeRate'
GO