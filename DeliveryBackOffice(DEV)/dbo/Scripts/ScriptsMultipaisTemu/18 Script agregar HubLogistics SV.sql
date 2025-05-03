--SELECT * FROM DeliveryBackOffice.dbo.HubLogistics

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[HubLogistics]([HubName],[HubAbbreviation],[HubStatus],[IdStation],[IdCountry],[TokenCreated],[DateCreated],[TokenUpdate],[DateUpdated],[IsGateway],[HubLatitude],[HubLongitude],[DescriptionCC]) 
	VALUES('SANTA ANA','SNA',1,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,NULL,NULL,NULL,'Centro de distribucion Santa Ana'),
	('SAN SALVADOR','SSV',1,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,NULL,NULL,NULL,'Centro de distribucion San Salvador'),
	('SAN MIGUEL','SMG',1,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,NULL,NULL,NULL,'Centro de distribucion San Miguel'),
	('LA LIBERTAD','LLB',1,NULL,'SV','SYS-WOROZCO',GETDATE(),NULL,NULL,NULL,NULL,NULL,'Centro de distribucion La Libertad');
	
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;


