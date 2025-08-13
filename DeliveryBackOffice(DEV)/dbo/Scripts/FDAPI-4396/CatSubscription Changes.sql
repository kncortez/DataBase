BEGIN TRY
	BEGIN TRANSACTION
	DECLARE @IdCountry NVARCHAR(3) = 'GT'

	DECLARE @CatSubcription INT = ( SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Básico' AND IdCountry = @IdCountry AND RowStatus = 1)

	--ACTUALIZAMOS EL PRECIO
	UPDATE CatSubscription SET SubscriptionDescription = '50 guías a Q25.00 c/u.', SubscriptionCost = '1250.00', Tag = 'NOVEDADES' WHERE IdCatSubscription = @CatSubcription

	--ACTUALIZAMOS DECRIPCIONES

	UPDATE CatSubscriptionDescription SET Description = 'Compra en la tienda virtual y recibe las guías en tu correo electrónico.  Prepara tus paquetes, completa la información de envío y entrégalos en las  +100 agencias express center o puedes solicitar la recolección a tu casa u  oficina. Rastrea el progreso del envío con el número de guía proporcionado  para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al  centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de  los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus  guías prepagadas de 50 envíos con tarifa única a todo el país a Q25.00  c/u.' WHERE CatSubscriptionId = @CatSubcription AND RowStatus = 1 AND Title = '¿Cómo Funciona?'

	-- SE DA DE BAJA EL PAQUETE FLEXI
	UPDATE CatSubscription SET RowStatus = 0 WHERE SubscriptionName = 'Paquete FLEXI'

	-- SE ACTUALIZA ENCABEZADO DE DETALLE
	UPDATE CatSubscriptionAtribute SET SubscriptionAttributeDescription = '50 guias a Q25.00 c/u.', SubscriptionAttributeDescriptionLong = '50 guías a Q25 c/u.' WHERE CatSubscriptionId = @CatSubcription AND  RowStatus = 1 AND SubscriptionAttributePosition = 1 

	COMMIT TRANSACTION;
	SELECT 'DATOS ACTUALIZADOS CORRECTAMENTE' AS MESSAGE
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	SELECT @@ERROR,
		   ERROR_MESSAGE(),
		   ERROR_LINE()
END CATCH