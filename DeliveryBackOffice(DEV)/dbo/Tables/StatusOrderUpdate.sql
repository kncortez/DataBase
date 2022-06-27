CREATE TABLE [dbo].[StatusOrderUpdate] (
    [StatusOrderId]   TINYINT NOT NULL,
    [InvalidIdUpdate] TINYINT NOT NULL,
    PRIMARY KEY CLUSTERED ([StatusOrderId] ASC, [InvalidIdUpdate] ASC),
    FOREIGN KEY ([StatusOrderId]) REFERENCES [dbo].[StatusOrder] ([StatusOrderId])
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder validar el estado origen al cual se va a actualizar una guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrderUpdate', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder validar el estado destino al cual se va a actualizar una guía.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrderUpdate', @level2type = N'COLUMN', @level2name = N'InvalidIdUpdate';

