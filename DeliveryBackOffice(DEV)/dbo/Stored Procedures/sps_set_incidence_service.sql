/* =================================================
   SP:        [<dbo>].[sps_set_incidence_service]
   Propósito: <Registrar incidente de entrega en sitio>
   Autor:     <Cano, Carlos>
   Historia:  <El Autor no dejó registro de la Epica usada para la creación>
   Fecha:     2020-09-08
   === CHANGELOG ================================
   2026-05-15 | Historia/épica: <FDAPI-6282> | Autor: Keila Cortéz |
   -----
   2026-03-18 | Historia/épica: <FDAPI-5584> | Autor: <Bilkar Morataya> | Se agregó almacenar el comentario en la tabla de ConfirmationOfIncidence, además de registrar el usuario que creó el intento de entrega fallida.
   ============================================
*/

ALTER PROCEDURE [dbo].[sps_set_incidence_service]
    @Token VARCHAR(200),
    @IdIssue INT,
    @Comment VARCHAR(500),
    @Guides TblListGuides READONLY
AS
BEGIN
    DECLARE @jsonResult NVARCHAR(MAX);

    -- Validacion de Token
    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.TokenLog
        WHERE TknRowStatus = 1
          AND TknIdToken = @Token
    )
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF
            (
                (
                    SELECT ',{"IdStatus":' + '500' + ',' + '"Description":"' + 'Token inválido' + '"' + '}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'),
                1,
                1,
                ''
            )
        );

        SELECT '[' + @jsonResult + ']' FormatJson;

        RETURN;
    END;

    -- control de inserciones para transacción
    DECLARE @RInserted INT = 0;

    -- estatus
    DECLARE @IdEstatus AS INT;

    SET @IdEstatus =
    (
        SELECT StatusOrderId
        FROM [dbo].[StatusOrder]
        WHERE OrderDescription = 'Incidencia en ruta'
    );

    DECLARE @IdSystem INT =
    (
        SELECT SysIdSystem
        FROM dbo.CatSystem
        WHERE SysNameSystem = 'FDExpressCenter'
    );

    BEGIN TRANSACTION;

    BEGIN TRY

        DECLARE @GuidesWork TABLE
        (
            Guide_Serie NVARCHAR(2),
            Guide_Number INT,
            PRIMARY KEY (Guide_Serie, Guide_Number)
        );

        DECLARE @InsertedConfirmation TABLE
        (
            Guide_Serie NVARCHAR(2),
            Guide_Number INT,
            IdConfirmationOfIncidence INT
        );

        DECLARE @InsertedAttempts TABLE
        (
            Guide_Serie NVARCHAR(2),
            Guide_Number INT,
            IdAttempt INT,
            IdConfirmationOfIncidence INT
        );

        ;WITH GuidesCTE AS
        (
            SELECT DISTINCT
                G.Guide_Serie,
                G.Guide_Number
            FROM @Guides G
        )
        INSERT INTO @GuidesWork
        (
            Guide_Serie,
            Guide_Number
        )
        SELECT
            G.Guide_Serie,
            G.Guide_Number
        FROM GuidesCTE G;

        -- Crear ConfirmationOfIncidence por guía. Registro de Incidencia
        MERGE [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence] AS TARGET
        USING
        (
            SELECT
                GW.Guide_Serie,
                GW.Guide_Number
            FROM @GuidesWork GW
            INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder DO
                ON DO.Guide_Serie = GW.Guide_Serie
               AND DO.Guide_Number = GW.Guide_Number
        ) AS SOURCE
            ON 1 = 0
        WHEN NOT MATCHED THEN
            INSERT
            (
                ConfirmationOfIncidentToken,
                CatTypeConfirmationOfIncidenceId,
                IsValid,
                IsConfirmed,
                StatusOrderId,
                DateStatusOrder,
                RowStatus,
                TokenCreated,
                DateCreated,
                TokenUpdated,
                DateUpdated,
                IsActionIssued,
                ActionObservation,
                CourierContempt,
                ClientConfirmsReturn,
                IncidentfinalizedbySAC,
                IsDenied,
                LastStatusOrderId,
                CommentOnIncident
            )
            VALUES
            (
                @Token,    -- ConfirmationOfIncidentToken - nvarchar(50)
                1,         -- CatTypeConfirmationOfIncidenceId - int
                0,         -- IsValid - bit
                0,         -- IsConfirmed - bit
                @IdEstatus,-- StatusOrderId - tinyint
                GETDATE(), -- DateStatusOrder - datetime
                1,         -- RowStatus - bit
                @Token,    -- TokenCreated - nvarchar(50)
                GETDATE(), -- DateCreated - datetime
                NULL,      -- TokenUpdated - nvarchar(50)
                NULL,      -- DateUpdated - datetime
                NULL,      -- IsActionIssued - bit
                NULL,      -- ActionObservation - nvarchar(600)
                NULL,      -- CourierContempt - bit
                NULL,      -- ClientConfirmsReturn - bit
                NULL,      -- IncidentfinalizedbySAC - bit
                0,         -- IsDenied - bit
                NULL,      -- LastStatusOrderId - tinyint
                @Comment   -- CommentOnIncident
            )
        OUTPUT
            SOURCE.Guide_Serie,
            SOURCE.Guide_Number,
            INSERTED.IdConfirmationOfIncidence
        INTO @InsertedConfirmation
        (
            Guide_Serie,
            Guide_Number,
            IdConfirmationOfIncidence
        );

        -- Crear DeliveryAttempt por guía. Crear intentos de entrega fallida.
        MERGE DeliveryBackOffice.dbo.DeliveryAttempt AS TARGET
        USING
        (
            SELECT
                DO.Guide_Serie,
                DO.Guide_Number,
                IC.IdConfirmationOfIncidence
            FROM DeliveryBackOffice.dbo.DeliveryOrder DO
            INNER JOIN @InsertedConfirmation IC
                ON IC.Guide_Serie = DO.Guide_Serie
               AND IC.Guide_Number = DO.Guide_Number
        ) AS SOURCE
            ON 1 = 0
        WHEN NOT MATCHED THEN
            INSERT
            (
                Guide_Serie,
                Guide_Number,
                ID_Incident,
                User_Created,
                Date_Created,
                Dry,
                Cold,
                Delivered,
                ConfirmationOfIncidenceId
            )
            VALUES
            (
                SOURCE.Guide_Serie,
                SOURCE.Guide_Number,
                @IdIssue,
                @Token,
                GETDATE(),
                0,
                0,
                0,
                SOURCE.IdConfirmationOfIncidence
            )
        OUTPUT
            SOURCE.Guide_Serie,
            SOURCE.Guide_Number,
            INSERTED.ID,
            SOURCE.IdConfirmationOfIncidence
        INTO @InsertedAttempts
        (
            Guide_Serie,
            Guide_Number,
            IdAttempt,
            IdConfirmationOfIncidence
        );

        -- Crear checkpoint 45 usando el DeliveryAttempt correcto de esa guía
        INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
        (
            Guide_Serie,
            Guide_Number,
            StatusOrderId,
            UserCreated,
            DateCreated,
            DateCreatedInSystem,
            Observations,
            Temperature_Celsius,
            DeliveryAttemptId,
            SystemOrigin
        )
        SELECT
            DO.Guide_Serie,
            DO.Guide_Number,
            @IdEstatus,
            @Token,
            GETDATE(),
            GETDATE(),
            @Comment,
            NULL,
            IA.IdAttempt,
            @IdSystem
        FROM DeliveryBackOffice.dbo.DeliveryOrder DO
        INNER JOIN @InsertedAttempts IA
            ON IA.Guide_Serie = DO.Guide_Serie
           AND IA.Guide_Number = DO.Guide_Number;

        SET @RInserted = @@ROWCOUNT;

        -- Actualizar DeliveryOrder de esa guía.
        UPDATE DO
        SET DO.StatusOrderId = @IdEstatus
        FROM DeliveryBackOffice.dbo.DeliveryOrder DO
        INNER JOIN @GuidesWork GW
            ON GW.Guide_Serie = DO.Guide_Serie
           AND GW.Guide_Number = DO.Guide_Number;

    END TRY
    BEGIN CATCH

        SET @jsonResult =
        (
            SELECT STUFF
            (
                (
                    SELECT ',{"IdStatus":' + '500' + ',' + '"Description":"' + ERROR_MESSAGE() + '"' + '}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'),
                1,
                1,
                ''
            )
        );

        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;

        SELECT '[' + @jsonResult + ']' FormatJson;

        RETURN;

    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF
            (
                (
                    SELECT ',{"IdStatus":' + '200' + ',' + '"Description":"' + 'Éxito' + '"' + '}'
                    FOR XML PATH(''), TYPE
                ).value('.', 'varchar(max)'),
                1,
                1,
                ''
            )
        );

        SELECT '[' + @jsonResult + ']' FormatJson;

        COMMIT TRANSACTION;
    END;
END;