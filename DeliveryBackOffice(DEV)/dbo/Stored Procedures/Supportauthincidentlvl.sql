CREATE PROCEDURE Supportauthincidentlvl
    @IdUser INT,
    @CatManagementLevelId INT,
    @RowStatus INT,
    @Token NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. Validar existencia de usuario
        IF NOT EXISTS (SELECT 1 FROM InternalUser WITH(NOLOCK) WHERE IdUser = @IdUser)
        BEGIN
            RAISERROR('El usuario no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 2. Validar existencia del nivel solicitado
        IF NOT EXISTS (SELECT 1 FROM CatManagementLevel WHERE IdCatManagementLevel = @CatManagementLevelId)
        BEGIN
            RAISERROR('Nivel de manejo no existe.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 3. Extraer RegisterUserID del usuario
        DECLARE @RegisterUserID INT;
        SELECT @RegisterUserID = RegisterUserID
        FROM InternalUser WITH(NOLOCK)
        WHERE IdUser = @IdUser;

        -- 4. Validaciones sobre roles y estación

        -- 4.1 Validar que el usuario tenga roles
        IF NOT EXISTS (
            SELECT 1 FROM RolByUserBySystem 
            WHERE RusIdUser = @RegisterUserID
        )
        BEGIN
            RAISERROR('El usuario no tiene roles asignados.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 4.2 Validar que no existan roles sin estación
        IF EXISTS (
            SELECT 1 FROM RolByUserBySystem 
            WHERE RusIdUser = @RegisterUserID AND StationId IS NULL
        )
        BEGIN
            RAISERROR('Asignar una estación al usuario.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 4.3 Validar que todas las estaciones sean iguales
        IF (
            SELECT COUNT(DISTINCT StationId)
            FROM RolByUserBySystem
            WHERE RusIdUser = @RegisterUserID
        ) > 1
        BEGIN
            RAISERROR('El usuario tiene roles en diferentes estaciones.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 5. Obtener datos finales: StationID y CountryID
        DECLARE @StationID INT;
        DECLARE @CountryID VARCHAR(2);

        SELECT TOP 1 
            @StationID = rl.StationId,
            @CountryID = cs.CountryId
        FROM RolByUserBySystem rl WITH(NOLOCK)
        INNER JOIN CatStation cs WITH(NOLOCK) ON cs.IdStation = rl.StationId
        WHERE rl.RusIdUser = @RegisterUserID;

        -- 6. Validar que el nivel corresponde al país
        
        IF NOT EXISTS (
            SELECT 1 
            FROM CatManagementLevel WITH(NOLOCK)
            WHERE IdCatManagementLevel = @CatManagementLevelId 
              AND CountryId = @CountryID
        )
        BEGIN
            RAISERROR('ERROR: El permiso no corresponde al país del usuario.', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;

        -- 7. Insert / Update según exista en ManagementLevelByUser
        IF NOT EXISTS (
            SELECT 1 FROM ManagementLevelByUser WITH(NOLOCK)
            WHERE RegisterUserId = @RegisterUserID
        )
        BEGIN
            -- INSERT: RowStatus SIEMPRE ES 1
            INSERT INTO ManagementLevelByUser
            (
                RegisterUserId,
                CatManagementLevelId,
                RowStatus,
                DateCreated,
                TokenCreated,
                DateUpdated,
                TokenUpdated
            )
            VALUES
            (
                @RegisterUserID,
                @CatManagementLevelId,
                1,
                GETDATE(),
                @Token,
                NULL,
                NULL
            );
        END
        ELSE
        BEGIN
            -- UPDATE: RowStatus viene desde el parámetro
            UPDATE ManagementLevelByUser
            SET 
                CatManagementLevelId = @CatManagementLevelId,
                RowStatus = @RowStatus,   -- 0 = inactivar, 1 = activar
                DateUpdated = GETDATE(),
                TokenUpdated = @Token
            WHERE RegisterUserId = @RegisterUserID;
        END;

        COMMIT TRANSACTION;
    END TRY

    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
        SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
        RAISERROR(@ErrMsg, @ErrSeverity, 1);
    END CATCH
END;
GO