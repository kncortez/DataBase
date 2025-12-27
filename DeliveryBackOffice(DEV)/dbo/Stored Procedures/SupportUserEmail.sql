CREATE PROCEDURE SupportUserEmail
    @UsrIdUser INT,
    @UsrEmail VARCHAR(100),
    @UsrTokenUpdated VARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Declarar variables
    DECLARE @OLDUsrEmail VARCHAR(100);
    DECLARE @OLDUsrTokenUpdated VARCHAR(50);
    
    BEGIN TRY
        -- Iniciar transacción
        BEGIN TRANSACTION;
        
        -- Validar existencia del usuario
        IF NOT EXISTS 
        (
            SELECT TOP 1 1 
            FROM RegisterUser WITH(NOLOCK) 
            WHERE UsrIdUser = @UsrIdUser
              AND UsrRowStatus = 1 
        )
        BEGIN
            RAISERROR('No se encontraron datos del usuario.', 16, 1);
            RETURN;
        END;
        
        -- Guardar valores anteriores
        SELECT  
            @OLDUsrEmail = UsrEmail,
            @OLDUsrTokenUpdated = UsrTokenUpdated
        FROM RegisterUser WITH(UPDLOCK) -- Lock para actualización
        WHERE UsrIdUser = @UsrIdUser 
          AND UsrRowStatus = 1;
        
        -- Realizar actualización
        UPDATE RegisterUser
        SET 
            UsrEmail = @UsrEmail, 
            UsrTokenUpdated = @UsrTokenUpdated, 
            UsrDateUpdated = GETDATE()
        WHERE UsrIdUser = @UsrIdUser
          AND UsrRowStatus = 1;
        
        -- Confirmar transacción
        COMMIT TRANSACTION;
        
        -- Mostrar valor anterior
        SELECT 
            'Valor ANTERIOR' AS Descripcion,
            @UsrIdUser AS UsrIdUser,
            @OLDUsrEmail AS UsrEmail,
            @OLDUsrTokenUpdated AS UsrTokenUpdated;
        
        -- Mostrar valor actualizado
        SELECT 
            'Valor ACTUALIZADO' AS Descripcion,
            UsrIdUser,
            UsrEmail,
            UsrTokenUpdated
        FROM RegisterUser WITH(NOLOCK)
        WHERE UsrIdUser = @UsrIdUser
          AND UsrRowStatus = 1;
          
    END TRY
    BEGIN CATCH
        -- Si hay error, revertir transacción
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        
        -- Retornar información del error
        SELECT 
            ERROR_NUMBER() AS ErrorNumber,
            ERROR_MESSAGE() AS ErrorMessage,
            ERROR_SEVERITY() AS ErrorSeverity,
            ERROR_STATE() AS ErrorState;
    END CATCH;
END;