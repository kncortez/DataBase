use deliverybackoffice
go
/*
Pasos 
1. Insertar en tabla ConfigParams valor de porcentaje de comision para HN
*/
BEGIN TRY
    BEGIN TRANSACTION;

    update ConfigParams
      set IdCountry='GT'
    where name ='CODRateDef'
    AND IdCountry IS NULL
    --1. Insertar registro de porcentaje de comision (idCountry HN)
    INSERT INTO ConfigParams([Name],[Description],Value,Status,CreateDate,IdCountry)
    VALUES ('CODRateDef','Tarifa COD Default','12.14',1,GETDATE(),'HN')

    SELECT * 
      FROM ConfigParams 
     WHERE [name] = 'CODRateDef' 
       AND IdCountry = 'HN'

    COMMIT TRANSACTION;
END TRY 
    
BEGIN CATCH
	select  ERROR_MESSAGE() 
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	
END CATCH;