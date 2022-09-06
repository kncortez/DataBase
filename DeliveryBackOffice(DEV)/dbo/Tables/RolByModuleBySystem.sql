CREATE TABLE [dbo].[RolByModuleBySystem] (
    [RmsIdRol]          INT          NOT NULL,
    [RmsIdSystem]       INT          NOT NULL,
    [RmsIdModule]       INT          NOT NULL,
    [RmsRowStatus]      BIT          NOT NULL,
    [RmsTokenCreated]   VARCHAR (50) NOT NULL,
    [RmsDateCreated]    DATETIME     NOT NULL,
    [RmsTokenUpdated]   VARCHAR (50) NULL,
    [RmsDateUpdated]    DATETIME     NULL,
    [RmsModuleMenu]     INT          NULL,
    [RmsHasNewFunction] BIT          NULL,
    PRIMARY KEY CLUSTERED ([RmsIdRol] ASC, [RmsIdSystem] ASC, [RmsIdModule] ASC),
    CONSTRAINT [FKModulers] FOREIGN KEY ([RmsIdModule]) REFERENCES [dbo].[CatModule] ([ModIdModule]),
    CONSTRAINT [FKRolms] FOREIGN KEY ([RmsIdRol]) REFERENCES [dbo].[CatRol] ([RolIdRol]),
    CONSTRAINT [FKSystemrm] FOREIGN KEY ([RmsIdSystem]) REFERENCES [dbo].[CatSystem] ([SysIdSystem])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Union de rol, modulos y systemas para desplieuge de menús.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualziación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsTokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsTokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsRowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del sistema de la tabla CatSystem.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsIdSystem';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del rol de usuario de la tabla CatRol.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsIdRol';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del módulo de la tabla CatModule.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsIdModule';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsDateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsDateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del menú al que pertenece el módulo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsModuleMenu';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicativo si el modulo tiene nuevas funcionalidades (para poder desplegar un icono en frontend).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'RolByModuleBySystem', @level2type = N'COLUMN', @level2name = N'RmsHasNewFunction';

