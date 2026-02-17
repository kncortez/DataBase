
-- ==========================================================================
-- Author:		<Kevin,Oliva>
-- Create date: <2025-02-17>
-- Description:	<Cambiar contraseña de hermes desktop>
-- ==========================================================================

CREATE PROCEDURE SUPPORTCHANGEINTERNALPASSWORD 
    @USR_IdUser INT,
    @USR_UpdateToken VARCHAR(25),
    @USR_Password VARCHAR(150)
AS
BEGIN
    -- Configuración inicial
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Garantiza rollback automático en errores críticos
    
    DECLARE @RegisterUserID INT;
    DECLARE @ErrorMessage NVARCHAR(4000);
    DECLARE @ErrorSeverity INT;
    DECLARE @ErrorState INT;
    
    BEGIN TRY
        -- Inicia la transacción
        BEGIN TRANSACTION;
        
        -- Validación: Verificar que el usuario existe
        IF NOT EXISTS (
            SELECT 1
            FROM DenariusUser_Dev.dbo.LGN_User WITH (NOLOCK)
            WHERE USR_IdUser = @USR_IdUser
        )
        BEGIN
            RAISERROR('No se encontró el usuario con ID: %d', 16, 1, @USR_IdUser);
            RETURN;
        END;
        
        -- Actualizar tabla principal LGN_User
        UPDATE DenariusUser_Dev.dbo.LGN_User
        SET 
            USR_Password = @USR_Password,
            USR_UpdateToken = @USR_UpdateToken,
            USR_UpdateDate = GETDATE()
        WHERE USR_IdUser = @USR_IdUser;
        
        -- Verificar que el update afectó exactamente 1 registro
        IF @@ROWCOUNT = 0
        BEGIN
            RAISERROR('No se pudo actualizar la contraseña en LGN_User', 16, 1);
            ROLLBACK TRANSACTION;
            RETURN;
        END;
        
        -- Obtener el RegisterUserID relacionado
        SELECT @RegisterUserID = RegisterUserID 
        FROM InternalUser WITH (NOLOCK)
        WHERE IdUser = @USR_IdUser;
        
        -- Actualizar tabla RegisterUser si existe registro relacionado
        IF @RegisterUserID IS NOT NULL
        BEGIN
            UPDATE RegisterUser
            SET 
                UsrLastPassword = @USR_Password,
                UsrTokenUpdated = @USR_UpdateToken,
                UsrDateUpdated = GETDATE()
            WHERE UsrIdUser = @RegisterUserID;
            
            -- Verificar que el update fue exitoso
            IF @@ROWCOUNT = 0
            BEGIN
                RAISERROR('No se pudo actualizar la contraseña en RegisterUser', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
        END;
        
        -- Si todo fue exitoso, confirmar la transacción
        COMMIT TRANSACTION;
        
        -- Retornar los datos actualizados
        SELECT 
            'Contraseña actualizada exitosamente' AS Resultado,
            'ÉXITO' AS Estado,
            GETDATE() AS FechaActualizacion;
            
        -- Datos de LGN_User actualizados
        SELECT 
            'Datos LGN_User' AS Tabla,
            USR_IdUser,
            USR_Username,
            USR_Password,
            USR_IdEmployee,
            USR_Email,
            USR_UpdateToken,
            USR_UpdateDate
        FROM DenariusUser_Dev.dbo.LGN_User WITH (NOLOCK)
        WHERE USR_IdUser = @USR_IdUser;
        
        -- Datos de RegisterUser actualizados (si existen)
        IF @RegisterUserID IS NOT NULL
        BEGIN
            SELECT 
                'Datos RegisterUser' AS Tabla,
                UsrIdUser AS RegisterUserID,
                UsrEmail, 
                UsrLastPassword,
                UsrTokenUpdated,
                UsrDateUpdated 
            FROM RegisterUser WITH (NOLOCK)
            WHERE UsrIdUser = @RegisterUserID;
        END;
        
    END TRY
    BEGIN CATCH
        -- Si hay una transacción activa, revertirla
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
        
        -- Capturar información del error
        SELECT @ErrorMessage = ERROR_MESSAGE(),
               @ErrorSeverity = ERROR_SEVERITY(),
               @ErrorState = ERROR_STATE();
        
        -- Retornar información detallada del error
        SELECT 
            'ERROR' AS Estado,
            @ErrorMessage AS MensajeError,
            ERROR_NUMBER() AS NumeroError,
            ERROR_LINE() AS LineaError,
            @ErrorSeverity AS Severidad,
            @ErrorState AS EstadoError,
            'La transacción ha sido revertida' AS Accion;
            
    END CATCH;
END;
GO