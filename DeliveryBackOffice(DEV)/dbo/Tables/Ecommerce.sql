CREATE TABLE [dbo].[Ecommerce] (
    [IdEcommerce]          INT            IDENTITY (1, 1) NOT FOR REPLICATION NOT NULL,
    [EcomerceName]         VARCHAR (50)   NULL,
    [EcommerceDescription] NVARCHAR (200) NULL,
    [IsPaymentGateway]     BIT            NULL,
    [IdCountry]            NVARCHAR (2)   NULL,
    [ApiWSEndPoint]        NVARCHAR (50)  NULL,
    [ApiWSPort]            NVARCHAR (5)   NULL,
    [ApiWSResource]        NVARCHAR (100) NULL,
    [ApiWSController]      NVARCHAR (100) NULL,
    [ApiWSMethod]          NVARCHAR (100) NULL,
    [UserKey]              NVARCHAR (50)  NULL,
    [Passkey]              NVARCHAR (500) NULL,
    [SecretKey]            NVARCHAR (100) NULL,
    [CertSourceKey]        NVARCHAR (100) NULL,
    [EcommerceStatus]      BIT            NULL,
    [TokenCreated]         NVARCHAR (50)  NULL,
    [DateCreated]          DATETIME       NULL,
    [TokenUpdate]          NVARCHAR (50)  NULL,
    [DateUpdated]          DATETIME       NULL,
    [IdCustomer]           INT            NULL,
    CONSTRAINT [PK_Ecommerce] PRIMARY KEY CLUSTERED ([IdEcommerce] ASC),
    CONSTRAINT [FK_Ecommerce_Customer] FOREIGN KEY ([IdCustomer]) REFERENCES [dbo].[Customer] ([IdCustomer])
);








GO
CREATE NONCLUSTERED INDEX [idx_UserKey]
    ON [dbo].[Ecommerce]([UserKey] ASC);


GO
CREATE NONCLUSTERED INDEX [idx_IdCustomer]
    ON [dbo].[Ecommerce]([IdCustomer] ASC);

