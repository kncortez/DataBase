USE [DeliveryBackOffice];
GO

-- Plan básico - Individuales
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
		'Suscripción básica que brinda un nivel básico de beneficios y acceso a promociones, descuentos, recolecciones sin costo, con frecuencia programa de visita y otros beneficios más.',
		1,
		'PLAN BÁSICO',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo funciona?', 
		'Al adquirir tu suscripción básica, podrás realizar 50 envíos incluidos. Tus envíos adicionales a los primeros 50 tendrán un 15% de descuento mientras tu suscripción mensual esté vigente.',
		2,
		'PLAN BÁSICO',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo saber si es conveniente para ti o tu negocio?', 
		'Si realizas más de 50 envíos al año con Club Forza tendrás acceso a precios inigualables.',
		3,
		'PLAN BÁSICO',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Qué otros Beneficios obtienes con la membresía?', 
		'Promociones especiales en comercios afiliados;Recolecciones SIN COSTO;Envío de devoluciones SIN COSTO',
		4,
		'PLAN BÁSICO',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'Disfruta de más beneficios', 
		'Al ser parte de la suscripción básica podrás adquirir suscripciones aún mayores que te brindan paquetes de envíos cada vez mas económicos.;Desde un paquete básico plus de 100 envíos mensuales con un 20% de descuento, hasta paquetes de 500 envíos con un 30% de descuento',
		5,
		'PLAN BÁSICO',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	)

-- Plan básico plus - Individuales
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
		'Suscripción básica plus que brinda un nivel de beneficios y acceso a promociones, descuentos, recolecciones sin costo, con frecuencia programa de visita y otros beneficios más.',
		1,
		'PLAN BÁSICO +',
		2,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo funciona?', 
		'Al adquirir tu suscripción básica plus, podrás realizar 100 envíos incluidos. Tus envíos adicionales a los primeros 100 tendrán un 20% de descuento mientras tu suscripción mensual esté vigente.',
		2,
		'PLAN BÁSICO +',
		2,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo saber si es conveniente para ti o tu negocio?', 
		'Si realizas más de 100 envíos al año con Club Forza tendrás acceso a precios inigualables.',
		3,
		'PLAN BÁSICO +',
		2,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Qué otros Beneficios obtienes con la membresía?', 
		'Promociones especiales en comercios afiliados;Recolecciones SIN COSTO;Envío de devoluciones SIN COSTO',
		4,
		'PLAN BÁSICO +',
		2,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'Disfruta de más beneficios', 
		'Al ser parte de la suscripción básica plus podrás adquirir suscripciones aún mayores que te brindan paquetes de envíos cada vez mas económicos. Desde un paquete gold de 250 envíos mensuales con un 25% de descuento, hasta paquetes de 500 envíos con un 30% de descuento',
		5,
		'PLAN BÁSICO +',
		2,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	)

-- Plan gold - Individuales
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
		'Suscripción Gold que brinda un nivel oro de beneficios y acceso a promociones, descuentos, recolecciones sin costo, con frecuencia programa de visita y otros beneficios más.',
		1,
		'PLAN GOLD',
		3,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo funciona?', 
		'Al adquirir tu suscripción Gold, podrás realizar 250 envíos incluidos. Tus envíos adicionales a los primeros 250 tendrán un 25% de descuento mientras tu suscripción mensual esté vigente.',
		2,
		'PLAN GOLD',
		3,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo saber si es conveniente para ti o tu negocio?', 
		'Si realizas más de 250 envíos al año con Club Forza tendrás acceso a precios inigualables.',
		3,
		'PLAN GOLD',
		3,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Qué otros Beneficios obtienes con la membresía?', 
		'Promociones especiales en comercios afiliados;Recolecciones SIN COSTO;Envío de devoluciones SIN COSTO',
		4,
		'PLAN GOLD',
		3,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'Disfruta de más beneficios', 
		'Al ser parte de la suscripción Gold podrás adquirir la suscripción más premium que te brindara paquetes de envíos cada vez mas económicos.;De 500 envíos con un 30% de descuento',
		5,
		'PLAN GOLD',
		3,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	)

-- Plan corporativo - Individuales
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
		'Suscripción Corporativo que brinda el nivel premium de beneficios y acceso a promociones, descuentos, recolecciones sin costo, con frecuencia programa de visita y otros beneficios más.',
		1,
		'PLAN CORPORATIVO',
		4,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo funciona?', 
		'Al adquirir tu suscripción Corporativa, podrás realizar 500 envíos incluidos. Tus envíos adicionales a los primeros 500 tendrán un 30% de descuento mientras tu suscripción mensual esté vigente.',
		2,
		'PLAN CORPORATIVO',
		4,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo saber si es conveniente para ti o tu negocio?', 
		'Si realizas más de 500 envíos al año con Club Forza tendrás acceso a precios inigualables.',
		3,
		'PLAN CORPORATIVO',
		4,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Qué otros Beneficios obtienes con la membresía?', 
		'Promociones especiales en comercios afiliados;Recolecciones SIN COSTO;Envío de devoluciones SIN COSTO',
		4,
		'PLAN CORPORATIVO',
		4,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	)