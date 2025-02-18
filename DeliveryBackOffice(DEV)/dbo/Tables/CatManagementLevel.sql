CREATE TABLE [dbo].[CatManagementLevel] (
    [IdCatManagementLevel]	INT 			IDENTITY (1, 1) NOT NULL,
    [ManagementLevelName]   NVARCHAR (50)   NULL,
    [MinAmount]				DECIMAL(14,2)	NULL,
    [MaxAmount]				DECIMAL(14,2)	NULL,
    [RowStatus]             BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]           DATETIME        NULL,
    [TokenCreated]          NVARCHAR (50)   NOT NULL,
    [DateUpdated]           DATETIME        NULL,
    [TokenUpdated]          NVARCHAR (50)   NULL,
    [CountryId] [nvarchar](2) NULL,
    PRIMARY KEY CLUSTERED ([IdCatManagementLevel] ASC)
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre de jerarquías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManagementLevel', @level2type = N'COLUMN', @level2name = N'ManagementLevelName';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto mínimo para desbloquear incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManagementLevel', @level2type = N'COLUMN', @level2name = N'MinAmount';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto máximo para desbloquear incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManagementLevel', @level2type = N'COLUMN', @level2name = N'MaxAmount';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManagementLevel', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManagementLevel', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManagementLevel', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManagementLevel', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatManagementLevel', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Identificador de país' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CatManagementLevel', @level2type=N'COLUMN',@level2name=N'CountryId'
GO
