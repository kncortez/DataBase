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
	[DeliveryFavCODId]     INT            NULL,
    CONSTRAINT [PK_SP_DEPOSITOS_CUENTAS] PRIMARY KEY CLUSTERED ([DCBA_Id] ASC)
);




GO
CREATE NONCLUSTERED INDEX [IDX_DCBA_ID_DCBA_ID_ESTADO]
    ON [dbo].[DeliveryCustomerBankAccount]([DCBA_Id] ASC, [DCBA_Id_estado] ASC);

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identificador de la tabla DeliveryCustomerBankAccount', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'DeliveryCustomerBankAccount', @level2type = N'COLUMN', @level2name = N'DeliveryFavCODId';
GO
