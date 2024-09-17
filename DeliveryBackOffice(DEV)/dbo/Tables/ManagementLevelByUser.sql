CREATE TABLE [dbo].[ManagementLevelByUser] (
    [IdManagementLevelByUser]		INT			    IDENTITY (1, 1) NOT NULL,
    [TokenValidator]				NVARCHAR (50)   NULL,
    [CatManagementLevelId]			INT				NULL,
    [RowStatus]						BIT             DEFAULT ((1)) NOT NULL,
    [DateCreated]					DATETIME        NULL,
    [TokenCreated]					NVARCHAR (50)   NOT NULL,
    [DateUpdated]					DATETIME        NULL,
    [TokenUpdated]					NVARCHAR (50)   NULL,
	CONSTRAINT [PK_ManagementLevelByUser_IdManagementLevelByUser] PRIMARY KEY CLUSTERED ([IdManagementLevelByUser] ASC),
    CONSTRAINT [FK_ManagementLevelByUser_CatManagementLevelId] FOREIGN KEY ([CatManagementLevelId]) REFERENCES [dbo].[CatManagementLevel] ([IdCatManagementLevel]),
);
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Usuario que valida la incidencia', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManagementLevelByUser', @level2type = N'COLUMN', @level2name = N'TokenValidator';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id del Rango jerárquico para desbloqueo de rutas según su valor', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManagementLevelByUser', @level2type = N'COLUMN', @level2name = N'CatManagementLevelId';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManagementLevelByUser', @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManagementLevelByUser', @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManagementLevelByUser', @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManagementLevelByUser', @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ManagementLevelByUser', @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
