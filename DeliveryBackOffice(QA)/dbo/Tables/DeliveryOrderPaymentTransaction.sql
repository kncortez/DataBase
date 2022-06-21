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

