/*
  Name: APIForzaDelivery_VisitPointClient_Update_GuideTypes_ByCodeOfReference
  Summary: Actualiza el campo ParserGuideTypes en la tabla VisitPointClient basado en el CodeOfReference proporcionado.
  Inputs:
    @CodeOfReference INT (obligatorio): Código de referencia del punto de visita a actualizar.
    @GuidesTypes NVARCHAR(100) (obligatorio): Tipos de guías a asignar (ejemplo: 'STANDARD, COLLECT').
    @Token NVARCHAR(100) (opcional): Token para rastrear la actualización. Valor por defecto: 'SYS_HermesParserGuideTypes'.
  Outputs:
    ResultSet1: Código de estado y mensaje indicando el resultado de la operación.
      - Code INT: Código de estado (200 = éxito, 400 = error de validación, 500 = error interno).
      - Message NVARCHAR(255): Mensaje descriptivo del resultado.
  Notes:
    - 
  Author: <Bilkar Morataya> | Created: 2025-12-23 | Module: Hermes Desktop - Punto de Visita
  Ticket: <FDAPI-5303>
  CHANGELOG:
    - 2025-12-23 <Bilkar Morataya> V1: <FDAPI-5303> Creación de procedimiento para actualizar ParserGuideTypes
*/


CREATE PROCEDURE dbo.APIForzaDelivery_VisitPointClient_Update_GuideTypes_ByCodeOfReference
    @CodeOfReference INT,
    @GuidesTypes NVARCHAR(100),
    @Token NVARCHAR(100) = 'SYS_HermesParserGuideTypes'
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Validación de parámetros obligatorios
    IF @CodeOfReference IS NULL OR LTRIM(RTRIM(@CodeOfReference)) = ''
    BEGIN
        SELECT 400 AS Code, 'El parámetro @CodeOfReference es obligatorio.' AS Message;
        RETURN;
    END

    IF @GuidesTypes IS NULL OR LTRIM(RTRIM(@GuidesTypes)) = ''
    BEGIN
        SELECT 400 AS Code, 'El parámetro @GuidesTypes es obligatorio.' AS Message;
        RETURN;
    END

    -- 2. Manejo de Transacción y Errores
    BEGIN TRY
        BEGIN TRANSACTION;

        -- 3. Actualización de los registros
        UPDATE dbo.VisitPointClient
        SET
            ParserGuideTypes = @GuidesTypes,
            TokenUpdated = @Token,
            DateUpdated = GETDATE() -- Sugerencia: Mantener trazabilidad de tiempo
        WHERE
            CodeOfReference = @CodeOfReference;

        -- 4. Verificar si se afectaron filas (Opcional pero recomendado)
        IF @@ROWCOUNT = 0
        BEGIN
            ROLLBACK TRANSACTION;
            SELECT 404 AS Code, 'No se encontró ningún punto de visita con el CodeOfReference proporcionado.' AS Message;
            RETURN;
        END

        COMMIT TRANSACTION;

        -- 5. Respuesta exitosa solicitada
        SELECT 200 AS Code, 'Tipo de Guías asignada correctamente' AS Message;

    END TRY
    BEGIN CATCH
        -- 6. Rollback en caso de error
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        -- Registro del error (puedes usar tu tabla RoutePreparationLogError si lo deseas)
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        SELECT 500 AS Code, 'Error interno: ' + @ErrorMessage AS Message;

        -- Opcional: Re-lanzar el error para que la aplicación lo detecte
        -- RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END