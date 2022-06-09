CREATE TABLE [dbo].[CatTransportCompany] (
    [IdTransportCompany]          INT           IDENTITY (1, 1) NOT NULL,
    [TransportCompanyName]        NVARCHAR (50) NULL,
    [TransportCompanyDescription] VARCHAR (200) NULL,
    [TansportCompanyAbbreviation] NVARCHAR (10) NULL,
    [CountryID]                   VARCHAR (2)   NULL,
    [RowStatus]                   BIT           CONSTRAINT [DF_CatTransportCompany_RowStatus] DEFAULT ('TRUE') NULL,
    [TokenCreated]                NVARCHAR (50) NULL,
    [DateCreated]                 DATETIME      NULL,
    [TokenUpdated]                NVARCHAR (50) NULL,
    [DataUpdated]                 DATETIME      NULL,
    CONSTRAINT [PK_CatTransportCompany] PRIMARY KEY CLUSTERED ([IdTransportCompany] ASC),
    CONSTRAINT [FK_CatTransportCompany_CatCountry] FOREIGN KEY ([CountryID]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);

