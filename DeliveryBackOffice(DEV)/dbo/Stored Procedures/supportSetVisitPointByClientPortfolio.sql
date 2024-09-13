

--drop  PROCEDURE [dbo].[SetVisitPointByClientPortfolio]
--drop  TYPE [dbo].[TblAddressList]
-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-06-11>
-- Description:	<Guarda, modifica y elimina la cartera del cliente>
-- ==============================================

CREATE PROCEDURE [dbo].[supportSetVisitPointByClientPortfolio]
    -- Add the parameters for the stored procedure here
    @TblAddressesList AS [TblAddressList] READONLY
  , @TblCODList AS [TblCODList] READONLY
  , @TblBillingList AS [TblBillingList] READONLY
  , @IdVisitPointByClientPortfolio INT = 2
  , @FirstName NVARCHAR(50) = ''
  , @SecondName NVARCHAR(50) = ''
  , @LastName NVARCHAR(50) = ''
  , @SecondLastName NVARCHAR(50) = ''
  , @NirPhone NVARCHAR(10) = ''
  , @Phone NVARCHAR(20) = ''
  , @Email NVARCHAR(200) = ''
  , @CUI NVARCHAR(100) = ''
  , @IdAccount INT = 1
  , @Status INT = 1
  , @Token VARCHAR(200) = NULL
  , @InternalCode VARCHAR(50) = ''
  , @TaxId VARCHAR(50) = ''
  , @ContactName VARCHAR(50) = ''
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX);
    DECLARE @jsonResult1 NVARCHAR(MAX);
    DECLARE @jsonResult2 NVARCHAR(MAX);
    DECLARE @jsonError NVARCHAR(MAX);
    DECLARE @jsonToken NVARCHAR(MAX);
    DECLARE @VisitPointId INT = 0;
    DECLARE @VisitPointByClientPortfolioIdTransact INT;
    DECLARE @AddressIdTransact INT = 0;

    -- insertar en tabla temporal posbibles mensajes de respuesta
    --IF OBJECT_ID('tempdb.dbo.#UpdateNow', 'U') IS NOT NULL DROP TABLE #UpdateNow;
    IF OBJECT_ID('tempdb.dbo.#NowInsert', 'U') IS NOT NULL
        DROP TABLE #NowInsert;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;

    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
        DROP TABLE #Temp;
    SELECT *
    INTO #responsemessage
    FROM
    (
        SELECT 200                              AS IdResult
             , 'Estado  cambiado correctamente' AS Message
             , 'OK'                             AS Id
        UNION
        SELECT 500                                       AS IdResult
             , 'Error faltal intente de nuevo mas tarde' AS Message
             , 'Transac'                                 AS Id
    ) AS errror;

    BEGIN TRANSACTION;
    BEGIN TRY

        SET @VisitPointId =
        (
            SELECT TOP 1
                   vp.IdVisitPointClient
            FROM [dbo].RegisterUser                  usr
                LEFT JOIN [dbo].[RolByUserByAccount] rua
                    ON rua.RuaIdUser = usr.UsrIdUser
                       AND rua.RuaRowStatus = 1
                INNER JOIN [dbo].Account             ac
                    ON ac.AccIdAccount = rua.RuaIdAccount
                       AND ac.AccRowStatus = 1
                INNER JOIN VisitPointByUser          vp
                    ON vp.RegisterUserID = usr.UsrIdUser
            WHERE ac.AccIdAccount = @IdAccount
        );
        --				--IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL DROP TABLE #Temp;

        -----------------------Cliente nuevo -----------------------------------------------
        IF (@IdVisitPointByClientPortfolio = 0 AND @VisitPointId > 0)
        BEGIN




            --------------------------------------------- Registra en la tabla DeliveryOrderDetail la recoleccion de la guia  ---------------------------------
            PRINT 'Registra en la tabla DeliveryOrderDetail la entrega de la guia';
            INSERT INTO VisitPointByClientPortfolio
            (
                [FirstName]
              , [SecondName]
              , [LastName]
              , [SecondLastName]
              , [Email]
              , [NirPhone]
              , [Phone]
              , [CUI]
              , [VisitPointId]
              , [RowStatus]
              , [TokenCreated]
              , [DateCreated]
              , [TokenUpdated]
              , [DateUpdated]
              , [InternalCode]
              , [TaxId]
              , [ContactName]
            )
            VALUES
            (@FirstName, @SecondName, @LastName, @SecondLastName, @Email, @NirPhone, @Phone, @CUI, @VisitPointId
           , @Status, @Token, GETDATE(), NULL, NULL, @InternalCode, @TaxId, @ContactName);

            SET @VisitPointByClientPortfolioIdTransact = SCOPE_IDENTITY();

            DECLARE @validate1 INT =
                    (
                        SELECT TOP 1 Status FROM @TblAddressesList
                    );
            DECLARE @validate2 INT =
                    (
                        SELECT TOP 1 Status FROM @TblBillingList
                    );
            DECLARE @validate3 INT =
                    (
                        SELECT TOP 1 Status FROM @TblCODList
                    );

	DECLARE @IdSettlementcalc INT 


			SET @IdSettlementcalc =(SELECT  TOP 1 st.IdSettlement FROM dbo.Settlement st WHERE st.IdTownship IN(SELECT IdTownship FROM @TblAddressesList) ) 
			PRINT @IdSettlementcalc
            IF (@validate1 > 0)
            BEGIN

		

                INSERT INTO UserAddress
                (
                    [UadIdTownship]
                  , [UadIdAccount]
                  , [UadIdCountry]
                  , [UadFullName]
                  , [UadAddress1]
                  , [UadAddress2]
                  , [UadNirPhone]
                  , [UadPhone]
                  , [UadAdditionalInstructions]
                  , [UadRowStatus]
                  , [UadTokenCreated]
                  , [UadDateCreated]
                  , [UadTokenUpdated]
                  , [UadDateUpdated]
                  , [CodeOfReference]
                  , [IdCityPlace]
                  , [VisitPointByClientPortfolioId]
                  , [UadIdSettlement]
                  , [UadIdDeliveryOption]
                )
                SELECT ni.IdTownship
                     , ni.IdAccount
                     , ni.IdCountry
                     , ni.FullName
                     , ni.Address1
                     , ni.Address2
                     , ni.NirPhone
                     , ni.Phone
                     , ni.AdditionalInstructions
                     , ni.Status
                     , ni.Token
                     , GETDATE()
                     , NULL
                     , NULL
                     , NULL
                     , NULL
                     , @VisitPointByClientPortfolioIdTransact
                     , @IdSettlementcalc
                     , ni.IdDeliveryOption
                FROM @TblAddressesList ni;

                SET @AddressIdTransact = SCOPE_IDENTITY();

            END;

            IF (@validate2 > 0)
            BEGIN
                INSERT INTO BillingProfile
                (
                    [BlpIdAccount]
                  , [BlpName]
                  , [BlpAddress]
                  , [BlpTaxId]
                  , [BlpRowStatus]
                  , [BlpTokenCreated]
                  , [BlpDateCreated]
                  , [BlpTokenUpdated]
                  , [BlpDateUpdated]
                  , [VisitPointByClientPortfolioId]
                )
                SELECT bi.IdAccount
                     , bi.Name
                     , bi.Address
                     , bi.TaxId
                     , bi.Status
                     , bi.Token
                     , GETDATE()
                     , NULL
                     , NULL
                     , @VisitPointByClientPortfolioIdTransact
                FROM @TblBillingList bi;

            END;


            IF (@validate3 > 0)
            BEGIN
                INSERT INTO DeliveryFavCOD
                (
                    [AliasFavCOD]
                  , [NameAccountFavCOD]
                  , [TypeAccountFavCOD]
                  , [DocumentIdFavCOD]
                  , [StatusFavCOD]
                  , [IdAccountFavCOD]
                  , [TokenCreated]
                  , [DateCreated]
                  , [TokenUpdate]
                  , [DateUpdate]
                  , [IdBank]
                  , [NumberAccFavCOD]
                  , [VisitPointByClientPortfolioId]
                )
                SELECT ni.Alias
                     , ni.NameAccount
                     , ni.TypeAccount
                     , ni.DocID
                     , ni.Status
                     , ni.IdAccount
                     , ni.Token
                     , GETDATE()
                     , NULL
                     , NULL
                     , ni.IdBank
                     , ni.NumberAcc
                     , @VisitPointByClientPortfolioIdTransact
                FROM @TblCODList ni;
            END;

        END;

        ----------------------------------END Cliente Nuevo---------------------------------------------


        ----------------------------------------------------Start Client New COD,Billing,Addres----------------------------
        IF (@IdVisitPointByClientPortfolio > 0)
        BEGIN
            SET @VisitPointByClientPortfolioIdTransact = @IdVisitPointByClientPortfolio;
            --declare @VisitPointId int = (select IdVisitPointClient from VisitPointByUser where IdVisitPointByUser = @IdAccount)

            UPDATE VisitPointByClientPortfolio
            SET FirstName = @FirstName
              , SecondName = @SecondName
              , LastName = @LastName
              , SecondLastName = @SecondLastName
              , Email = @Email
              , NirPhone = @NirPhone
              , Phone = @Phone
              , CUI = @CUI
              , TokenUpdated = @Token
              , DateUpdated = GETDATE()
              , TaxId = @TaxId
              , ContactName = @ContactName
              , RowStatus = @Status
              , [InternalCode] = @InternalCode
            WHERE IdVisitPointByClientPortfolio = @IdVisitPointByClientPortfolio;




            INSERT INTO UserAddress
            (
                [UadIdTownship]
              , [UadIdAccount]
              , [UadIdCountry]
              , [UadFullName]
              , [UadAddress1]
              , [UadAddress2]
              , [UadNirPhone]
              , [UadPhone]
              , [UadAdditionalInstructions]
              , [UadRowStatus]
              , [UadTokenCreated]
              , [UadDateCreated]
              , [UadTokenUpdated]
              , [UadDateUpdated]
              , [CodeOfReference]
              , [IdCityPlace]
              , [VisitPointByClientPortfolioId]
              , [UadIdSettlement]
              , [UadIdDeliveryOption]
            )
            SELECT ni.IdTownship
                 , ni.IdAccount
                 , ni.IdCountry
                 , ni.FullName
                 , ni.Address1
                 , ni.Address2
                 , ni.NirPhone
                 , ni.Phone
                 , ni.AdditionalInstructions
                 , ni.Status
                 , ni.Token
                 , GETDATE()
                 , NULL
                 , NULL
                 , NULL
                 , NULL
                 , ni.IdVisitPointByClientPortfolio
                 , @IdSettlementcalc
                 , ni.IdDeliveryOption
            FROM @TblAddressesList ni
            WHERE ni.IdAddress = 0
                  AND ni.Status = 1;
            SET @AddressIdTransact = SCOPE_IDENTITY();


            UPDATE UserAddress
            SET UadIdTownship = ni.IdTownship
              , UadIdAccount = ni.IdAccount
              , UadIdCountry = ni.IdCountry
              , UadFullName = ni.FullName
              , UadAddress1 = ni.Address1
              , UadAddress2 = ni.Address2
              , UadNirPhone = ni.NirPhone
              , UadPhone = ni.Phone
              , UadAdditionalInstructions = ni.AdditionalInstructions
              , UadRowStatus = ni.Status
              , UadTokenUpdated = ni.Token
              , UadDateUpdated = GETDATE()
              , VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
              , UadIdSettlement = @IdSettlementcalc
              , UadIdDeliveryOption = ni.IdDeliveryOption
            FROM @TblAddressesList ni
                JOIN UserAddress   ud
                    ON ud.UadIdAddress = ni.IdAddress
            WHERE ni.IdAddress > 0
                  AND ud.VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio;




            INSERT INTO BillingProfile
            (
                [BlpIdAccount]
              , [BlpName]
              , [BlpAddress]
              , [BlpTaxId]
              , [BlpRowStatus]
              , [BlpTokenCreated]
              , [BlpDateCreated]
              , [BlpTokenUpdated]
              , [BlpDateUpdated]
              , [VisitPointByClientPortfolioId]
            )
            SELECT bi.IdAccount
                 , bi.Name
                 , bi.Address
                 , bi.TaxId
                 , bi.Status
                 , bi.Token
                 , GETDATE()
                 , NULL
                 , NULL
                 , bi.IdVisitPointByClientPortfolio
            FROM @TblBillingList bi
            WHERE bi.IdBilling = 0
                  AND bi.Status = 1;


            UPDATE BillingProfile
            SET BlpIdAccount = ni.IdAccount
              , BlpName = ni.Name
              , BlpAddress = ni.Address
              , BlpTaxId = ni.TaxId
              , BlpRowStatus = ni.Status
              , BlpTokenUpdated = ni.Token
              , BlpDateUpdated = GETDATE()
              , VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
            FROM @TblBillingList    ni
                JOIN BillingProfile bp
                    ON bp.BlpIdBilling = ni.IdBilling
            WHERE ni.IdBilling > 0
                  AND bp.VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio;



            INSERT INTO DeliveryFavCOD
            (
                [AliasFavCOD]
              , [NameAccountFavCOD]
              , [TypeAccountFavCOD]
              , [DocumentIdFavCOD]
              , [StatusFavCOD]
              , [IdAccountFavCOD]
              , [TokenCreated]
              , [DateCreated]
              , [TokenUpdate]
              , [DateUpdate]
              , [IdBank]
              , [NumberAccFavCOD]
              , [VisitPointByClientPortfolioId]
            )
            SELECT ni.Alias
                 , ni.NameAccount
                 , ni.TypeAccount
                 , ni.DocID
                 , ni.Status
                 , ni.IdAccount
                 , ni.Token
                 , GETDATE()
                 , NULL
                 , NULL
                 , ni.IdBank
                 , ni.NumberAcc
                 , ni.IdVisitPointByClientPortfolio
            FROM @TblCODList ni
            WHERE ni.Id = 0
                  AND ni.Status = 1;


            UPDATE DeliveryFavCOD
            SET AliasFavCOD = ni.Alias
              , NameAccountFavCOD = ni.NameAccount
              , TypeAccountFavCOD = ni.TypeAccount
              , DocumentIdFavCOD = ni.DocID
              , StatusFavCOD = ni.Status
              , IdAccountFavCOD = ni.IdAccount
              , TokenUpdate = ni.Token
              , DateUpdate = GETDATE()
              , IdBank = ni.IdBank
              , NumberAccFavCOD = ni.NumberAcc
              , VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio
            FROM @TblCODList        ni
                JOIN DeliveryFavCOD df
                    ON df.IdDeliveryFavCOD = ni.Id
            WHERE ni.Id > 0
                  AND VisitPointByClientPortfolioId = ni.IdVisitPointByClientPortfolio;

        END;

    -- retornar resultado en formato json

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE();
        -- retornar mensaje de error
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT '"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"'
                                       + CONVERT(NVARCHAR(MAX), ERROR_MESSAGE()) + '"}'
                                FROM #responsemessage
                                WHERE Id = 'Invalid'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)')
                          , 1
                          , 1
                          , ''
                        )
        );
    END CATCH;
    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;



        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',"Messege":"Cambios realizados exitosamente",'
                                       + '"IdVisitPointByClientPortfolio":'
                                       + CONVERT(NVARCHAR, ISNULL(@VisitPointByClientPortfolioIdTransact, '')) + ','
                                       + '"IdAddress":' + CONVERT(NVARCHAR, ISNULL(@AddressIdTransact, '')) + '}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)')
                          , 1
                          , 1
                          , ''
                        )
        );


    --- succesfull
    END;

    SELECT ('[{' + @jsonResult + ']') jsonResult;


    -----------------------------------------------

    --------------------

    --		DROP TABLE #Temp

    -- destruir tablas temporales

    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;
    IF OBJECT_ID('tempdb.dbo.#Temp', 'U') IS NOT NULL
        DROP TABLE #Temp;

-- retornar resultado en formato json



END;