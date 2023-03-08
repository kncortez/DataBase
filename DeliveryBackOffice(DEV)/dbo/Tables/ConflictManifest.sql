CREATE TABLE [dbo].[ConflictManifest] (
    [IdConflictManifest] BIGINT          IDENTITY (1, 1) NOT NULL,
    [CourierResponsible] INT             NOT NULL,
    [TotalAmount]        DECIMAL (18, 2) NOT NULL,
    [RowStatus]          BIT             CONSTRAINT [DF_ConflictManifest_RowStatus] DEFAULT ((0)) NOT NULL,
    [TokenCreated]       NVARCHAR (50)   NOT NULL,
    [DateCreated]        DATETIME        NOT NULL,
    [TokenUpdated]       NVARCHAR (50)   NULL,
    [DateUpdated]        DATETIME        NULL,
    CONSTRAINT [PK_ConflictManifest] PRIMARY KEY CLUSTERED ([IdConflictManifest] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'cha de actualziación de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifest', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de usuario de actualziación de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifest', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'fecha de creación de registr0', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifest', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifest', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifest', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Monto total', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifest', @level2type = N'COLUMN', @level2name = N'TotalAmount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Courierman responsable ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifest', @level2type = N'COLUMN', @level2name = N'CourierResponsible';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de manifiesto de conflicto', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'ConflictManifest', @level2type = N'COLUMN', @level2name = N'IdConflictManifest';

