 --Parametro para redireccionar hacia landing de checkout sin login
 
 INSERT INTO dbo.ConfigParams( [Name],	[Description],	[Value],	[Status],	[CreateDate],	[IdCountry],	[IdCurrencyCOD])
 VALUES('URLWithoutLogin','URL la landing para checkout sin login','https://develop.forzadelivery.com/checkout/',1,GETDATE(),NULL,NULL)
