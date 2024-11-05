-- =============================================  
-- Author:  <Edelman>  
-- Create date: <2024-10-08>  
-- Description: <Crear registro de cuenta nueva desde App Móvil>  
-- =============================================  
CREATE PROCEDURE [dbo].[SPHWAM_CreateAccountMovilApp]  
 -- Add the parameters for the stored procedure here  
 @FirstName NVARCHAR(100),  
 @LastName  NVARCHAR(100) ,  
 @Email  VARCHAR(200),  
 @CountryId AS NVARCHAR(2) ='GT', 
 @Password AS NVARCHAR(250) = NULL  
   
AS  
BEGIN  
 -- SET NOCOUNT ON added to prevent extra result sets from  
 -- interfering with SELECT statements.  
 SET NOCOUNT ON;  
   
  
  
 DECLARE @NewMainUserRol INT = (SELECT TOP 1 CR.RolIdRol FROM [DeliveryBackOffice].[dbo].[CatRol] CR WITH(NOLOCK) WHERE CR.RolName = 'Nuevo estandar' );  
  
 DECLARE @NewMainRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario de servicio estandar' COLLATE Latin1_General_CI_AI AND CountryId= @CountryId);  
 DECLARE @NewAlternativeRates INT = (SELECT TOP 1 RH.RheId FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH(NOLOCK) WHERE RH.RheName = 'Tarifario destinos express center' COLLATE Latin1_General_CI_AI AND CountryId = @CountryId);  
 DECLARE @IdCustomer as INT  
 DECLARE @IdSystem INT = (Select TOP 1  SysIdSystem From [dbo].[CatSystem]) --Where SysNameSystem ='App de clientes')  
 DECLARE @TypeAccount AS NVARCHAR(10)  = 'IND'  
 DECLARE @CountryName NVARCHAR (50) = (SELECT CountryNameES FROM CatCountry WHERE IdCountry = @CountryId);  
  
  -- insertar en tabla temporal posbibles mensajes de error  
  
  IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;  
   select * INTO #errormessage from (SELECT  500 AS IdResult  
     ,'Este correo ya fue registrado anteriormente' AS Message  
     ,'Exist' as Id   
   union  
   SELECT  500 AS IdResult  
     ,'Error fatal intente de nuevo mas tarde'  AS Message  
     ,'Transaction' as Id   
   union  
   SELECT  200 AS IdResult  
     ,'Cuenta creada correctamente' AS Message  
     ,'Ok' as Id )  as errror  
  
  
  -- validar que el correo no exite  
  
  IF NOT EXISTS(SELECT TOP 1 1 FROM RegisterUser usr WHERE usr.UsrEmail = @Email AND usr.UsrRowStatus=1)  -- no existe usuario, por lo tanto lo crea  
  BEGIN  
      
    BEGIN TRANSACTION  
    BEGIN TRY  
    -- insertar registro en la tabla persona  
     INSERT INTO  [DeliveryBackOffice].[dbo].[Person]    
     (PerFirstName  
     ,PerLastName  
     ,PerGender  
     ,PerBirthdate  
     ,PerIdentification  
     ,PerNationality  
     ,PerRowStatus  
     ,PerTokenCreated  
     ,PerDateCreated)  
     Values(@FirstName,@LastName, NULL,NULL,NULL, @CountryId, 1,'SYS-ADMIN-MOVIL-APP',GETDATE())  
       
     DECLARE @IdPerson AS BIGINT =  SCOPE_IDENTITY();  
  
    -- 90 dias para cambio de contraseña  
     declare @ExpirationDate as date = (SELECT DATEADD(DAY,90,GETDATE()));  
  
    -- insertar registro en tabla RegisterUser   
       
     Insert Into  [DeliveryBackOffice].[dbo].[RegisterUser]    
      (UsrIdPerson  
      ,UsrNickName  
      ,UsrEmail  
      ,UsrAvatar  
      ,UsrLastPassword  
      ,UsrPasswordExpiration  
      ,UsrLang  
      ,UsrDeviceType  
      ,UsrCurrency  
      ,UsrEnable2FA  
      ,UsrRestrictionAddressIp  
      ,UsrRowStatus  
      ,UsrTokenCreated  
      ,UsrDateCreated  
      ,PrefixCallingCode   
      ,Phone  
      )  
     Values(@IdPerson, @FirstName,@Email,NULL,@Password,@ExpirationDate,NULL,NULL,NULL,NULL,NULL, 1,'SYS-ADMIN-MOVIL-APP',GETDATE(),NULL,NULL)  
     DECLARE @IdUser as bigint =  SCOPE_IDENTITY();  
  
       
    --- Insertar tupla de restricciones  
     INSERT INTO [DeliveryBackOffice].[dbo].[UserSystemRestriction]    
      (UstIdUser  
      ,UstIdSystem  
      ,UstAccessRetries -- 10 intentos por default  
      ,UstRetries      -- inicia el contador en 0  
      ,UstStatus  --- Insertar siempre como ACTIVE  
      ,UstRowStatus  
      ,UstTokenCreated  
      ,UstDateCreated  
      ,UstOperationDate)  
     VALUES (@IdUser,@IdSystem,10,0,'ACTIVE', 1,'SYS-ADMIN-MOVIL-APP',GETDATE(),GETDATE())  
      print 'aqui 3'  
    -- CREAR CUSTOMER       
     INSERT INTO [dbo].[Customer]  
        ([Name]  
        ,[Description]  
        ,[Domain]  
        ,[RegexSubject]  
        ,[RegexEmail]  
        ,[RegexFilename]  
        ,[Abbreviation]  
        ,[IdCustomerType]  
        ,BusinessSegmentID   
        , SaleAdvisorID  
        ,TypeOfBusinessID  
        ,BusinessActivityID  
        ,CommercialSegmentID  
        ,CountryID  
     )  
        VALUES  
        (  
          CAST((@FirstName + ' ' + @LastName) AS NVARCHAR(100))  
      ,CAST((@FirstName + ' ' + @LastName) AS NVARCHAR(100))  
      ,CAST(SUBSTRING (@Email, CHARINDEX( '@', @Email ), LEN(@Email)  ) AS nvarchar(50))  
      ,'^.*solicitud.*$'  
      ,CAST(('^' + @Email + '$') AS NVARCHAR(100))  
      ,'^envios_.*\.xls$'  
      ,CAST((@FirstName + ' ' + @LastName) AS NVARCHAR(25))  
      ,3  
      ,10  
      ,72  
      ,16  
      ,28  
      ,2  
      ,@CountryId  
        )  
         SET @IdCustomer =  SCOPE_IDENTITY();  
       print 'aqui 4'  
    --- ASIGNAR TARIFARIO PARA CLIENTES INDIVIDUALES   
       
     INSERT INTO [dbo].[RatebyCustomer]  
      (  
       [RbcIdRate]  
       ,[RbcIdCustomer]  
       ,[RbcRowStatus]  
       ,[RbcTokenCreated]  
       ,[RbcDateCreated]  
      )  
     VALUES  
      (  
       @NewMainRates  
       , @IdCustomer  
       ,1  
       ,'SYS-ADMIN-MOVIL-APP'  
       ,GETDATE()  
      )  
       print 'aqui 5'  
    -- ASIGNAR TARIFARIO ALTERNO PARA CLIENTES INDIVIDUALES  
     INSERT INTO [dbo].[AlternativeRateByCustomer]  
      (  
       [RateId]  
       ,[CustomerId]  
       ,[RowStatus]  
       ,[TokenCreated]  
       ,[DateCreated]  
      )  
     VALUES  
      (  
       @NewAlternativeRates  
       , @IdCustomer  
       ,1  
       ,'SYS-ADMIN-MOVIL-APP'  
       ,GETDATE()  
      )  
        
       print 'aqui 6'  
    -- CREAR CUENTA  
     -- Tipo de cuenta individual  
     DECLARE @TypeAccounntId as int =(SELECT tac.TacIdTypeAccount FROM  DeliveryBackOffice.dbo.CatTypeAccount tac where tac.TacShortName = @TypeAccount)  
       
     INSERT INTO [dbo].[Account]  
        ([AccName]  
        ,[AccIdTypeAccount]  
        ,[AccRowStatus]  
        ,[AccTokenCreated]  
        ,[AccDateCreated]  
        ,[AccTokenUpdated]  
        ,[AccDateUpdated]  
        ,[IdCustomer]    
        ,[AccConfirm] -- P = Pendiente de Confirmar / C = Correo Confirmado  
        )  
      VALUES(CAST(concat('Envíos de ',@FirstName) AS VARCHAR(100)),@TypeAccounntId,1,'SYS-ADMIN-MOVIL-APP',GETDATE(),NULL,NULL,@IdCustomer,'P')  
       print 'aqui 7'  
      DECLARE @IdAccount as bigint =  SCOPE_IDENTITY();  
  
    
     -- Insertar en la tabla de TermnsAndConditionsByUser  
     INSERT INTO [dbo].[TermsAndConditionsByUser]  
      (TACId  
      ,IdAccount  
      ,TAC  
      ,RowStatus  
      ,TokenCreated  
      ,DateCreated  
      ,TokenUpdated  
      ,DateUpdated  
      )  
     VALUES((SELECT TOP 1 IdTAC FROM [dbo].[TermsAndConditions] WHERE RowStatus = 1 AND Name = 'New Termns And Conditions' ORDER BY DateCreated DESC)  
       ,@IdAccount  
       ,1  
       ,1  
       ,'SYS-ADMIN-MOVIL-APP'  
       ,GETDATE()  
       ,NULL  
       ,NULL  
       )  
     -- FIN MODIFICACIÓN  
      print 'aqui 8'  
    ---- Asignar rol por cuenta  
     -- rol estadar  
     DECLARE @IdRol as int =(select TOP 1 rol.RolIdRol from dbo.CatRol rol where rol.RolIdSystem = @IdSystem and rol.RolName = 'Estandar')  
  
     insert into [DeliveryBackOffice].[dbo].[RolByUserByAccount]    
      (RuaIdRol,  
      RuaIdUser  
      ,RuaIdAccount  
      ,RuaRowStatus  
      ,RuaTokenCreated  
      ,RuaDateCreated)  
     values (@NewMainUserRol,@IdUser,@IdAccount,1,'SYS-ADMIN-MOVIL-APP',GETDATE())  
      print 'aqui 9'  
     --inserta los wizards por deafult  
     insert into DeliveryBackOffice.dbo.DeliveryWizardAccount  
     (AccIdAccount,  
     Idwiz,  
     StatusAccountWiz,  
     DateCreate,  
     TokenCreate   
     )  
     values(CAST(@IdAccount AS INT),1,1,GETDATE(),'SYS-ADMIN-MOVIL-APP')  
       
     insert into DeliveryBackOffice.dbo.DeliveryWizardAccount  
     (AccIdAccount,  
     Idwiz,  
     StatusAccountWiz,  
     DateCreate,  
     TokenCreate   
     )  
     values(CAST(@IdAccount AS INT),2,1,GETDATE(),'SYS-ADMIN-MOVIL-APP')  
  
  
    ---- Asignar rol por systema  
     insert into DeliveryBackOffice.dbo.RolByUserBySystem    
      (RusIdRol  
      ,RusIdSystem  
      ,RusIdUser  
      ,RusRowStatus  
      ,RusTokenCreated  
      ,RusDateCreated)  
     values (@NewMainUserRol,@IdSystem,@IdUser,1,'SYS-ADMIN-MOVIL-APP',GETDATE())  
       
  
     -- Agregar registros de los tutoriales  
     INSERT INTO [dbo].[TutorialByAccount] ([TutorialId]  
     , [AccountId]  
     , [ToDisplay]  
     , [RowStatus]  
     , [DateCreated]  
     , [TokenCreated])  
      SELECT  
       t.IdTutorial  
         ,@IdAccount  
         ,1  
         ,1  
         ,GETDATE()  
         ,'SYS-ADMIN-MOVIL-APP'  
      FROM Tutorial t  
      WHERE t.RowStatus = 1  
     -- Fin Agregar registros de los tutoriales     
     --   
  
    END TRY  
    BEGIN CATCH      
       
     SELECT 0 AS [StatusCode], 'No es posible crear la cuenta' AS[MessageResponse],  
                ERROR_NUMBER() AS [ErrorNumber],  
          ERROR_SEVERITY() AS [ErrorSeverity],  
          ERROR_STATE() AS [ErrorState],  
          ERROR_PROCEDURE() AS [ErrorProcedure],  
          ERROR_LINE() AS [ErrorLine],  
          ERROR_MESSAGE() AS [Erro]  
  
  
     ROLLBACK TRANSACTION  
    END CATCH;  
    IF @@TRANCOUNT > 0 BEGIN  
     COMMIT TRANSACTION;  
     SELECT 1 AS [StatusCode], 'Ok' AS[MessageResponse], @Password AS [Password],@IdAccount AS [IdAccount], @CountryName AS [CountryName]  
  
    END  
  
      
   end  
   else -- el usuario ya esta registrado  
   BEGIN  
    SELECT 0 AS [StatusCode], 'La cuenta ya existe' AS[MessageResponse], @Password AS [Password]  
  
   end  
  
  -- destruir tablas temporales  
  
  IF OBJECT_ID('tempdb.dbo.#errormessage', 'U') IS NOT NULL DROP TABLE #errormessage;  
  
  
END  
  