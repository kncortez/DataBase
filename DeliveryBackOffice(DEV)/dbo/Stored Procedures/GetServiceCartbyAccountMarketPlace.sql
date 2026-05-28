/* =================================================
   SP: GetServiceCartbyAccountMarketPlace
   Propósito: Obtiene información del carrito de compras MarketPlace
              con manejo de moneda multipais
   Historia: 
   Fecha:     
================================================= */
/* === CHANGELOG ============================
2026-03-25 | Historia/épica: FDAPI-5861   | Autor: Pedro Macajol  | Corrección CASE moneda por JOIN dinámico multipais y corrección ISNULL IdCountry
2024-08-07 | Historia/épica: (pendiente)  | Autor: Edelman        | Agregar país para obtener carrito de compra
2024-08-05 | Historia/épica: (pendiente)  | Autor: Cristian Suazo | Se agrega la moneda por país en la consulta
2023-08-31 | Historia/épica: (pendiente)  | Autor: Edelman        | Creación inicial
=========================================== */
CREATE PROCEDURE [dbo].[GetServiceCartbyAccountMarketPlace]
    @IdAccount BIGINT,
    @Token NVARCHAR(50),
    @IdCountry NVARCHAR(3),
    @IsUserTeleMarketing BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT ON;

    BEGIN TRANSACTION

    BEGIN TRY

        DECLARE @AccountServiceCartId INT = NULL;

        IF(@IsUserTeleMarketing=0)
        BEGIN
            SELECT TOP 1
                @AccountServiceCartId = [IdMarketplaceCart]
            FROM [dbo].[MarketplaceCart]
            WHERE ISNULL(AccountId,0) = @IdAccount
            AND RowStatus = 1
            AND IdCountry = @IdCountry
            ORDER BY DateCreated DESC
        END
        ELSE
        BEGIN
            SELECT TOP 1
                @AccountServiceCartId = [IdMarketplaceCart]
            FROM [dbo].[MarketplaceCart]
            WHERE ISNULL(RegisterUserId,0) = @IdAccount
            AND RowStatus = 1
            AND IdCountry = @IdCountry
            ORDER BY DateCreated DESC
	    
		            END

        IF (@AccountServiceCartId IS NOT NULL OR @AccountServiceCartId != '')
        BEGIN


            IF(@IsUserTeleMarketing=0)
            BEGIN

            SELECT
					1 'StatusCode'
				   ,'Records found' 'Description'

                SELECT
                    mpcm.CatProductId,
                    cp.SubscriptionName [CatProductName],
                    cp.SubscriptionDescription [CatProductDescription],
                    cp.SubscriptionCost [CatProductCost],
                    ccc.Symbol                      AS CurrencySymbol,
                    mpcm.IdMarketplaceCartDetail,
                    cp.SubscriptionFixedValue   [CatProductDiscountValue],
                    IIF(cp.SubscriptionValidity = 1,
                        CONVERT(Varchar, cp.SubscriptionValidity)+' mes',
                        CONVERT(Varchar, cp.SubscriptionValidity)+' meses') [ExpirationProduct]
                FROM [dbo].[MarketplaceCartDetail] mpcm WITH (NOLOCK)
                INNER JOIN [dbo].[MarketplaceCart] mpc
                    ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
                INNER JOIN dbo.CatSubscription cp WITH (NOLOCK)
                    ON mpcm.CatProductId = cp.IdCatSubscription
                LEFT JOIN DeliveryCurrency dc WITH(NOLOCK)
                    ON dc.Currency_IdCountry = cp.IdCountry
                    AND dc.DefaultPerCountry = 1
                LEFT JOIN CatCurrencyCOD ccc WITH(NOLOCK)
                    ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
                WHERE ISNULL(mpc.AccountId, 0) = @IdAccount
                AND mpc.RowStatus = 1
                AND mpcm.RowStatus=1
                AND mpc.IdCountry = @IdCountry
                AND mpcm.TypeProduct <> 'Club Forza'

                UNION ALL
                SELECT
                    mpcm.CatProductId,
                    cp.MembershipName [CatProductName],
                    cp.MembershipDescription  [CatProductDescription],
                    cp.MembershipCost [CatProductCost],
                    ccc.Symbol                      AS CurrencySymbol,
                    mpcm.IdMarketplaceCartDetail,
                    cp.MembershipFixedValue   [CatProductDiscountValue],
                    IIF(cp.MembershipValidity = 1,
                        CONVERT(Varchar, cp.MembershipValidity)+' mes',
                        CONVERT(Varchar, cp.MembershipValidity)+' meses') [ExpirationProduct]
                FROM [dbo].[MarketplaceCartDetail] mpcm
                INNER JOIN [dbo].[MarketplaceCart] mpc
                    ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
                INNER JOIN dbo.CatMembership cp WITH (NOLOCK)
                    ON mpcm.CatProductId = cp.IdCatMembership
                    AND mpcm.TypeProduct = cp.MembershipName
                LEFT JOIN DeliveryCurrency dc WITH(NOLOCK)
                    ON dc.Currency_IdCountry = cp.IdCountry
                    AND dc.DefaultPerCountry = 1
                LEFT JOIN CatCurrencyCOD ccc WITH(NOLOCK)
                    ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
                WHERE ISNULL(mpc.AccountId, 0) = @IdAccount
                AND mpc.RowStatus = 1
                AND mpcm.RowStatus=1
                AND mpc.IdCountry = @IdCountry

            END
            ELSE
            BEGIN
            SELECT
					1 'StatusCode'
				   ,'Records found' 'Description'
		
                SELECT
                    mpcm.CatProductId,
                    cp.SubscriptionName [CatProductName],
                    cp.SubscriptionDescription  [CatProductDescription],
                    cp.SubscriptionCost [CatProductCost],
                    ccc.Symbol                      AS CurrencySymbol,
                    mpcm.IdMarketplaceCartDetail,
                    cp.SubscriptionFixedValue   [CatProductDiscountValue],
                    IIF(cp.SubscriptionValidity = 1,
                        CONVERT(Varchar, cp.SubscriptionValidity)+' mes',
                        CONVERT(Varchar, cp.SubscriptionValidity)+' meses') [ExpirationProduct]
                FROM [dbo].[MarketplaceCartDetail] mpcm WITH (NOLOCK)
                INNER JOIN [dbo].[MarketplaceCart] mpc WITH (NOLOCK)
                    ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
                INNER JOIN dbo.CatSubscription cp WITH (NOLOCK)
                    ON mpcm.CatProductId = cp.IdCatSubscription
                LEFT JOIN DeliveryCurrency dc WITH(NOLOCK) 
                    ON dc.Currency_IdCountry = cp.IdCountry
                    AND dc.DefaultPerCountry = 1
                LEFT JOIN CatCurrencyCOD ccc WITH(NOLOCK)
                    ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
                WHERE  ISNULL(mpc.RegisterUserId,0) = @IdAccount
                AND mpc.RowStatus = 1
                AND mpcm.RowStatus=1
                AND mpc.IdCountry = @IdCountry 
                AND mpcm.TypeProduct <> 'Club Forza'

                UNION ALL
                SELECT
                    mpcm.CatProductId,
                    cp.MembershipName [CatProductName],
                    cp.MembershipDescription  [CatProductDescription],
                    cp.MembershipCost [CatProductCost],
                    ccc.Symbol                      AS CurrencySymbol,
                    mpcm.IdMarketplaceCartDetail,
                    cp.MembershipFixedValue   [CatProductDiscountValue],
                    IIF(cp.MembershipValidity = 1,
                        CONVERT(Varchar, cp.MembershipValidity)+' mes',
                        CONVERT(Varchar, cp.MembershipValidity)+' meses') [ExpirationProduct]
                FROM [dbo].[MarketplaceCartDetail] mpcm
                INNER JOIN [dbo].[MarketplaceCart] mpc
                    ON mpcm.MarketplaceCartId = mpc.IdMarketplaceCart
                INNER JOIN dbo.CatMembership cp WITH (NOLOCK)
                    ON mpcm.CatProductId = cp.IdCatMembership
                    AND mpcm.TypeProduct = cp.MembershipName
                LEFT JOIN DeliveryCurrency dc WITH(NOLOCK)  
                    ON dc.Currency_IdCountry = cp.IdCountry
                    AND dc.DefaultPerCountry = 1
                LEFT JOIN CatCurrencyCOD ccc WITH(NOLOCK)
                    ON ccc.IdCatCurrencyCOD = dc.IdCurrencyCOD
                WHERE  ISNULL(mpc.RegisterUserId,0) = @IdAccount
                AND mpc.RowStatus = 1
                AND mpcm.RowStatus=1
                AND mpc.IdCountry =@IdCountry

            END

        END
        ELSE
        BEGIN
            SELECT
                2 [StatusCode]
                ,'Service Cart not found' [Description]
        END

        IF (@@TRANCOUNT > 0)
            COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH

        SELECT
            0 [StatusCode]
		   ,ERROR_MESSAGE() [Description]
		   ,ERROR_NUMBER() [ErrorNumber]
		   ,ERROR_SEVERITY() [ErrorSeverity]
		   ,ERROR_STATE() [ErrorState]
		   ,ERROR_PROCEDURE() [ErrorProcedure]
		   ,ERROR_LINE() [ErrorLine];

        ROLLBACK TRANSACTION;
    END CATCH
END
