CREATE TABLE [dbo].[CostDetail] (
    [IdCostDetail]  INT             IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [IdCost]        INT             NULL,
    [IdTypeOfMoney] INT             NULL,
    [Amount]        DECIMAL (18, 2) NULL,
    [Voucher]       VARCHAR (300)   NULL,
    [RowStatus]     BIT             NULL,
    [TokenCreated]  VARCHAR (50)    NOT NULL,
    [DateCreated]   DATETIME        NOT NULL,
    [TokenUpdated]  VARCHAR (50)    NULL,
    [DateUpdated]   DATETIME        NULL,
    [Responsible]   NVARCHAR (100)  NULL,
    PRIMARY KEY CLUSTERED ([IdCostDetail] ASC),
    CONSTRAINT [FKCostDetCost] FOREIGN KEY ([IdCost]) REFERENCES [dbo].[Cost] ([IdCost]),
    CONSTRAINT [FKCostDetTypeMoney] FOREIGN KEY ([IdTypeOfMoney]) REFERENCES [dbo].[ctgTypeOfInOutOfMoney] ([tio_pk_id])
);












GO
CREATE NONCLUSTERED INDEX [idx_IdCost]
    ON [dbo].[CostDetail]([IdCost] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_DateCreated]
    ON [dbo].[CostDetail]([DateCreated] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_idcost_amount_voucher]
    ON [dbo].[CostDetail]([IdCost] ASC, [Amount] ASC, [Voucher] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_Voucher]
    ON [dbo].[CostDetail]([Voucher] ASC);

