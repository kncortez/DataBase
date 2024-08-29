USE [DenariusUser_Dev]
CREATE PROCEDURE AddNewRolByUserByRegion
    @Codigo INT,
    @IdCountry VARCHAR(2),
    @IdRol INT
AS
BEGIN
    DECLARE @Username VARCHAR(100);
    DECLARE @IdSystem INT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT = 16; 
    DECLARE @ErrorState INT = 1; 

    BEGIN TRY
        -- Verificar si el usuario existe
        IF NOT EXISTS(
            SELECT * FROM [DenariusUser_Dev].[dbo].[LGN_User] WITH (NOLOCK)
            WHERE USR_IdUser = @Codigo
        )
        BEGIN
            SET @ErrorMessage = 'El usuario con el Código proporcionado no existe.';
            RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- Verificar si el rol existe
        IF NOT EXISTS(
            SELECT * FROM [DenariusUser_Dev].[dbo].[LGN_Rol] WITH (NOLOCK)
            WHERE LGN_IdRol = @IdRol
        )
        BEGIN
            SET @ErrorMessage = 'El rol con el Id proporcionado no existe.';
            RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
            RETURN;
        END

        -- Obtener el nombre de usuario
        SELECT @Username = USR_Username 
        FROM [DenariusUser_Dev].[dbo].[LGN_User] WITH (NOLOCK)
        WHERE USR_IdUser = @Codigo;

        -- Obtener el Id del sistema asociado al rol
        SELECT @IdSystem = LGN_IdSystem
        FROM [DenariusUser_Dev].[dbo].[LGN_Rol] WITH (NOLOCK)
        WHERE LGN_IdRol = @IdRol;

        -- Insertar en LGN_RolByUserByRegion
        INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
        VALUES
        (
            @IdRol,
            @Codigo,
            CASE 
                WHEN @IdCountry = 'GT' THEN '-1'
                WHEN @IdCountry = 'HN' THEN '-2'
                ELSE '-1'
            END,
            @IdCountry,
            @Username,
            1
        );

        -- Insertar en LGN_Restriction
		IF NOT EXISTS(
			SELECT * FROM DenariusUser_Dev.dbo.LGN_Restriction WITH(NOLOCK)
			WHERE RST_IdUser = @Codigo AND RST_Username = @Username AND RST_IdSystem = @IdSystem
		)
		BEGIN
			INSERT INTO DenariusUser_Dev.dbo.LGN_Restriction 
				VALUES
				(
					@Codigo,
					@Username,
					@IdSystem,
					10,
					'ACTIVE',
					0,
					GETDATE(),
					NULL,
					NULL,
					NULL
				);
		END

        -- Mensaje opcional de éxito
        PRINT 'Registro insertado correctamente.';
    END TRY
    BEGIN CATCH
        -- Captura del error
        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        -- Lanzar el error capturado
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END