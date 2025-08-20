-- =============================================
-- Author:      Juan Ramirez
-- Create date: 2025/06/04
-- Description: Tabla de tipos de entidades para clasificar registros (Seller, Buyer, etc.)
-- =============================================

-- Crear tabla EntityTypeByBillingSV
CREATE TABLE [EntityTypeByBillingSV] (
    IdEntityTypeByBillingSV INT IDENTITY(1,1),     -- Identificador único de la entidad
    TypeName                VARCHAR(50) NOT NULL UNIQUE,       -- Nombre del tipo de entidad (Seller, Buyer, etc.)
    [Description]           VARCHAR(200) NULL,                 -- Descripción detallada del tipo de entidad
    RowStatus               BIT NOT NULL DEFAULT 1,            -- Indica si el tipo de entidad está activo (1=Activo, 0=Inactivo)    DateCreated   DATETIME NOT NULL,
    DateCreated             DATETIME NOT NULL,
    TokenCreated            NVARCHAR(50) NOT NULL,
    DateUpdated             DATETIME NULL,
    TokenUpdated            NVARCHAR(50) NULL,
    CONSTRAINT [PK_EntityTypeByBillingSV] PRIMARY KEY CLUSTERED ([IdEntityTypeByBillingSV] ASC)
);
GO
-- Documentación de la tabla EntityTypeByBillingSV
EXECUTE sp_addextendedproperty
    N'MS_Description',
    N'Tabla que almacena los tipos de entidades del sistema (Seller, Buyer, etc.)',
    N'SCHEMA', N'dbo',
    N'TABLE', N'EntityTypeByBillingSV';
GO
-- Documentación de columnas
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Identificador único autoincremental del tipo de entidad',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'EntityTypeByBillingSV',
    @level2type = N'COLUMN', @level2name = N'IdEntityTypeByBillingSV';
GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Nombre único del tipo de entidad (Seller, Buyer, Admin, etc.)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'EntityTypeByBillingSV',
    @level2type = N'COLUMN', @level2name = N'TypeName';
GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Descripción detallada del propósito y características del tipo de entidad',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'EntityTypeByBillingSV',
    @level2type = N'COLUMN', @level2name = N'Description';
GO
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Estado del tipo de entidad: 1=Activo, 0=Inactivo',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'EntityTypeByBillingSV',
    @level2type = N'COLUMN', @level2name = N'RowStatus';
GO
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora exacta de creación del registro. Campo obligatorio para auditoría.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'EntityTypeByBillingSV',
    @level2type = N'COLUMN', @level2name = N'DateCreated';
GO
-- Para campo TokenCreated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token o identificador único del usuario/sistema que creó el registro. Permite trazabilidad completa.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'EntityTypeByBillingSV',
    @level2type = N'COLUMN', @level2name = N'TokenCreated';
GO
-- Para campo DateUpdated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora de la última actualización del registro. NULL si nunca ha sido modificado.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'EntityTypeByBillingSV',
    @level2type = N'COLUMN', @level2name = N'DateUpdated';
GO
-- Para campo TokenUpdated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token o identificador del usuario/sistema que realizó la última actualización. NULL si nunca ha sido modificado.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'EntityTypeByBillingSV',
    @level2type = N'COLUMN', @level2name = N'TokenUpdated';
GO
