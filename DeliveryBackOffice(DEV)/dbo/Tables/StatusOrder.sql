CREATE TABLE [dbo].[StatusOrder] (
    [StatusOrderId]                  TINYINT        IDENTITY (1, 1) NOT NULL,
    [OrderDescription]               NVARCHAR (100) NOT NULL,
    [CatCheckpointTypeId]            TINYINT        DEFAULT ((2)) NOT NULL,
    [CatStatusTypeId]                INT            NULL,
    [StatusOrderTrackingDescription] NVARCHAR (200) NULL,
    [RowStatus]                      BIT            NULL,
    [TokenUpdated]                   NVARCHAR (50)  NULL,
    [DateUpdated]                    DATETIME       NULL,
    [StatusMessage]                  NVARCHAR (500) NULL,
    CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED ([StatusOrderId] ASC),
    CONSTRAINT [FK_StatusOrder_CatCheckpointType] FOREIGN KEY ([CatCheckpointTypeId]) REFERENCES [dbo].[CatCheckpointType] ([IdCatCheckpointType]),
    CONSTRAINT [FK_StatusOrder_StatusType] FOREIGN KEY ([CatStatusTypeId]) REFERENCES [dbo].[CatStatusType] ([IdCatStatusType])
);






GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Tabla de estados de guías.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'OrderDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de estado de la tabla CatCheckpointType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'CatCheckpointTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador del tipo de visibilidad de la tabla CatStatusType.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'CatStatusTypeId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Último token de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del estado para desplegar en tracking u otros sistemas.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'StatusOrderTrackingDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Mensaje de estado para consumo Contact Center', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'StatusMessage';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Última fecha de actualización del registro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'DateUpdated';

