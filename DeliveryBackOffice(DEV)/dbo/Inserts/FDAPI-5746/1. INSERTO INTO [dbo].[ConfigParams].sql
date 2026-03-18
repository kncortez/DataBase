USE DeliveryBackOffice;

GO
BEGIN
INSERT INTO [dbo].[ConfigParams] (Name,Description,Value,Status,CreateDate,IdCountry,IdCurrencyCOD)
VALUES ('MicroserviceCourier','Dirección de microservicio courier','AGREGAR URL API MICROSERVICIO AMBIENTE INSTALACION',1,GETDATE(),NULL,NULL)
END

