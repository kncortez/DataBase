CREATE TABLE [dbo].[DeliveryCustomerBankAccount] (
    [DCBA_Id]              INT            NOT NULL,
    [DCBA_Bank_Id]         INT            NOT NULL,
    [DCBA_Customer_Id]     BIGINT         NOT NULL,
    [DCBA_Num_account]     NVARCHAR (50)  NOT NULL,
    [DCBA_Nom_account]     NVARCHAR (MAX) NOT NULL,
    [DCBA_Id_currency]     INT            NOT NULL,
    [DCBA_TokenCreated]    NVARCHAR (50)  NOT NULL,
    [DCBA_DateCreated]     DATETIME       NOT NULL,
    [DCBA_TokenUpdate]     NVARCHAR (50)  NULL,
    [ACN_DateUpdate]       DATETIME       NULL,
    [DCBA_Id_estado]       INT            NOT NULL,
    [DCBA_Prefix]          NVARCHAR (10)  NULL,
    [DCBA_IsCodeIBAN]      BIT            NULL,
    [DCBA_LegalIDN]        NVARCHAR (50)  NULL,
    [DCBA_BankAccountType] VARCHAR (40)   NULL,
    [DCBA_Identification]  VARCHAR (40)   NULL,
    CONSTRAINT [PK_SP_DEPOSITOS_CUENTAS] PRIMARY KEY CLUSTERED ([DCBA_Id] ASC)
);








GO



GO
CREATE NONCLUSTERED INDEX [idx_DCBA_Bank_Id_DCBA_Num_account_DCBA_Id_estado]
    ON [dbo].[DeliveryCustomerBankAccount]([DCBA_Bank_Id] ASC, [DCBA_Num_account] ASC, [DCBA_Id_estado] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_DCBA_Id]
    ON [dbo].[DeliveryCustomerBankAccount]([DCBA_Id] ASC)
    INCLUDE([DCBA_Bank_Id]);

