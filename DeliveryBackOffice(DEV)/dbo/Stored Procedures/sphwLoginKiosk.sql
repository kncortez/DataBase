/* ===============================================
   SP:        [dbo].[sphwLoginKiosk]
   Propósito: <Login - Método validar pais, estacion y codigo de kiosko asignado>
   Autor:     <Brandon Pedroza>
   Historia:  <>  
   Fecha:     2024-11-19
========= CHANGELOG ==============================
2025-10-29 | Historia/épica: <FDAPI-4646> | Autor: <Juan Ramirez> |
-----
=========================================== */

CREATE PROCEDURE [dbo].[sphwLoginKiosk]
    @KioskCode INT,
    @IdCountry NVARCHAR(2),
    @IdStation INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRAN;

    BEGIN TRY

        DECLARE @Today DATE = CONVERT(DATE, GETDATE()),
                @isError BIT = 0,
                @resultMessage NVARCHAR(350),
                @resultCode INT,
                @codeOfReference NVARCHAR(30),
                @isActive       BIT,
                @storedDate     DATE,
                @AttemptsCount  INT,
                @MaxValue       SMALLINT = 3;

        SELECT @codeOfReference = FAC.dpf_VpCodeOfReference
          FROM DeliveryBackOffice.dbo.del_ParametrosFactura FAC WITH (NOLOCK)
               INNER JOIN DeliveryBackOffice.dbo.CatStation CAT WITH (NOLOCK)
                  ON FAC.dpf_VpCodeOfReference = CAT.CodeOfReference
         WHERE CAT.IdStation = @IdStation
           AND CAT.CountryId = @IdCountry

        IF NOT EXISTS (
             SELECT 1
               FROM DeliveryBackOffice.dbo.KioskAuthState WITH (NOLOCK)
              WHERE CodeOfReference = @codeOfReference
        )  
        BEGIN
            INSERT INTO DeliveryBackOffice.dbo.KioskAuthState
              (CodeOfReference, IsActive, AttemptsDate, AttemptsCount, LastAttemptAt)
            VALUES
              (@codeOfReference, 1, @Today, 0, @Today);
        END

        SELECT @isActive     = IsActive,
               @storedDate   = AttemptsDate,
               @AttemptsCount = AttemptsCount
          FROM DeliveryBackOffice.dbo.KioskAuthState WITH (NOLOCK)
         WHERE CodeOfReference = @codeOfReference;

        -- Validar si el código de kiosco es incorrecto para la estación existente
        IF NOT EXISTS (
            SELECT 1
              FROM DeliveryBackOffice.dbo.del_ParametrosFactura FAC WITH (NOLOCK)
                   INNER JOIN DeliveryBackOffice.dbo.CatStation CAT WITH (NOLOCK)
                      ON FAC.dpf_VpCodeOfReference = CAT.CodeOfReference
             WHERE FAC.KioskCode = @KioskCode
               AND CAT.IdStation = @IdStation
               AND CAT.CountryId = @IdCountry
              )
              AND @AttemptsCount < 3
        BEGIN
            SELECT @resultCode = 400 ,
                   @resultMessage = 'El código de kiosco no es válido para esta estación.'

                SET @isError = 1;

                SET @AttemptsCount = @AttemptsCount + 1;
 
                UPDATE DeliveryBackOffice.dbo.KioskAuthState
                   SET AttemptsCount = @AttemptsCount,
                       LastAttemptAt = @Today
                 WHERE CodeOfReference = @codeOfReference;

            SELECT @resultCode AS [StatusCode],
                   @resultMessage AS [Description];
            COMMIT TRANSACTION;
            RETURN;
        END

        IF (@isActive = 0)
        BEGIN
 
            SELECT @resultCode = 400 ,
                   @resultMessage = 'La estación de Kiosko está inactiva. Contacte a soporte técnico para activar la cuenta.'

                SET @isError = 1;

            SELECT @resultCode AS [StatusCode],
                   @resultMessage AS [Description];
            COMMIT TRANSACTION;
            RETURN;
        END

        IF (@storedDate IS NULL OR @storedDate <> @Today)
        BEGIN
 
            UPDATE DeliveryBackOffice.dbo.KioskAuthState
               SET AttemptsDate  = @Today,
                   AttemptsCount = 0,
                   LastAttemptAt = @Today
             WHERE CodeOfReference = @codeOfReference;

            SET @AttemptsCount = 0;
            SET @isError = 0;
        END

        IF (@AttemptsCount >= @MaxValue )
        BEGIN
 
            SELECT @resultCode = 400 ,
                   @resultMessage = 'Ha alcanzado el limite de intentos para loguearse. Contacte a soporte técnico para activar la cuenta.'

            UPDATE DeliveryBackOffice.dbo.KioskAuthState
               SET AttemptsCount = @AttemptsCount,
                   LastAttemptAt = @Today,
                   isActive = 0
             WHERE CodeOfReference = @codeOfReference;

            SET @isError = 1;
            SELECT @resultCode AS [StatusCode],
                   @resultMessage AS [Description];
            COMMIT TRANSACTION;
            RETURN;
        END

        IF (@isError = 1)
        BEGIN 
            SET @AttemptsCount = @AttemptsCount + 1;
 
            UPDATE DeliveryBackOffice.dbo.KioskAuthState
               SET AttemptsCount = @AttemptsCount,
                   LastAttemptAt = @Today
             WHERE CodeOfReference = @codeOfReference;

            SELECT @resultCode AS [StatusCode],
                   @resultMessage AS [Description];
            COMMIT TRANSACTION;
            RETURN;
        END 

        -- Consulta principal
        SELECT 
			200						AS [StatusCode],
			'Informacion Obtenida'	AS [Description],
            CAT.IdStation			AS [IdStation],
            CAT.CountryId			AS [CountryId],	
			CAT.StationName			AS [StationName],
            FAC.KioskCode			AS [KioskCode]
        FROM 
            DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
        INNER JOIN 
            DeliveryBackOffice.dbo.CatStation CAT WITH(NOLOCK)
            ON VPC.CodeOfReference = CAT.CodeOfReference
        INNER JOIN 
            DeliveryBackOffice.dbo.del_ParametrosFactura FAC WITH(NOLOCK)
            ON VPC.CodeOfReference = FAC.dpf_VpCodeOfReference 
        WHERE 
            VPC.IdKindOfVPBusiness IN (8, 21, 23) -- EXPRESS CENTER
            AND VPC.StatusClient = 1
            AND FAC.KioskCode = @KioskCode
            AND CAT.CountryId = @IdCountry
            AND CAT.IdStation = @IdStation
        ORDER BY 
            VPC.IdVisitPointClient ASC;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Capturar errores
        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

        ROLLBACK TRANSACTION;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();


        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
