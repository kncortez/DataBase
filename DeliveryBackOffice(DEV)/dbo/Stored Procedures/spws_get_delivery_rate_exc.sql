/* =================================================
   SP:        [dbo].[spws_get_delivery_rate_exc]
   Propósito: <Manejo de tarifarios y valores de una guía>
   Autor:     <Cristian Azurdia>
   Historia:  <FDAPI-5460>
   Fecha:     2026-03-02
============================================
=== CHANGELOG ================================
-- 2026-05-25 | Historia/épica: FDAPI-6197 | Autor: Cristian Azurdia |
-- 2026-03-02 | Historia/épica: FDAPI-5460 | Autor: Cristian Azurdia |
=========================================== */

CREATE PROCEDURE [dbo].[spws_get_delivery_rate_exc]  
    @CodApp AS NVARCHAR(50) = ''  
  , @IdCustomerParams AS INT = 0  
  , @HeaderCodeDestiny AS VARCHAR(10) = ''  
  , @HeaderCodeSource AS VARCHAR(10) = ''  
  , @Country AS NVARCHAR(2) = 'GT'  
  , @CountPiecesParams AS INT = 1  
  , @IsFragile AS BIT = 'FALSE'  
  , @IsCollected AS BIT = 'FALSE'  
  , @IsInsurance AS BIT = 0
  , @WeigthParcels AS NVARCHAR(MAX) = '0'  
  , @InsuranceAmount AS DECIMAL(18, 2) = 0  
  , @IsCreditCardPayment AS BIT = 'false'  
  , @ParcelCode AS NVARCHAR(MAX) = '0'  
  , @Zone AS INT = 0  
  , @AddressParse AS NVARCHAR(600) = ''  
  , @IdSettlementSource AS INT = 0  
  , @IdSettlementDestiny AS INT = 0  
  , @CodeOfReferenceSource AS INT = 0  
  , @CodeOfReferenceDestiny AS INT = 0  
  , @IdSalePipeLine AS INT = 0  
  , @FormatResponse AS NVARCHAR(10) = 'DataTable'  
  , @CalculateTaxes BIT = 'false'  
  , @CalculateMembership BIT = 'false'  
  , @RevaluedGuide BIT = 0  
  , @CategoryProductId INT = 0  
  , @ProductId INT = 0  
  , @FetchActivePRoduct BIT = 1  

