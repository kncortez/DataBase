-- =============================================
-- Author:      Juan Ramirez
-- Create date: 2025/06/04
-- Description: Tabla de información adicional para configuraciones globales del sistema
-- =============================================

-- Crear tabla AddInfoByConfigSV
CREATE TABLE AddInfoByConfigSV (
    IdAddInfoByConfigSV INT IDENTITY(1,1),                    -- Identificador único del registro de configuración
    [Node]              VARCHAR(150) NOT NULL,  -- Nombre del nodo o campo de información (NRC, RUC, etc.)
    [Name]              VARCHAR(150) NOT NULL,  -- Nombre del nodo o campo de información (NRC, RUC, etc.)
    [Data]              VARCHAR(500) NULL,      -- Dato asociado al nodo, puede ser NULL
    [Value]             VARCHAR(500) NULL,      -- Valor asociado al nodo, puede ser NULL
    RowStatus           BIT NOT NULL DEFAULT 1,
    DateCreated         DATETIME NOT NULL,
    TokenCreated        NVARCHAR(50) NOT NULL,
    DateUpdated         DATETIME NULL,
    TokenUpdated        NVARCHAR(50) NULL,
    CONSTRAINT [PK_AddInfoByConfigSV] PRIMARY KEY 
    CLUSTERED ([IdAddInfoByConfigSV] ASC)
);
GO
-- Documentación de la tabla AddInfoByConfigSV
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Tabla que almacena configuraciones globales del sistema SV que no están asociadas a entidades específicas, con control de auditoría y estado',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV';
GO
-- =============================================
-- DOCUMENTACIÓN DE COLUMNAS
-- =============================================
GO
-- Campo: IdAddInfoByConfigSV
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador único autoincremental del registro de configuración SV. Clave primaria de la tabla.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'IdAddInfoByConfigSV';
    GO
-- Campo: Node
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nombre jerárquico del nodo de configuración que agrupa funcionalidades relacionadas (ej: Items.Config, System.Billing, etc.)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'Node';
    GO
-- Campo: Name
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nombre específico de la configuración dentro del nodo (ej: UnitOfMeasure, DocType, DefaultCurrency, etc.)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'Name';
    GO
-- Campo: Data
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Valor de la configuración especificada en Node.Name. Puede ser NULL para configuraciones booleanas, flags o valores por defecto del sistema.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'Data';
    GO
-- Campo: Value
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Valor de la configuración especificada en Node.Name. Puede ser NULL para configuraciones booleanas, flags o valores por defecto del sistema.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'Value';
    GO
-- Campo: RowStatus
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Estado del registro de configuración: 1=Activo, 0=Inactivo. Permite desactivar configuraciones sin eliminarlas físicamente.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'RowStatus';
    GO
-- Campo: DateCreated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora exacta de creación del registro de configuración. Campo obligatorio para auditoría.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'DateCreated';
    GO
-- Campo: TokenCreated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token o identificador único del usuario/sistema que creó la configuración. Permite trazabilidad completa de cambios en el sistema.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'TokenCreated';
    GO
-- Campo: DateUpdated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora de la última actualización de la configuración. NULL si nunca ha sido modificada después de su creación.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'DateUpdated';
    GO
-- Campo: TokenUpdated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token o identificador del usuario/sistema que realizó la última actualización de la configuración. NULL si nunca ha sido modificada.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'COLUMN', @level2name = N'TokenUpdated';
    GO
-- =============================================
-- DOCUMENTACIÓN DE CONSTRAINTS
-- =============================================

-- Primary Key
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Clave primaria clustered de la tabla AddInfoByConfigSV para identificación única de configuraciones',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByConfigSV',
    @level2type = N'CONSTRAINT', @level2name = N'PK_AddInfoByConfigSV';
    GO