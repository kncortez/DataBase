--SCRIPT PARA AGREGAR COLUMNA DE IDCOUNTRY PARA LA TABLA NOLABORCALENDAR

--SELECT * FROM [DeliveryBackOffice].[dbo].[NoLaborCalendar]

BEGIN TRY
    BEGIN TRANSACTION;

	ALTER TABLE [DeliveryBackOffice].[dbo].[NoLaborCalendar]
	ADD IdCountry VARCHAR(2) NOT NULL DEFAULT 'GT';

	ALTER TABLE [DeliveryBackOffice].[dbo].[NoLaborCalendar]
	ADD CONSTRAINT FK_NoLaborCalendar_CatCountry
	FOREIGN KEY (IdCountry)
	REFERENCES [DeliveryBackOffice].[dbo].[CatCountry](IdCountry);

	--Eliminar la restricción de clave única existente
	ALTER TABLE [DeliveryBackOffice].[dbo].[NoLaborCalendar]
	DROP CONSTRAINT UQ_NoLaborCalendar_NoRepeats;

	--Crear una nueva restricción de clave única compuesta
	ALTER TABLE [DeliveryBackOffice].[dbo].[NoLaborCalendar]
	ADD CONSTRAINT UQ_NoLaborCalendar_Composite UNIQUE (NoLaborDate, IdCountry);

	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;