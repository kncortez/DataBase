CREATE TABLE [dbo].[CatStatusProcess] (
    [IdStatusProcess]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [NameStatusProcess]        NVARCHAR (50)  NOT NULL,
    [DescriptionStatusProcess] NVARCHAR (200) NULL,
    [RowStatus]                BIT            NOT NULL,
    [UserCreated]              NVARCHAR (50)  NOT NULL,
    [DateCreated]              DATETIME       NOT NULL,
    [UserUpdated]              NVARCHAR (50)  NULL,
    [DateUpdated]              DATETIME       NULL,
    [Icon]                     NVARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([IdStatusProcess] ASC)
);




GO

EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único para los estados de proceso en tracking', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess', @level2type = N'COLUMN', @level2name = N'IdStatusProcess';



GO
EXECUTE sp_addextendedproperty 
@name = N'MS_Description', 
@value = N'Nombre del estado del proceso en tracking', 
@level0type = N'SCHEMA', @level0name = 'dbo', 
@level1type = N'TABLE',  @level1name = 'CatStatusProcess', 
@level2type = N'COLUMN', @level2name = 'NameStatusProcess';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del significado de cada uno de los estados en tracking', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess', @level2type = N'COLUMN', @level2name = N'DescriptionStatusProcess';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico (activo/inactivo)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess', @level2type = N'COLUMN', @level2name = N'RowStatus';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que creó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess', @level2type = N'COLUMN', @level2name = N'UserCreated';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess', @level2type = N'COLUMN', @level2name = N'DateCreated';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess', @level2type = N'COLUMN', @level2name = N'UserUpdated';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess', @level2type = N'COLUMN', @level2name = N'DateUpdated';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla que obtiene los nuevos estados de agrupación para proceso de seguimiento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess';



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Icono para visualización en tracking', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatStatusProcess', @level2type = N'COLUMN', @level2name = N'Icon';



GO