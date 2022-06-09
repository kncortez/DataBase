CREATE TABLE [dbo].[CatSaleAdvisor] (
    [IdSaleAdvisor]          INT           IDENTITY (1, 1) NOT NULL,
    [SaleAdvisorCode]        NVARCHAR (12) NOT NULL,
    [SaleAdvisorDescription] NVARCHAR (50) NOT NULL,
    [EmployeID]              INT           NOT NULL,
    [SAPSellerID]            INT           NULL,
    [CountryID]              VARCHAR (2)   NOT NULL,
    [SaleAdvisorStatus]      BIT           NOT NULL,
    [TokenCreated]           NVARCHAR (50) NOT NULL,
    [DateCreated]            DATETIME      NOT NULL,
    [TokenUpdated]           NVARCHAR (50) NULL,
    [DateUpdated]            DATETIME      NULL,
    CONSTRAINT [PK_CatSaleAdvisor] PRIMARY KEY CLUSTERED ([IdSaleAdvisor] ASC),
    CONSTRAINT [FK_CatSaleAdvisor_CatCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);

