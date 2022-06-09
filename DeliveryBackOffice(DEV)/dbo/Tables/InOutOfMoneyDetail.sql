CREATE TABLE [dbo].[InOutOfMoneyDetail] (
    [io_type]                      INT           NOT NULL,
    [io_vpCodeOfReferences]        INT           NOT NULL,
    [io_ticket]                    VARCHAR (100) NULL,
    [io_amount]                    MONEY         NOT NULL,
    [io_status]                    INT           NOT NULL,
    [io_invoice]                   BIGINT        NULL,
    [io_registryToken]             VARCHAR (50)  NOT NULL,
    [io_registryDate]              DATETIME      NOT NULL,
    [io_updateToken]               VARCHAR (50)  NULL,
    [io_updateDate]                DATETIME      NULL,
    [io_pk_id]                     INT           IDENTITY (1, 1) NOT NULL,
    [inv_SAPDocEntryPaymentDetail] INT           NULL,
    [io_SAPDocEntryPaymentDetail]  INT           NULL,
    [io_SAPErrorPaymentDetail]     VARCHAR (500) NULL,
    [io_canceledInSAP]             BIT           NULL,
    [io_canceledInSAPDescription]  VARCHAR (200) NULL,
    CONSTRAINT [pk_InOutOfMoneyDetail] PRIMARY KEY CLUSTERED ([io_pk_id] ASC)
);

