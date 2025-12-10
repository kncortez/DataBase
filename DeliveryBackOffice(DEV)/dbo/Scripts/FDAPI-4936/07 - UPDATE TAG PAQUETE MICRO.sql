BEGIN TRY
    BEGIN TRANSACTION;



    DECLARE @IdCatSubscriptionMicro   INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Micro' AND IdCountry='HN');

    DECLARE @IdCatNOVEDAD INT = (
                                    SELECT IdMarketplaceProductTags
                                    FROM [dbo].[MarketplaceProductTags] WITH (NOLOCK)
                                    WHERE MarketplaceProductTagsName = 'NOVEDADES'
                                          AND IdCountry = 'HN'
                                );


    DECLARE @IdCatTODOS INT = (
                                  SELECT IdMarketplaceProductTags
                                  FROM [dbo].[MarketplaceProductTags] WITH (NOLOCK)
                                  WHERE MarketplaceProductTagsName = 'TODOS LOS PRODUCTOS'
                                        AND IdCountry = 'HN'
                              );

     UPDATE [MarketplaceTagsByProduct]
     SET MarketplaceProductTagsId = @IdCatNOVEDAD
     WHERE  CatSubscriptionId = @IdCatSubscriptionMicro and MarketplaceProductTagsId = 2 


     UPDATE [MarketplaceTagsByProduct]
     SET MarketplaceProductTagsId = @IdCatTODOS
     WHERE  CatSubscriptionId = @IdCatSubscriptionMicro and MarketplaceProductTagsId = 4



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
