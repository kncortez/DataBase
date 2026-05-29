CREATE TABLE [dbo].[DeliveryOrderPaid] (
    [IdDeliveryOrderPaid]       BIGINT        IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [Guide_Serie]               NVARCHAR (2)  NULL,
    [Guide_Number]              INT           NULL,
    [Deposit_Number]            NVARCHAR (50) NULL,
    [IsVirtualDeposit]          BIT           CONSTRAINT [DF_DeliveryOrderPaid_IsVirtualDeposit] DEFAULT ('TRUE') NULL,
    [IdStatus]                  BIT           CONSTRAINT [DF_DeliveryOrderPaid_IdStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]              NVARCHAR (50) NULL,
    [DateCreated]               DATETIME      NULL,
    [TokenUpdate]               NVARCHAR (50) NULL,
    [DateUpdate]                DATETIME      NULL,
    [IdDeliveryOrderPaidHeader] BIGINT        NULL,
    [DocumentType]              INT           NULL,
    CONSTRAINT [PK_DeliveryOrderPaid] PRIMARY KEY CLUSTERED ([IdDeliveryOrderPaid] ASC),
    CONSTRAINT [FK_DeliveryOrderPaid_DeliveryOrder] FOREIGN KEY ([Guide_Serie], [Guide_Number]) REFERENCES [dbo].[DeliveryOrder] ([Guide_Serie], [Guide_Number])
);












GO



GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 electronic 0 manual', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderPaid', @level2type = N'COLUMN', @level2name = N'IsVirtualDeposit';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 Paid 0 UnPaid', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderPaid', @level2type = N'COLUMN', @level2name = N'IdStatus';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'0 Depósito, 1 Autorización', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryOrderPaid', @level2type = N'COLUMN', @level2name = N'DocumentType';


GO



GO
CREATE NONCLUSTERED INDEX [IDX_IdStatus_INCLUDE]
    ON [dbo].[DeliveryOrderPaid]([IdStatus] ASC)
    INCLUDE([Guide_Serie], [Guide_Number]);


GO
CREATE NONCLUSTERED INDEX [idx_DeliveryOrderPaid_Guide_Status_Consolidated]
    ON [dbo].[DeliveryOrderPaid]([Guide_Serie] ASC, [Guide_Number] ASC, [IdStatus] ASC);

