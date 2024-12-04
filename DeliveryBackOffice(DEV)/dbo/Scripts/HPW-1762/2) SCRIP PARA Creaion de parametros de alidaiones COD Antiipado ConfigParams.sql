-- SCRIP PARA Creaion de parametros de alidaiones COD Antiipado ConfigParams
BEGIN TRY
    BEGIN TRANSACTION;
		INSERT INTO DeliveryBackOffice.dbo.ConfigParams
		(Name,Description,Value,Status,CreateDate,IdCountry,IdCurrencyCOD)
		VALUES
		('MinGuidesPerMonthParam','Cantidad Minima de guias general para COD Anticipado',25,1,GETDATE(),'GT',NULL),
		('MinGuidesPerMonthParam','Cantidad Minima de guias general para COD Anticipado',25,1,GETDATE(),'HN',NULL),
		('ReturnPercentParam','Porcentaje de devolucion general para COD Anticipado',4,1,GETDATE(),'GT',NULL),
		('ReturnPercentParam','Procentaje de devolucion general para COD Anticipado',4,1,GETDATE(),'HN',NULL),
		('GuideAmountCODAnticipatedParam','Valor maximo por guia para validacion general de COD Anticipado',800,1,GETDATE(),'GT',NULL),
		('GuideAmountCODAnticipatedParam','Valor maximo por guia para validacion general de COD Anticipado',800,1,GETDATE(),'HN',NULL),
		('IsOldestParam','Antiguedad en dias de generacion de primera guia general para COD Anticipado',90,1,GETDATE(),'GT',NULL),
		('IsOldestParam','Antiguedad en dias de generacion de primera guia general para COD Anticipado',90,1,GETDATE(),'HN',NULL),
		('MinRangeCODComisison1Param','Minimo de rango para comision COD Anticipado rango 1 - 300',1,1,GETDATE(),'GT',NULL),
		('MaxRangeCODComisison1Param','Maximo de rango para comision COD Anticipado rango 1 - 300',300,1,GETDATE(),'GT',NULL),
		('ValueCODComisison1Param','Valor de comision COD Anticipado rango 1 - 300',6,1,GETDATE(),'GT',NULL),
		('MinRangeCODComisison1Param','Minimo de rango para comision COD Anticipado rango 1 - 300',1,1,GETDATE(),'HN',NULL),
		('MaxRangeCODComisison1Param','Maximo de rango para comision COD Anticipado rango 1 - 300',300,1,GETDATE(),'HN',NULL),
		('ValueCODComisison1Param','Valor de comision COD Anticipado rango 1 - 300',6,1,GETDATE(),'HN',NULL),
		('MinRangeCODComisison2Param','Minimo de rango para comision COD Anticipado rango 301 - 600',301,1,GETDATE(),'GT',NULL),
		('MaxRangeCODComisison2Param','Maximo de rango para comision COD Anticipado rango 301 - 600',600,1,GETDATE(),'GT',NULL),
		('ValueCODComisison2Param','Valor de comision COD Anticipado rango 301 - 600',1,1,GETDATE(),'GT',NULL),
		('MinRangeCODComisison2Param','Minimo de rango para comision COD Anticipado rango 301 - 600',301,1,GETDATE(),'HN',NULL),
		('MaxRangeCODComisison2Param','Maximo de rango para comision COD Anticipado rango 301 - 600',600,1,GETDATE(),'HN',NULL),
		('ValueCODComisison2Param','Valor de comision COD Anticipado rango 301 - 600',1,1,GETDATE(),'HN',NULL),
		('MinRangeCODComisison3Param','Minimo de rango para comision COD Anticipado rango 601 - 800',601,1,GETDATE(),'GT',NULL),
		('MaxRangeCODComisison3Param','Maximo de rango para comision COD Anticipado rango 601 - 800',800,1,GETDATE(),'GT',NULL),
		('ValueCODComisison3Param','Valor de comision COD Anticipado rango 601 - 800',1,1,GETDATE(),'GT',NULL),
		('MinRangeCODComisison3Param','Minimo de rango para comision COD Anticipado rango 601 - 800',601,1,GETDATE(),'HN',NULL),
		('MaxRangeCODComisison3Param','Maximo de rango para comision COD Anticipado rango 601 - 800',800,1,GETDATE(),'HN',NULL),
		('ValueCODComisison3Param','Valor de comision COD Anticipado rango 601 - 800',1,1,GETDATE(),'HN',NULL)
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH
