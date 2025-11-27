BEGIN TRY
    BEGIN TRANSACTION;


    --ORDERNAR TAG NOVEDAD

    DECLARE @IdCatNOVEDAD INT = (
                                    SELECT IdMarketplaceProductTags
                                    FROM [dbo].[MarketplaceProductTags] WITH (NOLOCK)
                                    WHERE MarketplaceProductTagsName = 'NOVEDADES'
                                          AND IdCountry = 'HN'
                                );
    WITH CTE
    AS (SELECT MPTP.IdMarketplaceTagsByProduct,
               ROW_NUMBER() OVER (ORDER BY CS.SubscriptionMaxServiceFixedValue ASC) AS NewPosition
        FROM [MarketplaceTagsByProduct] MPTP WITH (NOLOCK)
            INNER JOIN CatSubscription CS WITH (NOLOCK)
                ON MPTP.CatSubscriptionId = CS.IdCatSubscription
            INNER JOIN [MarketplaceProductTags] MPT WITH (NOLOCK)
                ON MPT.IdMarketplaceProductTags = MPTP.MarketplaceProductTagsId
        WHERE CS.IdCountry = 'HN'
              AND MPT.IdMarketplaceProductTags = @IdCatNOVEDAD
       )
    UPDATE MPTP
    SET MPTP.Position = CTE.NewPosition,
        MPTP.TokenUpdated = 'SYS-BPEDROZA',
        MPTP.DateUpdated = GETDATE()
    FROM [MarketplaceTagsByProduct] MPTP
        INNER JOIN CTE
            ON MPTP.IdMarketplaceTagsByProduct = CTE.IdMarketplaceTagsByProduct;

    --ORDERNAR TAG TODOS LOS PRODUCTOS
    DECLARE @IdCatTODOS INT = (
                                  SELECT IdMarketplaceProductTags
                                  FROM [dbo].[MarketplaceProductTags] WITH (NOLOCK)
                                  WHERE MarketplaceProductTagsName = 'TODOS LOS PRODUCTOS'
                                        AND IdCountry = 'HN'
                              );

    WITH CTE2
    AS (SELECT MPTP.IdMarketplaceTagsByProduct,
               ROW_NUMBER() OVER (ORDER BY CS.SubscriptionMaxServiceFixedValue ASC) AS NewPosition
        FROM [MarketplaceTagsByProduct] MPTP WITH (NOLOCK)
            INNER JOIN CatSubscription CS WITH (NOLOCK)
                ON MPTP.CatSubscriptionId = CS.IdCatSubscription
            INNER JOIN [MarketplaceProductTags] MPT WITH (NOLOCK)
                ON MPT.IdMarketplaceProductTags = MPTP.MarketplaceProductTagsId
        WHERE CS.IdCountry = 'HN'
              AND MPT.IdMarketplaceProductTags = @IdCatTODOS
       )
    UPDATE MPTP
    SET MPTP.Position = CTE2.NewPosition,
        MPTP.TokenUpdated = 'SYS-BPEDROZA',
        MPTP.DateUpdated = GETDATE()
    FROM [MarketplaceTagsByProduct] MPTP
        INNER JOIN CTE2
            ON MPTP.IdMarketplaceTagsByProduct = CTE2.IdMarketplaceTagsByProduct;



    COMMIT TRANSACTION;
    PRINT 'Actualización completada exitosamente.';

END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    PRINT 'Se produjo un error en la ejecución.';
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR(10));
    PRINT 'Severidad: ' + CAST(ERROR_SEVERITY() AS VARCHAR(10));
    PRINT 'Estado: ' + CAST(ERROR_STATE() AS VARCHAR(10));
    PRINT 'Procedimiento: ' + ISNULL(ERROR_PROCEDURE(), '-');
    PRINT 'Línea: ' + CAST(ERROR_LINE() AS VARCHAR(10));
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
END CATCH;
