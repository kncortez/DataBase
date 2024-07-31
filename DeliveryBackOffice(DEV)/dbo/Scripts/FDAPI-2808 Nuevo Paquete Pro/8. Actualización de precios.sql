USE [DeliveryBackOffice]
GO


BEGIN TRANSACTION
BEGIN TRY



    DECLARE @IdPlanAmigo int= (select idcatsubscription from dbo.catsubscription where subscriptionname='Plan Amigo' and rowstatus=1)
    DECLARE @IdPaquetePetit int= (select idcatsubscription from dbo.catsubscription where subscriptionname='Paquete Petit' and rowstatus=1)
    DECLARE @IdPaqueteBasico int= (select idcatsubscription from dbo.catsubscription where subscriptionname='Paquete Básico' and rowstatus=1)
    DECLARE @IdPaquetePlus int= (select idcatsubscription from dbo.catsubscription where subscriptionname='Paquete Plus' and rowstatus=1)
    DECLARE @IdPaqueteGold int= (select  idcatsubscription from dbo.catsubscription where subscriptionname='Paquete Gold' and rowstatus=1)
    DECLARE @IdPaquetePlatino int= (select  idcatsubscription from dbo.catsubscription where subscriptionname='Paquete Platino' and rowstatus=1)

    IF @IdPlanAmigo IS NULL 
    BEGIN
        SELECT 'No existe plan Amigo'
        THROW;
    END
    ELSE IF @IdPaquetePetit IS NULL 
    BEGIN
        SELECT 'No existe plan petit'
        THROW;
    END
    ELSE IF @IdPaqueteBasico IS NULL 
    BEGIN
        SELECT 'No existe plan basico'
        THROW;
    END
    ELSE IF @IdPaquetePlus IS NULL 
    BEGIN
        SELECT 'No existe plan plus'
        THROW;
    END
    ELSE IF @IdPaqueteGold IS NULL 
    BEGIN
        SELECT 'No existe plan gold'
        THROW;
    END
    ELSE IF @IdPaquetePlatino  IS NULL 
    BEGIN
        SELECT 'No existe plan platino'
        THROW;
    END

		

	update dbo.catsubscription set
		SubscriptionCost=199.00,
		SubscriptionValidity=6
	where idcatsubscription=@IdPlanAmigo
    and rowstatus=1

	update dbo.catsubscription set
		SubscriptionCost=875.00,
		SubscriptionValidity=6,
		SubscriptionMaxServiceFixedValue=25,
		Tag='MÁS VENDIDO',
		subscriptiondescription='25 envíos Q35.00 c/u'
	where idcatsubscription=@IdPaquetePetit
    and rowstatus=1

	update dbo.catsubscription set
		SubscriptionCost=1650,
		SubscriptionValidity=6,
		SubscriptionMaxServiceFixedValue=50,
		Tag='MÁS VENDIDO',
		subscriptiondescription='50 envíos Q33.00 c/u'
	where idcatsubscription=@IdPaqueteBasico
    and rowstatus=1

	update dbo.catsubscription set
		SubscriptionCost=3100,
		SubscriptionValidity=6,
		SubscriptionMaxServiceFixedValue=100,
		Tag=NULL,
		subscriptiondescription='100 envíos Q31.00 c/u'
	where idcatsubscription=@IdPaquetePlus
    and rowstatus=1

	update dbo.catsubscription set
		SubscriptionCost=5800,
		SubscriptionValidity=6,
		SubscriptionMaxServiceFixedValue=200,
		Tag=NULL,
		subscriptiondescription='200 envíos Q29.00 c/u'
	where idcatsubscription=@IdPaqueteGold 
    and rowstatus=1

	update dbo.catsubscription set
		SubscriptionCost=10800,
		SubscriptionValidity=6,
		SubscriptionMaxServiceFixedValue=400,
		Tag=NULL,
		subscriptiondescription='400 envíos Q27.00 c/u'
	where idcatsubscription=@IdPaquetePlatino
    and rowstatus=1


    COMMIT;
    SELECT 'Se han realizado los resgistros exitosamente'            

END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'Error'
END CATCH    