
--SCRIPT PARA AGREGAR NUEVA COLUMNA DE PAÍS EN CONFIGPARAMS

ALTER TABLE DeliveryBackOffice.dbo.ConfigParams
ADD IdCountry VARCHAR(2);

ALTER TABLE DeliveryBackOffice.dbo.ConfigParams
ADD CONSTRAINT FK_ConfigParams_CatCountry FOREIGN KEY (IdCountry)
REFERENCES DeliveryBackOffice.dbo.CatCountry(IdCountry);

--SCRIPT PARA AGREGAR NUEVA COLUMNA DE MONEDA EN CONFIGPARAMS

ALTER TABLE DeliveryBackOffice.dbo.ConfigParams
ADD IdCurrencyCOD INT;

ALTER TABLE DeliveryBackOffice.dbo.ConfigParams
ADD CONSTRAINT FK_ConfigParams_CatCurrencyCOD FOREIGN KEY (IdCurrencyCOD)
REFERENCES DeliveryBackOffice.dbo.CatCurrencyCOD (IdCatCurrencyCOD);
