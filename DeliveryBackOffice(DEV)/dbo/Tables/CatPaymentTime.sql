CREATE TABLE [dbo].[CatPaymentTime] (
    [TimePlaId]          INT           IDENTITY (1, 1) NOT NULL,
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

