CREATE TABLE [dbo].[UserSystemRestriction] (
    [UstIdRestriction] BIGINT       IDENTITY (1, 1) NOT NULL,
    [UstIdUser]        BIGINT       NOT NULL,
    [UstIdSystem]      INT          NOT NULL,
    [UstAccessRetries] INT          NOT NULL,
    [UstRetries]       INT          NOT NULL,
    [UstStatus]        VARCHAR (10) NOT NULL,
    [UstRowStatus]     BIT          NOT NULL,
    [UstTokenCreated]  VARCHAR (50) NOT NULL,
    [UstDateCreated]   DATETIME     NOT NULL,
    [UstOperationDate] DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([UstIdRestriction] ASC),
    CONSTRAINT [FKSystemRestriction] FOREIGN KEY ([UstIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem]),
    CONSTRAINT [FKUserRestriction] FOREIGN KEY ([UstIdUser]) REFERENCES [dbo].[RegisterUser] ([UsrIdUser])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla para registro de bloqueo de usuario por sistema.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'UserSystemRestriction';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstIdRestriction'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia de id del usuario (RegistreUser)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstIdUser'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Referencia de id del sistema(CatSystem)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstIdSystem'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'ReIntentos de acceso permitidos',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstAccessRetries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Reintentos realizados',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstRetries'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(ACTIVE, BLOCKED)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'1 Activo, 0 Inactivo',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstRowStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstTokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstDateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de operación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'UserSystemRestriction',
    @level2type = N'COLUMN',
    @level2name = N'UstOperationDate'