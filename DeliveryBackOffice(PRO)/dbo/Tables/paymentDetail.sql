CREATE TABLE [dbo].[paymentDetail] (
    [pay_ticket]        VARCHAR (100) NULL,
    [pay_type]          VARCHAR (50)  NOT NULL,
    [pay_amount]        MONEY         NOT NULL,
    [pay_status]        INT           NOT NULL,
    [pay_invoice]       BIGINT        NOT NULL,
    [pay_registryToken] VARCHAR (50)  NOT NULL,
    [pay_registryDate]  DATETIME      NOT NULL,
    [pay_updateToken]   VARCHAR (50)  NULL,
    [pay_updateDate]    DATETIME      NULL
);

