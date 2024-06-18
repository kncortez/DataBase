;WITH CTE_InsertData AS (
    SELECT *
    FROM (
          VALUES
          (1, GETDATE(), 'GT', 1, 2, 7.76374),
          (2, GETDATE(), 'HN', 4, 2, 0.04034),
          (3, GETDATE() + 1, 'GT', 1, 2, 7.76850),
          (4, GETDATE() + 1, 'HN', 4, 2, 0.04034),
          (5, GETDATE() + 2, 'GT', 1, 2, 7.76761),
          (6, GETDATE() + 2, 'HN', 4, 2, 0.04031),
          (7, GETDATE() + 3, 'GT', 1, 2, 7.76844),
          (8, GETDATE() + 3, 'HN', 4, 2, 0.037),
          (9, GETDATE() + 4, 'GT', 1, 2, 7.76638),
          (10, GETDATE() + 4, 'HN', 4, 2, 0.04033),
          (11, GETDATE() + 5, 'GT', 1, 2, 7.76638),
          (12, GETDATE() + 5, 'HN', 4, 2, 0.04035),
          (13, GETDATE() + 6, 'GT', 1, 2, 7.76638),
          (14, GETDATE() + 6, 'HN', 4, 2, 0.04034),
          (15, GETDATE() + 7, 'GT', 1, 2, 7.76241),
          (16, GETDATE() + 7, 'HN', 4, 2, 0.04035),
          (17, GETDATE() + 8, 'GT', 1, 2, 7.76241),
          (18, GETDATE() + 8, 'HN', 4, 2, 0.04030),
          (19, GETDATE(), 'GT', 2, 1, 7.752943),
          (20, GETDATE(), 'HN', 2, 4, 24.672196),
          (21, GETDATE() + 1, 'GT', 2, 1, 7.753243),
          (22, GETDATE() + 1, 'HN', 2, 4, 24.692196)
         ) AS T (IdExchange,ExchangeDate,IdCountry,SourceCurrency,TargetCurrency,ExchangeRate)

)
MERGE INTO CurrencyExchangeRates AS cts
USING CTE_InsertData AS Source
ON cts.IdExchange = Source.IdExchange
WHEN NOT MATCHED THEN
    INSERT (
        ExchangeDate,
        IdCountry,
        SourceCurrency,
        TargetCurrency,
        ExchangeRate
    )
    VALUES (
        Source.ExchangeDate,
        Source.IdCountry,
        Source.SourceCurrency,
        Source.TargetCurrency,
        Source.ExchangeRate
    )
WHEN MATCHED 
     THEN UPDATE 
     SET ExchangeDate = Source.ExchangeDate,
         IdCountry = Source.IdCountry,
         SourceCurrency = Source.SourceCurrency,
         TargetCurrency = Source.TargetCurrency,
         ExchangeRate = Source.ExchangeRate;