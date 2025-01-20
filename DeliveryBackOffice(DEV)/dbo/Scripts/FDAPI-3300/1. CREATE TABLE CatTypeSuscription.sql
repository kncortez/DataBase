CREATE TABLE [dbo].[CatTypeSuscription] (
    [IdTypeSuscription]   INT IDENTITY (1, 1) NOT NULL,
    [Name]                NVARCHAR (100) NOT NULL,
    [Description]         NVARCHAR (200) NULL,
    [RowStatus]           BIT NOT NULL DEFAULT 1,
    [UserCreated]         NVARCHAR(50) NOT NULL,
	[DateCreated]         DATETIME NOT NULL,
	[TokenCreated]        NVARCHAR(50) NOT NULL,
    [UserUpdated]         NVARCHAR(50) NULL,
	[DateUpdated]         DATETIME NULL,
	[TokenUpdated]        NVARCHAR(50) NULL,
    CONSTRAINT [PK_CatTypeSuscription] PRIMARY KEY CLUSTERED ([IdTypeSuscription] ASC)
);
EXECUTE sp_addextendedproperty N'MS_Description', N'Identificador del tipo de suscripción', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'IdTypeSuscription'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Nombre de la suscripción', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'Name'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Descripción de la suscripción', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'Description'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Estado lógico del registro', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'RowStatus'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'UserCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Fecha de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'DateCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Token de creación del registro', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'TokenCreated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Usuario que realizó la actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'UserUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Última fecha de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'DateUpdated'
GO
EXECUTE sp_addextendedproperty N'MS_Description', N'Último token de actualización del registro', N'SCHEMA', N'dbo', N'TABLE', N'CatTypeSuscription', N'COLUMN', N'TokenUpdated'
GO
