-- Iniciar transacción
BEGIN TRANSACTION

BEGIN TRY

--Juan Ramirez
--Add TaxPercentage
 -------------------------------

   ALTER TABLE DefaultValuesPerCountry
   ADD TaxPercentage NVARCHAR(20);

-------------------------------

   UPDATE DefaultValuesPerCountry
    SET TaxPercentage = '1.12'
   WHERE IdCountry IN ('GT');

   UPDATE DefaultValuesPerCountry
    SET TaxPercentage = '1.15'
   WHERE IdCountry IN ('HN'); 

   UPDATE DefaultValuesPerCountry
    SET TaxPercentage = '1.13'
   WHERE IdCountry IN ('SV'); 

 -------------------------------
	COMMIT TRANSACTION
	print 'Actualización de datos exitosa'

END TRY
BEGIN CATCH
	-- Revertir transacción en caso de error
	IF @@TRANCOUNT > 0
		ROLLBACK TRANSACTION
    
	-- Capturar información del error
	SELECT ERROR_MESSAGE(),
			ERROR_SEVERITY(),
			ERROR_STATE()

END CATCH