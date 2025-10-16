--SELECT * FROM [DeliveryBackOffice].[dbo].[ContentDetail] 

DECLARE @Token NVARCHAR(25) = 'SYS-WOROZCO'
DECLARE @IdCountry NVARCHAR(2) = 'SV'

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[ContentDetail] (
		[ContentTitleId],
		[ContentDetailTitle],
		[ContentDetailDescription],
		[ContentDetailVideoURL],
		[ContentDetailImageURL],
		[ContentDetailPageURLButton],
		[ContentDetailPageURL],
		[RowStatus],
		[DateCreated],
		[TokenCreated],
		[IsPageURLExternal],
		[IsVideoURLExternal]
	)
	-- 12:8
	SELECT 
		IdContentTitle AS [ContentTitleId],
		NULL AS [ContentDetailTitle],
		'Genera una guía estándar o C.O.D. con todos los datos que te solicitan para poder identificar y enviar tus paquetes.' AS [ContentDetailDescription],
		'https://youtu.be/aILGDgQJJdw' AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/Preguntasfrecuentes/Forza-Delivery-envío-200x400px1 2.jpg' AS [ContentDetailImageURL],
		'Realizar un envío' AS [ContentDetailPageURLButton],
		'/individual/crear-guia/estandar' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle] 
	WHERE ContentTitle = '¿Cómo realizar un envío?' AND CountryId = @IdCountry
	UNION
	-- 13:9
	SELECT 
		IdContentTitle AS [ContentTitleId],
		NULL AS [ContentDetailTitle],
		'Genera un envío Estándar o C.O.D. y permite asegurar tu paquete por un monto automático desde L 2566.52' AS [ContentDetailDescription],
		NULL AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/Preguntasfrecuentes/Forza-Delivery-seguro-200x400px1 2.jpg' AS [ContentDetailImageURL],
		'Asegurar un paquete' AS [ContentDetailPageURLButton],
		'/individual/crear-guia/estandar' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle] 
	WHERE ContentTitle = '¿Como asegurar los paquetes?' AND CountryId = @IdCountry
	UNION
	-- 15:11
	SELECT 
		IdContentTitle AS [ContentTitleId],
		NULL AS [ContentDetailTitle],
		'Tus paquetes necesitan un embalaje especial para poder proteger el producto interno de daños, deterioros pérdidas o robos.' AS [ContentDetailDescription],
		NULL AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/Preguntasfrecuentes/Forza-Delivery-empaque-200x400px1 2 2 2.jpg' AS [ContentDetailImageURL],
		NULL AS [ContentDetailPageURLButton],
		NULL AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = '¿Qué tipo de embalaje utilizar?' AND CountryId = @IdCountry
	UNION
	-- 16:12
	SELECT 
		IdContentTitle AS [ContentTitleId],
		NULL AS [ContentDetailTitle],
		'La guía permite identificar tu paquete con un código para poder registrar y rastrear su movimiento desde la web en tiempo real.' AS [ContentDetailDescription],
		NULL AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/Preguntasfrecuentes/Forza-Delivery-generaguia-200x400px1 2 2 2.jpg' AS [ContentDetailImageURL],
		'Generar una guía' AS [ContentDetailPageURLButton],
		'/individual/crear-guia/estandar' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = '¿Qué es una guía?' AND CountryId = @IdCountry
	UNION
	-- 17:13
	SELECT 
		IdContentTitle AS [ContentTitleId],
		NULL AS [ContentDetailTitle],
		'Se cuentan con condiciones y políticas de envío para transportar tus paquetes y evitar percances en el traslado.' AS [ContentDetailDescription],
		NULL AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/Preguntasfrecuentes/Forza-Delivery-tipoMercaderia-200x400px1.jpg' AS [ContentDetailImageURL],
		'Realizar un envío' AS [ContentDetailPageURLButton],
		'/individual/crear-guia/estandar' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = '¿Qué tipo de mercadería envíar?' AND CountryId = @IdCountry 
	UNION
	-- 18:14
	SELECT 
		IdContentTitle AS [ContentTitleId],
		NULL AS [ContentDetailTitle],
		'Realiza tus pagos desde el portal web con tarjeta y/o en nuestras Agencias Express Center en tarjeta o en efectivo.' AS [ContentDetailDescription],
		NULL AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/Preguntasfrecuentes/Forza-Delivery-Formas-200x400px1 2.jpg' AS [ContentDetailImageURL],
		'Realizar un envío' AS [ContentDetailPageURLButton],
		'/individual/crear-guia/estandar' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = '¿Cuáles son las formas de pago?' AND CountryId = @IdCountry 
	UNION
	-- 19:15
	SELECT 
		IdContentTitle AS [ContentTitleId],
		'Servicio C.O.D.' AS [ContentDetailTitle],
		'Servicio de entrega y cobro de mercadería en el destino. (Comisión del 3.8% sobre el valor de la mercancía) Deposito inmediato. ' AS [ContentDetailDescription],
		'https://youtu.be/ArQZ4qEW6nw' AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/CMS/COD200x400.jpg' AS [ContentDetailImageURL],
		'Crea tu guía' AS [ContentDetailPageURLButton],
		'/individual/crear-guia/cod' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = 'NUESTROS SERVICIOS' AND CountryId = @IdCountry
	UNION
	-- 20:15
	SELECT 
		IdContentTitle AS [ContentTitleId],
		'Servicio Estándar' AS [ContentDetailTitle],
		'Servicio regular de paquetería y encomiendas, con cobertura a nivel nacional de 24 a h48 horas. Puedes cancelar en origen o en destino (+L12.83).' AS [ContentDetailDescription],
		'https://youtu.be/aILGDgQJJdw' AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/CMS/Estandar200x400.jpg' AS [ContentDetailImageURL],
		'Solicita tu envío' AS [ContentDetailPageURLButton],
		'/individual/crear-guia/estandar' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = 'NUESTROS SERVICIOS' AND CountryId = @IdCountry 
	UNION
	-- 21:15
	SELECT 
		IdContentTitle AS [ContentTitleId],
		'Material de Empaque' AS [ContentDetailTitle],
		'Solución para que tus productos sean correctamente protegidos para prevenir daños y deterioros y los mantendrá intactos para la entrega a tus clientes.' AS [ContentDetailDescription],
		NULL AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/CMS/Forza-Delivery-empaque-200x400px1 2 2 2.jpg' AS [ContentDetailImageURL],
		'¡Protege tu producto!' AS [ContentDetailPageURLButton],
		'https://forzadelivery.com/material-de-empaque/' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		1 AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = 'NUESTROS SERVICIOS' AND CountryId = @IdCountry
	UNION
	-- 22:15
	SELECT 
		IdContentTitle AS [ContentTitleId],
		'Servicio Agencia - Agencia' AS [ContentDetailTitle],
		'Servicio de agencia a agencia, con cobertura a nivel nacional.' AS [ContentDetailDescription],
		NULL AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/CMS/SERVICIO-DE-AGENCIA-A-AGENCIA-fit.png' AS [ContentDetailImageURL],
		'Mas información' AS [ContentDetailPageURLButton],
		'https://forzadelivery.com/servicio-de-agencia-a-agencia/' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		1 AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = 'NUESTROS SERVICIOS' AND CountryId = @IdCountry
	UNION
	-- 23:16
	SELECT 
		IdContentTitle AS [ContentTitleId],
		NULL AS [ContentDetailTitle],
		'Realizamos tus envíos de puerta a puerta. Programando tu recolección desde nuestro portal web para que puedas enviar tus paquetes a nivel nacional.' AS [ContentDetailDescription],
		'https://youtu.be/xGyQdGIYzWU' AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/Preguntasfrecuentes/pickupimage.png' AS [ContentDetailImageURL],
		'Realizar un envío' AS [ContentDetailPageURLButton],
		'/individual/recoleccion/manual' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle]
	WHERE ContentTitle = '¿Cómo solicitar la recolección?' AND CountryId = @IdCountry
	UNION
	-- 24:15
	SELECT 
		IdContentTitle AS [ContentTitleId],
		'Club Forza' AS [ContentDetailTitle],
		'Club de beneficios para emprendedores y clientes que brinda una tarifa única a todo el país desde L80.20 cada envío' AS [ContentDetailDescription],
		NULL AS [ContentDetailVideoURL],
		'https://forzadelivery.com/images/CMS/Imagen_servicios_Hermes-fit.png' AS [ContentDetailImageURL],
		'Más información' AS [ContentDetailPageURLButton],
		'/individual/detalle/membresias' AS [ContentDetailPageURL],
		1 AS [RowStatus],
		GETDATE() AS [DateCreated],
		@Token AS [TokenCreated],
		NULL AS [IsPageURLExternal],
		NULL AS [IsVideoURLExternal]
	FROM [dbo].[ContentTitle] 
	WHERE ContentTitle = 'NUESTROS SERVICIOS' AND CountryId = @IdCountry
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
