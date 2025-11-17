BEGIN TRANSACTION

BEGIN TRY

   ALTER TABLE DefaultValuesPerCountry
   ADD RegxNRC NVARCHAR(200);

   ALTER TABLE DefaultValuesPerCountry
   ADD NRCShortDescription NVARCHAR(500);

   UPDATE DefaultValuesPerCountry
    SET RegxNRC = ''
   WHERE IdCountry IN ('GT','HN');

   UPDATE DefaultValuesPerCountry
    SET RegxNRC = '^\d{1,7}$'
   WHERE IdCountry IN ('SV'); 

   UPDATE DefaultValuesPerCountry
    SET NRCShortDescription = ''
   WHERE IdCountry IN ('GT','HN');

   UPDATE DefaultValuesPerCountry
    SET NRCShortDescription = 'NRC'
   WHERE IdCountry IN ('SV'); 

 -------------------------------

   ALTER TABLE DefaultValuesPerCountry
   ADD RegxPassport NVARCHAR(200);

   ALTER TABLE DefaultValuesPerCountry
   ADD PassportShortDescription NVARCHAR(500);

   UPDATE DefaultValuesPerCountry
    SET RegxPassport = ''
   WHERE IdCountry IN ('GT','HN');

   UPDATE DefaultValuesPerCountry
    SET RegxPassport = '^[A-Za-z]\d{7}$'
   WHERE IdCountry IN ('SV'); 

   UPDATE DefaultValuesPerCountry
    SET PassportShortDescription = 'Pasaporte'
   WHERE IdCountry IN ('GT','HN','SV');

  	COMMIT TRANSACTION
	print 'Campos actualizados exitosamente'

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