CREATE TABLE [dbo].[DeliveryOrderPaymentDetail] (
    [DopId]                 BIGINT          IDENTITY (1, 1) NOT NULL,
    [GuideNumber]           INT             NOT NULL,
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
    PRIMARY KEY CLUSTERED ([DopId] ASC)
);










GO
CREATE NONCLUSTERED INDEX [IX_NC_GuideSerieGuideNumber_DeliveryOrderPaymentDetail]
    ON [dbo].[DeliveryOrderPaymentDetail]([GuideSerie] ASC, [GuideNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_IdHeaderRecolection]
    ON [dbo].[DeliveryOrderPaymentDetail]([IdHeaderRecolection] ASC);


GO



GO
CREATE NONCLUSTERED INDEX [IDX_GuideNumber_GuideSerie]
    ON [dbo].[DeliveryOrderPaymentDetail]([GuideNumber] ASC, [GuideSerie] ASC);


GO
CREATE NONCLUSTERED INDEX [IDX_delivery_order_payment]
    ON [dbo].[DeliveryOrderPaymentDetail]([GuideSerie] ASC, [GuideNumber] ASC);

