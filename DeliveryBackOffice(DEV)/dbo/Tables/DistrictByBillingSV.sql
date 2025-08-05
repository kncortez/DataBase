
CREATE TABLE [dbo].[DistrictByBillingSV] (
	Id INT IDENTITY(1,1),
    CodeDistrict NVARCHAR(10),
    StateCode NVARCHAR(10),
    [Name] NVARCHAR(100),
	StateId INT NULL,
    RowStatus BIT NOT NULL,
    TokenCreated VARCHAR(50) NOT NULL,
    DateCreated DATETIME NOT NULL,
    TokenUpdated VARCHAR(50) NULL,
    DateUpdated DATETIME NULL,
    PRIMARY KEY (Id),
	CONSTRAINT [FKDistrictByBillingSV] FOREIGN KEY ([StateId]) REFERENCES [StateByBillingSV] ([Id]),
);
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description',    
						@value = N'Catálogo de municipios para facturación en El Salvador',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo',
  						@level1type = N'TABLE',  
						@level1name = N'DistrictByBillingSV';
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Identificador del registro',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'Id';	

GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Llave foreana referenciando Id de StateByBillingSV',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'StateId';
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Código del municipio',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'CodeDistrict';					
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Código de la provincia a la que pertenece el municipio',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'StateCode';
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Nombre del municipio',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'Name';
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Estado (1=Activo, 0=Inactivo)',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'RowStatus';
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Token del usuario que creó el registro',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'TokenCreated';
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Fecha de creación del registro',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'DateCreated';
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Token del usuario que actualizó el registro',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'TokenUpdated';
GO
EXEC sp_addextendedproperty 
						@name = N'MS_Description', 
						@value = N'Fecha de última actualización',    
						@level0type = N'SCHEMA', 
						@level0name = N'dbo', 
						@level1type = N'TABLE', 
						@level1name = N'DistrictByBillingSV', 
						@level2type = N'COLUMN', 
						@level2name = N'DateUpdated';
GO
