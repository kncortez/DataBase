--SELECT * FROM DeliveryBackOffice.dbo.NoLaborCalendar WITH(NOLOCK)

BEGIN TRY
    BEGIN TRANSACTION;

	--INSERTAR ASUETOS SV
	INSERT INTO [dbo].[NoLaborCalendar]
           ([NoLaborDate]
           ,[RowStatus]
           ,[DateCreated]
           ,[TokenCreated]
           ,[DateUpdated]
           ,[TokenUpdated]
           ,[IdCountry])
     VALUES
			('2025-04-17',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --jueves santo
			('2025-04-18',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --viernes santo
			('2025-04-19',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --sabado santo
			('2025-05-01',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Día del Trabajo
			('2025-05-10',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Día de la Madre
			('2025-06-17',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Día del Padre
			('2025-08-04',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Celebración del Divino Salvador del Mundo
			('2025-08-05',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Celebración del Divino Salvador del Mundo
			('2025-08-06',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Celebración del Divino Salvador del Mundo
			('2025-09-15',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Independencia
			('2025-11-02',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Día de los Difuntos
			('2025-12-25',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'), --Navidad
			('2026-01-01',1,GETDATE(),'SYS-WOROZCO',NULL,NULL,'SV'); --Año Nuevo
    
    --Luego de haber creado el SP InsertSundaysInRange, ejecutar para el año 2025 en El Salvador
	EXEC dbo.InsertSundaysInRange '2025-01-01', '2025-12-31', 'SV','SYS-WOROZCO'
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
