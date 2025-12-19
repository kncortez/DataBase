--ACTUALIZA ID STATION USUARIOS DESKTOP
DECLARE @RowsAffected INT = 1, @Contador int =0;

WHILE (@RowsAffected > 0 )
BEGIN
    BEGIN TRY
        BEGIN TRAN;
        UPDATE TOP (10000) DOD
            SET DOD.StationId = RUS.StationId
        FROM DeliveryOrderDetail DOD WITH (NOLOCK)
        INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken LL WITH (NOLOCK)
            ON DOD.UserCreated = LL.SSN_IdToken
        INNER JOIN InternalUser IU WITH (NOLOCK)
            ON IU.IdUser = LL.SSN_IdUser
        INNER JOIN RolByUserBySystem RUS WITH (NOLOCK)
            ON IU.RegisterUserID = RUS.RusIdUser
        WHERE DOD.StationId IS NULL
          AND RUS.StationId IS NOT NULL;
	    
        SET @RowsAffected = @@ROWCOUNT;
	    
	    COMMIT TRAN;

        SET @Contador += 1;
        PRINT('LOTE ' + CONVERT(NVARCHAR(10), @Contador) 
              + ' actualizado. Filas: ' + CONVERT(NVARCHAR(10), @RowsAffected));
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRAN;
        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        PRINT('ERROR EN LOTE ' + CONVERT(NVARCHAR(10), @Contador));
        PRINT(@ErrorMessage);

        -- Detiene el proceso ante error
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
        BREAK;
    END CATCH;
END;