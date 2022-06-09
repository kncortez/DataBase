CREATE TABLE [dbo].[Batch] (
    [IdBatch]             INT             IDENTITY (1, 1) NOT NULL,
    [BankId]              INT             NOT NULL,
    [BatchNumber]         INT             NOT NULL,
    [Name]                NVARCHAR (50)   NULL,
    [Date]                DATETIME        CONSTRAINT [DF_Batch_Date] DEFAULT (getdate()) NOT NULL,
    [TotalAmountIncluded] DECIMAL (18, 2) NULL,
    [BatchTimeRange]      VARCHAR (300)   NULL,
    [RowStatus]           BIT             DEFAULT ('TRUE') NOT NULL,
    CONSTRAINT [PK_Batch_IdBatch] PRIMARY KEY CLUSTERED ([IdBatch] ASC),
    CONSTRAINT [FK_Batch_DeliveryBank] FOREIGN KEY ([BankId]) REFERENCES [dbo].[DeliveryBank] ([Id_bank]),
    CONSTRAINT [UK_Batch_BankId_BatchNumber] UNIQUE NONCLUSTERED ([BankId] ASC, [BatchNumber] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Campo para poder registrar el rango de hora en que se ejecutó la generación de lotes', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'Batch', @level2type = N'COLUMN', @level2name = N'BatchTimeRange';

