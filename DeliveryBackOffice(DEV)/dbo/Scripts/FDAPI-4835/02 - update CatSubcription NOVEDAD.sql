BEGIN TRY
    BEGIN TRANSACTION;

  DECLARE @IdCatSubscriptionMICRO   INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete MICRO' AND IdCountry='GT')
  DECLARE @IdCatSubscriptionPETIT   INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Petit' AND IdCountry='GT')
  DECLARE @IdCatSubscriptionBASICO  INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Básico' AND IdCountry='GT')
  DECLARE @IdCatSubscriptionPLUS    INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Plus' AND IdCountry='GT')
  DECLARE @IdCatSubscriptionGOLD    INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Gold' AND IdCountry='GT')
  DECLARE @IdCatSubscriptionPLATINO INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Platino' AND IdCountry='GT')
  DECLARE @IdCatSubscriptionPRO     INT =(SELECT IdCatSubscription FROM [dbo].[CatSubscription] WITH(NOLOCK) WHERE SubscriptionName='Paquete Pro' AND IdCountry='GT')


  update CatSubscription 
  set Tag = 'NOVEDAD'
  WHERE IdCatSubscription IN (
  @IdCatSubscriptionMICRO  
  ,@IdCatSubscriptionPETIT  
  ,@IdCatSubscriptionBASICO 
  ,@IdCatSubscriptionPLUS   
  ,@IdCatSubscriptionGOLD   
  ,@IdCatSubscriptionPLATINO
  ,@IdCatSubscriptionPRO    
  ) and IdCountry ='GT'

	
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