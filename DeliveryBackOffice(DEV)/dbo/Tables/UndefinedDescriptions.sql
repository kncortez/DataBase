CREATE TABLE [dbo].[UndefinedDescriptions] (
    [IdUndefinedDescriptions] INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Name]                    NVARCHAR (100) NOT NULL,
    [Description]             NVARCHAR (500) NOT NULL,
    [RowStatus]               BIT            NOT NULL,
    [TokenCreated]            NVARCHAR (50)  NOT NULL,
    [DateCreated]             DATETIME       NOT NULL,
    CONSTRAINT [PK_UndefinedDescriptions] PRIMARY KEY CLUSTERED ([IdUndefinedDescriptions] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creaciòn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UndefinedDescriptions', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'usuario que crea el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UndefinedDescriptions', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'campo que indica si esta activo el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UndefinedDescriptions', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'descripciòn ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UndefinedDescriptions', @level2type = N'COLUMN', @level2name = N'Description';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'nombre de la descripciòn', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UndefinedDescriptions', @level2type = N'COLUMN', @level2name = N'Name';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'identificador de suscripciòn no definida', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UndefinedDescriptions', @level2type = N'COLUMN', @level2name = N'IdUndefinedDescriptions';

