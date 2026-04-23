/* =================================================
   Tabla:     [DeliveryBackOffice].[dbo].[StatusOrderForCustomer]
   Propósito: <Tabla para relacionar los estados de una Guía con un cliente específico, permitiendo personalizar la visualización de estados en función del cliente.>
   Historia:  FDAPI-6053
   Fecha:     2026-04-15
=== CHANGELOG ===============================
YYYY-MM-DD | Historia/épica:      | Autor:  | Comentario |
=========================================== */
CREATE TABLE [DeliveryBackOffice].[dbo].[StatusOrderForCustomer] (
	CustomerId               INT 		NOT NULL,
    StatusOrderId            TINYINT    NOT NULL,
    PublicStatus             BIT        NOT NULL,    
    CONSTRAINT PK_StatusOrderForCustomer PRIMARY KEY (CustomerId, StatusOrderId),
    CONSTRAINT FK_StatusOrderForCustomer_Customer FOREIGN KEY (CustomerId) REFERENCES Customer(IdCustomer),
    CONSTRAINT FK_StatusOrderForCustomer_StatusOrder FOREIGN KEY (StatusOrderId) REFERENCES StatusOrder(StatusOrderId)
);
GO

-- Documentación de la tabla StatusOrderForCustomer
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description',
    @value = N'Tabla para relacionar los estados de una Guía con un cliente específico, permitiendo personalizar la visualización de estados en función del cliente',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'StatusOrderForCustomer';
GO

-- =============================================
-- DOCUMENTACIÓN DE COLUMNAS
-- =============================================

-- Campo: CustomerId
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador del cliente. FK hacia la tabla Customer.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'StatusOrderForCustomer',
    @level2type = N'COLUMN', @level2name = N'CustomerId';
GO
-- Campo: StatusOrderId
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Identificador del estado de la orden. FK hacia la tabla StatusOrder.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'StatusOrderForCustomer',
    @level2type = N'COLUMN', @level2name = N'StatusOrderId';
GO
-- Campo: PublicStatus
EXEC sys.sp_addextendedproperty 
    @name = N'MS_Description', 
    @value = N'Indica si el estado de la orden es visible para el cliente (1) o no (0). Permite personalizar la visualización de estados en función del cliente.',
    @level0type = N'SCHEMA', @level0name = N'dbo',
    @level1type = N'TABLE', @level1name = N'StatusOrderForCustomer',
    @level2type = N'COLUMN', @level2name = N'PublicStatus';
GO
