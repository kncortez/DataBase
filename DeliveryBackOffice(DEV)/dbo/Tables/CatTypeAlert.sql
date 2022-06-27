CREATE TABLE [dbo].[CatTypeAlert] (
    [IdCatTypeAlert] INT           IDENTITY (1, 1) NOT NULL,
    [AlertName]      VARCHAR (15)  NULL,
    [RowStatus]      BIT           NOT NULL,
    [TokenCreated]   NVARCHAR (50) NOT NULL,
    [DateCreated]    NVARCHAR (50) NOT NULL,
    [TokenUpdated]   NVARCHAR (50) NULL,
    [DateUpdated]    DATETIME      NULL,
    CONSTRAINT [PK_CatAlertStatus] PRIMARY KEY CLUSTERED ([IdCatTypeAlert] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Catalogo de tipos de alertas de servicios/guías', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeAlert';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifiacdor de registro', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeAlert', @level2type = N'COLUMN', @level2name = N'IdCatTypeAlert';




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Descripción del tipo de alerta', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeAlert', @level2type = N'COLUMN', @level2name = N'AlertName';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Estado lógico', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeAlert', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeAlert', @level2type = N'COLUMN', @level2name = N'TokenCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de creación', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeAlert', @level2type = N'COLUMN', @level2name = N'DateCreated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Token de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeAlert', @level2type = N'COLUMN', @level2name = N'TokenUpdated';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Fecha de actualización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatTypeAlert', @level2type = N'COLUMN', @level2name = N'DateUpdated';

