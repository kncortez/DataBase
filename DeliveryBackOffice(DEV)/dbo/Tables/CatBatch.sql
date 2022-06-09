CREATE TABLE [dbo].[CatBatch] (
    [IdCatBatch]     INT            IDENTITY (1, 1) NOT NULL,
    [CatName]        NVARCHAR (500) NOT NULL,
    [CatDescription] VARCHAR (500)  NOT NULL,
    [RowStatus]      BIT            CONSTRAINT [DF_CatBatch_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]   NVARCHAR (50)  NOT NULL,
    [DateCreated]    DATETIME       CONSTRAINT [DF_CatBatch_DateCreated] DEFAULT (getdate()) NOT NULL,
    [TokenUpdated]   NVARCHAR (50)  NULL,
    [DateUpdated]    DATETIME       NULL,
    CONSTRAINT [PK_CatBatch_IdCatBatchD] PRIMARY KEY CLUSTERED ([IdCatBatch] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id correlativo de la tabla IdCatBatch', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatch', @level2type = N'COLUMN', @level2name = N'IdCatBatch';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Nombre del tipo de lote (COD, Recolección, Collect, Comisiones)', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatch', @level2type = N'COLUMN', @level2name = N'CatName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Describe lo que involucra el lote', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatch', @level2type = N'COLUMN', @level2name = N'CatDescription';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatch', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que crea el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatch', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación del registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatch', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token del usuario que actualiza el registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatch', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatBatch', @level2type = N'COLUMN', @level2name = N'DateUpdated';

