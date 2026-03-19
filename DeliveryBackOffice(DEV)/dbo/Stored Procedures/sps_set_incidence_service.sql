/* =================================================
   SP:        [<dbo>].[sps_set_incidence_service]
   Propósito: <Registrar incidente de entrega en sitio>
   Autor:     <Cano, Carlos>
   Historia:  <El Autor no dejó registro de la Epica usada para la creación>
   Fecha:     2020-09-08
   === CHANGELOG ================================
2026-03-18 | Historia/épica: <FDAPI-5584> | Autor: <Bilkar Morataya> | Se agregó almacenar el comentario en la tabla de ConfirmationOfIncidence, además de registrar el usuario que creó el intento de entrega fallida.
============================================
*/

CREATE PROCEDURE [dbo].[sps_set_incidence_service]
    @Token VARCHAR(200)
  , @IdIssue INT
  , @Comment VARCHAR(500)
  , @Guides TblListGuides READONLY
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
    -- AND CAST(TknDateCreated AS DATE) = CAST(GETDATE() AS DATE)
    )
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF((
                             SELECT ',{"IdStatus":' + '500' + ',' + '"Description":"' + 'Token inválido' + '"' + '}'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

        SELECT '[' + @jsonResult + ']' FormatJson;

        RETURN;
    END;


    -- control de inserciones para transacción
    DECLARE @RInserted INT;

    -- tabla temporal para actualizar registros encontrados
    DECLARE @Table AS TABLE
    (
        ID INT
    );

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
    DECLARE @IdAttempt INT;
    DECLARE @IdConfirmationOfIncidence INT;

    BEGIN TRANSACTION;

    BEGIN TRY


        --- registro de incidencia
        INSERT [DeliveryBackOffice].[dbo].[ConfirmationOfIncidence]
        (
            ConfirmationOfIncidentToken
          , CatTypeConfirmationOfIncidenceId
          , IsValid
          , IsConfirmed
          , StatusOrderId
          , DateStatusOrder
          , RowStatus
          , TokenCreated
          , DateCreated
          , TokenUpdated
          , DateUpdated
          , IsActionIssued
          , ActionObservation
          , CourierContempt
          , ClientConfirmsReturn
          , IncidentfinalizedbySAC
          , IsDenied
          , LastStatusOrderId
          , CommentOnIncident
        )
        VALUES
        (   @Token    -- ConfirmationOfIncidentToken - nvarchar(50)
          , 1         -- CatTypeConfirmationOfIncidenceId - int
          , 0         -- IsValid - bit
          , 0         -- IsConfirmed - bit
          , 45        -- StatusOrderId - tinyint
          , GETDATE() -- DateStatusOrder - datetime
          , 1         -- RowStatus - bit
          , @Token    -- TokenCreated - nvarchar(50)
          , GETDATE() -- DateCreated - datetime
          , NULL      -- TokenUpdated - nvarchar(50)
          , NULL      -- DateUpdated - datetime
          , NULL      -- IsActionIssued - bit
          , NULL      -- ActionObservation - nvarchar(600)
          , NULL      -- CourierContempt - bit
          , NULL      -- ClientConfirmsReturn - bit
          , NULL      -- IncidentfinalizedbySAC - bit
          , 0         -- IsDenied - bit
          , NULL      -- LastStatusOrderId - tinyint
          , @Comment  -- CommentOnIncident
            );

        SET @IdConfirmationOfIncidence = SCOPE_IDENTITY();

        -- registra de intentos de entrega fallida...
        INSERT INTO DeliveryBackOffice.dbo.DeliveryAttempt
        (
            Guide_Serie
          , Guide_Number
          , ID_Incident
          , User_Created
          , Date_Created
          , Dry
          , Cold
          , Delivered
          , ConfirmationOfIncidenceId
        )
        SELECT DO.Guide_Serie
             , DO.Guide_Number
             , @IdIssue
             , @Token
             , GETDATE()
             , 0
             , 0
             , 0
             , @IdConfirmationOfIncidence
        FROM DeliveryBackOffice.dbo.DeliveryOrder DO
            INNER JOIN @Guides                    G
                ON G.Guide_Serie = DO.Guide_Serie
                   AND G.Guide_Number = DO.Guide_Number;

        SET @IdAttempt = SCOPE_IDENTITY();


        -- registrar estado en tabla de checkpoints
        INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
        (
            Guide_Serie
          , Guide_Number
          , StatusOrderId
          , UserCreated
          , DateCreated
          , DateCreatedInSystem
          , Observations
          , Temperature_Celsius
          , DeliveryAttemptId
          , SystemOrigin
        )
        SELECT DO.Guide_Serie
             , DO.Guide_Number
             , @IdEstatus
             , @Token
             , GETDATE()
             , GETDATE()
             , @Comment
             , NULL
             , @IdAttempt
             , @IdSystem
        FROM DeliveryBackOffice.dbo.DeliveryOrder DO
            INNER JOIN @Guides                    G
                ON G.Guide_Serie = DO.Guide_Serie
                   AND G.Guide_Number = DO.Guide_Number;


        -- actualizar tabla de registro de guías electrónicas
        UPDATE DO
        SET DO.StatusOrderId = @IdEstatus
        FROM DeliveryBackOffice.dbo.DeliveryOrder DO
            INNER JOIN @Guides                    G
                ON G.Guide_Serie = DO.Guide_Serie
                   AND G.Guide_Number = DO.Guide_Number;


        SET @RInserted = @@ROWCOUNT;

    END TRY
    BEGIN CATCH
        SET @jsonResult =
        (
            SELECT STUFF((
                             SELECT ',{"IdStatus":' + '500' + ',' + '"Description":"' + ERROR_MESSAGE() + '"' + '}'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

        SELECT '[' + @jsonResult + ']' FormatJson;

        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF((
                             SELECT ',{"IdStatus":' + '200' + ',' + '"Description":"' + 'Éxito' + '"' + '}'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

        SELECT '[' + @jsonResult + ']' FormatJson;

        COMMIT TRANSACTION;
    END;
    ELSE
    BEGIN
        SET @jsonResult =
        (
            SELECT STUFF((
                             SELECT ',{"IdStatus":' + '500' + ',' + '"Description":"' + ERROR_MESSAGE() + '"' + '}'
                             FOR XML PATH(''), TYPE
                         ).value('.', 'varchar(max)')
                       , 1
                       , 1
                       , ''
                        )
        );

        SELECT '[' + @jsonResult + ']' FormatJson;
    END;
END;
