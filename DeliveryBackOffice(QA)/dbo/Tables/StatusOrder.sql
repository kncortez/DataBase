CREATE TABLE [dbo].[StatusOrder] (
    [StatusOrderId]                  TINYINT        IDENTITY (1, 1) NOT NULL,
    [OrderDescription]               NVARCHAR (100) NOT NULL,
    [CatCheckpointTypeId]            TINYINT        DEFAULT ((2)) NOT NULL,
    [CatStatusTypeId]                INT            NULL,
    [StatusMessage]                  NVARCHAR (500) NULL,
    [StatusOrderTrackingDescription] NVARCHAR (200) NULL,
    [RowStatus]                      BIT            DEFAULT ((1)) NOT NULL,
    [TokenCreated]                   NVARCHAR (50)  NULL,
    [DateCreated]                    DATETIME       NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL,
    [NextSteps]                      NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED ([StatusOrderId] ASC),
    CONSTRAINT [FK_StatusOrder_CatCheckpointType] FOREIGN KEY ([CatCheckpointTypeId]) REFERENCES [dbo].[CatCheckpointType] ([IdCatCheckpointType]),
    CONSTRAINT [FK_StatusOrder_StatusType] FOREIGN KEY ([CatStatusTypeId]) REFERENCES [dbo].[CatStatusType] ([IdCatStatusType])
);








GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'OrderDescription';


GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de estados de guías.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de estado de la tabla CatCheckpointType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'CatCheckpointTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de visibilidad de la tabla CatStatusType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'CatStatusTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último Token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción a desplegar en tracking bajo el estado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'StatusOrderTrackingDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mensaje de estado para consumo Contact Center', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'StatusMessage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Siguientes pasos del estado.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'NextSteps';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'DateUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'DateCreated';

