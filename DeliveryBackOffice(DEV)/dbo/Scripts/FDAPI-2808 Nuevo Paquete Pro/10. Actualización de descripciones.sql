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


	update dbo.CatSubscriptionDESCRIPTION	set
		description='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a Q35.00 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaquetePetit
	AND title='¿Cómo Funciona?'

	update dbo.CatSubscriptionDESCRIPTION	set
		description='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a Q33.00 c/u.  '
	where rowstatus=1
	and catsubscriptionid=@IdPaqueteBasico
	AND title='¿Cómo Funciona?'

	update dbo.CatSubscriptionDESCRIPTION	set
		description='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a Q31.00 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaquetePlus
	AND title='¿Cómo Funciona?'


	update dbo.CatSubscriptionDESCRIPTION	set
		description='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a Q29.00 c/u.  '
	where rowstatus=1
	and catsubscriptionid=@IdPaqueteGold
	AND title='¿Cómo Funciona?'


	update dbo.CatSubscriptionDESCRIPTION	set
		description='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a Q27.00 c/u.'
	where rowstatus=1
	and catsubscriptionid=@IdPaquetePlatino
	AND title='¿Cómo Funciona?'

    COMMIT;
    SELECT 'Se han realizado los resgistros exitosamente'            

END TRY
BEGIN CATCH
    ROLLBACK
    SELECT 'Error'
END CATCH    