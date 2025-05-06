-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-11-19>
-- Description: <Obtenemos la informacion de un parametro basado en el nombre y pais>
-- =============================================
CREATE PROCEDURE [GetCustomParameterConfig]
(
 @ParameterName AS NVARCHAR(3000),
 @IdCountry     AS VARCHAR(2) = 'GT'
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
           DECLARE @ParamValue NVARCHAR(MAX);

           SELECT @ParamValue = [Value]
             FROM ConfigParams
            WHERE [Name] = @ParameterName
              AND IdCountry = @IdCountry

            IF @ParamValue IS NOT NULL OR
               LEN(@ParamValue) > 0
            BEGIN
               SELECT 1 AS StatusCode,
                      'Parametro obtenido correctamente' AS StatusMessage

               SELECT @ParamValue AS Parameter
            END
            ELSE
            BEGIN
               SELECT 0 AS StatusCode,
                      'No hay datos para mostrar' AS StatusMessage
            END

        -- Confirma la transacción si no hubo errores
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Deshace la transacción en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Manejo del error
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        -- Lanza el error para que sea visible para el cliente que llamó al SP
        SELECT 0 AS StatusCode, 
               'Ha ocurrido un error en el proceso' AS StatusMessage
    END CATCH
END;