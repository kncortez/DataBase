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

	update dbo.CatSubscriptionAtribute
		set SubscriptionAttributeDescription='25 guías a Q35 c/u.',
        SubscriptionAttributeDescriptionLong='25 guías a Q35 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaquetePetit
	and subscriptionattributeposition=1



	update dbo.CatSubscriptionAtribute
		set SubscriptionAttributeDescription='50 guías a Q33 c/u.',
            SubscriptionAttributeDescriptionLong='50 guías a Q33 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaqueteBasico
	and subscriptionattributeposition=1

	update dbo.CatSubscriptionAtribute
		set SubscriptionAttributeDescription='50 guías a Q33 c/u.',
        SubscriptionAttributeDescriptionLong='50 guías a Q33 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaqueteBasico
	and subscriptionattributeposition=1

	update dbo.CatSubscriptionAtribute
		set SubscriptionAttributeDescription='100 guías a Q31 c/u.',
        SubscriptionAttributeDescriptionLong='100 guías a Q31 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaquetePlus
	and subscriptionattributeposition=1

	update dbo.CatSubscriptionAtribute
		set SubscriptionAttributeDescription='200 guías a Q29 c/u.',
        SubscriptionAttributeDescriptionLong='200 guías a Q29 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaqueteGold
	and subscriptionattributeposition=1


	update dbo.CatSubscriptionAtribute
		set SubscriptionAttributeDescription='400 guías a Q27 c/u.',
        SubscriptionAttributeDescriptionLong='400 guías a Q27 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaquetePlatino 
	and subscriptionattributeposition=1

    COMMIT;
    SELECT 'Se han realizado los resgistros exitosamente'            

END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'Error'
END CATCH    