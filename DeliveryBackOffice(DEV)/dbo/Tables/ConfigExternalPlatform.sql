CREATE TABLE [dbo].[ConfigExternalPlatform] (
    [IdConfigExternalPlatform] INT            IDENTITY (1, 1) NOT NULL,
    [ExternalPlatformId]       INT            NOT NULL,
    [ConfigParameterName]      NVARCHAR (50)  NOT NULL,
    [ConfigParameterValue]     NVARCHAR (600) NOT NULL,
    [ConfigMaxValidDate]       DATETIME       NULL,
    [RowStatus]                BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]             NVARCHAR (50)  NOT NULL,
    [DateCreated]              DATETIME       NOT NULL,
    [TokenUpdated]             NVARCHAR (50)  NULL,
    [DateUpdated]              DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([IdConfigExternalPlatform] ASC),
    CONSTRAINT [FK_ConfigExternalPlatform_ExternalPlatform] FOREIGN KEY ([ExternalPlatformId]) REFERENCES [dbo].[CatExternalPlatform] ([IdExternalPlatform])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha máxima de validez, si el valor tiene expiración.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'ConfigMaxValidDate';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Valor del parametro configurable.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'ConfigParameterValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del parametro configurable.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'ConfigParameterName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la plataforma externa de la tabla CatExternalPlatform.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'ExternalPlatformId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform', @level2type = N'COLUMN', @level2name = N'IdConfigExternalPlatform';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Datos de configuraciones de plataformas externas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConfigExternalPlatform';

