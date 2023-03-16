USE [DeliveryBackOffice];
GO

DECLARE @DiamondPlan INT = 
(
	SELECT 
		TOP (1) 
			CS.[IdCatSubscription]
	FROM 
		[DeliveryBackOffice].[dbo].[CatSubscription] CS  WITH(NOLOCK) 
	WHERE
		CS.[SubscriptionName] = 'Plan diamante'  COLLATE Latin1_General_CI_AI 
)

-- Plan diamante - Individuales
INSERT INTO [CatSubscriptionDescription]
	(
		Title, 
		[Description], 
		Position, 
		[Type], 
		CatSubscriptionId, 
		RowStatus, 
		DateCreated, 
		TokenCreated
	)
VALUES
	(
		'¿Qué es?', 
		'Suscripción Diamante que brinda el nivel premium de beneficios y acceso a promociones, descuentos, recolecciones sin costo, con frecuencia programa de visita y otros beneficios más.',
		1,
		'PLAN DIAMANTE',
		@DiamondPlan,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo funciona?', 
		'Al adquirir tu suscripción Diamante, podrás realizar 500 envíos incluidos. Tus envíos adicionales a los primeros 500 tendrán un 30% de descuento mientras tu suscripción mensual esté vigente.',
		2,
		'PLAN DIAMANTE',
		@DiamondPlan,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo saber si es conveniente para ti o tu negocio?', 
		'Si realizas más de 500 envíos al año con Club Forza tendrás acceso a precios inigualables.',
		3,
		'PLAN DIAMANTE',
		@DiamondPlan,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Qué otros Beneficios obtienes con la membresía?', 
		'Promociones especiales en comercios afiliados;Recolecciones SIN COSTO;Envío de devoluciones SIN COSTO',
		4,
		'PLAN DIAMANTE',
		@DiamondPlan,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	)