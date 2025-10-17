
/*********************************************

NOTA:
	ESTE SCRIPT NO DEBE EJECUTARSE, PUES YA HA SIDO 
	EJECUTADO EN AMBIENTE PRODUCTIVO. ESTA UNICAMENTE 
	COMO HISTORICO DE LOS CAMBIOS QUE SE HAN EJECUTADO
	EN PRODUCCION.

**********************************************/


-- ACTUALIZACIÓN DE ACTIVIDAD ECONOMICA PARA FORZA

BEGIN TRANSACTION;
BEGIN TRY

UPDATE AddInfoByCodeOfReference 
   SET [Value] = 'Servicios para el transporte acuático'
 WHERE IdAddInfoByCodeOfReference = 3
   AND CodeOfReference = '1378846'
   AND [Name] = 'DescActividad'
  COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH