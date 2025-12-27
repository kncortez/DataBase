CREATE PROCEDURE SUPPORTACTIVATEROL
    @RusIdUser INT,
    @RusIdRol INT,
    @RusIdSystem INT,
    @RusRowStatus INT,
    @RusTokenUpdated VARCHAR(50)
AS
BEGIN TRY	

    -- Validar que RusRowStatus solo sea 0 o 1
    IF @RusRowStatus NOT IN (0, 1)
    BEGIN
        RAISERROR('El valor de RusRowStatus solo puede ser 0 o 1.', 16, 1);
        RETURN;
    END;

    -- Validar existencia
    IF NOT EXISTS 
    (
        SELECT 1 
        FROM RolByUserBySystem WITH(NOLOCK) 
        WHERE RusIdUser = @RusIdUser 
          AND RusIdRol = @RusIdRol 
          AND RusIdSystem = @RusIdSystem
    )
    BEGIN
        RAISERROR('No se encontraron datos del rol.', 16, 1);
        RETURN;
    END;

    -- Guardar valores anteriores
    DECLARE @OLDRusRowStatus INT;
    DECLARE @OLDRusTokenUpdated VARCHAR(50);

    SELECT  
        @OLDRusRowStatus = RusRowStatus,
        @OLDRusTokenUpdated = RusTokenUpdated
    FROM RolByUserBySystem WITH(NOLOCK)
    WHERE RusIdUser = @RusIdUser 
      AND RusIdRol = @RusIdRol 
      AND RusIdSystem = @RusIdSystem;

    -- Realizar actualización
    UPDATE RolByUserBySystem
    SET 
        RusRowStatus = @RusRowStatus, 
        RusTokenUpdated = @RusTokenUpdated, 
        RusDateUpdated = GETDATE()
    WHERE RusIdUser = @RusIdUser 
      AND RusIdRol = @RusIdRol 
      AND RusIdSystem = @RusIdSystem;

    -- Mostrar valor anterior
    SELECT 
        'Valor ANTERIOR' AS Descripcion,
        @RusIdRol AS RusIdRol,
        @RusIdSystem AS RusIdSystem,
        @RusIdUser AS RusIdUser,
        @OLDRusRowStatus AS RusRowStatus,
        @OLDRusTokenUpdated AS RusTokenUpdated;

    -- Mostrar valor actualizado
    SELECT 
        'Valor ACTUALIZADO' AS Descripcion,
        RusIdRol,
        RusIdSystem,
        RusIdUser,
        RusRowStatus,
        RusTokenUpdated
    FROM RolByUserBySystem WITH(NOLOCK)
    WHERE RusIdUser = @RusIdUser 
      AND RusIdRol = @RusIdRol 
      AND RusIdSystem = @RusIdSystem;

END TRY
BEGIN CATCH
    SELECT ERROR_MESSAGE() AS RESPUESTA;
END CATCH;