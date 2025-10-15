-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-06-11>
-- Description:	<Guarda, modifica y elimina la cartera del cliente>
-- ==============================================

CREATE PROCEDURE [dbo].[SetVisitPointByClientPortfolio]  
    -- Add the parameters for the stored procedure here  
    @TblAddressesList AS [TblAddressList] READONLY,  
    @TblCODList AS [TblCODList] READONLY,  
    @TblBillingList AS [TblBillingList] READONLY,  
  
    @IdVisitPointByClientPortfolio int = 2,
    @FirstName nvarchar(50) = '',
    @SecondName nvarchar(50) = '',
    @LastName nvarchar(50) = '',
    @SecondLastName nvarchar(50) = '',
    @NirPhone nvarchar(10) = '',
    @Phone nvarchar(20) = '',
    @Email nvarchar(200) = '',
    @CUI nvarchar(100) = '',
    @IdAccount int = 1,
    @Status int  = 1,
    @Token varchar(200) = null,
    @InternalCode VARCHAR(50)='',
    @TaxId VARCHAR(50)='',
    @ContactName VARCHAR(50)=''
  
AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from  
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;
    DECLARE @VisitPointId int = 0
    DECLARE @VisitPointByClientPortfolioIdTransact INT;
    DECLARE @AddressIdTransact INT=0;

    -- insertar en tabla temporal posbibles mensajes de respuesta  
    IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL DROP TABLE #NowInsert;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;
  
    SELECT * INTO #responsemessage 
    FROM (SELECT  200 AS IdResult  
        ,'Estado  cambiado correctamente' AS Message  
        ,'OK' as Id   
          UNION  
          SELECT  500 AS IdResult  
        ,'Error faltal intente de nuevo mas tarde' AS Message  
        ,'Transac' as Id   
         )  as errror  

    BEGIN TRANSACTION
    BEGIN TRY

        set  @VisitPointId = (
                              SELECT TOP 1 vp.IdVisitPointClient
                              FROM [dbo].RegisterUser usr
                              LEFT JOIN [dbo].[RolByUserByAccount] rua
                                  ON rua.RuaIdUser = usr.UsrIdUser
                                  AND rua.RuaRowStatus = 1
                              INNER JOIN [dbo].Account ac
                                  ON ac.AccIdAccount = rua.RuaIdAccount
                                  AND ac.AccRowStatus = 1
                              INNER join VisitPointByUser vp ON vp.RegisterUserID = usr.UsrIdUser
                              WHERE ac.AccIdAccount = @IdAccount)

        -----------------------Cliente nuevo -----------------------------------------------  
        IF( @IdVisitPointByClientPortfolio = 0 and @VisitPointId > 0)  
        BEGIN
        --------------------------------------------- Registra en la tabla DeliveryOrderDetail la recoleccion de la guia  ---------------------------------  
            --print 'Registra en la tabla DeliveryOrderDetail la entrega de la guia'  
            INSERT INTO VisitPointByClientPortfolio(
                 [FirstName]
                ,[SecondName]
                ,[LastName]
                ,[SecondLastName]
                ,[Email]
                ,[NirPhone]
                ,[Phone]
                ,[CUI]
                ,[VisitPointId]
                ,[RowStatus]
                ,[TokenCreated]
                ,[DateCreated]
                ,[TokenUpdated]
                ,[DateUpdated]
                ,[InternalCode]
                ,[TaxId]
                ,[ContactName]
                )
            VALUES(@FirstName,@SecondName,@LastName, @SecondLastName,
                   @Email,@NirPhone,@Phone,@CUI,@VisitPointId,@Status,
                   @Token, GETDATE(),null, null, @InternalCode, @TaxId,
                   @ContactName)

            SET @VisitPointByClientPortfolioIdTransact = SCOPE_IDENTITY();

            DECLARE @validate1 int = (SELECT TOP 1 Status FROM @TblAddressesList)
            DECLARE @validate2 int = (SELECT TOP 1 Status FROM @TblBillingList)
            DECLARE @validate3 int = (SELECT TOP 1 Status FROM @TblCODList)

            IF( @validate1 > 0 )
            BEGIN

                INSERT INTO UserAddress(
                    [UadIdTownship]
                   ,[UadIdAccount]
                   ,[UadIdCountry]
                   ,[UadFullName]
                   ,[UadAddress1]
                   ,[UadAddress2]
                   ,[UadNirPhone]
                   ,[UadPhone]
                   ,[UadAdditionalInstructions]
                   ,[UadRowStatus]
                   ,[UadTokenCreated]
                   ,[UadDateCreated]
                   ,[UadTokenUpdated]
                   ,[UadDateUpdated]
                   ,[CodeOfReference]
                   ,[IdCityPlace]
                   ,[VisitPointByClientPortfolioId]
                   ,[UadIdSettlement]
                   ,[UadIdDeliveryOption]
                   )
                SELECT ni.IdTownship
                      ,ni.IdAccount
                      ,ni.IdCountry
                      ,ni.FullName
                      ,ni.Address1
                      ,ni.Address2
                      ,ni.NirPhone
                      ,ni.Phone
                      ,ni.AdditionalInstructions
                      ,ni.Status
                      ,ni.Token
                      ,GETDATE()
                      ,null
                      ,null
                      ,null
                      ,null
                      ,@VisitPointByClientPortfolioIdTransact
                      ,ni.IdSettlement
                      ,ni.IdDeliveryOption
                  FROM @TblAddressesList ni

                SET @AddressIdTransact = SCOPE_IDENTITY();

            END

            IF(@validate2 > 0)
            BEGIN
                INSERT INTO BillingProfile(
                                           [BlpIdAccount]
                                          ,[BlpName]
                                          ,[BlpAddress]
                                          ,[BlpTaxId]
                                          ,[NRC]
                                          ,[TypeIdentificationDocumentCode]
                                          ,[IdDocument]
                                          ,[DistrictId]
                                          ,[StateId]
                                          ,[ActivityCode]
                                          ,[Inv_type]
                                          ,[BlpRowStatus]
                                          ,[BlpTokenCreated]
                                          ,[BlpDateCreated]
                                          ,[BlpTokenUpdated]
                                          ,[BlpDateUpdated]
                                          ,[VisitPointByClientPortfolioId]
                                          )
                SELECT bi.IdAccount
                     ,bi.Name
                     ,bi.Address
                     ,bi.TaxId
                     ,bi.NRC
                     ,bi.TypeIdentificationDocumentCode
                     ,bi.IdDocument
                     ,bi.DistrictId
                     ,bi.StateId
                     ,bi.ActivityCode
                     ,bi.Inv_type
                     ,bi.Status
                     ,bi.Token
                     ,GETDATE()
                     ,null
                     ,null
                     ,@VisitPointByClientPortfolioIdTransact
                FROM @TblBillingList bi

            END

            IF(@validate3 > 0)
            BEGIN
                INSERT INTO DeliveryFavCOD(
                                           [AliasFavCOD]
                                          ,[NameAccountFavCOD]
                                          ,[TypeAccountFavCOD]
                                          ,[DocumentIdFavCOD]
                                          ,[StatusFavCOD]
                                          ,[IdAccountFavCOD]
                                          ,[TokenCreated]
                                          ,[DateCreated]
                                          ,[TokenUpdate]
                                          ,[DateUpdate]
                                          ,[IdBank]
                                          ,[NumberAccFavCOD]
                                          ,[VisitPointByClientPortfolioId]
                                          )
                SELECT ni.Alias
                      ,ni.NameAccount
                      ,ni.TypeAccount
                      ,ni.DocID
                      ,ni.Status
                      ,ni.IdAccount
                      ,ni.Token
                      ,GETDATE()
                      ,null
                      ,null
                      ,ni.IdBank
                      ,ni.NumberAcc
                      ,@VisitPointByClientPortfolioIdTransact
                FROM @TblCODList ni

            END

        END  

       ----------------------------------END Cliente Nuevo---------------------------------------------  

       ----------------------------------Start Client New COD,Billing,Addres----------------------------  
       IF( @IdVisitPointByClientPortfolio > 0 )
       BEGIN

            SET @VisitPointByClientPortfolioIdTransact = @IdVisitPointByClientPortfolio;

            UPDATE VisitPointByClientPortfolio
            SET FirstName = @FirstName
               ,SecondName = @SecondName
               ,LastName = @LastName
               ,SecondLastName = @SecondLastName
               ,Email = @Email
               ,NirPhone = @NirPhone
               ,Phone = @Phone
               ,CUI = @CUI
               ,TokenUpdated = @Token
               ,DateUpdated = GETDATE()
               ,TaxId = @TaxId
               ,ContactName=@ContactName
               ,RowStatus = @Status
               ,[InternalCode]=@InternalCode
            WHERE IdVisitPointByClientPortfolio = @IdVisitPointByClientPortfolio

            INSERT INTO UserAddress(
                                    [UadIdTownship]
                                   ,[UadIdAccount]
                                   ,[UadIdCountry]
                                   ,[UadFullName]
                                   ,[UadAddress1]
                                   ,[UadAddress2]
                                   ,[UadNirPhone]
                                   ,[UadPhone]
                                   ,[UadAdditionalInstructions]
                                   ,[UadRowStatus]
                                   ,[UadTokenCreated]
                                   ,[UadDateCreated]
                                   ,[UadTokenUpdated]
                                   ,[UadDateUpdated]
                                   ,[CodeOfReference]
                                   ,[IdCityPlace]
                                   ,[VisitPointByClientPortfolioId]
                                   ,[UadIdSettlement]
                                   ,[UadIdDeliveryOption]
                                   )
            SELECT
                  ni.IdTownship
                  ,ni.IdAccount
                  ,ni.IdCountry
                  ,ni.FullName
                  ,ni.Address1
                  ,ni.Address2
                  ,ni.NirPhone
                  ,ni.Phone
                  ,ni.AdditionalInstructions
                  ,ni.Status
                  ,ni.Token
                  ,GETDATE()
                  ,null
                  ,null
                  ,null
                  ,null
                  ,ni.IdVisitPointByClientPortfolio
                  ,ni.IdSettlement
                  ,ni.IdDeliveryOption
            FROM @TblAddressesList ni
            WHERE ni.IdAddress = 0
            AND ni.Status = 1

            SET @AddressIdTransact = SCOPE_IDENTITY();

            UPDATE UserAddress
            SET
               UadIdTownship = ni.IdTownship
              ,UadIdAccount = ni.IdAccount
              ,UadIdCountry = ni.IdCountry
              ,UadFullName = ni.FullName
              ,UadAddress1 = ni.Address1
              ,UadAddress2 = ni.Address2
              ,UadNirPhone = ni.NirPhone
              ,UadPhone = ni.Phone
              ,UadAdditionalInstructions = ni.AdditionalInstructions
              ,UadRowStatus = ni.Status
              ,UadTokenUpdated = ni.Token
              ,UadDateUpdated = GETDATE()
              ,VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
              ,UadIdSettlement= ni.IdSettlement
              ,UadIdDeliveryOption=ni.IdDeliveryOption
            FROM @TblAddressesList ni
            JOIN UserAddress ud
                on ud.UadIdAddress = ni.IdAddress
            WHERE ni.IdAddress > 0
              AND ud.VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio

            INSERT INTO BillingProfile(
                                       [BlpIdAccount]
                                      ,[BlpName]
                                      ,[BlpAddress]
                                      ,[BlpTaxId]
                                      ,[NRC]
                                      ,[TypeIdentificationDocumentCode]
                                      ,[IdDocument]
                                      ,[DistrictId]
                                      ,[StateId]
                                      ,[ActivityCode]
                                      ,[Inv_type]
                                      ,[BlpRowStatus]
                                      ,[BlpTokenCreated]
                                      ,[BlpDateCreated]
                                      ,[BlpTokenUpdated]
                                      ,[BlpDateUpdated]
                                      ,[VisitPointByClientPortfolioId]
                                      )
            SELECT bi.IdAccount
                  ,bi.Name
                  ,bi.Address
                  ,bi.TaxId
                  ,bi.NRC
                  ,bi.TypeIdentificationDocumentCode
                  ,bi.IdDocument
                  ,bi.DistrictId
                  ,bi.StateId
                  ,bi.ActivityCode
                  ,bi.Inv_type
                  ,bi.Status
                  ,bi.Token
                  ,GETDATE()
                  ,null
                  ,null
                  ,bi.IdVisitPointByClientPortfolio
            FROM @TblBillingList bi
            WHERE bi.IdBilling = 0
            AND bi.Status = 1

            UPDATE BillingProfile
            SET BlpIdAccount = ni.IdAccount
               ,BlpName = ni.Name
               ,BlpAddress = ni.Address
               ,BlpTaxId = ni.TaxId
               ,NRC = ni.NRC
               ,TypeIdentificationDocumentCode = ni.TypeIdentificationDocumentCode
               ,IdDocument = ni.IdDocument
               ,DistrictId = ni.DistrictId
               ,StateId = ni.StateId
               ,ActivityCode = ni.ActivityCode
               ,Inv_type = ni.Inv_type
               ,BlpRowStatus = ni.Status
               ,BlpTokenUpdated = ni.Token
               ,BlpDateUpdated = GETDATE()
               ,VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
            FROM @TblBillingList ni
            JOIN BillingProfile bp
            ON bp.BlpIdBilling = ni.IdBilling
            WHERE ni.IdBilling > 0
            AND bp.VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio

            INSERT INTO DeliveryFavCOD(
                                       [AliasFavCOD]
                                      ,[NameAccountFavCOD]
                                      ,[TypeAccountFavCOD]
                                      ,[DocumentIdFavCOD]
                                      ,[StatusFavCOD]
                                      ,[IdAccountFavCOD]
                                      ,[TokenCreated]
                                      ,[DateCreated]
                                      ,[TokenUpdate]
                                      ,[DateUpdate]
                                      ,[IdBank]
                                      ,[NumberAccFavCOD]
                                      ,[VisitPointByClientPortfolioId]
                                      )
            SELECT
                  ni.Alias
                 ,ni.NameAccount
                 ,ni.TypeAccount
                 ,ni.DocID
                 ,ni.Status
                 ,ni.IdAccount
                 ,ni.Token
                 ,GETDATE()
                 ,null
                 ,null
                 ,ni.IdBank
                 ,ni.NumberAcc
                 ,ni.IdVisitPointByClientPortfolio
            FROM @TblCODList ni
            WHERE ni.Id = 0 and ni.Status = 1

            UPDATE DeliveryFavCOD
            SET AliasFavCOD = ni.Alias
               ,NameAccountFavCOD = ni.NameAccount
               ,TypeAccountFavCOD = ni.TypeAccount
               ,DocumentIdFavCOD = ni.DocID
               ,StatusFavCOD = ni.Status
               ,IdAccountFavCOD = ni.IdAccount
               ,TokenUpdate = ni.Token
               ,DateUpdate= GETDATE()
               ,IdBank = ni.IdBank
               ,NumberAccFavCOD = ni.NumberAcc
               ,VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
            FROM @TblCODList ni
            JOIN DeliveryFavCOD df on df.IdDeliveryFavCOD = ni.Id
            WHERE ni.Id > 0
            AND VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio

        END

        -- retornar resultado en formato json  

    END TRY
    BEGIN CATCH
    ROLLBACK TRANSACTION

        select ERROR_MESSAGE()  

        -- retornar mensaje de error  

        SELECT
              CONVERT(VARCHAR,IdResult) [IdResult]
             ,CONVERT(NVARCHAR(MAX),ERROR_MESSAGE()) [Message]
        FROM #responsemessage where Id ='Invalid'

    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        --- succesfull
        COMMIT TRANSACTION;

        SELECT
              CONVERT(NVARCHAR,ISNULL(@VisitPointByClientPortfolioIdTransact,'')) [IdVisitPointByClientPortfolio]
             ,CONVERT(NVARCHAR,ISNULL(@AddressIdTransact,'')) [IdAddress]
             ,'Cambios realizados exitosamente' [Messege]

    END

        -- destruir tablas temporales  

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL DROP TABLE #listGuides;
        IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
        IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;

        -- retornar resultado en formato json  

END