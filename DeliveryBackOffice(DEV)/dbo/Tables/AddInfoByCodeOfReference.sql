-- =============================================
-- Author:      Juan Ramirez
-- Create date: 2025/06/04
-- Description: Tabla de información adicional asociada a códigos de referencia específicos
-- =============================================

-- Crear tabla AddInfoByCodeOfReference
CREATE TABLE [dbo].[AddInfoByCodeOfReference] (
    [IdAddInfoByCodeOfReference] INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [CodeOfReference]            INT           NOT NULL,
    [Node]                       VARCHAR (150) NOT NULL,
    [Name]                       VARCHAR (150) NOT NULL,
    [Data]                       VARCHAR (500) NULL,
    [Value]                      VARCHAR (500) NULL,
    [EntityTypeByBillingSVId]    INT           NOT NULL,
    [RowStatus]                  BIT           DEFAULT ((1)) NOT NULL,
    [DateCreated]                DATETIME      NOT NULL,
    [TokenCreated]               NVARCHAR (50) NOT NULL,
    [DateUpdated]                DATETIME      NULL,
    [TokenUpdated]               NVARCHAR (50) NULL,
    CONSTRAINT [PK_AddInfoByCodeOfReference] PRIMARY KEY CLUSTERED ([IdAddInfoByCodeOfReference] ASC),
    CONSTRAINT [FK_AddInfoByCodeOfReference_EntityTypeByBillingSV] FOREIGN KEY ([EntityTypeByBillingSVId]) REFERENCES [dbo].[EntityTypeByBillingSV] ([IdEntityTypeByBillingSV]),
    CONSTRAINT [FK_AddInfoByCodeOfReference_VisitPointClient] FOREIGN KEY ([CodeOfReference]) REFERENCES [dbo].[VisitPointClient] ([CodeOfReference])
);


    GO
-- Documentación de la tabla AddInfoByCodeOfReference
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Tabla que almacena información adicional asociada a códigos de referencia específicos de clientes/puntos de visita con control de auditoría',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference';
    GO
-- =============================================
-- DOCUMENTACIÓN DE COLUMNAS
-- =============================================

-- Campo: IdAddInfoByCodeOfReference
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador único autoincremental del registro de información adicional. Clave primaria de la tabla.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'IdAddInfoByCodeOfReference';
    GO
-- Campo: CodeOfReference
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Código de referencia que identifica el punto de visita del cliente. FK hacia VisitPointClient.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'CodeOfReference';
    GO
-- Campo: NodeName
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nombre del nodo de información adicional (ej: NRC, RUC, DUI, Teléfono, Email, Dirección, etc.)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'Node';
-- Campo: NodeName
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Nombre del campo del nodo de información adicional (ej: NRC,CodigoActividad,DescActividad,NombreComercial,TipoEstablecimiento,CodEstablecimientoMH, etc.)',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'Name';
    GO
-- Campo: Data
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Valor de la configuración especificada en Node.Name. Puede ser NULL para configuraciones booleanas, flags o valores por defecto del sistema.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'Data';
    GO
-- Campo: Value
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Valor de la configuración especificada en Node.Name. Puede ser NULL para configuraciones booleanas, flags o valores por defecto del sistema.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'Value';
    GO
-- Campo: EntityTypeByBillingSVId
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador del tipo de entidad para facturación SV (Seller, Buyer, etc.) - FK hacia EntityTypeByBillingSV.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'EntityTypeByBillingSVId';
    GO
-- Campo: DateCreated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora exacta de creación del registro. Campo obligatorio para auditoría.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'DateCreated';
    GO
-- Campo: TokenCreated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token o identificador único del usuario/sistema que creó el registro. Permite trazabilidad completa.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'TokenCreated';
    GO
-- Campo: DateUpdated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Fecha y hora de la última actualización del registro. NULL si nunca ha sido modificado.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'DateUpdated';
    GO
-- Campo: TokenUpdated
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Token o identificador del usuario/sistema que realizó la última actualización. NULL si nunca ha sido modificado.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'TokenUpdated';
    GO
 
EXEC sp_addextendedproperty 
    @name = N'MS_Description', @value = N'Estado del tipo de entidad: 1=Activo, 0=Inactivo',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'COLUMN', @level2name = N'RowStatus';
-- =============================================
-- DOCUMENTACIÓN DE CONSTRAINTS
-- =============================================
GO
-- Primary Key
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Clave primaria clustered de la tabla AddInfoByCodeOfReference',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'CONSTRAINT', @level2name = N'PK_AddInfoByCodeOfReference';
    GO
-- Foreign Key hacia EntityTypeByBillingSV
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Relación con tabla EntityTypeByBillingSV para clasificar el tipo de entidad en contexto de facturación',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'CONSTRAINT', @level2name = N'FK_AddInfoByCodeOfReference_EntityTypeByBillingSV';
    GO
-- Foreign Key hacia VisitPointClient
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Relación con tabla VisitPointClient para asociar información adicional con puntos de visita específicos',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference',
    @level2type = N'CONSTRAINT', @level2name = N'FK_AddInfoByCodeOfReference_VisitPointClient';
    GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del nodo de información adicional (ej: NRC, RUC, DUI, Teléfono, Email, Dirección, etc.)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference', @level2type = N'COLUMN', @level2name = N'Node';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del campo del nodo de información adicional (ej: NRC,CodigoActividad,DescActividad,NombreComercial,TipoEstablecimiento,CodEstablecimientoMH, etc.)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'AddInfoByCodeOfReference', @level2type = N'COLUMN', @level2name = N'Name';

