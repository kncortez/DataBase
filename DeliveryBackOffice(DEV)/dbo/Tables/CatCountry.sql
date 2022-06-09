CREATE TABLE [dbo].[CatCountry] (
    [IdCountry]           VARCHAR (2)  NOT NULL,
    [CountryNameEN]       VARCHAR (55) NULL,
    [CountryNameES]       VARCHAR (55) NULL,
    [CountryAlpha3Code]   VARCHAR (3)  NULL,
    [CountryNationality]  VARCHAR (50) NULL,
    [CountryRowStatus]    BIT          CONSTRAINT [DF_CatCountry_CountryRowStatus] DEFAULT ('TRUE') NULL,
    [CountryTokenCreated] VARCHAR (50) NULL,
    [CountryDateCreated]  DATETIME     NOT NULL,
    [CountryTokenUpdated] VARCHAR (50) NULL,
    [CountryDateUpdated]  DATETIME     NULL,
    CONSTRAINT [PK_CatCountry] PRIMARY KEY CLUSTERED ([IdCountry] ASC)
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ISO Code 3166 Alpha2Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCountry', @level2type = N'COLUMN', @level2name = N'IdCountry';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'ISO Code 3166 Alpha3Code', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCountry', @level2type = N'COLUMN', @level2name = N'CountryAlpha3Code';

