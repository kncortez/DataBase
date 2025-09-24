    /***
-- ACTUALIZACIÓN DE ACTIVIDAD ECONOMICA PARA FORZA
***/

BEGIN TRANSACTION;
BEGIN TRY


update AddInfoByCodeOfReference 
set [Name] = 'CodigoActividad',
    [Value] = '52220'
where [Name] = 'CodigoActividad'
  and CodeOfReference = '1378846'

update AddInfoByCodeOfReference 
set [Name] = 'DescActividad',
    [Value] = 'Actividades de servicios relacionadas con el transporte acuático'
where [Name] = 'DescActividad'
  and CodeOfReference = '1378846'
    COMMIT TRANSACTION;

END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
    DECLARE @ErrorState INT = ERROR_STATE();

    RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);

END CATCH


