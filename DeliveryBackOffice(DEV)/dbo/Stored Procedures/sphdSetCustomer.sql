-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-04-27>
-- Description:	<inserta o actualiza registros a clientes en base a flag @option 1 insert 2 update>
-- =============================================
-- =============================================
-- Author:		<Oscar,Rodriguez>
-- Create date: <2024-04-23>
-- Description:	<Se agrego modificacion para campo isCOD>
-- =============================================
-- =============================================
-- Author:		<Aylinne,Recinos>
-- Create date: <2024-12-20>
-- Description:	<Agrega validación de usuario individual>
-- Modified:	<Tito Garcia>
-- Update date: <2024-10-21>
-- Description:	<Se agrega nuevo campo IsVoucherRequired>
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Update date: <2025-08-14>
-- Description:	<Guias Rapidas - Se guarda nuevo campo RestrictionByArticle, indica si restringue uso a tarifario por articulo>
-- =============================================
CREATE PROCEDURE [dbo].[sphdSetCustomer]
    -- Add the parameters for the stored procedure here
    @IdCustomer INT
  , @NameCustomer NVARCHAR(100)
  , @Description NVARCHAR(100) = ''
  , @Domain NVARCHAR(50) = ''
  , @RegexSubject NVARCHAR(100) = ''
  , @RegexEmail NVARCHAR(100) = ''
  , @RegexFilename NVARCHAR(100) = ''
  , @Abbreviation NVARCHAR(25) = ''
  , @IdCustomerType INT = 1 -- 1	CORPORATIVO; 2	REDISTRIBUIDOR;  3	INDIVIDUAL
  , @CountryID VARCHAR(2) = 'GT'
  , @CommercialName NVARCHAR(50)
  , @CustomerPhone NVARCHAR(50)
  , @WebsiteURI NVARCHAR(50) = ''
  , @ContactName NVARCHAR(50)
  , @ContactEmail NVARCHAR(50)
  , @NotificationAddress NVARCHAR(200)
  , @SaleAdvisorID INT = -1
  , @DateUpService DATETIME = NULL
  , @DateDownService DATETIME = NULL
  , @TypeOfBusinessID INT
  , @BusinessSegmentID INT
  , @BusinessActivityID INT
  , @CommercialSegmentID INT
  , @OperationContactName NVARCHAR(50) = ''
  , @OperationContactPhone NVARCHAR(50) = ''
  , @OperationContactEmail NVARCHAR(50) = ''
  , @LegalSponsorName NVARCHAR(50) = ''
  , @LegalSponsorLastName NVARCHAR(50) = ''
  , @LegalSponsorDPI NVARCHAR(50) = ''
  , @HasAgreement BIT = 'FALSE'
  , @AgreementNumber NVARCHAR(50) = ''
  , @AgreementDateStart DATETIME = NULL
  , @AgreementDateEnd DATETIME = NULL
  , @InvoiceName NVARCHAR(100) = ''
  , @TaxIdentificationNumber NVARCHAR(50) = ''
  , @FiscalAddress NVARCHAR(200) = ''
  , @InvoiceEmail NVARCHAR(50) = ''
  , @ConditionOfPaymentID INT = 1
  , @InvoiceContactName NVARCHAR(50) = ''
  , @InvoiceContactPhone NVARCHAR(50) = ''
  , @InvoiceContactEmail NVARCHAR(50) = ''
  , @CODAccountBankID INT = NULL
  , @CODAccountNumber NVARCHAR(50) = ''
  , @CODAccountName NVARCHAR(50) = ''
  , @CODAccountTypeID INT = NULL
  , @CODCurrencyID INT = NULL
  , @CODContactName NVARCHAR(50) = ''
  , @CODContactPhone NVARCHAR(50) = ''
  , @CODContactEmail NVARCHAR(50) = ''
  , @RowSatus BIT = 'TRUE'
  , @Token NVARCHAR(50) = 'SYS-FDADMIN'
  , @Option AS INT          -- 1 create record, 2 update record
  , @ExcludePriceShippingCOD BIT = 'FALSE'
  , @ExcludeCommissionCOD BIT = 'FALSE'
  , @CatBatchTypeCODId BIGINT
  , @CatBatchFrequencyCODId BIGINT
  , @BillingTimeId INT = NULL
  , @BillingVolumeId INT = NULL
  , @BillingCut_offDate DATE = NULL
                            -----------------------------------------------------
  , @CardCode NVARCHAR(50) = NULL
                            -----------------------------------------------------
  , @NumImg INT = NULL
  , @isCOD INT = NULL
  , @IsVoucherRequired INT = 0
  , @RestrictionByArticle BIT = 'FALSE'
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRANSACTION;
    BEGIN TRY


        IF (@BillingTimeId = -1)
            SET @BillingTimeId =
        (
            SELECT IdCatBillingTime
            FROM [dbo].[CatBillingTime] CBT
            WHERE CBT.DescriptionBillingTime = 'Default(Cada domingo del mes y el día 2 del siguiente mes)'
        )   ;

        IF (@BillingVolumeId = -1)
            SET @BillingVolumeId =
        (
            SELECT IdCatBillingVolume
            FROM [dbo].[CatBillingVolume] CBV
            WHERE CBV.DescriptionBillingVolume = 'Una guía por factura'
        )   ;

        DECLARE @msgerror NVARCHAR(MAX) = N'';
        SELECT @msgerror = STUFF((
                                     SELECT CHAR(10) + Name
                                     FROM dbo.Customer C WITH (NOLOCK)
                                     WHERE C.TaxIdentificationNumber = @TaxIdentificationNumber
                                           AND LEN(TaxIdentificationNumber) > 0
                                           AND RowSatus = 1
                                           AND
                                           (
                                               @Option = 1
                                               OR
                                               (
                                                   @Option = 2
                                                   AND IdCustomer <> @IdCustomer
                                               )
                                           )
                                     FOR XML PATH('')
                                 )
                               , 1
                               , 1
                               , ''
                                );
        IF (LEN(@msgerror) > 0)
        BEGIN
            SET @msgerror
                = N'Los siguientes clientes ya estan registrados con el NIT ' + @TaxIdentificationNumber + N': '
                  + CHAR(10) + @msgerror;
            RAISERROR(@msgerror, 16, 1);
        --END
        END;

        -----------
        DECLARE @SAPCARDCODEUSEREXIST NVARCHAR(50);
        SELECT @SAPCARDCODEUSEREXIST = Name
        FROM dbo.Customer WITH (NOLOCK)
        WHERE SAPCardCode = @CardCode
              AND IdCustomer <> @IdCustomer;
        IF (@SAPCARDCODEUSEREXIST IS NOT NULL)
        --BEGIN
        BEGIN
            SELECT 'FALSE'                                                                               [blnResult]
                 , '-1'                                                                                  [IdResult]
                 , ''                                                                                    AS [ErrorNumber]
                 , ''                                                                                    AS [ErrorSeverity]
                 , ''                                                                                    AS [ErrorState]
                 , ''                                                                                    AS [ErrorProcedure]
                 , ''                                                                                    AS [ErrorLine]
                 , CONCAT('El usuario ', @SAPCARDCODEUSEREXIST, '  ya posee el codigo SAP: ', @CardCode) AS [Message];
        END;
        --END		
        ELSE
        -----------


        IF (@Option = 1)
        BEGIN
            DECLARE @IndUser INT = ISNULL((SELECT cli.IdCustomerType FROM Customer cli WITH (NOLOCK)
                WHERE (cli.RegexEmail = @RegexEmail AND cli.RowSatus = 1 AND cli.IdCustomerType != 1)),0)
            PRINT 'insert record';
            IF (@IndUser = 0)
            BEGIN 
                IF NOT EXISTS
                (
                    SELECT cli.IdCustomer
                    FROM Customer cli WITH (NOLOCK)
                    WHERE cli.Name = @NameCustomer AND cli.RowSatus = 1
                )
                BEGIN

                    INSERT INTO [DeliveryBackOffice].[dbo].[Customer]
                    (
                        [Name]
                    , [Description]
                    , [Domain]
                    , [RegexSubject]
                    , [RegexEmail]
                    , [RegexFilename]
                    , [Abbreviation]
                    , [IdCustomerType]
                    , [CountryID]
                    , [CommercialName]
                    , [CustomerPhone]
                    , [WebsiteURI]
                    , [ContactName]
                    , [ContactEmail]
                    , [NotificationAddress]
                    , [SaleAdvisorID]
                    , [DateUpService]
                    , [DateDownService]
                    , [TypeOfBusinessID]
                    , [BusinessSegmentID]
                    , [BusinessActivityID]
                    , [CommercialSegmentID]
                    , [OperationContactName]
                    , [OperationContactPhone]
                    , [OperationContactEmail]
                    , [LegalSponsorName]
                    , [LegalSponsorLastName]
                    , [LegalSponsorDPI]
                    , [HasAgreement]
                    , [AgreementNumber]
                    , [AgreementDateStart]
                    , [AgreementDateEnd]
                    , [InvoiceName]
                    , [TaxIdentificationNumber]
                    , [FiscalAddress]
                    , [InvoiceEmail]
                    , [ConditionOfPaymentID]
                    , [InvoiceContactName]
                    , [InvoiceContactPhone]
                    , [InvoiceContactEmail]
                    , [CODAccountBankID]
                    , [CODAccountNumber]
                    , [CODAccountName]
                    , [CODAccountTypeID]
                    , [CODCurrencyID]
                    , [CODContactName]
                    , [CODContactPhone]
                    , [CODContactEmail]
                    , [RowSatus]
                    , [TokenCreated]
                    , [DateCreated]
                    , [TokenUpdated]
                    , [DateUpdated]
                    , [SAPCardCode]
                    , [ExcludePriceShippingCOD]
                    , [ExcludeCommissionCOD]
                    , [CatBatchTypeCODId]
                    , [CatBatchFrequencyCODId]
                    , [CatBillingTimeId]
                    , [CatBillingVolumeId]
                    , [BillingCut_offDate]
                    , [NumImgEvidence]
                    , [IsCOD]
                    )
                    VALUES
                    (   @NameCustomer, @Description, @Domain, @RegexSubject, @RegexEmail, @RegexFilename, @Abbreviation
                    , @IdCustomerType, @CountryID, @CommercialName, @CustomerPhone, @WebsiteURI, @ContactName
                    , @ContactEmail, @NotificationAddress, @SaleAdvisorID, @DateUpService, @DateDownService
                    , @TypeOfBusinessID, @BusinessSegmentID, @BusinessActivityID, @CommercialSegmentID
                    , @OperationContactName, @OperationContactPhone, @OperationContactEmail, @LegalSponsorName
                    , @LegalSponsorLastName, @LegalSponsorDPI, @HasAgreement, @AgreementNumber, @AgreementDateStart
                    , @AgreementDateEnd, @InvoiceName, @TaxIdentificationNumber, @FiscalAddress, @InvoiceEmail
                    , @ConditionOfPaymentID, @InvoiceContactName, @InvoiceContactPhone, @InvoiceContactEmail
                    , @CODAccountBankID, @CODAccountNumber, @CODAccountName, @CODAccountTypeID, @CODCurrencyID
                    , @CODContactName, @CODContactPhone, @CODContactEmail, @RowSatus --'TRUE'
                    , @Token, GETDATE(), NULL, NULL
                                                                                    -------------------------
                                                                                    --,NULL				   
                    , @CardCode
                                                                                    -------------------------
                    , @ExcludePriceShippingCOD, @ExcludeCommissionCOD, @CatBatchTypeCODId, @CatBatchFrequencyCODId
                    , @BillingTimeId, @BillingVolumeId, @BillingCut_offDate, @NumImg, @isCOD);

                    SELECT 'TRUE'                            [blnResult]
                        , CAST(SCOPE_IDENTITY() AS VARCHAR) [IdResult]
                        , ''                                AS [ErrorNumber]
                        , ''                                AS [ErrorSeverity]
                        , ''                                AS [ErrorState]
                        , ''                                AS [ErrorProcedure]
                        , ''                                AS [ErrorLine]
                        , 'Success'                         AS [Message];
                END;
                ELSE
                BEGIN
                    SELECT 'FALSE'                                                [blnResult]
                        , '-1'                                                   [IdResult]
                        , ''                                                     AS [ErrorNumber]
                        , ''                                                     AS [ErrorSeverity]
                        , ''                                                     AS [ErrorState]
                        , ''                                                     AS [ErrorProcedure]
                        , ''                                                     AS [ErrorLine]
                        , 'El cliente que intenta crear ya existe en base datos' AS [Message];
                END;
            END
            ELSE
            BEGIN
                SELECT 'FALSE'                                                [blnResult]
                    , '-1'                                                   [IdResult]
                    , ''                                                     AS [ErrorNumber]
                    , ''                                                     AS [ErrorSeverity]
                    , ''                                                     AS [ErrorState]
                    , ''                                                     AS [ErrorProcedure]
                    , ''                                                     AS [ErrorLine]
                    , 'El cliente que intenta crear ya cuenta con un usuario individual' AS [Message];
            END;

        END;
        ELSE IF (@Option = 2)
        BEGIN
            PRINT 'update record';

            UPDATE [DeliveryBackOffice].[dbo].[Customer]
            SET [Name] = @NameCustomer
              , [Description] = @Description
              --,[Domain] = <Domain, nvarchar(50),>
              --,[RegexSubject] = <RegexSubject, nvarchar(100),>
              --,[RegexEmail] = <RegexEmail, nvarchar(100),>
              --,[RegexFilename] = <RegexFilename, nvarchar(100),>
              --,[Abbreviation] = <Abbreviation, nvarchar(25),>
              --,[IdCustomerType] = <IdCustomerType, int,>
              , [CountryID] = @CountryID
              , [CommercialName] = @CommercialName
              , [CustomerPhone] = @CustomerPhone
              , [WebsiteURI] = @WebsiteURI
              , [ContactName] = @ContactName
              , [ContactEmail] = @ContactEmail
              , [NotificationAddress] = @NotificationAddress
              , [SaleAdvisorID] = @SaleAdvisorID
              , [DateUpService] = @DateUpService
              , [DateDownService] = @DateDownService
              , [TypeOfBusinessID] = @TypeOfBusinessID
              , [BusinessSegmentID] = @BusinessSegmentID
              , [BusinessActivityID] = @BusinessActivityID
              , [CommercialSegmentID] = @CommercialSegmentID
              , [OperationContactName] = @OperationContactName
              , [OperationContactPhone] = @OperationContactPhone
              , [OperationContactEmail] = @OperationContactEmail
              , [LegalSponsorName] = @LegalSponsorName
              , [LegalSponsorLastName] = @LegalSponsorLastName
              , [LegalSponsorDPI] = @LegalSponsorDPI
              , [HasAgreement] = @HasAgreement
              , [AgreementNumber] = @AgreementNumber
              , [AgreementDateStart] = @AgreementDateStart
              , [AgreementDateEnd] = @AgreementDateEnd
              , [InvoiceName] = @InvoiceName
              , [TaxIdentificationNumber] = @TaxIdentificationNumber
              , [FiscalAddress] = @FiscalAddress
              , [InvoiceEmail] = @InvoiceEmail
              , [ConditionOfPaymentID] = @ConditionOfPaymentID
              , [InvoiceContactName] = @InvoiceContactName
              , [InvoiceContactPhone] = @InvoiceContactPhone
              , [InvoiceContactEmail] = @InvoiceContactEmail
              , [CODAccountBankID] = @CODAccountBankID
              , [CODAccountNumber] = @CODAccountNumber
              , [CODAccountName] = @CODAccountName
              , [CODAccountTypeID] = @CODAccountTypeID
              , [CODCurrencyID] = @CODCurrencyID
              , [CODContactName] = @CODContactName
              , [CODContactPhone] = @CODContactPhone
              , [CODContactEmail] = @CODContactEmail
              , [RowSatus] = @RowSatus
              , [TokenUpdated] = @Token
              , [DateUpdated] = GETDATE()
              --[SAPCardCode] = [SAPCardCode]
              , [ExcludePriceShippingCOD] = @ExcludePriceShippingCOD
              , [ExcludeCommissionCOD] = @ExcludeCommissionCOD
              , [CatBatchTypeCODId] = @CatBatchTypeCODId
              , [CatBatchFrequencyCODId] = @CatBatchFrequencyCODId
              -------------------------
              , [SAPCardCode] = @CardCode
              -------------------------
              , [CatBillingTimeId] = @BillingTimeId
              , [CatBillingVolumeId] = @BillingVolumeId
              , [BillingCut_offDate] = @BillingCut_offDate
              , [NumImgEvidence] = @NumImg
			  , [IsCOD] = @isCOD
			  , [IsVoucherRequired] = @IsVoucherRequired
              , [RestrictionByArticle] = @RestrictionByArticle
            WHERE IdCustomer = @IdCustomer;

            -- Inactivar el registro
            IF (ISNULL(@RowSatus, 0) = 0)
            BEGIN

                -- Inactivar horarios de recolección de puntos de visita
                UPDATE VPItin -- Itinerario de recolección
                SET RowStatus = 0
                  , TokenUpdated = @Token
                  , DateUpdated = GETDATE()
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient]                  VPC WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointConfiguration] VPConf WITH (NOLOCK)
                        ON VPC.CodeOfReference = VPConf.VisitPointID
                    LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointFrequency]      VPFreq WITH (NOLOCK)
                        ON VPConf.IdVPConfiguration = VPFreq.VPConfigurationID
                    LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointItinerary]      VPItin WITH (NOLOCK)
                        ON VPFreq.IdVPFrequency = VPItin.VPFrequencyID
                WHERE VPC.CustomerID = @IdCustomer;

                UPDATE VPFreq -- Frecuencia de recolección
                SET RowStatus = 0
                  , TokenUpdated = @Token
                  , DateUpdated = GETDATE()
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient]                  VPC WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].[VisitPointConfiguration] VPConf WITH (NOLOCK)
                        ON VPC.CodeOfReference = VPConf.VisitPointID
                    LEFT JOIN [DeliveryBackOffice].[dbo].[VisitPointFrequency]      VPFreq WITH (NOLOCK)
                        ON VPConf.IdVPConfiguration = VPFreq.VPConfigurationID
                WHERE VPC.CustomerID = @IdCustomer;

                -- Inactivar puntos de visita
                UPDATE VPC -- Puntos de visita
                SET StatusClient = 0
                  , TokenUpdated = @Token
                  , DateUpdated = GETDATE()
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
                WHERE VPC.CustomerID = @IdCustomer;


            END;

            SELECT 'TRUE'                       [blnResult]
                 , CAST(@IdCustomer AS VARCHAR) [IdResult]
                 , ''                           AS [ErrorNumber]
                 , ''                           AS [ErrorSeverity]
                 , ''                           AS [ErrorState]
                 , ''                           AS [ErrorProcedure]
                 , ''                           AS [ErrorLine]
                 , 'Success'                    AS [Message];

        END;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH
        SELECT 'FALSE'                                [blnResult]
             , CAST(ERROR_NUMBER() AS VARCHAR)        AS [ErrorNumber]
             , CAST(ERROR_SEVERITY() AS VARCHAR)      AS [ErrorSeverity]
             , CAST(ERROR_STATE() AS VARCHAR)         AS [ErrorState]
             , CAST(ERROR_PROCEDURE() AS VARCHAR)     AS [ErrorProcedure]
             , CAST(ERROR_LINE() AS VARCHAR)          AS [ErrorLine]
             , CAST(ERROR_MESSAGE() AS NVARCHAR(MAX)) AS [Message];
        ROLLBACK TRANSACTION;
    END CATCH;
END;
