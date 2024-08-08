CREATE TABLE [dbo].[CatBatchTypeCOD] (
    [CatBatchTypeCODId] BIGINT       IDENTITY (1, 1) NOT NULL,
    [Name]              VARCHAR (50) NOT NULL,
    [RowStatus]         BIT          NOT NULL,
    [TokenCreated]      VARCHAR (50) NOT NULL,
    [DateCreated]       DATETIME     NOT NULL,
    [TokenUpdated]      VARCHAR (50) NULL,
    [DateUpdated]       DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([CatBatchTypeCODId] ASC)
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id para la tabla CatBatchTypeCOD ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatchTypeCOD', @level2type = N'COLUMN', @level2name = N'CatBatchTypeCODId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el nombre del tipo de formato en el que los clientes quieren que se les realice el depósito, ya sea acumulado o detallado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatchTypeCOD', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el estado del registro, para poder deshabilitarlo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatchTypeCOD', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el token de usuario con el que se insertó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatchTypeCOD', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es la fecha en la que se insertó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatchTypeCOD', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es el token de usuario con el que se actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatchTypeCOD', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Es la fecha en que se actualizó el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatchTypeCOD', @level2type = N'COLUMN', @level2name = N'DateUpdated';

