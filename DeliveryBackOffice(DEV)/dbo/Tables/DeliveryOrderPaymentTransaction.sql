CREATE TABLE [dbo].[DeliveryOrderPaymentTransaction] (
    [DopId]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [GuideNumber]           INT             NULL,
    [GuideSerie]            NVARCHAR (2)    NULL,
    [PayTypeId]             INT             NULL,
    [TypeofInOutMoneyId]    INT             NULL,
    [TimePlaId]             INT             NULL,
    [amount]                DECIMAL (18, 2) NULL,
    [TokenCreated]          VARCHAR (50)    NULL,
    [DateCreated]           DATETIME        NULL,
    [TokenUpdated]          VARCHAR (50)    NULL,
    [DateUpdated]           DATETIME        NULL,
    [PaymentRecollections]  DECIMAL (18, 2) NULL,
    [PaymentNow]            DECIMAL (18, 2) NULL,
    [PaymentDelivery]       DECIMAL (18, 2) NULL,
    [StartDate]             DATETIME        NULL,
    [EndDate]               DATETIME        NULL,
    [ShipmentCompleted]     BIT             NULL,
    [RecollectionCompleted] BIT             NULL,
    [PaidGuide]             BIT             NULL,
    [TransaccionFAC]        NVARCHAR (100)  NULL,
    [IdHeaderRecolection]   INT             NULL,
    [RecolectNow]           DECIMAL (18, 2) NULL,
    [RecolectDelivery]      DECIMAL (18, 2) NULL,
    [RecolectPayment]       DECIMAL (18, 2) NULL,
    [TypeServiceId]         INT             NULL,
    [AccountId]             BIGINT          NULL,
    [CODAmountProcess]      DECIMAL (18, 2) NULL,
    [VisitPoint]            INT             NULL,
    [Fel]                   NVARCHAR (100)  NULL,
    PRIMARY KEY CLUSTERED ([DopId] ASC),
    CONSTRAINT [FK_Account] FOREIGN KEY ([AccountId]) REFERENCES [dbo].[Account] ([AccIdAccount]),
    CONSTRAINT [FK_CatTypeServiceClosure] FOREIGN KEY ([TypeServiceId]) REFERENCES [dbo].[CatTypeServiceClosure] ([IdTypeService])
);








GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID del tipo de servicio de tabla CatTypeServiceClosure', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderPaymentTransaction', @level2type = N'COLUMN', @level2name = N'TypeServiceId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ID de la cuenta del usuario', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderPaymentTransaction', @level2type = N'COLUMN', @level2name = N'AccountId';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Express center que hizo la transaccion', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderPaymentTransaction', @level2type = N'COLUMN', @level2name = N'VisitPoint';


GO
CREATE NONCLUSTERED INDEX [IDX_GuideNumber_GuideSerie]
    ON [dbo].[DeliveryOrderPaymentTransaction]([GuideNumber] ASC, [GuideSerie] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_ShipmentCompleted_AccountId_DateCreated]
    ON [dbo].[DeliveryOrderPaymentTransaction]([ShipmentCompleted] ASC, [AccountId] ASC, [DateCreated] ASC)
    INCLUDE([GuideNumber], [GuideSerie], [TypeofInOutMoneyId], [amount], [TypeServiceId], [CODAmountProcess]);


GO
CREATE NONCLUSTERED INDEX [idx_GuideSerie_AccountId_DateCreated]
    ON [dbo].[DeliveryOrderPaymentTransaction]([GuideSerie] ASC, [AccountId] ASC, [DateCreated] ASC)
    INCLUDE([TypeofInOutMoneyId], [amount], [TypeServiceId], [CODAmountProcess], [Fel]);


GO
CREATE NONCLUSTERED INDEX [IDX_DateCreated]
    ON [dbo].[DeliveryOrderPaymentTransaction]([DateCreated] ASC)
    INCLUDE([GuideNumber], [GuideSerie]);


GO
CREATE NONCLUSTERED INDEX [IDX_AccountId_DateCreated_CODAmountProcess]
    ON [dbo].[DeliveryOrderPaymentTransaction]([AccountId] ASC, [DateCreated] ASC, [CODAmountProcess] ASC)
    INCLUDE([GuideNumber], [GuideSerie]);


GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'identificador del registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'DopId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Número de guía',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'GuideNumber'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Serie de guía',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'GuideSerie'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'id tipo de pago',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'PayTypeId'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien creó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'TokenCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de creación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'DateCreated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Código de quien modificó el registro',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'TokenUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Fecha de modificación',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'DateUpdated'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Monto ',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'amount'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Envio completado (1 Si, 0 No)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'ShipmentCompleted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Recolección completada(1 Si, 0 No)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'RecollectionCompleted'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Guía pagada(1 Si, 0 No)',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'PaidGuide'
GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Factura electrónica',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryOrderPaymentTransaction',
    @level2type = N'COLUMN',
    @level2name = N'Fel'