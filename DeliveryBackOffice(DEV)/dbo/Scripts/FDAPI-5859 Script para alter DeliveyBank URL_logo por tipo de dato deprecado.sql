/* =================================================
   SCRIPT:
   Propósito: Cambiar el tipo de dato a dbo.DeliveryBank.URL_logo por tipo de dato deprecado 
   Autor:     Brenda Echeverria
   Historia:  FDAPI-5859
   Fecha:     2026-03-13
   =========================================== */
/* === CHANGELOG =============================

   =========================================== */

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRY
    DECLARE @MaxLength        INT;
    DECLARE @NewLength        INT;
    DECLARE @RowsWithData     INT;
    DECLARE @Sql              NVARCHAR(MAX);
    DECLARE @CurrentDataType  SYSNAME;

    IF OBJECT_ID(N'dbo.DeliveryBank', N'U') IS NULL
    BEGIN
        PRINT N'ERROR: La tabla dbo.DeliveryBank no existe.';
        RETURN;
    END;

    IF COL_LENGTH(N'dbo.DeliveryBank', N'URL_logo') IS NULL
    BEGIN
        PRINT N'ERROR: La columna dbo.DeliveryBank.URL_logo no existe.';
        RETURN;
    END;

    SELECT @CurrentDataType = t.name
    FROM sys.columns c
    INNER JOIN sys.types t
        ON c.user_type_id = t.user_type_id
    WHERE c.object_id = OBJECT_ID(N'dbo.DeliveryBank')
      AND c.name = N'URL_logo';

    PRINT N'Tipo actual detectado: ' + ISNULL(@CurrentDataType, N'(desconocido)');

    IF @CurrentDataType IN (N'nvarchar', N'nchar')
    BEGIN
        PRINT N'La columna ya es de tipo Unicode.';
        RETURN;
    END;

    SELECT
          @RowsWithData = COUNT(1)
        , @MaxLength    = ISNULL(MAX(LEN(CONVERT(NVARCHAR(MAX), URL_logo))), 0)
    FROM dbo.DeliveryBank WITH (NOLOCK)
    WHERE URL_logo IS NOT NULL;

    SET @NewLength = @MaxLength + 30;

    IF ISNULL(@NewLength, 0) = 0
        SET @NewLength = 100;

    PRINT N'Longitud máxima actual encontrada: ' + CAST(@MaxLength AS NVARCHAR(20));
    PRINT N'Longitud propuesta para la nueva columna: ' + CAST(@NewLength AS NVARCHAR(20));

    IF ISNULL(@RowsWithData, 0) = 0
    BEGIN
        PRINT N'No existen registros con valor en URL_logo. Se utilizará longitud por defecto de 100.';
        SET @NewLength = 100;
    END;

    IF @NewLength > 4000
    BEGIN
        PRINT N'ADVERTENCIA: La longitud calculada (' + CAST(@NewLength AS NVARCHAR(20))
            + N') supera el máximo permitido para NVARCHAR(n).';
        PRINT N'Se recomienda evaluar NVARCHAR(MAX) o redefinir el tamaño manualmente.';
        RETURN;
    END;

    SET @Sql = N'
        ALTER TABLE dbo.DeliveryBank
        ALTER COLUMN URL_logo NVARCHAR(' + CAST(@NewLength AS NVARCHAR(10)) + N') NULL;
    ';

    PRINT N'SQL a ejecutar: ' + @Sql;

    EXEC sp_executesql @Sql;

    PRINT N'ALTER TABLE aplicado correctamente sobre dbo.DeliveryBank.URL_logo.';
END TRY
BEGIN CATCH
    PRINT N'ERROR: ' + ERROR_MESSAGE();
END CATCH;