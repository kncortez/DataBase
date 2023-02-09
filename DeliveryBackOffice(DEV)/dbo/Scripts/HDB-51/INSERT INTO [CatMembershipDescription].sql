USE [DeliveryBackOffice];
GO

-- Club forza - Individuales
INSERT INTO [CatMembershipDescription]
	(
		Title, 
		[Description], 
		Position, 
		[Type], 
		CatMembershipId, 
		RowStatus, 
		DateCreated, 
		TokenCreated
	)
VALUES
	(
		'¿Qué es?', 
		'Es un programa para emprendedores y Pymes que brinda beneficios y accesos exclusivos a promociones, descuentos, recolecciones sin costo, con frecuencia programada de visita y muchos beneficios más.',
		1,
		'CLUB FORZA',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo funciona?', 
		'Al adquirir tu membresía Club Forza, podrás realizar 50 envíos de Q. 1.00 cada uno. Tus envíos adicionales a los primeros 50 tendrán un 10% de descuento mientras tu membresía esté vigente.',
		2,
		'CLUB FORZA',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Cómo saber si es conveniente para ti o tu negocio?', 
		'Si realizas más de 50 envíos al año con Club Forza tendrás acceso a precios inigualables.',
		3,
		'CLUB FORZA',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'¿Qué otros Beneficios obtienes con la membresía?', 
		'Promociones especiales en comercios afiliados; Recolecciones SIN COSTO; Envío de devoluciones SIN COSTO',
		4,
		'CLUB FORZA',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	),
	(
		'Disfruta de más beneficios', 
		'Al ser miembro del Club Forza podrás adquirir suscripciones mensuales que te brindan paquetes de envíos cada vez mas económicos. Desde un paquete básico de 50 envíos mensuales con un 15% de descuento, hasta paquetes de 500 envíos con un 30% de descuento',
		5,
		'CLUB FORZA',
		1,
		1,
		GETDATE(),
		'SYS-ARUIZ'
	)