AS  
BEGIN  
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.  
    SET NOCOUNT ON;

    DECLARE @CustomerId AS INT = 0;
    DECLARE @CustomerType INT  = 0;
    DECLARE @LimitInsuranceAmount INT = 5000;

    DECLARE @FechaCompra AS DATETIME = GETDATE();
    DECLARE @Time AS TIME = CONVERT(TIME, @FechaCompra);

    DECLARE @jsonResult AS NVARCHAR(MAX);  

    DECLARE @DefaultCurrency AS INT =
        (
            SELECT CCC.IdCatCurrencyCOD 
            FROM [DeliveryBackOffice].[dbo].DeliveryCurrency DC WITH(NOLOCK)  
            INNER JOIN [DeliveryBackOffice].[dbo].CatCurrencyCOD CCC WITH(NOLOCK)  
            ON DC.IdCurrencyCOD = CCC.IdCatCurrencyCOD  
            WHERE DC.Currency_IdCountry = @Country 
              AND DC.DefaultPerCountry = 1  
        );

    /*----------------------------------------------------------------------------------------------
    ------- determinar el cliente ------------------------------------------------------------------
    ------------------------------------------------------------------------------------------------*/
    IF @IdCustomerParams <= 0 -- si el id de client no viene en los parametros determinar via CODAPP
    BEGIN

        SET @CustomerId =
        (  
            SELECT TOP 1
                   eco.IdCustomer
            FROM [DeliveryBackOffice].[dbo].[Ecommerce] eco WITH (NOLOCK)
            WHERE eco.UserKey = @CodApp --'SIFDCECOM300720201459'
                  AND eco.IdCountry = @Country
                  AND eco.EcommerceStatus = 'TRUE'
        );

        SELECT @CustomerType = C.IdCustomerType
        FROM dbo.Customer C WITH (NOLOCK)
        WHERE IdCustomer = @CustomerId;

    END;
    ELSE
    BEGIN

        SET @CustomerId = @IdCustomerParams;

        SELECT @CustomerType = C.IdCustomerType
        FROM dbo.Customer C WITH (NOLOCK)
        WHERE IdCustomer = @CustomerId;

    END;

    /*----------------------------------------------------------------------------------------------
    ----Verifica los productos validos y activos del cliente----------------------------------------
    ------------------------------------------------------------------------------------------------*/

    IF @ProductId > 0
   AND @FetchActivePRoduct = 1
    BEGIN

        DECLARE @IdAcount INT =
                (  
                    SELECT TOP 1
                           AccIdAccount
                    FROM [DeliveryBackOffice].[dbo].Account WITH (NOLOCK)
                    WHERE IdCustomer = @CustomerId
                          AND AccRowStatus = 1
                );  
        DECLARE @TechnicalDescription NVARCHAR(50);  
  
        DECLARE @ActiveProducts TABLE  
        (  
            StatusId INT  
          , CatProductCategoryId INT  
          , ProductId INT  
          , ProductName NVARCHAR(50)  
          , ProductDescription NVARCHAR(300)  
          , IncludeCollect BIT  
        );  
        INSERT INTO @ActiveProducts  
        EXEC ClientSubscriptionFetcher_Data @IdAccount = @IdAcount;  

        SELECT TOP 1  
               @TechnicalDescription = TechnicalDescription  
        FROM [DeliveryBackOffice].[dbo].CatProductCategory  WITH (NOLOCK)
        WHERE IdCatProductCategory = @CategoryProductId  
              AND RowStatus = 1;  

        DECLARE @NewProductId INT = NULL;  

        SELECT TOP 1  
               @NewProductId = ProductId  
        FROM @ActiveProducts
        WHERE CatProductCategoryId =  
        (  
            SELECT IdCatProductCategory  
            FROM [DeliveryBackOffice].[dbo].CatProductCategory  WITH (NOLOCK)
            WHERE TechnicalDescription = @TechnicalDescription  
                  AND RowStatus = 1  
                  AND  
                  (  
                      IdCountry = @Country  
                      OR  
                      (  
                          IdCountry IS NULL  
                          AND @Country = 'GT'  
                      )  
                  )  
        );  

        IF (@NewProductId IS NULL)  
        BEGIN  
            SET @ProductId = 0;  
            SET @CategoryProductId = 0;  

        END;  
        ELSE  
        BEGIN  
            SET @ProductId = @NewProductId;  
        END;  
    END;  

    /*----------------------------------------------------------------------------------------------
    ----Determinar el Tarifario y tipo de tarifario que se va a aplicar-----------------------------
    ------------------------------------------------------------------------------------------------*/

    DECLARE @NewMainRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario de servicio estandar'
                      AND CountryId = @Country
            );
    DECLARE @NewAlternativeRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario destinos express center'
                      AND CountryId = @Country
            );
    DECLARE @NewAutoSalesMainRates INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario de servicio estandar autoventas'
                      AND CountryId = @Country
            );

    DECLARE @NewRateGeneral INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Tarifario de servicio interfer'
                      AND CountryId = @Country
            );
    DECLARE @NewRateGeneralDiscount INT =
            (
                SELECT TOP 1
                       RH.RheId
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.RheName = 'Promo Paquetequiero destinos exc'
                      AND CountryId = @Country
            );

    DECLARE @IdRate          INT;
    DECLARE @RateId          INT;
    DECLARE @CurrencyId      INT;
    DECLARE @Currency        VARCHAR(10);
    DECLARE @InsuranceRate   DECIMAL(12,2);
    DECLARE @InsuranceCharge DECIMAL(12,2);
    DECLARE @InsuranceExempt DECIMAL(12,2);
    DECLARE @CollectRate     DECIMAL(12,2);
    DECLARE @WeigthLimit     DECIMAL(12,2);
    DECLARE @PiecesIncluded  DECIMAL(12,2);
    DECLARE @PriceWithCreditCard  INT;
    DECLARE @RateTypeId      INT;

    IF EXISTS
    (
        SELECT top 1
               rbc.RbcIdRate
        FROM [DeliveryBackOffice].[dbo].RatebyCustomer rbc WITH (NOLOCK)
        WHERE rbc.RbcIdCustomer = @CustomerId
              AND rbc.RbcRowStatus = 'TRUE'
              AND rbc.RbcCodeOfReference = @CodeOfReferenceSource
    )
    BEGIN
        SELECT top 1
               @RateId         = rc.RbcIdRate
             , @RateTypeId     = rh.RateTypeId
             , @WeigthLimit    = rh.WeightLimit
             , @Currency       = dc.Symbol
             , @PiecesIncluded = rh.PiecesIncluded
             , @CurrencyId     = ISNULL(rh.IdCurrency, @DefaultCurrency)
        FROM [DeliveryBackOffice].[dbo].RatebyCustomer          rc WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].RateHeader     rh WITH (NOLOCK)
                ON rh.RheId = rc.RbcIdRate
                AND rh.RheRowStatus = 'true'
            LEFT JOIN [DeliveryBackOffice].[dbo].CatCurrencyCOD dc WITH (NOLOCK)
                ON dc.IdCatCurrencyCOD = rh.IdCurrency
        WHERE rc.RbcIdCustomer = @CustomerId
              AND rc.RbcRowStatus = 'true'
              AND rc.RbcCodeOfReference = @CodeOfReferenceSource;
    END;
    ELSE
    BEGIN
        SELECT top 1
               @RateId         = rc.RbcIdRate
             , @RateTypeId     = rh.RateTypeId
             , @WeigthLimit    = rh.WeightLimit
             , @Currency       = dc.Symbol
             , @PiecesIncluded = rh.PiecesIncluded
             , @CurrencyId     = ISNULL(rh.IdCurrency, @DefaultCurrency)
        FROM [DeliveryBackOffice].[dbo].RatebyCustomer          rc WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].RateHeader     rh WITH (NOLOCK)
                ON rh.RheId = rc.RbcIdRate
                AND rh.RheRowStatus = 'true'
            LEFT JOIN [DeliveryBackOffice].[dbo].CatCurrencyCOD dc WITH (NOLOCK)
                ON dc.IdCatCurrencyCOD = rh.IdCurrency
        WHERE rc.RbcIdCustomer = @CustomerId
              AND rc.RbcRowStatus = 'true'
              AND rc.RbcCodeOfReference IS NULL;
    END;

    IF @RateId IS NULL -- si el cliente no tiene una tarifa asociada determinar por canal de venta  
    BEGIN

        SELECT @RateId         = rh.RheId  
             , @RateTypeId     = rh.RateTypeId  
             , @WeigthLimit    = rh.WeightLimit  
             , @Currency       = dc.Symbol  
             , @PiecesIncluded = rh.PiecesIncluded  
        FROM [DeliveryBackOffice].[dbo].RateBySalePipeLine      sp WITH (NOLOCK)  
            LEFT JOIN [DeliveryBackOffice].[dbo].RateHeader     rh WITH (NOLOCK)  
                ON rh.RheId = sp.RateId  
                AND rh.RheRowStatus = 'true'  
            LEFT JOIN [DeliveryBackOffice].[dbo].CatCurrencyCOD dc WITH (NOLOCK)  
                ON dc.IdCatCurrencyCOD = rh.IdCurrency  
        WHERE sp.RowStatus = 'true'  
              AND sp.SalePipeLineId = @IdSalePipeLine;  
  
    END;

     IF @RateId IS NULL -- si no se encuentra por canal de venta se determina por el valor default 
    BEGIN
        SELECT top 1
               @RateId         = rh.RheId
             , @RateTypeId     = rh.RateTypeId
             , @WeigthLimit    = rh.WeightLimit
             , @Currency       = dc.Symbol
             , @PiecesIncluded = rh.PiecesIncluded
        FROM [DeliveryBackOffice].[dbo].RateHeader              rh WITH (NOLOCK)
            LEFT JOIN [DeliveryBackOffice].[dbo].CatCurrencyCOD dc WITH (NOLOCK)
                ON dc.IdCatCurrencyCOD = rh.IdCurrency
        WHERE rh.RheRowStatus = 'true'
              AND rh.RheDefault = 'true'
              AND ISNULL(rh.CountryId, 'GT') = @Country;
    END;

    IF (@CustomerType IN ( 2, 3 )) --Validación si Usuario es Individual o Express center
    BEGIN

        IF (EXISTS
        (
            SELECT TOP 1
                   1
            FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
            WHERE VPC.CodeOfReference = @CodeOfReferenceDestiny
                  AND VPC.StatusClient = 1
                  AND VPC.DescriptionOfClient LIKE 'FD%EXC%'
        )
           )
        BEGIN
            IF (EXISTS
            (
                SELECT top 1
                       1
                FROM [DeliveryBackOffice].[dbo].[AlternativeRateByCustomer] AR WITH (NOLOCK)
                WHERE AR.VisitPointClientId = @CodeOfReferenceSource
                      AND AR.RowStatus = 1
            )
               )
            BEGIN

                SELECT top 1
                       @IdRate = ARC.RateId
                FROM [DeliveryBackOffice].[dbo].[AlternativeRateByCustomer] ARC WITH (NOLOCK)
                WHERE ARC.VisitPointClientId = @CodeOfReferenceSource
                      AND ARC.RowStatus = 1;
                --AND @IdRate IN ( @NewMainRates, @NewAutoSalesMainRates );

                SET @RateId = ISNULL(@IdRate, @RateId);
            END;
            ELSE
            BEGIN
                SELECT top 1
                       @IdRate = ARC.RateId
                FROM [DeliveryBackOffice].[dbo].[AlternativeRateByCustomer] ARC WITH (NOLOCK)
                WHERE ARC.CustomerId = @CustomerId
                      AND ARC.VisitPointClientId IS NULL
                      AND ARC.RowStatus = 1;
                --AND @IdRate IN ( @NewMainRates, @NewAutoSalesMainRates );

                SET @RateId = ISNULL(@IdRate, @RateId);
            END;

            PRINT 'TARIFA ALTERNATIVA';
            PRINT @RateId;

        END;
    END;

    DECLARE @TypeSubscriptionId INT;

    SET @TypeSubscriptionId =  
    (  
        SELECT TOP 1  
               cts.IdCatTypeSubscription  
        FROM [DeliveryBackOffice].[dbo].CatSubscription               csp WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].CatTypeSubscription cts WITH (NOLOCK)
                ON csp.CatTypeSubscriptionId = cts.IdCatTypeSubscription  
            INNER JOIN [DeliveryBackOffice].[dbo].CatProductCategory  cpc WITH (NOLOCK)
                ON csp.CatProductCategoryId = cpc.IdCatProductCategory  
        WHERE cpc.IdCatProductCategory = @CategoryProductId  
    );  

    IF (@TypeSubscriptionId IS NULL)  
    BEGIN  
        SET @TypeSubscriptionId =  
        (  
            SELECT TOP 1  
                   cvt.IdCatValueType  
            FROM [DeliveryBackOffice].[dbo].CatValueType                      cvt WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].MembershipDiscountRange mdr WITH (NOLOCK)
                    ON cvt.IdCatValueType = mdr.ValueTypeId  
                INNER JOIN [DeliveryBackOffice].[dbo].Membership              mbs WITH (NOLOCK)
                    ON mdr.MembershipId = mbs.IdMembership  
            WHERE mbs.IdMembership = @ProductId  
        );  
    END;

    IF (@CalculateMembership = 1)  
    BEGIN

        DECLARE @CustomerHasActiveSubscription INT;

        SELECT @CustomerHasActiveSubscription = SC.IdSubscription
        FROM [DeliveryBackOffice].[dbo].[Subscription]                    SC WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPS WITH (NOLOCK)
                ON CSPS.IdCatSalesPackageStatus = SC.CatSubscriptionStatusId
            INNER JOIN [DeliveryBackOffice].[dbo].[Membership]            MB WITH (NOLOCK)
                ON SC.MembershipId = MB.IdMembership  
            INNER JOIN [DeliveryBackOffice].[dbo].[CatSalesPackageStatus] CSPSM WITH (NOLOCK)
                ON CSPSM.IdCatSalesPackageStatus = MB.CatMembershipStatusId
        WHERE SC.CustomerId = @CustomerId
              AND MB.CustomerId = @CustomerId
              AND GETDATE() <= MB.ExpirationDate
              AND MB.RowStatus = 1
              AND GETDATE() <= SC.ExpirationDate
              AND SC.RowStatus = 1
              AND CSPS.SalesPackageStatusName = 'Activa'
              AND CSPSM.SalesPackageStatusName = 'Activa'
              AND SC.CatTypeSubscriptionId = ISNULL(@TypeSubscriptionId, 2)
        ORDER BY SC.ExpirationDate ASC;

        IF (ISNULL(@CustomerHasActiveSubscription, 0) > 0)  
        BEGIN  

            -- Destino es un express center activo, aplicar tarifa destino express center de suscripción  
            IF (EXISTS  
            (  
                SELECT TOP 1  
                       1  
                FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)  
                WHERE VPC.CodeOfReference = @CodeOfReferenceDestiny  
                      AND VPC.StatusClient = 1  
                      AND VPC.DescriptionOfClient LIKE 'FD%EXC%'  
            )  
               )  
            BEGIN

                -- Si falla en encontrar tarifa "valida", defecto la tarifa actual  
                SELECT @IdRate = ISNULL(ISNULL(SC.AlternativeRateHeaderId, CS.AlternativeRateHeaderId), @RateId)  
                FROM [DeliveryBackOffice].[dbo].[Subscription]              SC WITH (NOLOCK)  
                    INNER JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)  
                        ON SC.CatSubscriptionId = CS.IdCatSubscription  
                WHERE SC.IdSubscription = @ProductId; --@CustomerHasActiveSubscription;  

                SET @RateId = ISNULL(@IdRate, @RateId);  
            END;  
            ELSE  
            BEGIN  
                -- Destino no es express center activo, aplicar tarifa base de suscripción 
                -- Si falla en encontrar tarifa "valida", defecto la tarifa actual  
                SELECT @IdRate = ISNULL(ISNULL(SC.RateHeaderId, CS.RateHeaderId), @RateId)  
                FROM [DeliveryBackOffice].[dbo].[Subscription]              SC WITH (NOLOCK)  
                    INNER JOIN [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)  
                        ON SC.CatSubscriptionId = CS.IdCatSubscription  
                WHERE SC.IdSubscription = @CustomerHasActiveSubscription;  

                SET @RateId = ISNULL(@IdRate, @RateId);  
            END;  

        END;

    END

    SET @CalculateTaxes = 'false';  

    ------------------------- Determinar si el servico es TDA ------------------------------------------------------------------  

        --DECLARE @Tsettlement table (IdSettlement bigint )  
        DECLARE @IsTDA BIT = 'false';  
        DECLARE @IsSDD BIT = 'false';  

        IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL  
        DROP TABLE #ItemAddress;  
        IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL  
        DROP TABLE #SettlementList;  

        --PRINT 'TEST 1'  
        -- Quitar Departamento y Municipio de la direccion para tener un mejor resultado en la coincidencia  
    SET @AddressParse =  
    (  
        SELECT TOP 1  
               REPLACE(  
                          REPLACE(  
                                     REPLACE(  
                                                REPLACE(  
                                                           REPLACE(  
                                                                      REPLACE(  
                                                                                 REPLACE(  
                                                                                            REPLACE(  
                                                                                                       REPLACE(  
                                                                                                                  REPLACE(  
                                                                                                                             REPLACE(  
                                                                                                                                        REPLACE(  
                                                                                                                                                   REPLACE(  
                                                                                                                                                              REPLACE(  
                                                                                                                                                                         REPLACE(  
                                                                                                                                                                                 REPLACE(  
                                                                                                                                                                                               REPLACE(  
                                                                                                                                                                                                          REPLACE(  
                                                                                                                                                                                                                     REPLACE(  
                                                                                                                                                                                                                                REPLACE(  
                                                                                                                                                                                                                                           REPLACE(  
                                                                                                                                                                                                                                                      REPLACE( 
 
                                                                                                                                                                                                                                                               
  REPLACE(  
                                                                                                                                                                                                                                                               
             REPLACE(  
                                                                                                                                                                                                                                                               
                        REPLACE(  
                                                                                                                                                                                                                                                               
                                   REPLACE(  
                                                                                                                                                                                                                                                               
                                              REPLACE(  
                                                                                                                                                                                                                                                               
                                                         REPLACE(  
                                                                                                                                                                                                                                                               
                                                                    REPLACE(  
                                                                                                                                                                                                                                                               
                                                                               REPLACE(  
                                                                                                                                                                                                                                                               
                                                                                          REPLACE(  
                                                                                                                                                                                                                                                               
                                                                                                     REPLACE(  
                                                                                                                                                                                                                                                               
                                                                                                                REPLACE(  
                                                                                                                                                                                                                                                               
                                                                                                                           REPLACE(  
                                                                                                                                                                                                                                                               
                                                                                                                                      REPLACE(  
                                                                                                                                                                                                                                                               
                                                                                                                                                 @AddressParse  
                                                                                                                                                                                                                                                               
                                                                                                                                               , '!'  
                                                                                                                                                                                                                                                               
                                                                                                                                               , ''  
                                                                                                                                                                                                                                                               
                                                                                                                                             )  
                                                                                                                                                                                                                                                               
                                                                                                                                    , '"'  
                                                                                                                                                                                                                                                               
                                    , ''  
                                                                                                                                                                                                                                                               
                                                                                                                                  )  
                                                                                                                                                                                                                                                               
                                                                                                                         , '#'  
                                                                                                                                                                                                                                                               
                                                                                                                         , ''  
                                                                                                                                                                                                                                                               
                                                                                                                       )  
                                                                                                                                                                                                                                                               
                                                                                                              , '$'  
                                                                                                                                                                                                                                                               
                                                                                                              , ''  
                                                                                                                                                                                                                                                               
                                                                                                            )  
                                                                                                                                                                                                                                                               
                                                                                                   , '%'  
                                                                                                                                                                                                                                                               
                                                                                                   , ''  
         )  
                                                                                                                                                                                                                                                               
                                                                                        , '&'  
                                                                                                                                                                                                                                                               
                                                                                        , 'y'  
                                                                                                                                                                                                                                                               
                                                                                      )  
                                                                                                                                                                                                                                                               
                                                                             , ''''  
                                                                                                                                                                                                                                                               
                                                                             , ''  
                                                                                                                                                                                                                                                               
                                                                           )  
                                                                                                                                                                                                                                                               
                                                                  , '*'  
                                                                                                                                                                                                                                                               
                                                                  , ''  
                                                                                                                                                                                                                                                               
                                                                )  
                                                                                                                                                                                                                                                               
                                                       , '+'  
                                                                                                                                                                                                                                                               
                                                       , ''  
                                                                                                                                                                                                                                                               
                                                     )  
                                                                                                                                                                                                                                                               
                                , '/'  
                                                                                                                                                                                                                                                               
                                            , ''  
                                                                                                                                                                                                                                                               
                                          )  
                                                                                                                                                                                                                                                               
                                 , '<'  
                                                                                                                                                                                                                                                               
                                 , ''  
                                                                                                                                                                                                                                                               
                               )  
                                                                                                                                                                                                                                                               
                      , '='  
                                                                                                                                                                                                                                                               
                      , ''  
                                                                                                                                                                                                                                                               
                    )  
                                                                                                                                                                                                                                                               
           , '>'  
                                                                                                                                                                                                                                                               
           , ''  
                                                                                                                                                                                                                                                               
         )  
                                                                                                                                                                                                                                                               
, '?'  
                                                                                                                                                                                                                                                               
, ''  
                                                                                                                                                                                                                  )  
                                                                                                                                                                                                                                                    , '@'  
                                                                                                                                                                                                                                                    , ''  
                                                                                                                                                                                                                                                  )  
                                                                                                                                                                                                                                         , '['  
                                                                                                                                                                                                                                         , ''  
                                                                                                                                                                                                                                       )  
                                                                                                                                                                                                                              , '\'  
                                                                                                                                                                                                                              , ''  
                                                                                                                                                                                                                            )  
                                                                                                                                                                                                                   , ']'  
                                                                                                                                                                                                                   , ''  
                                                                                                                                                                                                                 )  
                                                                                                                                                                                                        , '^'  
                                                                                                                                                                                                        , ''  
                                                                                                                                                                                                      )  
                                                                                                                                                                                             , '_'  
                                                                                                                                                                                             , ''  
                                                                                                                                                                                           )  
                                                                                                                                                                                  , '`'  
                                                                                                                                                                                  , ''  
                                                                                                                                                                                )  
                                                                                                                                                                       , '{'  
                                                                                                                                                                       , ''  
                                                                                                                                                                     )  
                                                                                                                                                            , '|'  
                                                                                                                                                            , ''  
                                                                                                                                                          )  
                                                                                                                                                 , '}'  
                                                                                                                                                 , ''  
                                                                                                                                               )  
                                                                                                                                      , '~'  
                                                                                                                                      , ''  
                                                                                                                                    )  
                                                                                                                           , '¡'  
                                                                                                                           , ''  
                                                                                                                         )  
                                                                                                                , '¿'  
                                                                                                                , ''  
                                                                                                              )  
                                                                                                     , '°'  
                                                                                                     , ''  
                                                                                                   )  
                                                                                          , '¬'  
                                                                                          , ''  
                                                                                        )  
                                                                                  , '´'  
                                                                               , ''  
                                                                             )  
                                                                    , '¨'  
                                                                    , ''  
                                                                  )  
                                                         , '&Quot;'  
                                                         , ''  
                                                       )  
                                              , CHAR(255)  
                                              , ''  
                                            )  
                                   , twn.TownshipName  
                                   , ''  
                                 )  
                        , prv.ProvinceName  
                        , ''  
                      )  
        FROM [DeliveryBackOffice].[dbo].Township          twn WITH (NOLOCK)  
            LEFT JOIN [DeliveryBackOffice].[dbo].Province prv WITH (NOLOCK)  
                ON prv.IdProvince = twn.IdProvince  
        WHERE twn.HeaderCode = @HeaderCodeDestiny  
              AND twn.TownshipStatus = 'true'  
    );  
  
    DECLARE @IdSettlement BIGINT;  
 
    IF @IdSettlementDestiny <= 0 --  no se envio el id settlement desde front por lo tanto intenta determinarlo con base a la dirección  
    BEGIN  
        -- separar en un arrglo la direccion   
  
        PRINT '+++++++++++++++++++++++@AddressParse++++++++++++++++++++';  
        PRINT @AddressParse;  
        SELECT Item  
        INTO #ItemAddress  
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@AddressParse, ' ');  
  
        --PRINT 'FIN DE PARSERO DE DIRECCEION'  
        IF @Zone = 0 -- si no trae zona verificar por direccion  
        BEGIN  
            SELECT TOP 1  
                   st.IdSettlement  
                 , COUNT(st.IdSettlement) AS mas_popular  
                 , st.Settlement  
            INTO #SettlementList  
            FROM #ItemAddress            i  
                LEFT JOIN [DeliveryBackOffice].[dbo].Township   tw WITH (NOLOCK)  
                    ON tw.HeaderCode = @HeaderCodeDestiny  
                LEFT JOIN [DeliveryBackOffice].[dbo].Settlement st WITH (NOLOCK)  
                    ON st.IdTownship = tw.IdTownship  
                    AND st.Settlement LIKE CONCAT('%', i.Item, '%')
            WHERE LEN(i.Item) > 3  
                  AND st.IdSettlement IS NOT NULL  
            GROUP BY st.IdSettlement  
                   , st.Settlement  
            ORDER BY 2 DESC;  
  
            CREATE NONCLUSTERED INDEX IX_SettlementList_ParcelCode  
            ON #SettlementList (IdSettlement);  
  
            SET @IdSettlement =  
            (  
                SELECT TOP 1 IdSettlement FROM #SettlementList  
            );  
  
        END;  
        ELSE  
        BEGIN -- si trae zona verificar por zona   
            SET @IdSettlement =  
            (  
                SELECT TOP 1  
                       st.IdSettlement  
                FROM [DeliveryBackOffice].[dbo].Township            tw WITH (NOLOCK)  
                    LEFT JOIN [DeliveryBackOffice].[dbo].Settlement st WITH (NOLOCK)  
                        ON st.IdTownship = tw.IdTownship  
                WHERE tw.HeaderCode = @HeaderCodeDestiny  
                      AND st.Settlement LIKE CONCAT('%Zona ', @Zone, '%')  
                ORDER BY IdSettlement  
            );  
  
        END;  

        IF @IdSettlement IS NULL -- si no se puede identificar el settlement trae el primero del municipio proporcionado  
        BEGIN  
            SET @IdSettlement =  
            (  
                SELECT TOP 1  
                       st.IdSettlement  
                FROM [DeliveryBackOffice].[dbo].Township            tw WITH (NOLOCK)  
                    LEFT JOIN [DeliveryBackOffice].[dbo].Settlement st WITH (NOLOCK)  
                        ON st.IdTownship = tw.IdTownship  
                WHERE tw.HeaderCode = @HeaderCodeDestiny  
                ORDER BY IdSettlement  
            );  
        END;  
  
    END;  
    ELSE  
    BEGIN  

        SET @IdSettlement = @IdSettlementDestiny;  
    END;  
  
    SET @IsTDA = ISNULL((  
                            SELECT TOP 1  
                                   IIF(cov.TDA = 0, 'false', 'true')  
                            FROM [DeliveryBackOffice].[dbo].DumpServiceCoverage cov WITH (NOLOCK)  
                            WHERE cov.IdSettlement = @IdSettlement  
                                  AND cov.RowStatus = 1  
                        )  
                      , 'false'  
                       );  
  
    DECLARE @IdRateGroup INT = (IIF(@IsTDA = 'false', 1, (1)));  
  
    IF @IdRateGroup = 1  
    BEGIN  
        SET @IsSDD = ISNULL((  
                                SELECT TOP 1  
                                       IIF(cov.SDD = 0, 'false', 'true')  
                                FROM [DeliveryBackOffice].[dbo].DumpServiceCoverage cov WITH (NOLOCK)  
                                WHERE cov.IdSettlement = @IdSettlement  
                                      AND cov.RowStatus = 1  
                            )  
                          , 'false'  
                           );  
  
        DECLARE @IdRateGroupSDD INT = (IIF(@IsSDD = 'false'  
                                         , 1  
                                         , (  
                                               SELECT TOP 1  
                                                      RateGroup  
                                               FROM [DeliveryBackOffice].[dbo].CatTypeService WITH (NOLOCK)  
                                               WHERE CtsShortName = 'SDD'  
                                                     AND CtsRowStatus = 1  
                                           ))  
                                      );  
    END;  
  
    --------------- Fin determinar si es TDA   -----------------------.-------------------------------------------------------------------------------------  
    ---------------- Determinar HubOrigen y Destino --------------------------------------------------------------------------------------------------------  
  
    DECLARE @IdHubSource INT;  
    DECLARE @IdHubDestiny INT;  
  
    SELECT TOP 1  
           @IdHubSource = hb.IdHubLogistic  
    FROM [DeliveryBackOffice].[dbo].DumpServiceCoverage   cov WITH (NOLOCK)  
        LEFT JOIN [DeliveryBackOffice].[dbo].HubLogistics hb WITH (NOLOCK)  
            ON hb.HubAbbreviation = cov.Hub  
    WHERE cov.HeaderCode = @HeaderCodeSource  
    ORDER BY cov.Hub;  
  
    SELECT TOP 1  
           @IdHubDestiny = hb.IdHubLogistic  
    FROM [DeliveryBackOffice].[dbo].DumpServiceCoverage   cov WITH (NOLOCK)  
        LEFT JOIN [DeliveryBackOffice].[dbo].HubLogistics hb WITH (NOLOCK)  
            ON hb.HubAbbreviation = cov.Hub  
    WHERE cov.HeaderCode = @HeaderCodeDestiny  
    ORDER BY cov.Hub DESC;  
    --------------- Fin determinar Hub Origen y Destino ---------------------------------------------------------------------------------------------------  
  
    ---------------- Determinar Segmento LOC/MET/FOR-------------------------------------------------------------------------------------------------------  
    --PRINT 'determinar segmento LOC/MET/FOR '  
    IF @CodeOfReferenceSource <= 0 -- si no viene el codeOfReference tomar el primero de cada cliente  
    BEGIN  
        SELECT TOP 1  
               @CodeOfReferenceSource = vp.CodeOfReference  
        FROM [DeliveryBackOffice].[dbo].VisitPointClient vp WITH (NOLOCK)  
        WHERE vp.CustomerID = @CustomerId;  
    END;  

    DECLARE @IdSegment INT;  
    -- HeaderCodes  - revisar tabla  
    IF (@CustomerType != 1)  
    BEGIN  

        SELECT TOP 1  
               @IdSegment = RTC.SegmentTypeId  
        FROM [DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTC WITH (NOLOCK)  
            INNER JOIN [DeliveryBackOffice].[dbo].[Township]   TwnSource WITH (NOLOCK)  
                ON RTC.TownshipSourceId = TwnSource.IdTownship  
            INNER JOIN [DeliveryBackOffice].[dbo].[Township]   TwnDestiny WITH (NOLOCK)  
                ON RTC.TownshipDestinyId = TwnDestiny.IdTownship  
        WHERE RTC.RateId = @RateId  
              AND (TwnSource.HeaderCode = @HeaderCodeSource)  
              AND (TwnDestiny.HeaderCode = @HeaderCodeDestiny)  
              AND RTC.RowStatus = 1;  
  
    END;  
    ELSE  
    BEGIN 

        SELECT TOP 1  
               @IdSegment = CTC.SegmentTypeId  
        FROM [DeliveryBackOffice].[dbo].[CorporateTownshipCoverage] CTC WITH (NOLOCK)  
            INNER JOIN [DeliveryBackOffice].[dbo].[Township]        TwnSource WITH (NOLOCK)  
                ON CTC.TownshipSourceId = TwnSource.IdTownship  
            INNER JOIN [DeliveryBackOffice].[dbo].[Township]        TwnDestiny WITH (NOLOCK)  
                ON CTC.TownshipDestinyId = TwnDestiny.IdTownship  
        WHERE (TwnSource.HeaderCode = @HeaderCodeSource)  
              AND (TwnDestiny.HeaderCode = @HeaderCodeDestiny)  
              AND CTC.RowStatus = 1;

    END;  
  
    IF @IdSegment IS NULL -- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.  
    BEGIN  
        SELECT TOP 1  
               @IdSegment = sg.CrsId  
          FROM [DeliveryBackOffice].dbo.CatRateSegment sg WITH (NOLOCK)  
         WHERE sg.CrsShortName = 'FOR';  
    END;  

    --------------- Fin Determinar Segmento LOC/MET/FOR --- ---------------------------------------------------------------------------------------------------  
    -------------------------------Obtener descuento --------------------------------------------------------------------------  
  
    SELECT TOP 1  
           ss.Name           AS DicountName  
         , ss.IsGlobal       AS IsGlobla  
         , sd.UnitId         AS IdUnit  
         , sd.Value          AS Value  
         , unt.Prefix        AS Unit  
         , sd.TypeDiscountId AS idTypeDiscount  
         , tyd.ShortName     AS TypeDiscount  
    INTO #Dicounts  
    FROM dbo.SpecialSale                 ss WITH (NOLOCK)  
        INNER JOIN [DeliveryBackOffice].[dbo].SpecialSaleDetail sd WITH (NOLOCK)  
            ON sd.SpecialSaleId = ss.IdSpecialSale  
        LEFT JOIN [DeliveryBackOffice].[dbo].Unit               unt WITH (NOLOCK)  
            ON unt.IdUnit = sd.UnitId  
        LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeDiscount    tyd WITH (NOLOCK)  
            ON tyd.IdCatTypeDiscount = sd.TypeDiscountId  
        LEFT JOIN [DeliveryBackOffice].[dbo].SpecialSaleTarget  tgt WITH (NOLOCK)  
            ON tgt.SpecialSaleId = ss.IdSpecialSale  
    WHERE ss.RowStatus = 1  
          AND sd.RowStatus = 1  
          AND GETDATE()  
          BETWEEN ss.StartDate AND ss.FinishDate  
          AND  
          (  
              ss.IsGlobal = 1  
              OR tgt.CustomerId = @CustomerId
              OR tgt.CustomerTypeid = @CustomerType  
          )  
    ORDER BY ss.Priority DESC;  
  
    DECLARE @Value DECIMAL(12, 2) = 0;  
  
    DECLARE @TypeDiscount VARCHAR(20) =  
            (  
                SELECT TOP 1 ds.TypeDiscount FROM #Dicounts ds  
            );  

    DECLARE @DiscountName VARCHAR(100) =  
            (  
                SELECT TOP 1 ds.DicountName FROM #Dicounts ds  
            );  

    DECLARE @Unit VARCHAR(10) =  
        (  
            SELECT TOP 1 ds.Unit FROM #Dicounts ds  
        );  

    SET @Value =  
    (  
        SELECT TOP 1 ISNULL(ds.Value, 0)FROM #Dicounts ds  
    );  

    PRINT 'PARCELCODE: ' + @ParcelCode
    ---------------------Fin obtener descuento -------------------------------------------------------------------------------------  
    ---------------------Determinar si existe exceso de libras ---------------------------------------------------------------------  
    -- Hotfix - Andrés Ruíz - 17-02-2023  
    IF (  
           (  
               LTRIM(RTRIM(REPLACE(@ParcelCode, ',', ''))) = ''  
               OR LTRIM(RTRIM(REPLACE(@ParcelCode, ',', ''))) = '0'  
           )  
           AND @RateTypeId = 3  
       )  
    BEGIN  
 
        DECLARE @DataCounter INT = 1;  
        DECLARE @ParcelCode2 NVARCHAR(40);   
  
        SELECT TOP 1  
               @ParcelCode = Code  
        FROM DeliveryBackOffice.dbo.ArticleByCustomer WITH (NOLOCK)  
        WHERE AbcIdArticle =  
        (  
            SELECT ArtId  
            FROM DeliveryBackOffice.dbo.CatArticle WITH (NOLOCK)  
            WHERE ArtName = 'Paquete pequeño'  
                  AND  
                  (  
                      IdCountry = @Country  
                      OR  
                      (  
                          IdCountry IS NULL  
                          AND @Country = 'GT'  
                      )  
                  )  
        );  
  
        SET @ParcelCode2 = @ParcelCode;  
  
        IF (@DataCounter < @CountPiecesParams)  
        BEGIN  
            WHILE @DataCounter < @CountPiecesParams  
            BEGIN  
  
                SET @ParcelCode = CONCAT(@ParcelCode, ',' + @ParcelCode2);  
                SET @DataCounter = @DataCounter + 1;  
  
            END;  
        END;  
  
    END;  
    -- Fin hotfix  

    IF OBJECT_ID('tempdb.dbo.#ParceCode', 'U') IS NOT NULL  
        DROP TABLE #ParceCode;  
    IF OBJECT_ID('tempdb.dbo.#ParceWeigth', 'U') IS NOT NULL  
        DROP TABLE #ParceWeigth;  
    
    PRINT 'DELETE PARCECODE Y PARCEWEIGHT'
    print 'parcelCode: ' + @ParcelCode
    PRINT 'RateTypeId: ' + CAST(@RateTypeId AS VARCHAR(10))

    SELECT Item  
         , ROW_NUMBER() OVER (ORDER BY (SELECT 0)) ID  
    INTO #ParceCode  
    FROM DeliveryBackOffice.dbo.SplitUnlimited(@ParcelCode, ',');  
    
    IF (@RateTypeId = 3)  
    BEGIN  
  
        UPDATE [#ParceCode]   
        SET [Item] = @ParcelCode2  
        WHERE LTRIM(RTRIM(ISNULL([Item], ''))) = '';  
  
    END;  
  
    SELECT Item  
         , ROW_NUMBER() OVER (ORDER BY (SELECT 0)) ID  
    INTO #ParceWeigth  
    FROM DeliveryBackOffice.dbo.SplitUnlimited(RTRIM(LTRIM(@WeigthParcels)), ',');  
  
    DECLARE @OverWeight DECIMAL(12, 2) = 0;  
    DECLARE @OverWeightchar NVARCHAR(100);  
  
    SET @OverWeightchar =  
    (  
        SELECT SUM(IIF((w.Item - @WeigthLimit) < 0, 0, (w.Item - @WeigthLimit))) AS exeso  
        FROM #ParceWeigth        w  
            LEFT JOIN #ParceCode p  
                ON p.ID = w.ID  
        WHERE p.Item = '0'  
              OR p.Item IS NULL  
              OR p.Item = ''  
    );  

    PRINT 'OverWeightChar: ' +  CAST(@OverWeightchar AS VARCHAR(100));  
  
    SET @OverWeight =  
    (  
        SELECT SUM(IIF((w.Item - @WeigthLimit) < 0, 0, (w.Item - @WeigthLimit))) AS exeso  
        FROM #ParceWeigth        w  
            LEFT JOIN #ParceCode p  
                ON p.ID = w.ID  
        WHERE p.Item = '0'  
              OR p.Item IS NULL  
              OR p.Item = ''  
    );  
  
    ----------------- Fin Determinar si existe exceso de libras --------------------------------------------------------------------  
    DECLARE @CountPiece INT = 0;  
  
    ----------------- Variable tipo tabla para almacenar tarifas --------------------------------------------------------------------  
  
   PRINT 'PARCELCODE: ' + @ParcelCode
    DECLARE @TempRate TABLE  
    (  
        Id INT IDENTITY(1, 1)
      , BaseRate DECIMAL(12, 2)
      , ReturnRate DECIMAL(12, 2) 
      , FragilRate DECIMAL(12, 2)
      , CollectedRate DECIMAL(12, 2)
      , CreditCardRate DECIMAL(12, 2)  
      , OverWeightRate DECIMAL(12, 2)
      , IrregularPieceRate DECIMAL(12, 2)  
      , TypeRate VARCHAR(50)
      , Segment VARCHAR(50)  
      , Service VARCHAR(50) 
      , ServiceName VARCHAR(100)    
      , Discount DECIMAL(12, 2)  
      , DiscountName VARCHAR(100)
      , ServiceDescription VARCHAR(200)  
      , InsuranceRate DECIMAL(12, 2)
      , InsuranceCharge DECIMAL(12, 2)
      , InsuranceExempt DECIMAL(12,2)
    );  
  
    ----------------- Fin Variable tipo tabla para almacenar tarifas --------------------------------------------------------------------  
	PRINT ('AFUERA IF @RateTypeId'+CONVERT(nvarchar(100),@RateTypeId))
    IF @RateTypeId = 1 -- tarifas estandar  
    BEGIN  
        --print 'aqui van las tarifas standar'  
        DECLARE @CountPiecebyArticle INT = 0;  
        DECLARE @ParcelPrice2 DECIMAL(12, 2) = 0;  
  
        SET @CountPiecebyArticle =  
        (  
            SELECT COUNT(1)  
            FROM #ParceWeigth         pw  
                INNER JOIN #ParceCode pc  
                    ON pc.ID = pw.ID  
            WHERE pc.Item <> '0'  
                  AND pc.Item <> ''  
                  AND pc.Item NOT IN  
                      (  
                          SELECT Code  
                          FROM DeliveryBackOffice.dbo.ArticleByCustomer     WITH (NOLOCK)
                          WHERE AbcIdArticle IN  
                                (  
                                    SELECT ArtId  
                                    FROM DeliveryBackOffice.dbo.CatArticle  WITH (NOLOCK)
                                    WHERE ArtName IN ( 'Paquete pequeño', 'Paquete mediano', 'Paquete grande'  
                                                     , 'Paquete extra grande', 'Paquete sobredimensionado'  
                                                     )  
                                          AND  
                                          (  
                                              IdCountry = @Country  
                                              OR  
                                              (  
                                                  IdCountry IS NULL  
                                                  AND @Country = 'GT'  
                                              )  
                                          )  
                                )  
                      )  
                  AND pc.Item IS NOT NULL  
        );  
  
        SET @CountPiece = [DeliveryBackOffice].[dbo].FnPiecesByPiecesIncluded(@CountPiecesParams, @PiecesIncluded) - @CountPiecebyArticle;  
  
        SELECT Item  
        INTO #ListCode2  
        FROM [DeliveryBackOffice].[dbo].SplitUnlimited(@ParcelCode, ',');  
  
        SET @ParcelPrice2 =  
        (  
            SELECT SUM(ISNULL(ra.RateValue, ISNULL(ar.PriceDefault, 0)))  
            FROM #ListCode2                      ls  
                INNER JOIN [DeliveryBackOffice].[dbo].ArticleByCustomer ar  WITH (NOLOCK)
                    ON ar.Code = ls.Item  
                INNER JOIN [DeliveryBackOffice].[dbo].RateData          ra  WITH (NOLOCK)
                    ON ra.ArticleId = ar.AbcId  
            WHERE ra.TypeSegmentId = @IdSegment  
                  AND ra.RateId = @RateId  
        );  
  
        IF (@IsSDD = 'true' AND @CountPiecebyArticle = 0) -----HOTFIX_SAMEDAY.INI   
        BEGIN  

            INSERT INTO @TempRate  
            SELECT 
                   (ISNULL(rd.RateValue, 0) * @CountPiece)                                                         AS BaseRate
                 , ISNULL(rh.ReturnRate, 0)                                                                        AS ReturnRate
                 , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)                                           AS fragilRate
                 , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)                                        AS CollectedRate
                 , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0)                             AS CreditCardRate
                 , IIF(ISNULL(@OverWeight, 0) > 0, ISNULL(@OverWeight, 0) * ISNULL(rh.AdditionalWeightRate, 0), 0) AS OverWeightRate
                 , ISNULL(@ParcelPrice2, 0)                                                                        AS IrregularParcelRate
                 , ISNULL(cr.Name, '')                                                                             AS TypeRate  
                 , ISNULL(sg.CrsShortName, '')                                                                     AS Segment  
                 , ISNULL(sv.CtsShortName, '')                                                                     AS Service  
                 , ISNULL(sv.CtsName, '')                                                                          AS ServiceName 
                 , CAST(((ISNULL(rd.RateValue, 0) * @CountPiece) * ISNULL(@Value, 0) / 100) AS DECIMAL(12, 2))     AS Discoun
                 , ISNULL(@DiscountName, '')                                                                       AS DiscountName  
                 , ISNULL(sv.CtsDescription, '')                                                                   AS ServiceDescription                  
                 , IIF(@IsInsurance = 1
                       , IIF(@CustomerType IN (2, 3)
                           -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                           , CASE
                               WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount 
                                   THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                               WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                                   THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                               ELSE 0
                             END
                           -- Tipo 1: comportamiento original
                           , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                               , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                               , 0)
                         )
                       , 
                    0)                                                                                             AS InsuranceRate
                 , ISNULL(RH.InsuranceCharge,0)                                                                    AS InsuranceCharge
                 , ISNULL(RH.InsuranceExempt,0)                                                                    AS InsuranceExempt
            FROM [DeliveryBackOffice].[dbo].RateHeader              rh WITH (NOLOCK)  
                INNER JOIN [DeliveryBackOffice].[dbo].RateData      rd WITH (NOLOCK)  
                    ON rd.RateId = rh.RheId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment sg WITH (NOLOCK)  
                    ON sg.CrsId = rd.TypeSegmentId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService sv WITH (NOLOCK)  
                    ON sv.CtsId = rd.TypeServiceId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate    cr WITH (NOLOCK)  
                    ON cr.IdTypeRate = rh.RateTypeId  
            WHERE rh.RheRowStatus = 'true'  
                  AND rd.RowStatus = 'true'  
                  AND rh.RheId = @RateId  
                  AND rd.ArticleId IS NULL  
                  AND (rd.TypeServiceId IN  
                       (  
                           SELECT CtsId  
                           FROM [DeliveryBackOffice].[dbo].CatTypeService  WITH (NOLOCK)
                           WHERE RateGroup = @IdRateGroup  
                                 AND CtsRowStatus = 1  
                       )  
                      )  
                  AND rd.HubSourceId = @IdHubSource  
                  AND rd.HubDestinyId = @IdHubDestiny  
                  AND CONVERT(DATETIME, @Time, 108) <= ISNULL(  
                                                                 CONVERT(  
                                                                            DATETIME  
                                                                          , ISNULL(  
                                                                                      rd.LimitHourPickup  
                                                                                    , sv.LimitHourPickup  
                                                                                  )  
                                                                          , 108  
                                                                        )  
                                                               , CONVERT(DATETIME, '23:59:59', 108)  
                                                             );  
  
        END;  
        ELSE  
        BEGIN  

            INSERT INTO @TempRate  
            SELECT 
                   (ISNULL(rd.RateValue, 0) * @CountPiece)                                                         AS BaseRate
                 , ISNULL(rh.ReturnRate, 0)                                                                        AS ReturnRate
                 , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)                                           AS fragilRate
                 , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)                                        AS CollectedRate 
                 , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0)                             AS CreditCardRate 
                 , IIF(ISNULL(@OverWeight, 0) > 0, ISNULL(@OverWeight, 0) * ISNULL(rh.AdditionalWeightRate, 0), 0) AS OverWeightRate 
                 , ISNULL(@ParcelPrice2, 0)                                                                        AS IrregularPieceRate
                 , ISNULL(cr.Name, '')                                                                             AS TypeRate                   
                 , ISNULL(sg.CrsShortName, '')                                                                     AS Segment  
                 , ISNULL(sv.CtsShortName, '')                                                                     AS Service
                 , ISNULL(sv.CtsName, '')                                                                          AS ServiceName
                 , CAST(((ISNULL(rd.RateValue, 0) * @CountPiece) * ISNULL(@Value, 0) / 100) AS DECIMAL(12, 2))     AS Discount
                 , ISNULL(@DiscountName, '')                                                                       AS DiscountName  
                 , ISNULL(sv.CtsDescription, '')                                                                   AS ServiceDescription                                     
                 , IIF(@IsInsurance = 1
                       , IIF(@CustomerType IN (2, 3)
                           -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                           , CASE
                               WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount
                                   THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                               WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                                   THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                               ELSE 0
                             END
                           -- Tipo 1: comportamiento original
                           , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                               , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                               , 0)
                         )
                       , 
                    0)                                                                                             AS InsuranceRate
                 , ISNULL(RH.InsuranceCharge,0)                                                                    AS InsuranceCharge
                 , ISNULL(RH.InsuranceExempt,0)                                                                    AS InsuranceExempt                                                                                            
            FROM [DeliveryBackOffice].[dbo].RateHeader              rh WITH (NOLOCK)  
                INNER JOIN [DeliveryBackOffice].[dbo].RateData      rd WITH (NOLOCK)  
                    ON rd.RateId = rh.RheId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment sg WITH (NOLOCK)  
                    ON sg.CrsId = rd.TypeSegmentId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService sv WITH (NOLOCK)  
                    ON sv.CtsId = rd.TypeServiceId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate    cr WITH (NOLOCK)  
                    ON cr.IdTypeRate = rh.RateTypeId  
            WHERE rh.RheRowStatus = 'true'  
                  AND rd.RowStatus = 'true'  
                  AND rh.RheId = @RateId  
                  AND rd.ArticleId IS NULL  
                  AND (rd.TypeServiceId IN  
                       (  
                           SELECT CtsId  
                           FROM [DeliveryBackOffice].[dbo].CatTypeService  WITH (NOLOCK)
                           WHERE RateGroup = @IdRateGroup  
                                 AND CtsRowStatus = 1  
                       )  
                      )  
                  AND rd.HubSourceId = @IdHubSource  
                  AND rd.HubDestinyId = @IdHubDestiny  
                  AND CONVERT(DATETIME, @Time, 108) <= ISNULL(  
                                                                 CONVERT(  
                                                                            DATETIME  
                                                                          , ISNULL(  
                                                                                      rd.LimitHourPickup  
                                                                                    , sv.LimitHourPickup  
                                                                                  )  
                                                                          , 108  
                                                                        )  
                                                               , CONVERT(DATETIME, '23:59:59', 108)  
                                                             )  
                  AND sv.CtsShortName NOT IN ( 'SDD' );  
  
        END; -----HOTFIX_SAMEDAY.FIN  
  
  
    END;  
    ELSE IF @RateTypeId = 2 -- tarifas todo destino  
    BEGIN  

        SET @CountPiece = [DeliveryBackOffice].[dbo].FnPiecesByPiecesIncluded(@CountPiecesParams, @PiecesIncluded); -- todos los demas clientes se les cobra por pieza  

        INSERT INTO @TempRate  
        SELECT 
               (ISNULL(rd.RateValue, 0) * @CountPiece)                                   AS BaseRate
             , ISNULL(rh.ReturnRate, 0)                                                  AS ReturnRate
             , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)                     AS fragilRate
             , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)                  AS CollectedRate
             , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0)       AS CreditCardRate
             , IIF(@OverWeight > 0, @OverWeight * ISNULL(rh.AdditionalWeightRate, 0), 0) AS OverWeightRate
             , 0                                                                         AS IrregularParcelRate 
             , ISNULL(cr.Name, '')                                                       AS TypeRate  
             , ISNULL(sg.CrsShortName, '')                                               AS Segment  
             , ISNULL(sv.CtsShortName, '')                                               AS Service  
             , ISNULL(sv.CtsName, '')                                                    AS serviceName
             , 0                                                                         AS Discount
             , ''                                                                        AS DiscountName  
             , ISNULL(sv.CtsDescription, '')                                             AS ServiceDescription                             
                 , IIF(@IsInsurance = 1
                       , IIF(@CustomerType IN (2, 3)
                           -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                           , CASE
                               WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount 
                                   THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                               WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                                   THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                               ELSE 0
                             END
                           -- Tipo 1: comportamiento original
                           , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                               , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                               , 0)
                         )
                       , 
                    0)                                                                                             AS InsuranceRate
                 , ISNULL(RH.InsuranceCharge,0)                                                                    AS InsuranceCharge
                 , ISNULL(RH.InsuranceExempt,0)                                                                    AS InsuranceExempt 
        FROM [DeliveryBackOffice].[dbo].RateHeader              rh WITH (NOLOCK)  
            INNER JOIN [DeliveryBackOffice].[dbo].RateData      rd WITH (NOLOCK)  
                ON rd.RateId = rh.RheId  
            LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment sg WITH (NOLOCK)  
                ON sg.CrsId = rd.TypeSegmentId  
            LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService sv WITH (NOLOCK)  
                ON sv.CtsId = rd.TypeServiceId  
            LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate    cr WITH (NOLOCK)  
                ON cr.IdTypeRate = rh.RateTypeId  
        WHERE rh.RheId = @RateId
              AND rd.RowStatus = 'true'  
              AND rd.ArticleId IS NULL  
              AND rd.TypeSegmentId = @IdSegment  
              AND (rd.TypeServiceId IN  
                   (  
                       SELECT CtsId  
                       FROM [DeliveryBackOffice].[dbo].CatTypeService  WITH (NOLOCK)
                       WHERE RateGroup = @IdRateGroup  
                             AND CtsRowStatus = 1  
                   )  
                  )  
              AND CONVERT(DATETIME, @Time, 108) <= ISNULL(  
                                                             CONVERT(  
                                                                        DATETIME  
                                                                      , ISNULL(rd.LimitHourPickup, sv.LimitHourPickup)  
                                                                      , 108  
                                                                    )  
                                                           , CONVERT(DATETIME, '23:59:59', 108)  
                                                         );  
    END;  
    ELSE IF @RateTypeId = 3 -- tarifas por articulo  
    BEGIN
        PRINT('ENTRA ID 3')
        SET @CountPiece =  
        (  
            SELECT COUNT(*)  
            FROM #ParceWeigth        w  
                LEFT JOIN #ParceCode p  
                    ON p.ID = w.ID  
            WHERE p.Item = '0'  
                  OR p.Item IS NULL  
                  OR p.Item = ''  
        );  
        ------------------------------------- verificar tarifas de piezas irregulares ---------------------------------------------------  
        SELECT Item  
        INTO #ListCode  
        FROM [DeliveryBackOffice].[dbo].SplitUnlimited(@ParcelCode, ',');  
  
        --select * from #ListCode  
        DECLARE @ParcelPrice DECIMAL(12, 2) = 0;  

        IF (@RateId IN ( 
                        @NewMainRates, @NewAlternativeRates
                       ,@NewAutoSalesMainRates, @NewRateGeneral
                       ,@NewRateGeneralDiscount
                       )
           )
        BEGIN

            SET @IdSegment = NULL; 

            IF (EXISTS (SELECT TOP 1 1 FROM #ListCode)  
                AND LTRIM(RTRIM((  
                                    SELECT TOP 1 Item FROM #ListCode  
                                )  
                               )  
                         ) <> ''  
               )  
            BEGIN 
		    	
		    	PRINT(@HeaderCodeSource+' VALOR @@HeaderCodeSource')
		    	PRINT(@HeaderCodeDestiny+' VALOR @@@HeaderCodeDestiny')
		    	PRINT(CONVERT(NVARCHAR(100),@RateId)+' VALOR @@@@RateId')
                -- HeaderCodes  - revisar tabla  
                SELECT TOP 1  
                       @IdSegment = RTC.SegmentTypeId  
                FROM [DeliveryBackOffice].[dbo].[RateTownshipCoverage] RTC WITH (NOLOCK)  
                    INNER JOIN [DeliveryBackOffice].[dbo].[Township]   TwnSource WITH (NOLOCK)  
                        ON RTC.TownshipSourceId = TwnSource.IdTownship  
                    INNER JOIN [DeliveryBackOffice].[dbo].[Township]   TwnDestiny WITH (NOLOCK)  
                        ON RTC.TownshipDestinyId = TwnDestiny.IdTownship  
                WHERE RTC.RateId = @RateId
                      AND (TwnSource.HeaderCode = @HeaderCodeSource)  
                      AND (TwnDestiny.HeaderCode = @HeaderCodeDestiny)  
                      AND RTC.RowStatus = 1; 

            
                IF (@IdSegment IS NULL) -- si no se encuentra una configuracion válida para determinar el segmento tomar el foraneo como predeterminado.  
                BEGIN  
                     SELECT TOP 1  
                            @IdSegment = sg.CrsId  
                       FROM [DeliveryBackOffice].dbo.CatRateSegment sg WITH (NOLOCK)  
                      WHERE sg.CrsShortName = 'FOR';  
                END;  
            
                -- Cálculo de precios  
                -- Cálculo de precios  
                IF OBJECT_ID('tempdb.dbo.#ParcelAmountPerType', 'U') IS NOT NULL  
                    DROP TABLE #ParcelAmountPerType;  
                IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerType', 'U') IS NOT NULL  
                    DROP TABLE #ParcelOverweightPerType;  
            
                -- Servicios y segmentos  
                SELECT CRS.CrsId                 'SegmentType'  
                     , CTS.CtsId                 'ServiceType'  
                     , CAST(0 AS DECIMAL(18, 2)) 'TotalAmount'  
                INTO #ParcelAmountPerType  
                FROM [DeliveryBackOffice].[dbo].[CatRateSegment]           CRS WITH (NOLOCK)
                    CROSS JOIN [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH (NOLOCK);  
            
                -- Paquetes con su peso indicado  
                DECLARE @ExpectedWeight DECIMAL(12, 2) = 0;  
            
                SELECT p.ID           'RowNumber'  
                     , ABC.Code       'ParcelCode'  
                     , ABC.MassWeight 'ParcelWeight'  
                INTO #ParcelOverweightPerType  
                FROM #ParceCode                                               p  
                    INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH (NOLOCK)  
                        ON p.Item = ABC.Code COLLATE Latin1_General_CI_AI  
                WHERE ABC.AbcRowStatus = 1;  
            
                SET @ExpectedWeight =  
                (  
                    SELECT SUM(POPT.ParcelWeight)FROM #ParcelOverweightPerType POPT  
                );  
            
                BEGIN TRY  
            
                    SET @OverWeight =  
                    (  
                        SELECT SUM(CAST(ROUND(CAST(PW.Item AS DECIMAL(12, 2)), 0) AS INT))  
                        FROM #ParceWeigth PW  
                    );  
            
                END TRY  
                BEGIN CATCH  
            
                    SET @OverWeight = @ExpectedWeight;  
            
                END CATCH;  
            
                DECLARE @NewOverWeight DECIMAL(12, 2) = 0;  
                SET @NewOverWeight = (@OverWeight - @ExpectedWeight);  
            
                -- Actualizar con los que esten dentro del tarifario por tipo de servicio y tipo de segmento  
                UPDATE #ParcelAmountPerType  
                SET TotalAmount = TotalAmount + AddedTotalAmount  
                FROM  
                (  
                    SELECT rd.TypeSegmentId  AddedSegmentType  
                         , rd.TypeServiceId  AddedServiceType  
                         , SUM(rd.RateValue) 'AddedTotalAmount'  
                    FROM [DeliveryBackOffice].[dbo].RateHeader                  rh  
                        INNER JOIN [DeliveryBackOffice].[dbo].RateData          rd  WITH (NOLOCK)
                            ON rd.RateId = rh.RheId  
                        INNER JOIN [DeliveryBackOffice].[dbo].ArticleByCustomer abc WITH (NOLOCK)
                            ON rd.ArticleId = abc.AbcId  
                        INNER JOIN #ListCode             LC  WITH (NOLOCK)
                            ON abc.Code = LC.Item  
                    WHERE rh.RheId = @RateId
                          AND rd.RowStatus = 'true'  
                          AND rd.TypeSegmentId = @IdSegment  
                    GROUP BY rd.TypeSegmentId  
                           , rd.TypeServiceId  
                ) TempValues  
                WHERE TempValues.AddedSegmentType = #ParcelAmountPerType.SegmentType  
                      AND TempValues.AddedServiceType = #ParcelAmountPerType.ServiceType;  
            
                -- Actualizar con los que NO esten dentro del tarifario por tipo de servicio y tipo de segmento  
                UPDATE #ParcelAmountPerType  
                SET TotalAmount = TotalAmount + AddedTotalAmount  
                FROM  
                (  
                    SELECT rd.TypeSegmentId                            AddedSegmentType  
                         , SUM(ISNULL(rd.RateValue, abc.PriceDefault)) 'AddedTotalAmount'  
                    FROM #ListCode                                              lc  
                        INNER JOIN [DeliveryBackOffice].[dbo].ArticleByCustomer abc  WITH (NOLOCK)
                            ON abc.Code = lc.Item  
                        INNER JOIN [DeliveryBackOffice].[dbo].RateData          rd   WITH (NOLOCK)
                            ON rd.ArticleId = abc.AbcId  
                    WHERE rd.TypeServiceId IS NULL  
                          AND rd.TypeSegmentId = @IdSegment  
                          AND rd.RateId = @RateId
                    GROUP BY rd.TypeSegmentId  
                ) TempValues  
                WHERE TempValues.AddedSegmentType = SegmentType;  
            
                DECLARE @RealRateGroup AS TABLE  
                (  
                    ServiceTypeId INT NOT NULL  
                  , RowStatus BIT NOT NULL  
                        DEFAULT 1  
                );  
            
                INSERT INTO @RealRateGroup  
                (  
                    ServiceTypeId  
                )  
                SELECT CtsId  
                FROM [DeliveryBackOffice].[dbo].CatTypeService CTS WITH (NOLOCK)  
                WHERE RateGroup = @IdRateGroup  
                      AND CtsRowStatus = 1;  
            
                DECLARE @SDDTypeId INT =  
                        (  
                            SELECT TOP 1  
                                   CTS.CtsId  
                            FROM [DeliveryBackOffice].[dbo].[CatTypeService] CTS WITH (NOLOCK)  
                            WHERE CTS.CtsShortName = 'SDD'  
                        );  
                IF (@IsSDD = 0)  
                    UPDATE @RealRateGroup  
                    SET RowStatus = 0  
                    WHERE ServiceTypeId = @SDDTypeId;  
            
                -- Tarifas finales  
            
                INSERT INTO @TempRate  
                SELECT DISTINCT
                          (ISNULL(rd.RateValue, 0) * @CountPiece)                                         AS BaseRate
                        , ISNULL(rh.ReturnRate, 0)                                                        AS ReturnRate
                        , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)                           AS fragilRate
                        , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)                        AS CollectRate
                        , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0)             AS CreditCardRate
                        , IIF(@NewOverWeight > 0, @NewOverWeight * ISNULL(rh.AdditionalWeightRate, 0), 0) AS OverWeightRate
                        , ISNULL(papt.TotalAmount, 0)                                                     AS IrregularParcelRate
                        , ISNULL(cr.Name, '')                                                             AS TypeRate
                        , ISNULL(sg.CrsShortName, '')                                                     AS Segment
                        , ISNULL(sv.CtsShortName, '')                                                     AS Service
                        , ISNULL(sv.CtsName, '')                                                          AS ServiceName
                        , 0                                                                               AS Discount
                        , ''                                                                              AS DiscountName
                        , ISNULL(sv.CtsDescription, '')                                                   AS ServiceDescription
                        , IIF(@IsInsurance = 1
                            , IIF(@CustomerType IN (2, 3)
                                -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                                , CASE
                                    WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount 
                                        THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                                    WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                                        THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                                    ELSE 0
                                    END
                                -- Tipo 1: comportamiento original
                                , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                                    , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                                    , 0)
                                )
                            , 
                            0)                                                                            AS InsuranceRate
                        , ISNULL(RH.InsuranceCharge,0)                                                    AS InsuranceCharge
                        , ISNULL(RH.InsuranceExempt,0)                                                    AS InsuranceExempt
                FROM [DeliveryBackOffice].[dbo].RateHeader                 rh   WITH (NOLOCK)
                    INNER JOIN [DeliveryBackOffice].[dbo].RateData         rd   WITH (NOLOCK)
                        ON rd.RateId = rh.RheId  
                    INNER JOIN #ParcelAmountPerType papt  
                        ON rd.TypeSegmentId = papt.SegmentType  
                        AND rd.TypeServiceId = papt.ServiceType  
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment    sg   WITH (NOLOCK)
                        ON sg.CrsId = rd.TypeSegmentId  
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService    sv   WITH (NOLOCK)
                        ON sv.CtsId = rd.TypeServiceId  
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate       cr   WITH (NOLOCK)
                        ON cr.IdTypeRate = rh.RateTypeId  
                WHERE rh.RheId = @RateId  
                      AND rd.RowStatus = 'true' 
                      AND rd.TypeSegmentId = @IdSegment  
                      AND (rd.TypeServiceId IN  
                           (  
                               SELECT RRG.ServiceTypeId FROM @RealRateGroup RRG WHERE RRG.RowStatus = 1  
                           )  
                          )  
                      AND CONVERT(DATETIME, @Time, 108) <= ISNULL(  
                                                                     CONVERT(  
                                                                                DATETIME  
                                                                              , ISNULL(  
                              rd.LimitHourPickup  
                                                                                        , sv.LimitHourPickup  
                                                                                      )  
                                                                              , 108  
                                                                            )  
                                                                   , CONVERT(DATETIME, '23:59:59', 108)  
                                                                 );  
            
                IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerType', 'U') IS NOT NULL  
                    DROP TABLE #ParcelOverweightPerType;  
                IF OBJECT_ID('tempdb.dbo.#ParcelAmountPerType', 'U') IS NOT NULL  
                    DROP TABLE #ParcelAmountPerType;  
            END;  
        END
        ELSE
        BEGIN

            -- Paquetes con su peso indicado
            IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerTypeCorp', 'U') IS NOT NULL
                DROP TABLE #ParcelOverweightPerTypeCorp;

            DECLARE @DefaultWeighRatetOfRate DECIMAL(12, 2) = 0;
            DECLARE @DefaultWeightOfRate DECIMAL(18, 2) = 0;

            SET @DefaultWeighRatetOfRate =
            (
                SELECT TOP (1)
                       RH.[AdditionalWeightRate]
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.[RheId] = @RateId
            );

            SET @DefaultWeightOfRate =
            (
                SELECT TOP (1)
                       RH.[WeightLimit]
                FROM [DeliveryBackOffice].[dbo].[RateHeader] RH WITH (NOLOCK)
                WHERE RH.[RheId] = @RateId
            );

            DECLARE @ExpectedWeightCorp DECIMAL(12, 2) = 0;

            SELECT p.ID     'RowNumber'
                 , ABC.Code 'ParcelCode'
                 , (CASE
                        WHEN RD.[IdRateData] IS NULL THEN
                            @DefaultWeightOfRate
                        ELSE
                            CAST(PW.[Item] AS DECIMAL(12, 2))
                    END
                   )        'ParcelWeight'
            INTO #ParcelOverweightPerTypeCorp
            FROM #ParceCode                                               p
                INNER JOIN [#ParceWeigth]                                 PW
                    ON p.[ID] = PW.[ID]
                INNER JOIN [DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH (NOLOCK)
                    ON p.Item = ABC.Code
                OUTER APPLY
            (
                SELECT TOP (1)
                       RD.[IdRateData]
                FROM [DeliveryBackOffice].[dbo].[RateData] RD WITH (NOLOCK)
                WHERE [RD].[ArticleId] = [ABC].[AbcId]
                      AND [RD].[RateId] = @RateId
            )                                                             RD
            WHERE ABC.AbcRowStatus = 1;

            SET @ExpectedWeightCorp =
            (
                SELECT SUM(POPT.ParcelWeight)FROM #ParcelOverweightPerTypeCorp POPT
            );

            BEGIN TRY

                SET @OverWeight =
                (
                    SELECT SUM(CAST(ROUND(CAST(PW.Item AS DECIMAL(12, 2)), 0) AS INT))
                    FROM #ParceWeigth PW
                );

            END TRY
            BEGIN CATCH

                SET @OverWeight = @ExpectedWeightCorp;

            END CATCH;

            DECLARE @NewOverWeightCorp DECIMAL(12, 2) = 0;
            SET @NewOverWeightCorp = (@OverWeight - @ExpectedWeightCorp);

            -------------------------------------- fin verificar tarifas de piezas irregulares -----------------------------------------------
            INSERT INTO @TempRate
            SELECT 
                   SUM(x.BaseRate)
                 , x.ReturnRate
                 , x.fragilRate
                 , x.CollectedRate
                 , x.CreditCardRate
                 , x.OverWeightRate
                 , SUM(x.IrregularParcelRate)
                 , x.TypeRate
                 , x.Segment
                 , x.Service
                 , x.ServiceName
                 , SUM(x.Discount)
                 , x.DiscountName
                 , x.ServiceDescription
                 , SUM(x.InsuranceRate)
                   + CAST((IIF(@NewOverWeightCorp > 0, @NewOverWeightCorp * ISNULL(@DefaultWeighRatetOfRate, 0), 0)) AS DECIMAL(12, 2))
                 , MAX(x.InsuranceCharge)
                 , MAX(x.InsuranceExempt)
            FROM
            (
                SELECT 
                       (ISNULL(rd.RateValue, 0) * @CountPiece)                             AS BaseRate
                     , ISNULL(rh.ReturnRate, 0)                                            AS ReturnRate
                     , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)               AS fragilRate
                     , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)            AS CollectedRate
                     , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate
                     , 0                                                                   AS OverWeightRate
                     , ISNULL(rd.RateValue, ISNULL(ar.PriceDefault, 0))                    AS IrregularParcelRate
                     , ISNULL(cr.Name, '')                                                 AS TypeRate
                     , ISNULL(sg.CrsShortName, '')                                         AS Segment
                     , ISNULL(sv.CtsShortName, '')                                         AS Service
                     , ISNULL(sv.CtsName, '')                                              AS ServiceName
                     , 0                                                                   AS Discount
                     , ''                                                                  AS DiscountName
                     , ISNULL(sv.CtsDescription, '')                                       AS ServiceDescription
                     , IIF(@IsInsurance = 1
                         , IIF(@CustomerType IN (2, 3)
                             -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                             , CASE
                                 WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount 
                                     THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                                 WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                                     THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                                 ELSE 0
                                 END
                             -- Tipo 1: comportamiento original
                             , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                                 , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                                 , 0)
                             )
                         , 
                         0)                                                                                             AS InsuranceRate
                     , ISNULL(RH.InsuranceCharge,0)                                                                    AS InsuranceCharge
                     , ISNULL(RH.InsuranceExempt,0)                                                                    AS InsuranceExempt
                FROM #ParceCode                      ls
                    INNER JOIN [DeliveryBackOffice].[dbo].ArticleByCustomer ar WITH (NOLOCK)
                        ON ar.Code = ls.Item
                    INNER JOIN [DeliveryBackOffice].[dbo].RateHeader        rh WITH (NOLOCK)
                        ON rh.RheId = @RateId
                    INNER JOIN [DeliveryBackOffice].[dbo].RateData          rd WITH (NOLOCK)
                        ON rd.ArticleId = ar.AbcId
                        AND rd.RateId = rh.RheId
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment     sg WITH (NOLOCK)
                        ON sg.CrsId = rd.TypeSegmentId
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService     sv WITH (NOLOCK)
                        ON sv.CtsId = rd.TypeServiceId
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate        cr WITH (NOLOCK)
                        ON cr.IdTypeRate = rh.RateTypeId
                WHERE rd.TypeSegmentId = @IdSegment
                      AND rd.RowStatus = 'true'
                      AND (rd.TypeServiceId IN
                           (
                               SELECT CtsId
                               FROM [DeliveryBackOffice].[dbo].CatTypeService WITH (NOLOCK)
                               WHERE RateGroup = @IdRateGroup
                                     AND CtsRowStatus = 1
                           )
                          )
                UNION ALL
                SELECT
                       (ISNULL(rd.RateValue, 0) * @CountPiece)                             AS BaseRate
                     , ISNULL(rh.ReturnRate, 0)                                            AS ReturnRate
                     , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)               AS fragilRate
                     , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)            AS CollectedRate
                     , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate
                     , 0                                                                   AS OverWeightRate
                     , ISNULL(rd.RateValue, ISNULL(ar.PriceDefault, 0))                    AS IrregularParcelRate
                     , ISNULL(cr.Name, '')                                                 AS TypeRate
                     , ISNULL(sg.CrsShortName, '')                                         AS Segment
                     , ISNULL(sv.CtsShortName, '')                                         AS Service
                     , ISNULL(sv.CtsName, '')                                              AS ServiceName
                     , 0                                                                   AS Discount
                     , ''                                                                  AS DiscountName
                     , ISNULL(sv.CtsDescription, '')                                       AS ServiceDescription
                     , IIF(@IsInsurance = 1
                         , IIF(@CustomerType IN (2, 3)
                             -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                             , CASE
                                 WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount 
                                     THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                                 WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                                     THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                                 ELSE 0
                                 END
                             -- Tipo 1: comportamiento original
                             , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                                 , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                                 , 0)
                             )
                         , 
                         0)                                                                                             AS InsuranceRate
                     , ISNULL(RH.InsuranceCharge,0)                                                                    AS InsuranceCharge
                     , ISNULL(rh.InsuranceExempt,0)                                                                    AS InsuranceExempt
                FROM #ParceCode                      ls
                    INNER JOIN [DeliveryBackOffice].[dbo].ArticleByCustomer ar WITH (NOLOCK)
                        ON ar.Code = ls.Item
                    INNER JOIN [DeliveryBackOffice].[dbo].RateHeader        rh WITH (NOLOCK)
                        ON rh.RheId = @RateId
                    LEFT JOIN [DeliveryBackOffice].[dbo].RateData           rdignore WITH (NOLOCK) -- Ignorar artículos sin codigo dentro de tarifario
                        ON rdignore.ArticleId = ar.AbcId
                        AND rdignore.RateId = rh.RheId
                        AND rdignore.RowStatus = 'true'
                    LEFT JOIN [DeliveryBackOffice].[dbo].RateData           rd WITH (NOLOCK)
                        ON rd.ArticleId IS NULL
                        AND rd.RateId = rh.RheId
                        AND rd.RowStatus = 'true'
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment     sg WITH (NOLOCK)
                        ON sg.CrsId = rd.TypeSegmentId
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService     sv WITH (NOLOCK)
                        ON sv.CtsId = rd.TypeServiceId
                    LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate        cr WITH (NOLOCK)
                        ON cr.IdTypeRate = rh.RateTypeId
                WHERE rdignore.IdRateData IS NULL -- Ignorar artículos sin codigo dentro de tarifario
                      AND rd.TypeSegmentId = @IdSegment
                      AND (rd.TypeServiceId IN
                           (
                               SELECT CtsId
                               FROM [DeliveryBackOffice].[dbo].CatTypeService WITH (NOLOCK)
                               WHERE RateGroup = @IdRateGroup
                                     AND CtsRowStatus = 1
                           )
                          )
            ) x
            GROUP BY x.TypeRate
                   , x.Segment
                   , x.Service
                   , x.DiscountName
                   , x.fragilRate
                   , x.CollectedRate
                   , x.ServiceName
                   , x.CreditCardRate
                   , x.OverWeightRate
                   , x.ServiceDescription
                   , x.ReturnRate;

            IF OBJECT_ID('tempdb.dbo.#ParcelOverweightPerTypeCorp', 'U') IS NOT NULL
                DROP TABLE #ParcelOverweightPerTypeCorp;

        END

       -- PRINT @INSURANCEAMOUNT

    END;
    ELSE IF @RateTypeId = 4 -- tarifas especiales  
    BEGIN  
        PRINT 'aqui van las tarifas especiales';  
    END;  
    -- FDD-671 INI  
    ELSE IF @RateTypeId = 5 -- tarifas por peso  
    BEGIN  
  
        --Cálcular las piezas que no entran en rangos  
        DECLARE @tblNotInRange AS TABLE  
        (  
            ID INT NULL  
          , Weight DECIMAL(12, 2) NULL  
          , CatTypeServiceId INT NULL  
        );  
  
        INSERT INTO @tblNotInRange  
        SELECT pw.ID  
             , pw.Item  
             , cts.CtsId  
        FROM #ParceWeigth pw  
           , CatTypeService cts  
        WHERE NOT EXISTS  
        (  
            SELECT 1  
            FROM [DeliveryBackOffice].[dbo].RateData  WITH (NOLOCK)
            WHERE RateId = @RateId
                  AND TypeSegmentId = @IdSegment  
                  AND TypeServiceId = cts.CtsId  
                  AND RowStatus = 1  
                  AND pw.Item  
                  BETWEEN WeightFrom AND WeightTo  
        )  
              AND cts.CtsRowStatus = 1  
              AND cts.RateGroup = @IdRateGroup;  


        INSERT INTO @TempRate  
        SELECT 
               SUM(BaseRate)                                                                       [BaseRate]
             , ReturnRate                                                                          [ReturnRate]
             , fragilRate                                                                          [fragilRate]
             , CollectedRate                                                                       [CollectedRate]
             , CreditCardRate                                                                      [CreditCardRate]
             , (SUM(OverWeightRate) + IIF(@OverWeight > 0, @OverWeight, 0)) * AdditionalWeightRate [OverWeightRate]
             , IrregularParcelRate                                                                 [IrregularParcelRate]
             , TypeRate                                                                            [TypeRate]
             , Segment                                                                             [Segment]
             , Service                                                                             [Service]
             , CtsName                                                                             [ServiceName]
             , DiscountValue                                                                       [Discount]
             , DiscountName                                                                        [DiscountName]
             , CtsDescription                                                                      [ServicieDescription]
             , InsuranceRate                                                                       [InsuranceRate]
             , InsuranceCharge                                                                     [InsuranceCharge]
             , InsuranceExempt                                                                     [InsuranceExempt]
        FROM  
        (  
            SELECT 
                   ISNULL(rd.RateValue, 0)                                             AS BaseRate
                 , ISNULL(rh.ReturnRate, 0)                                            AS ReturnRate
                 , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)               AS fragilRate
                 , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)            AS CollectedRate
                 , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0) AS CreditCardRate
                 , 0                                                                   AS OverWeightRate
                 , ISNULL(@ParcelPrice, 0)                                             AS IrregularParcelRate   
                 , ISNULL(ctr.Name, '')                                                AS TypeRate  
                 , ISNULL(crs.CrsShortName, '')                                        AS Segment 
                 , ISNULL(cts.CtsShortName, '')                                        AS [Service]
                 , ISNULL(cts.CtsName, '')                                             AS ServiceName
                 , ''                                                                  AS DiscountName  
                 , 0                                                                   AS DiscountValue  
                , ISNULL(cts.CtsDescription, '')                                       AS ServiceDescription 
                , IIF(@IsInsurance = 1
                    , IIF(@CustomerType IN (2, 3)
                        -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                        , CASE
                            WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount 
                                THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                            WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                                THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                            ELSE 0
                            END
                        -- Tipo 1: comportamiento original
                        , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                            , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                            , 0)
                        )
                    , 
                0)                                                                     AS InsuranceRate
                , ISNULL(RH.InsuranceCharge,0)                                         AS InsuranceCharge
                , ISNULL(RH.InsuranceExempt,0)                                         AS InsuranceExempt 
                , ISNULL(rh.AdditionalWeightRate, 0)                                   AS AdditionalWeightRate  
            FROM [DeliveryBackOffice].[dbo].RateHeader              rh          WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].RateData      rd          WITH (NOLOCK)
                    ON rd.RateId = rh.RheId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment crs         WITH (NOLOCK)
                    ON crs.CrsId = rd.TypeSegmentId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService cts         WITH (NOLOCK)
                    ON cts.CtsId = rd.TypeServiceId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate    ctr         WITH (NOLOCK)
                    ON ctr.IdTypeRate = rh.RateTypeId  
                INNER JOIN #ParceWeigth  pw          WITH (NOLOCK)
                    ON pw.Item  
                       BETWEEN rd.WeightFrom AND rd.WeightTo  
            WHERE rh.RheId = @RateId
                  AND rd.RowStatus = 1  
                  AND rd.TypeSegmentId = @IdSegment  
                  AND (rd.TypeServiceId IN  
                       (  
                           SELECT CtsId  
                           FROM [DeliveryBackOffice].[dbo].CatTypeService        WITH (NOLOCK)
                           WHERE RateGroup = @IdRateGroup  
                                 AND CtsRowStatus = 1  
                       )  
                      )  
                  AND CONVERT(DATETIME, @Time, 108) <= ISNULL(  
                                                                 CONVERT(  
                                                                            DATETIME  
                                                                          , ISNULL(  
                                                                                      rd.LimitHourPickup  
                                                                                    , cts.LimitHourPickup  
                                                                                  )  
                                                                          , 108  
                                                                        )  
                                                               , CONVERT(DATETIME, '23:59:59', 108)  
                                                             )  
            UNION ALL  
            SELECT 
                   ISNULL(rd.RateValue, 0)                                               AS BaseRate
                 , ISNULL(rh.ReturnRate, 0)                                              AS ReturnRate
                 , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)                 AS fragilRate
                 , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)              AS CollectedRate
                 , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0)   AS CreditCardRate
                 , IIF(pw.Weight <= @WeigthLimit  
                       , pw.Weight - rd.WeightTo  
                       , IIF(@WeigthLimit > rd.WeightTo, @WeigthLimit - rd.WeightTo, 0)) AS OverWeightRate
                 , ISNULL(@ParcelPrice, 0)                                               AS IrregularParcelRate             
                 , ISNULL(ctr.Name, '')                                                  AS TypeRate  
                 , ISNULL(crs.CrsShortName, '')                                          AS Segment  
                 , ISNULL(cts.CtsShortName, '')                                          AS Service  
                 , ISNULL(cts.CtsName, '')                                               AS ServiceName
                 , 0                                                                     AS DiscountValue
                 , ''                                                                    AS DiscountName  
                 , ISNULL(cts.CtsDescription, '')                                        AS ServiceDescription 
                 , IIF(@IsInsurance = 1
                     , IIF(@CustomerType IN (2, 3)
                         -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                         , CASE
                             WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount 
                                 THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                             WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                                 THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                             ELSE 0
                             END
                         -- Tipo 1: comportamiento original
                         , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                             , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                             , 0)
                         )
                     , 
                 0)                                                                     AS InsuranceRate
                 , ISNULL(RH.InsuranceCharge,0)                                         AS InsuranceCharge
                 , ISNULL(RH.InsuranceExempt,0)                                         AS InsuranceExempt 
                 , ISNULL(rh.AdditionalWeightRate, 0)                                   AS AdditionalWeightRate  
            FROM [DeliveryBackOffice].[dbo].RateHeader               rh        WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].RateData       rd        WITH (NOLOCK)
                    ON rd.RateId = rh.RheId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment  crs       WITH (NOLOCK)
                    ON crs.CrsId = rd.TypeSegmentId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService  cts       WITH (NOLOCK)
                    ON cts.CtsId = rd.TypeServiceId  
                LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate     ctr       WITH (NOLOCK)
                    ON ctr.IdTypeRate = rh.RateTypeId  
                INNER JOIN @tblNotInRange pw
                    ON pw.CatTypeServiceId = rd.TypeServiceId  
            WHERE rh.RheId = @RateId
                  AND rd.RowStatus = 1  
                  AND rd.IdRateData =  
                  (  
                      SELECT TOP 1  
                             IdRateData  
                      FROM [DeliveryBackOffice].[dbo].RateData                 WITH (NOLOCK)
                      WHERE RateId = @RateId
                            AND TypeSegmentId = @IdSegment  
                            AND TypeServiceId = cts.CtsId  
                            AND RowStatus = 1  
                      ORDER BY WeightTo DESC  
                  )  
                  AND rd.TypeSegmentId = @IdSegment  
                  AND CONVERT(DATETIME, @Time, 108) <= ISNULL(  
                                                                 CONVERT(  
                                                                            DATETIME  
                                                                          , ISNULL(  
                                                                                      rd.LimitHourPickup  
                                                                                    , cts.LimitHourPickup  
                                                                                  )  
                                                                          , 108  
                                                                        )  
                                                               , CONVERT(DATETIME, '23:59:59', 108)  
                                                             )  
        ) X  
        GROUP BY TypeRate  
               , Segment  
               , Service  
               , DiscountName  
               , DiscountValue  
               , fragilRate  
               , CollectedRate  
               , InsuranceRate  
               , CreditCardRate  
               , IrregularParcelRate  
               , CtsName  
               , CtsDescription  
               , ReturnRate  
               , AdditionalWeightRate;  
    END;  
    -- FDD-671 FIN  
    ELSE IF @RateTypeId = 6 -- tarifas coberturas  
    BEGIN  
        SET @CountPiece = [DeliveryBackOffice].[dbo].FnPiecesByPiecesIncluded(@CountPiecesParams, @PiecesIncluded);  

        INSERT INTO @TempRate  
        SELECT
               (ISNULL(rd.RateValue, 0) * @CountPiece)                                   AS BaseRate
             , ISNULL(rh.ReturnRate, 0)                                                  AS ReturnRate
             , IIF(@IsFragile = 'true', ISNULL(rh.FragilRate, 0), 0)                     AS fragilRate
             , IIF(@IsCollected = 'true', ISNULL(rh.CollectRate, 0), 0)                  AS CollectedRate
             , IIF(@IsCreditCardPayment = 'true', ISNULL(rh.CreditCardRate, 0), 0)       AS CreditCardRate
             , IIF(@OverWeight > 0, @OverWeight * ISNULL(rh.AdditionalWeightRate, 0), 0) AS OverWeightRate
             , 0                                                                         AS IrregularParcelRate
             , ISNULL(cr.Name, '')                                                       AS TypeRate  
             , ISNULL(sg.CrsShortName, '')                                               AS Segment  
             , ISNULL(sv.CtsShortName, '')                                               AS Service  
             , ISNULL(sv.CtsName, '')                                                    AS ServiceName
             , 0                                                                         AS Discount
             , ''                                                                        AS DiscountName  
             , ISNULL(sv.CtsDescription, '')                                             AS ServiceDescription             
             , IIF(@IsInsurance = 1
                 , IIF(@CustomerType IN (2, 3)
                     -- Tipos 2 y 3: tres rangos según @InsuranceAmount
                     , CASE
                         WHEN @InsuranceAmount >= 0.00 AND @InsuranceAmount <  @LimitInsuranceAmount 
                             THEN CAST(ISNULL(rh.InsuranceCharge, 3) AS DECIMAL(12, 2))
                         WHEN @InsuranceAmount >=  @LimitInsuranceAmount 
                             THEN CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                         ELSE 0
                         END
                     -- Tipo 1: comportamiento original
                     , IIF(@InsuranceAmount > ISNULL(rh.InsuranceExempt, 0)
                         , CAST((@InsuranceAmount * ISNULL(rh.InsuranceRate, 0) / 100) AS DECIMAL(12, 2))
                         , 0)
                     )
                 , 
             0)                                                                          AS InsuranceRate
             , ISNULL(RH.InsuranceCharge,0)                                              AS InsuranceCharge
             , ISNULL(RH.InsuranceExempt,0)                                              AS InsuranceExempt
        FROM [DeliveryBackOffice].[dbo].RateHeader              rh WITH (NOLOCK)  
            INNER JOIN [DeliveryBackOffice].[dbo].RateData      rd WITH (NOLOCK)  
                ON rd.RateId = rh.RheId  
            LEFT JOIN [DeliveryBackOffice].[dbo].CatRateSegment sg WITH (NOLOCK)  
                ON sg.CrsId = rd.TypeSegmentId  
            LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeService sv WITH (NOLOCK)  
                ON sv.CtsId = rd.TypeServiceId  
            LEFT JOIN [DeliveryBackOffice].[dbo].CatTypeRate    cr WITH (NOLOCK)  
                ON cr.IdTypeRate = rh.RateTypeId  
        WHERE rh.RheId = @RateId
              AND rd.RowStatus = 'true'  
              AND rd.ArticleId IS NULL  
              AND rd.TypeSegmentId = @IdSegment  
              AND (rd.TypeServiceId IN  
                   (  
                       SELECT CtsId  
                       FROM [DeliveryBackOffice].[dbo].CatTypeService   WITH (NOLOCK)
                       WHERE RateGroup = @IdRateGroup  
                             AND CtsRowStatus = 1  
                   )  
                  )  
              AND CONVERT(DATETIME, @Time, 108) <= ISNULL(  
                                                             CONVERT(  
                                                                        DATETIME  
                                                                      , ISNULL(rd.LimitHourPickup, sv.LimitHourPickup)  
                                                                      , 108  
                                                                    )  
                                                           , CONVERT(DATETIME, '23:59:59', 108)  
                                                         );  
    END;  
    ELSE  
    BEGIN  
        PRINT 'error no se encontro un tarifario';  
    END;  

    /* Membresías y Suscripciones */  
    -- Oscar Morales 2022-07-18  
    /* Actualización: Aplicar descuento únicamente a costo base   
    Autor: Jerson Ochoa 30-12-2022 */  
    IF (  
           @CalculateMembership = 'true'  
           AND @ProductId > 0  
           AND @CategoryProductId > 0  
       )  
    BEGIN  
        DECLARE @PriceShippment DECIMAL(14, 2);  
        DECLARE @MembershipId INT;  
        DECLARE @ServiceValue DECIMAL(14, 2) = 0;  
        DECLARE @Discount DECIMAL(18, 2) = 0;  
        DECLARE @NewPriceShippment DECIMAL(14, 2);  
        --DECLARE @CatMembershipStatusId INT  
        DECLARE @SubscriptionId INT;  
        DECLARE @ServiceValueSubscription DECIMAL(14, 2) = 0;  
        DECLARE @DiscountValue DECIMAL(5, 2);  
        DECLARE @DescriptionTypeSubscription NVARCHAR(50);  
        DECLARE @Type NVARCHAR(50);  
        DECLARE @DiscountValue2 DECIMAL(5, 2);  
        DECLARE @Type2 NVARCHAR(50);  
  
        DECLARE @i INT = 0;  
        DECLARE @total INT = ISNULL((  
                                        SELECT MAX(Id)FROM @TempRate  
                                    )  
                                  , 0  
                                   );  
  
        --Se busca suscripciones   
        IF (@TypeSubscriptionId > 0)  
        BEGIN  
            DECLARE @NameTypeSubscrition VARCHAR(50);  
            DECLARE @NameCategoryProduct VARCHAR(50);  
  
            SET @NameTypeSubscrition =  
            (  
                SELECT TOP 1  
                       cts.CatTypeSubscriptionName  
                FROM [DeliveryBackOffice].[dbo].CatSubscription               csp WITH (NOLOCK)  
                    INNER JOIN [DeliveryBackOffice].[dbo].CatTypeSubscription cts WITH (NOLOCK)  
                        ON csp.CatTypeSubscriptionId = cts.IdCatTypeSubscription  
                    INNER JOIN [DeliveryBackOffice].[dbo].CatProductCategory  cpc WITH (NOLOCK)  
                        ON csp.CatProductCategoryId = cpc.IdCatProductCategory  
                WHERE cpc.IdCatProductCategory = @CategoryProductId  
            );  
  
  
  
            IF (@NameTypeSubscrition IS NULL)  
            BEGIN  
                SET @NameTypeSubscrition =  
                (  
                    SELECT TOP 1  
                           cvt.ValueTypeName  
                    FROM [DeliveryBackOffice].[dbo].CatValueType                      cvt WITH (NOLOCK)  
                        INNER JOIN [DeliveryBackOffice].[dbo].MembershipDiscountRange mdr WITH (NOLOCK)  
                            ON cvt.IdCatValueType = mdr.ValueTypeId  
                        INNER JOIN [DeliveryBackOffice].[dbo].Membership              mbs WITH (NOLOCK)  
                            ON mdr.MembershipId = mbs.IdMembership  
                    WHERE mbs.IdMembership = @ProductId  
                );  
            END;  
  
            SET @NameCategoryProduct =  
            (  
                SELECT TOP 1  
                       TechnicalDescription  
                FROM [DeliveryBackOffice].[dbo].CatProductCategory WITH (NOLOCK)  
                WHERE IdCatProductCategory = @CategoryProductId  
            );  
  
            IF (@NameCategoryProduct = 'Planes')  
            BEGIN  
  
                SELECT TOP 1  
                       @SubscriptionId              = sc.IdSubscription  
                     , @ServiceValueSubscription  
                                                    = IIF(sc.ActualServiceCount + 1 <= sc.SubscriptionMaxServiceFixedValue, scdr.DiscountValue, -1)  
                     , @DescriptionTypeSubscription = cts.TechnicalDescription  
                FROM Subscription                        sc WITH (NOLOCK)  
                    INNER JOIN [DeliveryBackOffice].[dbo].CatSalesPackageStatus     csps WITH (NOLOCK)  
                        ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId  
                    INNER JOIN [DeliveryBackOffice].[dbo].CatSubscription           cat WITH (NOLOCK)  
                        ON sc.CatSubscriptionId = cat.IdCatSubscription  
                    INNER JOIN [DeliveryBackOffice].[dbo].CatProductCategory        cts WITH (NOLOCK)  
                        ON cat.CatProductCategoryId = cts.IdCatProductCategory  
                    INNER JOIN [DeliveryBackOffice].[dbo].SubscriptionDiscountRange scdr WITH (NOLOCK)  
                        ON sc.IdSubscription = scdr.SubscriptionId  
                WHERE sc.CustomerId = @CustomerId
                      AND GETDATE() <= sc.ExpirationDate  
                      AND sc.RowStatus = 1  
                      AND csps.SalesPackageStatusName = 'Activa'  
                      AND sc.IdSubscription = @ProductId  
                      AND cts.IdCatProductCategory = @CategoryProductId  
                ORDER BY scdr.DiscountValue DESC;  
  
            END;  
            ELSE IF (@NameCategoryProduct = 'Paquetes')  
            BEGIN  
                IF (@RevaluedGuide = 0)  
                BEGIN  
                    SELECT TOP 1  
                           @SubscriptionId              = sc.IdSubscription  
                         , @ServiceValueSubscription  
                                                        = IIF(sc.ActualServiceCount + 1 <= sc.SubscriptionMaxServiceFixedValue  
                                  , sc.SubscriptionFixedValue  
                                  , -1)  
                         , @DescriptionTypeSubscription = cts.TechnicalDescription  
                    FROM [DeliveryBackOffice].[dbo].Subscription                    sc WITH (NOLOCK)  
                        INNER JOIN [DeliveryBackOffice].[dbo].CatSalesPackageStatus csps WITH (NOLOCK)  
                            ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId  
                        INNER JOIN [DeliveryBackOffice].[dbo].CatSubscription       cat WITH (NOLOCK)  
                            ON sc.CatSubscriptionId = cat.IdCatSubscription  
                        INNER JOIN [DeliveryBackOffice].[dbo].CatProductCategory    cts WITH (NOLOCK)  
                            ON cat.CatProductCategoryId = cts.IdCatProductCategory  
                    WHERE sc.CustomerId = @CustomerId
                          AND GETDATE() <= sc.ExpirationDate  
                     AND sc.RowStatus = 1  
                          AND csps.SalesPackageStatusName = 'Activa'  
                          AND sc.SubscriptionMaxServiceFixedValue - sc.ActualServiceCount > 0 --validar que suscripcion tenga paquetes y obtener suscripcion mas antiguo  
                          AND sc.IdSubscription = @ProductId  
                          AND cts.IdCatProductCategory = @CategoryProductId  
                    ORDER BY sc.IdSubscription ASC;  
                END;  
                ELSE IF (@RevaluedGuide = 1)  
                BEGIN  
                    SELECT TOP 1  
                           @SubscriptionId              = sc.IdSubscription  
                         , @ServiceValueSubscription  
                                                        = IIF(sc.ActualServiceCount + 1 <= sc.SubscriptionMaxServiceFixedValue  
                                  , sc.SubscriptionFixedValue  
                                  , -1)  
                         , @DescriptionTypeSubscription = cts.TechnicalDescription  
                    FROM [DeliveryBackOffice].[dbo].Subscription                    sc WITH (NOLOCK)  
                        INNER JOIN [DeliveryBackOffice].[dbo].CatSalesPackageStatus csps WITH (NOLOCK)  
                            ON csps.IdCatSalesPackageStatus = sc.CatSubscriptionStatusId  
                        INNER JOIN [DeliveryBackOffice].[dbo].CatSubscription       cat WITH (NOLOCK)  
                            ON sc.CatSubscriptionId = cat.IdCatSubscription  
                        INNER JOIN [DeliveryBackOffice].[dbo].CatProductCategory    cts WITH (NOLOCK)  
                            ON cat.CatProductCategoryId = cts.IdCatProductCategory  
                    WHERE sc.CustomerId = @CustomerId
                          AND GETDATE() <= sc.ExpirationDate  
                          AND sc.RowStatus = 1  
                          AND csps.SalesPackageStatusName = 'Activa'  
                          AND sc.SubscriptionMaxServiceFixedValue - sc.ActualServiceCount = 0 --validar que suscripcion tenga paquetes y obtener suscripcion mas antiguo  
                          AND sc.IdSubscription = @ProductId  
                          AND cts.IdCatProductCategory = @CategoryProductId  
                    ORDER BY sc.IdSubscription ASC;  
                END;  
            END;  
            ELSE IF (@NameCategoryProduct = 'Membresías')  
            BEGIN  
                SELECT TOP 1  
                       @SubscriptionId              = sc.IdMembership  
                     , @ServiceValueSubscription  
                                                    = IIF(sc.ActualServiceCount + 1 <= sc.MembershipMaxServiceFixedValue  
                              , sc.MembershipFixedValue  
                              , -1)  
                     , @DescriptionTypeSubscription = cts.TechnicalDescription  
                FROM [DeliveryBackOffice].[dbo].Membership                        sc WITH (NOLOCK)  
                    INNER JOIN [DeliveryBackOffice].[dbo].CatSalesPackageStatus   csps WITH (NOLOCK)  
                        ON csps.IdCatSalesPackageStatus = sc.CatMembershipStatusId  
                    INNER JOIN [DeliveryBackOffice].[dbo].CatSubscription         cat WITH (NOLOCK)  
                        ON sc.CatMembershipId = cat.IdCatSubscription  
                    INNER JOIN [DeliveryBackOffice].[dbo].CatProductCategory      cts WITH (NOLOCK)  
                        ON cat.CatProductCategoryId = cts.IdCatProductCategory  
                    INNER JOIN [DeliveryBackOffice].[dbo].MembershipDiscountRange scdr WITH (NOLOCK)  
                        ON sc.IdMembership = scdr.MembershipId  
                WHERE sc.CustomerId = @CustomerId
                      AND GETDATE() <= sc.ExpirationDate  
                      AND sc.RowStatus = 1  
                      AND csps.SalesPackageStatusName = 'Activa'  
                      AND sc.IdMembership = @ProductId  
                      AND cts.IdCatProductCategory = @CategoryProductId  
                      AND sc.MembershipMaxServiceFixedValue > sc.ActualServiceCount  
                ORDER BY scdr.DiscountValue DESC;  
            END;  
  
        END;  
  
        --Se busca membresía por rango de servicios2  
        PRINT @DiscountValue;  
        SELECT TOP 1  
               @DiscountValue = DiscountValue  
             , @Type          = cvt.ValueTypeName  
        FROM [DeliveryBackOffice].[dbo].SubscriptionDiscountRange sdr WITH (NOLOCK)  
            INNER JOIN [DeliveryBackOffice].[dbo].Subscription    sc WITH (NOLOCK)  
                ON sc.IdSubscription = sdr.SubscriptionId  
            INNER JOIN [DeliveryBackOffice].[dbo].CatValueType    cvt WITH (NOLOCK)  
                ON sdr.ValueTypeId = cvt.IdCatValueType  
            INNER JOIN [DeliveryBackOffice].[dbo].CatSubscription css WITH (NOLOCK)  
                ON sc.CatSubscriptionId = css.IdCatSubscription  
        WHERE sdr.SubscriptionId = @SubscriptionId  
              AND css.CatProductCategoryId = @CategoryProductId  
              AND  
              (  
                  (sc.ActualServiceCount + 1  
              BETWEEN sdr.DiscountLowServiceRange AND sdr.DiscountTopServiceRange  
                  )  
                  OR sc.ActualServiceCount + 1 >= sdr.DiscountLowServiceRange  
                     AND sdr.DiscountTopServiceRange IS NULL  
              )  
              AND sdr.RowStatus = 1  
        ORDER BY sdr.DateCreated DESC;  
        IF (@DiscountValue IS NULL)  
        BEGIN  
            SELECT TOP 1  
                   @DiscountValue = DiscountValue  
                 , @Type          = cvt.ValueTypeName  
            FROM [DeliveryBackOffice].[dbo].MembershipDiscountRange sdr WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].Membership    sc  WITH (NOLOCK)  
                    ON sc.IdMembership = sdr.MembershipId  
                INNER JOIN [DeliveryBackOffice].[dbo].CatValueType  cvt WITH (NOLOCK)  
                    ON sdr.ValueTypeId = cvt.IdCatValueType  
                INNER JOIN [DeliveryBackOffice].[dbo].CatMembership css WITH (NOLOCK)  
                    ON sc.CatMembershipId = css.IdCatMembership  
            WHERE sdr.MembershipId = @ProductId  
                  AND css.CatProductCategoryId = @CategoryProductId  
                  AND  
                  (  
                      (sc.ActualServiceCount + 1  
                  BETWEEN sdr.DiscountLowServiceRange AND sdr.DiscountTopServiceRange  
                      )  
                      OR sc.ActualServiceCount + 1 > sdr.DiscountLowServiceRange  
                         AND sdr.DiscountTopServiceRange IS NULL  
                  )  
                  AND sdr.RowStatus = 1  
            ORDER BY sdr.DateCreated DESC;  
        END;  
  
        IF (@DiscountValue = 0 AND @CategoryProductId = 2)  
        BEGIN  
            SET @DiscountValue = NULL;  
        END;  
        WHILE @i < @total  
        BEGIN  
            SET @i = @i + 1;  
  
            SELECT @PriceShippment = (tr.BaseRate + tr.IrregularPieceRate)  
            FROM @TempRate tr  
            WHERE Id = @i;  
  
            --Si tiene precio  
            IF @PriceShippment IS NOT NULL  
               AND @PriceShippment > 0  
            BEGIN  
                --Si existe una suscripción  
                IF @SubscriptionId IS NOT NULL  
                BEGIN  
                    --Si es tarifa fija  
                    IF @ServiceValueSubscription >= 0  
                        IF (@ServiceValueSubscription > 0)  
                        BEGIN  
                            SELECT @Discount  
                                       = IIF(@NameTypeSubscrition = 'Porcentaje'  
                                           , (tr.IrregularPieceRate * (@DiscountValue / 100))  
                                           , (IIF(@DiscountValue IS NULL, tr.IrregularPieceRate, @DiscountValue)))  
                                 , @NewPriceShippment  
                                       = (tr.FragilRate + tr.CollectedRate + tr.InsuranceRate + tr.OverWeightRate)  
                            FROM @TempRate tr  
                            WHERE Id = @i;  
                            SET @PriceWithCreditCard = 1;  
                        END;  
                        ELSE  
                        BEGIN  
                            SET @Discount = @PriceShippment - @ServiceValueSubscription;  
                            SELECT @NewPriceShippment  
      = (@ServiceValueSubscription + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate  
                                   + tr.CreditCardRate + tr.OverWeightRate  
                                  )  
                            FROM @TempRate tr  
                            WHERE Id = @i;  
                        END;  
                    ELSE  
                    BEGIN  
                        IF @DiscountValue IS NOT NULL  
                        BEGIN  
                            IF @Type = 'Porcentaje'  
                            BEGIN  
                                SET @Discount = @PriceShippment * (@DiscountValue / 100);  
                            END;  
                            ELSE IF @Type = 'Monto'  
                            BEGIN  
                                SET @Discount = @DiscountValue;  
                            END;  
                            ELSE IF @Type = 'Servicio'  
                            BEGIN  
                                SET @Discount = @PriceShippment;  
                            END;  
  
                            SELECT @NewPriceShippment  
                                = (@PriceShippment - @Discount)  
                                  + (tr.FragilRate + tr.CollectedRate + tr.InsuranceRate + tr.CreditCardRate  
                                     + tr.OverWeightRate  
                                    )  
                            FROM @TempRate tr  
                            WHERE Id = @i;  
  
                            IF @NewPriceShippment < 0  
                            BEGIN  
                                SET @Discount = @PriceShippment;  
                                SET @NewPriceShippment = 0;  
                            END;  
                        END;  
                    END;  
                END;  
  
                IF @SubscriptionId IS NULL  
                   OR @Discount = 0  
                BEGIN  
                    --Tarifa por rango de servicios (Membresía)  
                    IF @DiscountValue2 IS NOT NULL  
                    BEGIN  
                        IF @Type2 = 'Porcentaje'  
                        BEGIN  
                            SET @Discount = @PriceShippment * (@DiscountValue2 / 100);  
                        END;  
                        ELSE IF @Type2 = 'Monto'  
                        BEGIN  
                            SET @Discount = @DiscountValue2;  
                        END;  
                        ELSE IF @Type2 = 'Servicio'  
                        BEGIN  
                            SET @Discount = @PriceShippment;  
                        END;  
  
                        SELECT @NewPriceShippment  
                            = (@PriceShippment - @Discount)  
                              + (tr.FragilRate + tr.CollectedRate + tr.InsuranceRate + tr.CreditCardRate  
                                 + tr.OverWeightRate  
                                )  
                        FROM @TempRate tr  
                        WHERE Id = @i;  
  
                        IF @NewPriceShippment < 0  
                        BEGIN  
                            SET @Discount = @PriceShippment;  
                            SET @NewPriceShippment = 0;  
                        END;  
                    END;  
                END;  
            END;  
  
            IF @Discount > 0  
               AND @NameTypeSubscrition = 'Monto Fijo'  
               AND @IsCollected = 1  
            BEGIN  
                UPDATE @TempRate  
                SET Discount = 0  
                  , DiscountName = 'No puede utilizar la suscripción de monto fijo con un servicio collect'  
                WHERE Id = @i;  
            END;  
            ELSE IF (@Discount > 0)  
            BEGIN  
                UPDATE @TempRate  
                SET Discount = @Discount  
                  , DiscountName = 'Descuento membresía'  
                WHERE Id = @i;  
            END;  
        END;  
    END;  

    /* Termina membresías y suscripciones */  
    IF @FormatResponse = 'Json'
    BEGIN

        -- Desplegar valor base sin IVA
        IF (
               @IdRate IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates, @NewRateGeneral
                          , @NewRateGeneralDiscount
                          )
               AND @IdCustomerParams != 0
           )

            SET @CalculateTaxes = 'false';
            SET @jsonResult =  
            (  
                SELECT STUFF(  
                                (  
                                    SELECT ',{"Title":"' + ISNULL(tr.ServiceName, '') + '",' + '"UseMembership":"'  
                                           + CONVERT(VARCHAR(1), @CalculateMembership) + '",' + '"Service":"'  
                                           + IIF(@IdCustomerParams = 0 AND @CustomerId = 6  
                                                 , ISNULL(tr.ServiceName, '')  
                                                 , ISNULL(tr.Segment, '')) + '",' + '"ServiceDescription":"'  
                                           + ISNULL(tr.ServiceDescription, '') + '",' + '"ServiceShortName":"'  
                                           + ISNULL(tr.Service, '') + '",' + '"DeliveryDate":"'  
                                           + CONVERT(VARCHAR(24), @FechaCompra, 120) + '",' + '"Price":"'  
                                           + CONVERT(  
                                                        VARCHAR(20)  
                                                      , CONVERT(  
                                                                   DECIMAL(12, 2)  
                                                                 , dbo.fnt_Iva_Calculator(  
                                                                                             @CalculateTaxes  
                                                                                           , @Country  
                                                                                           , tr.BaseRate  
                                                                                             + tr.IrregularPieceRate  
                                                                                           , 'false'  
                                                                                         )  
                                                               )  
                                                        + CONVERT(  
                                                                     DECIMAL(12, 2)  
                                                                   , (dbo.fnt_Iva_Calculator(  
                                                                                                @CalculateTaxes  
                                                                                              , @Country  
                                                                                              , (tr.Discount * -1)  
                                                                                              , 'false'  
                                                                                            )  
                                                                     )  
                                                                 )  
                                                        + CONVERT(  
                                                                     DECIMAL(12, 2)  
                                                                   , dbo.fnt_Iva_Calculator(  
                                                                                               @CalculateTaxes  
                                               , @Country  
                                                                                             , tr.FragilRate  
                                                                                             , 'false'  
                                                                                           )  
                                                                 )  
                                                        + CONVERT(  
                                                                     DECIMAL(12, 2)  
                                                                   , dbo.fnt_Iva_Calculator(  
                                                                                               @CalculateTaxes  
                                                                                             , @Country  
                                                                                             , tr.CollectedRate  
                                                                                             , 'false'  
                                                                                           )  
                                                                 )  
                                                        + CONVERT(  
                                                                     VARCHAR(20)  
                                                                   , CONVERT(  
                                                                                DECIMAL(12, 2)  
                                                                              , dbo.fnt_Iva_Calculator(  
                                                                                                          @CalculateTaxes  
                                                                                                        , @Country  
                                                                                                        , tr.InsuranceRate  
                                                                                                        , 'false'  
                                                                                                      )  
                                                                            )  
                                                                 )  
                                                        + CONVERT(  
                                                                     VARCHAR(20)  
                                                                   , dbo.fnt_Iva_Calculator(  
                                                                                               @CalculateTaxes  
                                                                                             , @Country  
                                                                                             , tr.CreditCardRate  
                                                                                             , 'false'  
                                                                                           )  
                                                                 )  
                                                        + CONVERT(  
                                                                     VARCHAR(20)  
                                                                   , CONVERT(  
                                                                                DECIMAL(12, 2)  
                                                                              , dbo.fnt_Iva_Calculator(  
                                                                                                          @CalculateTaxes  
                                                                                                        , @Country  
                                                                                                        , tr.OverWeightRate  
                                                                                                        , 'false'  
                                                                                                      )  
                                                                            )  
                                                                 )  
                                                        + CONVERT(  
                                                                     DECIMAL(12, 2)  
                                                                   , dbo.fnt_Iva_Calculator(  
                                                                                               @CalculateTaxes  
                                                                                             , @Country  
                                                                                             , (CONVERT(  
                                                                                                           DECIMAL(12, 2)  
                                                                                                         , tr.BaseRate  
                                                                                                       )  
                                                                                                - CONVERT(  
                                                                                                             DECIMAL(12, 2)  
                                                                                                           , tr.Discount  
                                                                                                         )  
                                                                                                + CONVERT(  
                                                                                                             DECIMAL(12, 2)  
                                                                                                           , tr.FragilRate  
                                                                                                         )  
                                                                                                + CONVERT(  
                                                                                                             DECIMAL(12, 2)  
                                                                                                           , tr.CollectedRate  
                                                                                                         )  
                                                                                                + CONVERT(  
                                                                                                             DECIMAL(12, 2)  
                                                                                                           , tr.InsuranceRate  
                                                                                                         )  
                                                                                                + CONVERT(  
                                                                                                             DECIMAL(12, 2)  
                                                                                                           , tr.CreditCardRate  
                                                                                                         )  
                                                                                                + CONVERT(  
                                                                                                             DECIMAL(12, 2)  
                                                                                                           , tr.OverWeightRate  
                                                                                                         )  
                                                                                                + CONVERT(  
                                                      DECIMAL(12, 2)  
                                                                                                           , tr.IrregularPieceRate  
                                                                                                         )  
                                                                                               )  
                                                                                             , 'true'  
                                                                                           )  
                                                                 )  
                                                    ) + '",' + '"Currency":"' + @Currency + '",'  
                                           + '"Integration":[{"Description":"' + 'Servicio' + '",' + '"Price":"'  
                                           + CONVERT(  
                                                        VARCHAR(20)  
                                                      , CONVERT(  
                                                                   DECIMAL(12, 2)  
                                                                 , dbo.fnt_Iva_Calculator(  
                                                                                             @CalculateTaxes  
                                                                                           , @Country  
                                                                                           , tr.BaseRate  
                                                                                             + tr.IrregularPieceRate  
                                                                                           , 'false'  
                                                                                         )  
                                                               )  
                                                    ) + '",' + '"Currency":"' + @Currency + '"' + '}'  
                                           + IIF(tr.FragilRate > 0  
                                               , ',{"Description":"' + 'Frágil' + '",' + '"Price":"'  
                                                 + CONVERT(  
                                                              VARCHAR(20)  
                                                            , CONVERT(  
                                                                         DECIMAL(12, 2)  
                                                                       , dbo.fnt_Iva_Calculator(  
                                                                                                   @CalculateTaxes  
                                                                                                 , @Country  
                                                                                                 , tr.FragilRate  
                                                                                                 , 'false'  
                                                                                               )  
                                                                     )  
                                                          ) + '",' + '"Currency":"' + @Currency + '"' + '}'  
                                               , ' ')  
                                           + IIF(tr.InsuranceRate > 0  
                                               , ',{"Description":"' + 'Seguro' + '",' + '"Price":"'  
                                                 + CONVERT(  
                                                              VARCHAR(20)  
                                                            , CONVERT(  
                                                                         DECIMAL(12, 2)  
                                                                       , dbo.fnt_Iva_Calculator(  
                                                                                                   @CalculateTaxes  
                                                                                                 , @Country  
                                                                                                 , tr.InsuranceRate  
                                                                                                 , 'false'  
                                                                                               )  
                                                                     )  
                                                          ) + '",' + '"Currency":"' + @Currency + '"' + '}'  
                                               , ' ')  
                                           + IIF(tr.CollectedRate > 0  
                                               , ',{"Description":"' + 'Pago en Destino' + '",' + '"Price":"'  
                                                 + CONVERT(  
                                                              VARCHAR(20)  
                                                            , CONVERT(  
                                                                         DECIMAL(12, 2)  
                                                                       , dbo.fnt_Iva_Calculator(  
                                                                                                   @CalculateTaxes  
                                                                                                 , @Country  
                                                                                                 , tr.CollectedRate  
                                                                                                 , 'false'  
                                                                                               )  
                                                                     )  
                                                          ) + '",' + '"Currency":"' + @Currency + '"' + '}'  
                                               , ' ')  
                                           + IIF((tr.OverWeightRate) > 0  
                                               , ',{"Description":"' + 'Recargo por Peso' + '",' + '"Price":"'  
                                                 + CONVERT(  
                                                              VARCHAR(20)  
                                                            , CONVERT(  
                                                                         DECIMAL(12, 2)  
                                                                       , dbo.fnt_Iva_Calculator(  
                                                                                                   @CalculateTaxes  
                                                                                                 , @Country  
                                                                                                 , tr.OverWeightRate  
                                                                                                 , 'false'  
                                                                                               )  
                                                                     )  
                                                          ) + '",' + '"Currency":"' + @Currency + '"' + '}'  
                                               , ' ')  
                                           + IIF((tr.CreditCardRate) > 0  
                                               , ',{"Description":"' + 'Otros recargos' + '",' + '"Price":"'  
                                                 + CONVERT(  
                                                              VARCHAR(20)  
                                                            , dbo.fnt_Iva_Calculator(  
                                                                                        @CalculateTaxes  
                                                                                      , @Country  
                                                                                      , tr.CreditCardRate  
                                                                                      , 'false'  
                                                                                  )  
                                                          ) + '",' + '"Currency":"' + COALESCE(@Currency, '') + '"' + '}'  
                                               , ' ')  
                                           + IIF((ISNULL(tr.Discount, 0)) > 0  
                                               , ',{"Description":"' + ISNULL(tr.DiscountName, '') + '",' + '"Price":"'  
                                                 + CONVERT(  
                                                              VARCHAR  
                                                            , CONVERT(  
                                                                         DECIMAL(12, 2)  
                                                                       , (dbo.fnt_Iva_Calculator(  
                                                                                                    @CalculateTaxes  
                                                                                                  , @Country  
                                                                                                  , (tr.Discount * -1)  
                                                                                                  , 'false'  
                                                                                                )  
                                                                         )  
                                                                     )  
                                                          ) + '",' + '"Currency":"' + COALESCE(@Currency, '') + '"' + '}'  
                                               , ' ')  
                                           + IIF((ISNULL(  
                                                            dbo.fnt_Iva_Calculator(  
                                                                                      @CalculateTaxes  
                                                                                    , @Country  
                                                                                    , (CONVERT(DECIMAL(12, 2), tr.BaseRate)  
                                                                                       - CONVERT(  
                                                                                                    DECIMAL(12, 2)  
                                                                                                  , tr.Discount  
                                                                                                )  
                                                                                       + CONVERT(  
                                                                                                    DECIMAL(12, 2)  
                                                                                                  , tr.FragilRate  
                                                                                                )  
                                                                                       + CONVERT(  
                                                                                                    DECIMAL(12, 2)  
                                                                                                  , tr.CollectedRate  
                                                                                                )  
                                                                                       + CONVERT(  
                                                                                                    DECIMAL(12, 2)  
                                                                                                  , tr.InsuranceRate  
                                                                                                )  
                                                                                       + CONVERT(  
                                                                                                    DECIMAL(12, 2)  
                                                                                                  , tr.CreditCardRate  
                                                                                                )  
                                                                                       + CONVERT(  
                                                                                                    DECIMAL(12, 2)  
                                                                                                  , tr.OverWeightRate  
                                                                                                )  
                                                                                       + CONVERT(  
                                                                                                    DECIMAL(12, 2)  
                                                                                                  , tr.IrregularPieceRate  
                                                                                                )  
                                                                                      )  
                                                                                    , 'true'  
                                                                                  )  
                                                          , 0  
                                                        )  
                                                 ) > 0  
                                               , ',{"Description":"' + 'IVA' + '",' + '"Price":"'  
                                                 + CONVERT(  
                                                              VARCHAR(20)  
                                                            , CONVERT(  
                                                                         DECIMAL(12, 2)  
                                                                       , dbo.fnt_Iva_Calculator(  
                                                                                                   @CalculateTaxes  
                                                                                                 , @Country  
                                                                                                 , (CONVERT(  
                                                                                                               DECIMAL(12, 2)  
                                                                                                             , tr.BaseRate  
                                                                                                           )  
                                                                                                    - CONVERT(  
                                                                                                                 DECIMAL(12, 2)  
                                                                                                               , tr.Discount  
                                                                                                             )  
                                                                                                    + CONVERT(  
                                                                                                                 DECIMAL(12, 2)  
                                                                                                               , tr.FragilRate  
                                                                                                             )  
                                                                                                    + CONVERT(  
                                                                                                                 DECIMAL(12, 2)  
                                                                                                               , tr.CollectedRate  
                                                                                                             )  
                                                                                                    + CONVERT(  
                                                                                                                 DECIMAL(12, 2)  
                                                                                                               , tr.InsuranceRate  
                                                                                                             )  
                                                                                                    + CONVERT(  
                                                                                                                 DECIMAL(12, 2)  
                                                                                                               , tr.CreditCardRate  
                                                                                                             )  
                                                                                                    + CONVERT(  
                                                                                                                 DECIMAL(12, 2)  
                                                                                                               , tr.OverWeightRate  
                                                                                                             )  
                                                                                                    + CONVERT(  
                                                                                                                 DECIMAL(12, 2)  
                                                                                                               , tr.IrregularPieceRate  
                                                                                                             )  
                                                                                                   )  
                                                                                                 , 'true'  
                                                                                               )  
                                                                     )  
                                                          ) + '",' + '"Currency":"' + @Currency + '"' + '}'  
                                               , ' ') + ' ]}'  
                                    FROM @TempRate tr  
                                    -- where us.UsrEmail = @UserName and us.UsrRowStatus = 1   
                                    FOR XML PATH(''), TYPE  
                                ).value('.', 'varchar(max)')  
                              , 1  
                              , 1  
                              , ''  
                            )  
            );

            SELECT '[' + @jsonResult + ']';
        END
    ELSE
    BEGIN

         -- Desplegar valor base sin IVA
         IF (
                @RateId IN ( @NewMainRates, @NewAlternativeRates, @NewAutoSalesMainRates, @NewRateGeneral
                           , @NewRateGeneralDiscount
                           )
                AND @IdCustomerParams != 0
            )
             SET @CalculateTaxes = 'false';

         SELECT tr.TypeRate
              , tr.Segment
              , tr.Service
              , IIF(@PriceWithCreditCard = 1
                  , (tr.BaseRate - tr.Discount + tr.IrregularPieceRate + tr.CreditCardRate)
                  , (tr.BaseRate - tr.Discount + tr.IrregularPieceRate))                          AS Price --  + tr.FragilRate + tr.CollectedRate + tr.InsuranceRate  +tr.CreditCardRate + tr.OverWeightRate  + tr.IrregularPieceRate ) as Price
              , dbo.fnt_Iva_Calculator(@CalculateTaxes, @Country, tr.BaseRate, 'false')           AS BaseRate
              , dbo.fnt_Iva_Calculator(@CalculateTaxes, @Country, (tr.Discount * -1), 'false')    AS DiscountValue
              , tr.DiscountName
              , dbo.fnt_Iva_Calculator(@CalculateTaxes, @Country, tr.FragilRate, 'false')         AS FragilRate
              , dbo.fnt_Iva_Calculator(@CalculateTaxes, @Country, tr.CollectedRate, 'false')      AS CollectedRate
              , dbo.fnt_Iva_Calculator(@CalculateTaxes, @Country, tr.InsuranceRate, 'false')      AS InsuranceRate
              , dbo.fnt_Iva_Calculator(@CalculateTaxes, @Country, tr.OverWeightRate, 'false')     AS OverWeightRate
              , dbo.fnt_Iva_Calculator(@CalculateTaxes, @Country, tr.IrregularPieceRate, 'false') AS IrregularPieceRate
              , dbo.fnt_Iva_Calculator(@CalculateTaxes, @Country, tr.CreditCardRate, 'false')     AS CreditCardRate
              , dbo.fnt_Iva_Calculator(
                                          @CalculateTaxes
                                        , @Country
                                        , (tr.BaseRate - tr.Discount + tr.FragilRate + tr.CollectedRate
                                           + tr.InsuranceRate + tr.CreditCardRate + tr.OverWeightRate
                                           + tr.IrregularPieceRate
                                          )
                                        , 'true'
                                      )                                                       AS Iva
              , @FechaCompra                                                                  [FechaCompra]
              , @Currency                                                                     [Currency]
              , tr.ReturnRate                                                                 [ReturnRate]
              , @CurrencyId                                                                   [CurrencyId]
         FROM @TempRate tr;
    END;


END;