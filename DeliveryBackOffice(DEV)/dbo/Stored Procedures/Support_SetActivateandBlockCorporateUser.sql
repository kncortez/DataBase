/* =================================================
   SP:        dbo.Support_SetActivateandBlockCorporateUser
   Propósito: Activar o bloquear un usuario corporativo POR CUSTOMER.
   Autor:     IRVIN GONZALEZ
   Historia:  FDAPI-5391
   Fecha:     2026-01-17
=========================================== */
CREATE PROCEDURE dbo.Support_SetActivateandBlockCorporateUser
    @Status BIT,        
    @CustomerId INT,         
    @Token NVARCHAR(60),
    @Comment NVARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    

    -- PASO 1: TABLA TEMPORAL 

    DECLARE @UserData TABLE (
        IdUser INT,
        Username NVARCHAR(100),
        RegisterUserID INT,
        IdPerson INT,
        IdVisitPointClient INT,
        CustomerID INT,
        CurrentInternalUserRowStatus BIT,
        CurrentRegisterUserRowStatus BIT,
        CurrentUserStatus NVARCHAR(50)
    );

    INSERT INTO @UserData (
        IdUser,
        Username,
        RegisterUserID,
        IdPerson,
        IdVisitPointClient,
        CustomerID,
        CurrentInternalUserRowStatus,
        CurrentRegisterUserRowStatus,
        CurrentUserStatus
    )
    SELECT 
        it.IdUser,
        it.Username,
        rg.UsrIdUser,
        per.PerIdPerson,
        vpu.IdVisitPointClient,
        cus.IdCustomer,
        it.RowStatus,
        rg.UsrRowStatus,
        res.UstStatus
    FROM DeliveryBackOffice.dbo.Customer cus WITH(NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
            ON vpc.CustomerID = cus.IdCustomer
        INNER JOIN DeliveryBackOffice.dbo.VisitPointByUser vpu WITH(NOLOCK)
            ON vpu.IdVisitPointClient = vpc.IdVisitPointClient
        INNER JOIN DeliveryBackOffice.dbo.RegisterUser rg WITH(NOLOCK)
            ON rg.UsrIdUser = vpu.RegisterUserID
        INNER JOIN DeliveryBackOffice.dbo.UserSystemRestriction res WITH(NOLOCK)
            ON res.UstIdUser = rg.UsrIdUser
        INNER JOIN DeliveryBackOffice.dbo.InternalUser it WITH(NOLOCK)
            ON it.RegisterUserID = vpu.RegisterUserID
        INNER JOIN DeliveryBackOffice.dbo.Person per WITH(NOLOCK)
            ON per.PerIdPerson = rg.UsrIdPerson
    WHERE cus.IdCustomer = @CustomerId;


    -- PASO 2: Customer existe

    IF NOT EXISTS (SELECT 1 FROM @UserData)
    BEGIN
        SELECT 
            'Error' AS Estado,
            'No se encontró relación con VisitPointClient para el Customer especificado.' AS Mensaje,
            @CustomerId AS CustomerID;
        RETURN;
    END


    -- PASO 3: ACTUALIZACIÓN

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @NewStatus NVARCHAR(50) = CASE WHEN @Status = 1 THEN 'ACTIVE' ELSE 'BLOCKED' END;
        DECLARE @NewRetries INT = CASE WHEN @Status = 1 THEN 0 ELSE NULL END;
        DECLARE @NewAccessRetries INT = CASE WHEN @Status = 1 THEN 10 ELSE 0 END;

        -- UPDATE 1: InternalUser
        UPDATE it
        SET 
            RowStatus = @Status,
            TokenUpdated = @Token,
            DateUpdated = GETDATE(),
            Comment = @Comment
        FROM DeliveryBackOffice.dbo.InternalUser it WITH(NOLOCK)
        INNER JOIN @UserData ud ON it.IdUser = ud.IdUser;

        -- UPDATE 2: RegisterUser
        UPDATE rg
        SET 
            UsrRowStatus = @Status,
            UsrTokenUpdated = @Token,
            UsrDateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.RegisterUser rg WITH(NOLOCK)
        INNER JOIN @UserData ud ON rg.UsrIdUser = ud.RegisterUserID;

        -- UPDATE 3: Person
        UPDATE per
        SET 
            PerRowStatus = @Status,
            PerTokenUpdated = @Token,
            PerDateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.Person per WITH(NOLOCK)
        INNER JOIN @UserData ud ON per.PerIdPerson = ud.IdPerson;

        -- UPDATE 4: UserSystemRestriction
        UPDATE res
        SET 
            UstStatus = @NewStatus,
            UstOperationDate = GETDATE(),
            UstAccessRetries = @NewAccessRetries,
            UstRetries = ISNULL(@NewRetries, res.UstRetries)
        FROM DeliveryBackOffice.dbo.UserSystemRestriction res WITH(NOLOCK)
        INNER JOIN @UserData ud ON res.UstIdUser = ud.RegisterUserID
        WHERE (@Status = 0 OR ud.CurrentUserStatus = 'BLOCKED');

        -- UPDATE 5: LGN_Restriction (Denarius)
        UPDATE lgn
        SET 
            RST_Status = @NewStatus,
            RST_Retries = ISNULL(@NewRetries, lgn.RST_Retries)
        FROM DenariusUser_Dev.dbo.LGN_Restriction lgn WITH(NOLOCK)
        INNER JOIN @UserData ud ON lgn.RST_IdUser = ud.IdUser AND lgn.RST_Username = ud.Username
        WHERE (@Status = 0 OR lgn.RST_Status = 'BLOCKED');

    
        --PASO 4: ACTUALIZAR ESTADO DEL CUSTOMER
        BEGIN TRY
            EXECUTE DeliveryBackOffice.dbo.Support_ActivateAndBlockCorporateUser
                @RowStatus = @Status,
                @Customer = @CustomerId;
        END TRY
        BEGIN CATCH
            SELECT 'Error ejecutando Support_ActivateAndBlockCorporateUser: ' AS Estado,
            ERROR_MESSAGE() AS Mensaje;
        END CATCH


        COMMIT TRANSACTION;

    
        --PASO 5: RESULTADO
    
        SELECT 
            'Éxito' AS Estado,
            CASE WHEN @Status = 1 THEN 'Activado' ELSE 'Bloqueado' END AS Accion,
            @CustomerId AS CustomerID,
            IdUser,
            Username,
            IdVisitPointClient,
            CurrentInternalUserRowStatus AS InternalUserEstadoAnterior,
            CurrentRegisterUserRowStatus AS RegisterUserEstadoAnterior,
            @Status AS EstadoNuevo,
            CurrentUserStatus AS StatusAnterior,
            @NewStatus AS StatusNuevo,
            CASE WHEN @Status = 0 THEN 'Sesión cerrada' ELSE 'Sesión activa' END AS SesionStatus
        FROM @UserData
        ORDER BY IdUser, IdVisitPointClient;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        SELECT 
            'Error' AS Estado,
            ERROR_MESSAGE() AS Mensaje,
            ERROR_LINE() AS Linea,
            ERROR_NUMBER() AS NumeroError,
            @CustomerId AS CustomerID;
    END CATCH;
END;
GO