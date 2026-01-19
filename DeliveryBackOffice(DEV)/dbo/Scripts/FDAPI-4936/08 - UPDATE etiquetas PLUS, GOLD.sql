BEGIN TRY
    BEGIN TRANSACTION;

	
  DECLARE @IdCatSubscriptionPETIT   INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Petit' AND IdCountry='HN')
  DECLARE @IdCatSubscriptionBASIC   INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Básico' AND IdCountry='HN')
  DECLARE @IdCatSubscriptionGOLD   INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Gold' AND IdCountry='HN')
  DECLARE @IdCatSubscriptionPLUS    INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WHERE SubscriptionName='Paquete Plus' AND IdCountry='HN')
  DECLARE @IdCatNOVEDAD    INT =(   SELECT IdMarketplaceProductTags FROM [dbo].[MarketplaceProductTags] WITH(NOLOCK) WHERE MarketplaceProductTagsName ='NOVEDADES' AND IdCountry = 'HN');

 
 ----********
 ----******** PAQUETE PETIT
 ----********

  INSERT INTO DeliveryBackOffice.dbo.MarketplaceTagsByProduct
(
    MarketplaceProductTagsId,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    CatSubscriptionId,
    CatMembershipId,
    Position
)
VALUES
(   @IdCatNOVEDAD,
    1,      
    N'SYS-BPEDROZA',
    GETDATE(), 
    NULL, 
    NULL,
    @IdCatSubscriptionPETIT,      -- CatSubscriptionId - int
    NULL, 
    1
    )


 ----********
 ----******** PAQUETE BASICO
 ----********

	  INSERT INTO DeliveryBackOffice.dbo.MarketplaceTagsByProduct
(
    MarketplaceProductTagsId,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    CatSubscriptionId,
    CatMembershipId,
    Position
)
VALUES
(   @IdCatNOVEDAD,
    1,      
    N'SYS-BPEDROZA',
    GETDATE(), 
    NULL, 
    NULL,
    @IdCatSubscriptionBASIC,      -- CatSubscriptionId - int
    NULL, 
    1
    )



 ----********
 ----******** PAQUETE GOLD
 ----********

 UPDATE CatSubscription
 SET Tag = 'NOVEDADES',
	TokenUpdated = 'SYS-BPEDROZA',
	DateUpdated = GETDATE()
 WHERE IdCatSubscription = @IdCatSubscriptionGOLD;

  INSERT INTO DeliveryBackOffice.dbo.MarketplaceTagsByProduct
(
    MarketplaceProductTagsId,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    CatSubscriptionId,
    CatMembershipId,
    Position
)
VALUES
(   @IdCatNOVEDAD,
    1,      
    N'SYS-BPEDROZA',
    GETDATE(), 
    NULL, 
    NULL,
    @IdCatSubscriptionGOLD,      -- CatSubscriptionId - int
    NULL, 
    1
    )




 ----********
 ----******** PAQUETE PLUS
 ----********
   UPDATE CatSubscription
 SET Tag = 'NOVEDADES',
	TokenUpdated = 'SYS-BPEDROZA',
	DateUpdated = GETDATE()
 WHERE IdCatSubscription = @IdCatSubscriptionPLUS;
		  INSERT INTO DeliveryBackOffice.dbo.MarketplaceTagsByProduct
(
    MarketplaceProductTagsId,
    RowStatus,
    TokenCreated,
    DateCreated,
    TokenUpdated,
    DateUpdated,
    CatSubscriptionId,
    CatMembershipId,
    Position
)
VALUES
(   @IdCatNOVEDAD,
    1,      
    N'SYS-BPEDROZA',
    GETDATE(), 
    NULL, 
    NULL,
    @IdCatSubscriptionPLUS,      -- CatSubscriptionId - int
    NULL, 
    1
    )

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