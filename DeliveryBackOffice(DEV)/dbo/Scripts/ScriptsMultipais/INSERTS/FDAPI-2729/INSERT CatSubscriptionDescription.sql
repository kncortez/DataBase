
/*********PAQUETE BASICO HN*****************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('¿Qué es?',
       'Nuestro paquete te ofrece 50 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
	   1,'',13,1,GETDATE(),'SYS-BHERRERA'),
	   ('¿Cómo Funciona?',
	   'Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a L99.00 c/u.  ',
	   2,'',13,1,GETDATE(),'SYS-BHERRERA'),
	   ('Aplican restricciones',
	   'En caso de que tu envío exceda el peso, +L3.19.00 por libra adicional, consulta los términos y condiciones.',
	   5,'PAQUETE BÁSICO',13,1,GETDATE(),'SYS-EVASQUEZ')

/*********PAQUETE PLUS HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('¿Qué es?',
	    'Nuestro paquete te ofrece 100 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
		1,'PAQUETE PLUS',14,1,GETDATE(),'SYS-BHERRERA'),
	  ('¿Cómo Funciona?',
	   'Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a L92.62 c/u.',
	   2,'PAQUETE PLUS',14,1,GETDATE(),'SYS-BHERRERA'),
	  ('Aplican restricciones',
	  'En caso de que tu envío exceda el peso, +L3.19.00 por libra adicional, consulta los términos y condiciones.',
	  5,'PAQUETE PLUS',14,1,GETDATE(),'SYS-BHERRERA')

/*********PAQUETE GOLD HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('¿Qué es?',
	   'Nuestro paquete te ofrece 200 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
	   1,'PAQUETE GOLD',15,1,GETDATE(),'SYS-BHERRERA'),
	  ('¿Cómo Funciona?','Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a L86.23 c/u.  ',
	   2,'PAQUETE GOLD',15,1,GETDATE(),'SYS-BHERRERA'),
	  ('Aplican restricciones',
	   'En caso de que tu envío exceda el peso, +L3.19.00 por libra adicional, consulta los términos y condiciones.',
	   5,'PAQUETE GOLD',15,1,GETDATE(),'SYS-BHERRERA')

/*********PLAN AMIGO HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('¿Qué es?',
	   'El Plan Amigo es una oportunidad única para ahorrar en tus envíos a nivel nacional. Obtén un 10% de descuento sobre la tarifa vigente en todos tus envíos, ya sea en servicio C.O.D o Estándar. Este plan recompensa tu lealtad al ofrecerte tarifas mejoradas según el servicio y destino. ¡Únete ahora y disfruta de tarifas más económicas mientras envías con confianza!',
	    1,'PLAN AMIGO',16,1,GETDATE(),'SYS-BHERRERA'),
	   ('¿Cómo Funciona?',
	    'Simplemente regístrate en nuestro Plan Amigo y automáticamente comenzarás a disfrutar de un 10% de descuento en todos tus envíos a nivel nacional. No hay tarifas ocultas ni complicados procesos. Solo envía tus paquetes como lo harías normalmente, y el descuento se aplicará automáticamente a la tarifa estándar. ¡Así de simple es comenzar a ahorrar con nuestro Plan Amigo!',
		2,'PLAN AMIGO',16,1,GETDATE(),'SYS-BHERRERA'),
	   ('Aplican restricciones',
	    'En caso de que tu envío exceda el peso, +L3.19.00 por libra adicional, consulta los términos y condiciones.',
		5,'PLAN AMIGO',16,1,GETDATE(),'SYS-BHERRERA')

/*********PAQUETE PETIT HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('¿Qué es?',
	   'Nuestro paquete te ofrece 25 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
	   1,'PAQUETE PETIT',17,1,GETDATE(),'SYS-EVASQUEZ'),
	  ('¿Cómo Funciona?',
	   'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a L105.39 c/u.',
	   2,'PAQUETE PETIT',17,1,GETDATE(),'SYS-EVASQUEZ'),
	  ('Aplican restricciones',
	   'En caso de que tu envío exceda el peso, +L3.19.00 por libra adicional, consulta los términos y condiciones.',
	   5,'PAQUETE PETIT',17,1,GETDATE(),'SYS-EVASQUEZ')

/*********PAQUETE PLATINO HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('¿Qué es?',
	   'Nuestro paquete te ofrece 400 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
	   1,'PAQUETE PLATINO',18,1,GETDATE(),'SYS-AIXCHOP'),
	  ('¿Cómo Funciona?',
	   'Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a L79.84 c/u.',
	   2,'PAQUETE PLATINO',18,1,GETDATE(),'SYS-AIXCHOP'),
	  ('Aplican restricciones',
	   'En caso de que tu envío exceda el peso, +L3.19.00 por libra adicional, consulta los términos y condiciones.',
	   5,'PAQUETE PLATINO',18,1,GETDATE(),'SYS-EVASQUEZ')