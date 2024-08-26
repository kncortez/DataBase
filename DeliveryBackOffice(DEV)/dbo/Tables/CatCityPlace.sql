CREATE TABLE [dbo].[CatCityPlace] (
    [IdCityPlace]           INT          IDENTITY (1, 1) NOT NULL,
    [CityPlace]             VARCHAR (50) NULL,
    [CityPlaceRowStatus]    BIT          NULL,
    [CityPlaceTokenCreated] VARCHAR (50) NULL,
    [CityPlaceDateCreated]  DATETIME     NULL,
    [CityPlaceTokenUpdated] VARCHAR (50) NULL,
    [CityPlaceDateUpdate]   DATETIME     NULL,
    [OrderCityPlace]        INT          NULL,
    [IdCountry]             VARCHAR (2)  NULL,
    CONSTRAINT [PK_CatCityPlace] PRIMARY KEY CLUSTERED ([IdCityPlace] ASC),
    FOREIGN KEY ([IdCountry]) REFERENCES [dbo].[CatCountry] ([IdCountry])
);


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'List of place in the city', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCityPlace', @level2type = N'COLUMN', @level2name = N'CityPlace';


GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'1 active  0 inactive', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCityPlace', @level2type = N'COLUMN', @level2name = N'CityPlaceRowStatus';

GO
EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'Identifier of the country to which city place', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = N'CatCityPlace', @level2type = N'COLUMN', @level2name = N'IdCountry';
