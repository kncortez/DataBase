INSERT INTO ConfigParams 
(
  Name
 ,Description
 ,Value
 ,Status
 ,CreateDate
 ,IdCountry
 ,IdCurrencyCOD
)
VALUES
(
 'TaxPercentage',
 'Porcentaje para el calculo de IVA ',
 '1.12',
 1,
 GETDATE(),
 'GT',
 NULL
 )

INSERT INTO ConfigParams 
(
  Name
 ,Description
 ,Value
 ,Status
 ,CreateDate
 ,IdCountry
 ,IdCurrencyCOD
)
VALUES
(
 'TaxPercentage',
 'Porcentaje para el calculo de ISV ',
 '1.15',
 1,
 GETDATE(),
 'HN',
 NULL
 )