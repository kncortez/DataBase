/* =================================================
   SP:        [dbo].[spws_guide_route_reassignment]
   Propósito: Reasignación de rutas a guías por país.
              Valida guías contra DeliveryOrder y rutas
              contra CatRoute. Hace UPSERT si todo es válido.
   Autor:     Pedro Macajol
   Historia:  FDAPI-6343
   Fecha:     26-05-2026
===== CHANGELOG ============================
    Fecha       Historia        Descripción                                 Autor   
    ----------  --------------  -------------------------------------    ----------
    2026-05-26  FDAPI-6343     Creación del SP                           Pedro Macajol
=========================================== */
CREATE PROCEDURE [dbo].[spws_guide_route_reassignment]
    @IdCountry VARCHAR(2),
    @TblItems  [dbo].[TblGuideRouteItemType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @Errors TABLE (
            RowColumn    NVARCHAR(10),
            NoGuia       NVARCHAR(50),
            ErrorMessage NVARCHAR(200)
        );

        DECLARE @RowIndex INT, @Guide NVARCHAR(50), @Route NVARCHAR(50);
        DECLARE @Serie NVARCHAR(10);
        DECLARE @Number INT;
        DECLARE @CountryFound VARCHAR(2);

        DECLARE item_cursor CURSOR LOCAL FAST_FORWARD FOR
            SELECT RowIndex, Guide, RouteCode FROM @TblItems;

        OPEN item_cursor;
        FETCH NEXT FROM item_cursor INTO @RowIndex, @Guide, @Route;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @Serie  = LEFT(@Guide, PATINDEX('%[0-9]%', @Guide) - 1);
            SET @Number = SUBSTRING(@Guide, PATINDEX('%[0-9]%', @Guide), LEN(@Guide));

            IF @Serie IS NULL OR @Serie = '' OR @Number IS NULL
            BEGIN
                INSERT INTO @Errors (RowColumn, NoGuia, ErrorMessage)
                VALUES ('A' + CAST(@RowIndex AS VARCHAR), @Guide, 'Formato de guía inválido');
            END
            ELSE
            BEGIN
                -- Validación 1 y 2: Verificar existencia de guía y país en una sola consulta
                SET @CountryFound = NULL;

                SELECT @CountryFound = SenderCountryId
                FROM dbo.DeliveryOrder WITH (NOLOCK)
                WHERE Guide_Serie  = @Serie
                  AND Guide_Number = @Number;

                IF @CountryFound IS NULL
                BEGIN
                    INSERT INTO @Errors (RowColumn, NoGuia, ErrorMessage)
                    VALUES ('A' + CAST(@RowIndex AS VARCHAR), @Guide, N'Guía no existe en el sistema');
                END
                ELSE IF @CountryFound <> @IdCountry
                BEGIN
                    INSERT INTO @Errors (RowColumn, NoGuia, ErrorMessage)
                    VALUES ('A' + CAST(@RowIndex AS VARCHAR), @Guide, N'La guía no corresponde al país seleccionado');
                END

                -- Validación 3: Verificar que la ruta existe, está habilitada y es de tipo Ultima Milla
                IF NOT EXISTS (
                    SELECT 1
                    FROM dbo.CatRoute CR WITH (NOLOCK)
                    INNER JOIN dbo.CatTypeRoute CTR WITH (NOLOCK)
                        ON CR.IdTypeRoute = CTR.IdTypeRoute
                    WHERE CR.RowStatus   = 1
                      AND CR.CountryId   = @IdCountry
                      AND CR.CodeRoute   = @Route
                      AND CTR.[Name]     = 'Ultima Milla'
                )
                BEGIN
                    INSERT INTO @Errors (RowColumn, NoGuia, ErrorMessage)
                    VALUES ('B' + CAST(@RowIndex AS VARCHAR), @Guide, N'La ruta asignada no está habilitada o no es de tipo Ultima Milla');
                END
            END

            FETCH NEXT FROM item_cursor INTO @RowIndex, @Guide, @Route;
        END

        CLOSE item_cursor;
        DEALLOCATE item_cursor;

        -- Si hay errores, retornarlos
        IF EXISTS (SELECT 1 FROM @Errors)
        BEGIN
            SELECT RowColumn, NoGuia, ErrorMessage FROM @Errors;
            RETURN;
        END

        -- Si no hay errores, realizar el MERGE
        MERGE dbo.GuideRouteReassignment AS target
        USING @TblItems AS source
            ON  target.NoGuia    = source.Guide
            AND target.IdCountry = @IdCountry
        WHEN MATCHED THEN
            UPDATE SET
                target.RouteCode   = source.RouteCode,
                target.DateUpdated = GETDATE(),
                target.RowStatus   = 1
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (NoGuia,       RouteCode,        IdCountry,  RowStatus, DateCreated)
            VALUES (source.Guide, source.RouteCode, @IdCountry, 1,         GETDATE());

        SELECT '200'                             AS StatusCode,
               'Registro guardado correctamente' AS [Message];

    END TRY
    BEGIN CATCH

        IF CURSOR_STATUS('local', 'item_cursor') >= 0
        BEGIN
            CLOSE item_cursor;
            DEALLOCATE item_cursor;
        END

        DECLARE @ErrorMessage  NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT            = ERROR_SEVERITY();
        DECLARE @ErrorState    INT            = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO