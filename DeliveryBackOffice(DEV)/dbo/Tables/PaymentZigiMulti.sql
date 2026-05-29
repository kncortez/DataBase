CREATE TABLE [dbo].[PaymentZigiMulti] (
    [Id]             INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Id_PaymentZigi] INT             NOT NULL,
    [GuideSerie]     NVARCHAR (50)   NOT NULL,
    [GuideNumber]    NVARCHAR (50)   NOT NULL,
    [Amount]         DECIMAL (10, 2) DEFAULT ((0.00)) NULL,
    [exclude_COD]    BIT             DEFAULT ((0)) NULL,
    [IsPay]          BIT             DEFAULT ((0)) NULL,
    [CODValue]       DECIMAL (10, 2) NULL,
    [CollectValue]   DECIMAL (10, 2) NULL,
    [RowStatus]      BIT             DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_PaymentZigi] FOREIGN KEY ([Id_PaymentZigi]) REFERENCES [dbo].[PaymentZigi] ([ZigiPaymentId])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador si el registro está vigente', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'RowStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Valor correspondiente al servicio Collect', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'CollectValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Valor de pago correspondiente a COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'CODValue';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Indicador si desde portal EXC se indica que está pagado', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'IsPay';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Exclusión de COD', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'exclude_COD';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = 'Monto a pagar completo', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'Amount';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Número d Guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'GuideNumber';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Serie de la guía', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'GuideSerie';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Id de relación con la tabla PaymentZigi ', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'Id_PaymentZigi';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador único del registro en la tabla', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'PaymentZigiMulti', @level2type = N'COLUMN', @level2name = N'Id';

