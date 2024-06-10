CREATE TABLE [dbo].[CurrencyExchangeRates] (
    [IdExchange]               INT             IDENTITY (1, 1) NOT NULL PRIMARY KEY,
    [ExchangeDate]             DATETIME        NOT NULL,
    [IdCountry]                VARCHAR(2)      NOT NULL,
    [SourceCurrency]           INT             NULL,
    [TargetCurrency]           INT             NULL,
    [ExchangeRate]             DECIMAL (12, 6) NULL,
    CONSTRAINT [FK_SourceCurrency_CatCurrencyCOD] FOREIGN KEY (SourceCurrency) REFERENCES [dbo].[CatCurrencyCOD](IdCatCurrencyCOD),
    CONSTRAINT [FK_TargetCurrency_CatCurrencyCOD] FOREIGN KEY (TargetCurrency) REFERENCES [dbo].[CatCurrencyCOD](IdCatCurrencyCOD)
);

GO

EXECUTE SYS.sp_addextendedproperty @name=N'MS_Description', @value=N'Tabla que contiene la informacion de las tasas de cambio por fecha ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CurrencyExchangeRates'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Id del registro para tasa de cambio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CurrencyExchangeRates', @level2type=N'COLUMN',@level2name=N'IdExchange'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Fecha de la tasa de cambio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CurrencyExchangeRates', @level2type=N'COLUMN',@level2name=N'ExchangeDate'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Pais al que pertenece la configuración de tasa de cambio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CurrencyExchangeRates', @level2type=N'COLUMN',@level2name=N'IdCountry'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Moneda origen de la tasa de cambio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CurrencyExchangeRates', @level2type=N'COLUMN',@level2name=N'SourceCurrency'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Moneda destino de la tasa de cambio' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CurrencyExchangeRates', @level2type=N'COLUMN',@level2name=N'TargetCurrency'
GO

EXECUTE sp_addextendedproperty @name=N'MS_Description', @value=N'Tasa de cambio de la configuracion registrada' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CurrencyExchangeRates', @level2type=N'COLUMN',@level2name=N'ExchangeRate'
GO
