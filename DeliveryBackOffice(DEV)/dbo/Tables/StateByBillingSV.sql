
CREATE TABLE [dbo].[StateByBillingSV] (
    [Id]           INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Code]         NVARCHAR (10)  NULL,
    [Name]         NVARCHAR (100) NULL,
    [RowStatus]    BIT            NOT NULL,
    [TokenCreated] VARCHAR (50)   NOT NULL,
    [DateCreated]  DATETIME       NOT NULL,
    [TokenUpdated] VARCHAR (50)   NULL,
    [DateUpdated]  DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);



GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description',
					@value = N'Catálogo de departementos para facturación en El Salvador',
					@level0type = N'SCHEMA',
					@level0name = N'dbo',
					@level1type = N'TABLE',
					@level1name = N'StateByBillingSV';
GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description', 
					@value = N'Identificador de registro',
					@level0type = N'SCHEMA',
					@level0name = N'dbo',
					@level1type = N'TABLE',
					@level1name = N'StateByBillingSV', 
					@level2type = N'COLUMN', 
					@level2name = N'Id';

GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description', 
					@value = N'Código de Estado',
					@level0type = N'SCHEMA',
					@level0name = N'dbo',
					@level1type = N'TABLE',
					@level1name = N'StateByBillingSV', 
					@level2type = N'COLUMN', 
					@level2name = N'Code';
					
GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description', 
					@value = N'Nombre de Estado',    
					@level0type = N'SCHEMA', 
					@level0name = N'dbo', 
					@level1type = N'TABLE', 
					@level1name = N'StateByBillingSV', 
					@level2type = N'COLUMN', 
					@level2name = N'Name';

GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description', 
					@value = N'Estado (1=Activo, 0=Inactivo)',
					@level0type = N'SCHEMA', 
					@level0name = N'dbo', 
					@level1type = N'TABLE', 
					@level1name = N'StateByBillingSV', 
					@level2type = N'COLUMN', 
					@level2name = N'RowStatus';

GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description', 
					@value = N'Token del usuario que creó el registro',
					@level0type = N'SCHEMA', 
					@level0name = N'dbo', 
					@level1type = N'TABLE', 
					@level1name = N'StateByBillingSV', 
					@level2type = N'COLUMN', 
					@level2name = N'TokenCreated';

GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description', 
					@value = N'Fecha de creación del registro',
					@level0type = N'SCHEMA', 
					@level0name = N'dbo', 
					@level1type = N'TABLE', 
					@level1name = N'StateByBillingSV', 
					@level2type = N'COLUMN', 
					@level2name = N'DateCreated';

GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description', 
					@value = N'Token del usuario que actualizó el registro',
					@level0type = N'SCHEMA', 
					@level0name = N'dbo', 
					@level1type = N'TABLE', 
					@level1name = N'StateByBillingSV', 
					@level2type = N'COLUMN', 
					@level2name = N'TokenUpdated';

GO
EXEC sp_addextendedproperty 
					@name = N'MS_Description', 
					@value = N'Fecha de última actualización',
					@level0type = N'SCHEMA', 
					@level0name = N'dbo', 
					@level1type = N'TABLE', 
					@level1name = N'StateByBillingSV', 
					@level2type = N'COLUMN', 
					@level2name = N'DateUpdated';
GO
