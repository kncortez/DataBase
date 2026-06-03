-- Author:	<Kevin, Oliva> 
-- Created: <2025-12-26> 
-- Description:	<Setup Usuario no existente en Portal Web Corporativo tomando en cuenta el pais de origen> 
-- ============================================= 
CREATE PROCEDURE [dbo].[spws_SetHwNewCorporateUserV3] 
    @UserName             VARCHAR(50), 
    @CodeOfReference      BIGINT, 
    @IdCountry            NVARCHAR(2), 
    @EncryptedPassword    NVARCHAR(500),  -- NUEVA Ya viene cifrada desde .NET 
	@TokenCreated         NVARCHAR(500)  
AS 
BEGIN 
    SET NOCOUNT ON; 
     
    DECLARE  
        @UserCode BIGINT, 
        @gender VARCHAR(1) = '', 
        @Cui VARCHAR(50) = '', 
        @IdRol BIGINT = 7, 
        @firstName VARCHAR(50) = '', 
        @lastName VARCHAR(50) = '', 
        @idCustomer BIGINT, 
        @nationality VARCHAR(50), 
        @Email NVARCHAR(MAX), 
		@IdVisitPointClient BIGINT, -- COMERCIAL 
        @CodeISOCurrency NVARCHAR(3); 
         
		IF NOT EXISTS (select 1 from VisitPointClient with(nolock) where CodeOfReference = @CodeOfReference AND CountryId = @IdCountry) 
		    BEGIN 
        SELECT  
            404 AS CodeResponse, 
            'Punto de visita no encontrado' AS MessageResponse, 
            NULL AS CorporateCode, 
            NULL AS UserName, 
            NULL AS Password; 
        RETURN; 
    END 
     
	SET @IdVisitPointClient = (select IdVisitPointClient from VisitPointClient with(nolock) where CodeOfReference = @CodeOfReference)    
     
    ------------------------------------------------------------- 
    -- 1 GENERAR UserCode ALEATORIO ÚNICO DE 6 DÍGITOS 
    ------------------------------------------------------------- 
    DECLARE @TempCode INT = 0; 
     
    WHILE 1 = 1 
    BEGIN 
        SET @TempCode = CONVERT(INT, (RAND(CHECKSUM(NEWID())) * 900000) + 100000); 
         
        IF NOT EXISTS ( 
            SELECT 1  
            FROM DeliveryBackOffice.dbo.InternalUser with(nolock) 
            WHERE IdUser = @TempCode 
        ) 
        BEGIN 
            SET @UserCode = @TempCode; 
            BREAK; 
        END 
    END 
     
    ------------------------------------------------------------- 
    -- 3 Obtener datos del punto de visita 
    ------------------------------------------------------------- 
    SELECT  
        @Email = cu.ContactEmail, 
        @nationality = cu.CountryID, 
        @firstName = vpc.DescriptionOfClient, 
        @idCustomer = vpc.CustomerID 
    FROM DeliveryBackOffice.dbo.Customer cu WITH(NOLOCK) 
    INNER JOIN DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK) 
        ON vpc.CustomerID = cu.IdCustomer 
    WHERE vpc.IdVisitPointClient = @IdVisitPointClient; 
     
    -- Validar que se encontró el punto de visita 
    IF @idCustomer IS NULL 
    BEGIN 
        SELECT  
            404 AS CodeResponse, 
            'Punto de visita no encontrado' AS MessageResponse, 
            NULL AS CorporateCode, 
            NULL AS UserName, 
            NULL AS Password; 
        RETURN; 
    END 
     
    ------------------------------------------------------------- 
    -- 4 Obtener moneda según país 
    ------------------------------------------------------------- 
    SELECT TOP 1 @CodeISOCurrency = cuCOD.CodeISO 
    FROM CatCurrencyCOD cuCOD WITH(NOLOCK) 
    INNER JOIN DeliveryCurrency cu WITH(NOLOCK) 
        ON cu.IdCurrencyCOD = cuCOD.IdCatCurrencyCOD 
    WHERE cu.DefaultPerCountry = 1 
      AND cu.Currency_IdCountry = @IdCountry; 
       
    ------------------------------------------------------------- 
    -- 5 TRANSACCIÓN: Crear usuario corporativo 
    ------------------------------------------------------------- 
    BEGIN TRANSACTION; 
    BEGIN TRY 
     
        --------------------------------------------------------- 
        -- PERSON 
        --------------------------------------------------------- 
        INSERT INTO DeliveryBackOffice.dbo.Person (  
            PerFirstName, PerLastName, PerGender, PerIdentification, 
            PerNationality, PerRowStatus, PerTokenCreated, PerDateCreated, 
            PerCountryOrigin 
        ) 
        VALUES ( 
            ISNULL(@firstName,''), ISNULL(@lastName,''), @gender, 
            @Cui, @nationality, 1, @TokenCreated, GETDATE(), @IdCountry 
        ); 
         
        DECLARE @IdPerson BIGINT = SCOPE_IDENTITY(); 
         
        --------------------------------------------------------- 
        -- REGISTERUSER 
        -- AQUÍ SE GUARDA LA CONTRASEÑA YA CIFRADA 
        --------------------------------------------------------- 
        DECLARE @ExpirationDate DATE = DATEADD(DAY, 90, GETDATE()); 
         
        INSERT INTO DeliveryBackOffice.dbo.RegisterUser ( 
            UsrIdPerson, UsrNickName, UsrEmail, UsrAvatar, UsrLastPassword, 
            UsrPasswordExpiration, UsrLang, UsrDeviceType, UsrCurrency, 
            UsrEnable2FA, UsrRestrictionAddressIp, UsrRowStatus, 
            UsrTokenCreated, UsrDateCreated 
        ) 
        VALUES ( 
            @IdPerson,  
            @UserName,  
            ISNULL(@Email,''),  
            NULL,  
            @EncryptedPassword,  -- SE GUARDA LA CONTRASEÑA CIFRADA QUE VIENE DE .NET 
            @ExpirationDate,  
            'ES',  
            'WEB',  
            @CodeISOCurrency, 
            NULL,  
            NULL,  
            1,  
            @TokenCreated,  
            GETDATE()  
        ); 
         
        DECLARE @IdUser BIGINT = SCOPE_IDENTITY(); 
         
        --------------------------------------------------------- 
        -- UserSystemRestriction 
        --------------------------------------------------------- 
        INSERT INTO DeliveryBackOffice.dbo.UserSystemRestriction ( 
            UstIdUser, UstIdSystem, UstAccessRetries, UstRetries, 
            UstStatus, UstRowStatus, UstTokenCreated, UstDateCreated, 
            UstOperationDate 
        ) 
        VALUES ( 
            @IdUser, 1, 10, 0, 'ACTIVE', 1, @TokenCreated, GETDATE(), GETDATE() 
        ); 
         
        --------------------------------------------------------- 
        -- RolByUserBySystem 
        --------------------------------------------------------- 
        INSERT INTO DeliveryBackOffice.dbo.RolByUserBySystem ( 
            RusIdRol, RusIdSystem, RusIdUser, RusRowStatus, RusTokenCreated, RusDateCreated 
        ) 
        VALUES ( 
            @IdRol, 1, @IdUser, 1, @TokenCreated, GETDATE() 
        ); 
         
        --------------------------------------------------------- 
        -- InternalUser 
        --------------------------------------------------------- 
        INSERT INTO DeliveryBackOffice.dbo.InternalUser ( 
            IdUser, Username, RegisterUserID, RowStatus, TokenCreated, DateCreated 
        ) 
        VALUES ( 
            @UserCode, @UserName, @IdUser, 1, @TokenCreated, GETDATE() 
        ); 
         
        --------------------------------------------------------- 
        -- Account 
        --------------------------------------------------------- 
        INSERT INTO DeliveryBackOffice.dbo.Account ( 
            AccName, AccIdTypeAccount, AccRowStatus, AccTokenCreated, 
            AccDateCreated, IdCustomer, AccConfirm 
        ) 
        VALUES ( 
            'Corporativo ' + @firstName, 2, 1, @TokenCreated, 
            GETDATE(), @idCustomer, 'C' 
        ); 
         
        DECLARE @IdAccount BIGINT = SCOPE_IDENTITY(); 
         
        --------------------------------------------------------- 
        -- RolByUserByAccount 
        --------------------------------------------------------- 
        INSERT INTO DeliveryBackOffice.dbo.RolByUserByAccount ( 
            RuaIdRol, RuaIdUser, RuaIdAccount, RuaRowStatus, 
            RuaTokenCreated, RuaDateCreated 
        ) 
        VALUES ( 
            @IdRol, @IdUser, @IdAccount, 1, @TokenCreated, GETDATE() 
        ); 
         
        --------------------------------------------------------- 
        -- VisitPointByUser 
        --------------------------------------------------------- 
        INSERT INTO DeliveryBackOffice.dbo.VisitPointByUser ( 
            IdVisitPointClient, RegisterUserID, RowStatus, 
            TokenCreated, DateCreated 
        ) 
        VALUES ( 
            @IdVisitPointClient, @IdUser, 1, @TokenCreated, GETDATE() 
        ); 
         
        COMMIT TRANSACTION; 
         
        --  LA CONTRASEÑA YA NO SE RETORNA AQUÍ 
        -- Solo se retorna el código de usuario 
        SELECT  
            200 AS CodeResponse, 
            'Usuario creado exitosamente' AS MessageResponse, 
            @UserCode AS CorporateCode, 
            @UserName AS UserName, 
            NULL AS Password  -- NULL porque la contraseña se maneja en .NET 
        ; 
         
    END TRY 
    BEGIN CATCH 
        IF @@TRANCOUNT > 0 
            ROLLBACK TRANSACTION; 
             
        SELECT  
            500 AS CodeResponse,  
            ERROR_MESSAGE() AS MessageResponse, 
            NULL AS CorporateCode, 
            NULL AS UserName, 
            NULL AS Password; 
    END CATCH; 
     
END; 