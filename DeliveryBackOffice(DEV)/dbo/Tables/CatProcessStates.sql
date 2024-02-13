CREATE TABLE [dbo].[CatProcessStates] (
    [IdCatProcessStates] INT            IDENTITY (1, 1) NOT NULL,
    [NameStatus]         NVARCHAR (50)  NOT NULL,
    [DescriptionStatus]  NVARCHAR (250) NOT NULL,
    [RowStatus]          BIT            NOT NULL,
    [TokenCreated]       NVARCHAR (50)  NOT NULL,
    [DateCreated]        DATETIME       NOT NULL,
    [TokenUpdate]        NVARCHAR (50)  NULL,
    [DateUpdate]         DATETIME       NULL,
    CONSTRAINT [PK_CatProcessStates] PRIMARY KEY CLUSTERED ([IdCatProcessStates] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProcessStates', @level2type = N'COLUMN', @level2name = N'DateUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualziación ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProcessStates', @level2type = N'COLUMN', @level2name = N'TokenUpdate';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha en que se creo el estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProcessStates', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'token de persona que creo el estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProcessStates', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'indica si el esatdo esta activo o inactivo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProcessStates', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción breve  del estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProcessStates', @level2type = N'COLUMN', @level2name = N'DescriptionStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del estado del proceso, este puede ser Prepagado, finaliziado, esto para indicar que el proceso de cobro, asignación y facturación de carrito haya finalziado correctamente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProcessStates', @level2type = N'COLUMN', @level2name = N'NameStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Llave principal de la tabla de estado de un proceso', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatProcessStates', @level2type = N'COLUMN', @level2name = N'IdCatProcessStates';

