CREATE TABLE [dbo].[StatusOrder] (
    [StatusOrderId]       TINYINT        IDENTITY (1, 1) NOT NULL,
    [OrderDescription]    NVARCHAR (100) NOT NULL,
    [CatCheckpointTypeId] TINYINT        DEFAULT ((2)) NOT NULL,
    CONSTRAINT [PK_Table_1] PRIMARY KEY CLUSTERED ([StatusOrderId] ASC),
    CONSTRAINT [FK_StatusOrder_CatCheckpointType] FOREIGN KEY ([CatCheckpointTypeId]) REFERENCES [dbo].[CatCheckpointType] ([IdCatCheckpointType])
);




GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'StatusOrderId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción de status order', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'StatusOrder', @level2type = N'COLUMN', @level2name = N'OrderDescription';


GO



GO


