-- =============================================
-- Author:	<Brandon, Pedroza>
-- Update date: <2024-07-11>
-- Description:	<Obtiene un mensaje descriptivo al realizar login fallido Hermes Desktop>
-- =============================================
CREATE PROCEDURE dbo.sphdGetMessageFromLogin
    @IdUser INT,
    @Username NVARCHAR(50),
    @Password NVARCHAR(50),
    @IdSystem INT,
    @IdModule INT
AS
BEGIN
    DECLARE @Resultado NVARCHAR(1000);

    -- Verifica si el rol del usuario tiene permisos para el módulo y sistema
    IF NOT EXISTS (
        SELECT * 
        FROM [DenariusUser_Dev].[dbo].[LGN_RolByUserByRegion] WITH(NOLOCK)
        WHERE RUR_IdUser = @IdUser 
          AND RUR_Username = @Username
          AND RUR_Status = 1 
          AND RUR_IdRol IN (
                SELECT MRS_IdRol
                FROM [DenariusUser_Dev].[dbo].[LGN_ModuleByRolBySystem] WITH(NOLOCK)
                WHERE MRS_IdSystem = @IdSystem 
                  AND MRS_IdModule = @IdModule
          )
    )
    BEGIN
        SET @Resultado = 'El rol del usuario no tiene acceso al sistema';
        SELECT @Resultado AS Mensaje;
        RETURN;
    END

    -- Verifica que el usuario tenga acceso al sistema
    IF NOT EXISTS (
        SELECT * 
        FROM [DenariusUser_Dev].[dbo].[LGN_Restriction] WITH(NOLOCK)
        WHERE RST_IdUser = @IdUser 
          AND RST_Username = @Username
          AND RST_IdSystem = @IdSystem 
          AND RST_Status = 'ACTIVE'
    )
    BEGIN
        SET @Resultado = 'El usuario no tiene acceso al sistema';
        SELECT @Resultado AS Mensaje;
        RETURN;
    END

    -- Verificar las credenciales
    IF NOT EXISTS (
        SELECT * 
        FROM [DenariusUser_Dev].[dbo].[LGN_User] WITH(NOLOCK)
        WHERE USR_IdUser = @IdUser
          AND USR_Username = @Username
          AND USR_Password = @Password
    )
    BEGIN
        SET @Resultado = 'Las credenciales no son válidas';
        SELECT @Resultado AS Mensaje;
        RETURN;
    END

    -- Si todas las verificaciones son exitosas
    SET @Resultado = 'Acceso concedido';
    SELECT @Resultado AS Mensaje;
END