CREATE TABLE [dbo].[DeliveryCurrency] (
    [Currency_Id]           INT            NOT NULL,
    [Currency_Name]         NVARCHAR (50)  NOT NULL,
    [Currency_Symbol]       NVARCHAR (10)  NOT NULL,
    [Currency_Description]  NVARCHAR (255) NULL,
    [Currency_Order]        INT            NOT NULL,
    [Currency_IdCountry]    NVARCHAR (10)  NOT NULL,
    [Currency_Status]       INT            NOT NULL,
    [Currency_TokenCreated] NVARCHAR (50)  NOT NULL,
    [Currency_DateCreated]  DATETIME       NOT NULL,
    [Currency_TokenUpdate]  NVARCHAR (50)  NULL,
    [Currency_DateUpdate]   DATETIME       NULL,
    [IdCurrencyCOD]         INT            NULL,
    [DefaultPerCountry]     INT            NULL,
    CONSTRAINT [PK_CMS_PRM_TYPE_OF_CURRENCY] PRIMARY KEY CLUSTERED ([Currency_Id] ASC),
    CONSTRAINT [FK_CatCurrencyCOD_DeliveryCurrency] FOREIGN KEY ([IdCurrencyCOD]) REFERENCES [dbo].[CatCurrencyCOD] ([IdCatCurrencyCOD])
);




GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO

GO
EXEC sp_addextendedproperty @name = N'MS_Description',
    @value = N'Moneda por defecto por pais',
    @level0type = N'SCHEMA',
    @level0name = N'dbo',
    @level1type = N'TABLE',
    @level1name = N'DeliveryCurrency',
    @level2type = N'COLUMN',
    @level2name = N'DefaultPerCountry'