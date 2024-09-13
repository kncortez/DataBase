CREATE TABLE [dbo].[InternalUser] (
    [IdUser]         BIGINT         NOT NULL,
    [Username]       NVARCHAR (50)  NOT NULL,
    [IdEmployee]     NVARCHAR (50)  NULL,
    [RegisterUserID] BIGINT         NULL,
    [RowStatus]      BIT            CONSTRAINT [DF_InternalUser_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]   NVARCHAR (50)  NULL,
    [DateCreated]    DATETIME       NULL,
    [TokenUpdated]   NVARCHAR (50)  NULL,
    [DateUpdated]    DATETIME       NULL,
    [Comment]        NVARCHAR (200) NULL,
    CONSTRAINT [PK_InternalUser] PRIMARY KEY CLUSTERED ([IdUser] ASC, [Username] ASC),
    CONSTRAINT [FK_InternalUser_RegisterUser] FOREIGN KEY ([RegisterUserID]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);






GO
CREATE NONCLUSTERED INDEX [idx_ RegisterUserID]
    ON [dbo].[InternalUser]([RegisterUserID] ASC);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificación de usuario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'IdUser'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'nombre de usuario',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'Username'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificacion de empleado',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'IdEmployee'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia de RegisterUser',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'RegisterUserID'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'RowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Representa la información de los usuarios internos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'InternalUser',
    @level2type = NULL,
    @level2name = NULL