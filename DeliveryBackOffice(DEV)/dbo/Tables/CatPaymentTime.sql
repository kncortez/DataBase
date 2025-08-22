CREATE TABLE [dbo].[CatPaymentTime] (
    [TimePlaId]          INT           IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [TimePlaName]        VARCHAR (55)  NULL,
    [TimePlaDescription] VARCHAR (100) NULL,
    [TimePlaAbrev]       VARCHAR (10)  NULL,
    [TimePlaStatus]      INT           NULL,
    [TokenCreated]       VARCHAR (50)  NULL,
    [DateCreated]        DATETIME      NULL,
    [TokenUpdated]       VARCHAR (50)  NULL,
    [DateUpdated]        DATETIME      NULL,
    [TimeSequence]       INT           NULL,
    [CollectCOD]         BIT           NULL,
    CONSTRAINT [TimePlaId] PRIMARY KEY CLUSTERED ([TimePlaId] ASC)
);




GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Secuencia de tiempo de pago, Ej. Ahora es antes que recolección', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPaymentTime', @level2type = N'COLUMN', @level2name = N'TimeSequence';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indica si en ese tiempo se debo cobrar el monto COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatPaymentTime', @level2type = N'COLUMN', @level2name = N'CollectCOD';


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Identificador de registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'TimePlaId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Nombre',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'TimePlaName'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Indica cuando se debe pagar el servicio',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = NULL,
    @level2name = NULL
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Descripción',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'TimePlaDescription'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Abreviatura',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'TimePlaAbrev'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Estado(1 Activo, 0 Inactivo)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'TimePlaStatus'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'CatPaymentTime',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'