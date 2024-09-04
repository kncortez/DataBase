--pendiente
/*********PAQUETE BASICO HN*****************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('�Qu� es?',
       'Nuestro paquete te ofrece 50 gu�as de env�o prepagadas con Tarifa �nica a todo el pa�s, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, �nuestra tarifa es la m�s barata del mercado! Ahorra y optimiza con nuestras gu�as prepagadas que ofrecen una ayuda invaluable para tu negocio. �Tienes una gran cantidad de env�os de manera continua? Estas gu�as son ideales para ti. Simplifica tus procesos de env�o, obt�n la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. �Haz que tus env�os sean m�s rentables y eficientes hoy mismo!',
	   1,'',13,1,GETDATE(),'SYS-BHERRERA'),
	   ('�C�mo Funciona?',
	   'Compra en la tienda virtual y recibe las gu�as en tu correo electronico. Prepara tus paquetes, completa la informaci�n de env�o y entr�galos en las +90 agencias express center o puedes solicitar la recolecci�n a tu casa u oficina. Rastrea el progreso del env�o con el n�mero de gu�a proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles log�sticos. Adquiere tu Paquete B�sico y podr�s obtener tus gu�as prepagadas de 50 env�os con tarifa �nica a todo el pa�s a L99.00 c/u.  ',
	   2,'',13,1,GETDATE(),'SYS-BHERRERA'),
	   ('Aplican restricciones',
	   'En caso de que tu env�o exceda el peso, +L3.19.00 por libra adicional, consulta los t�rminos y condiciones.',
	   5,'PAQUETE B�SICO',13,1,GETDATE(),'SYS-EVASQUEZ')

/*********PAQUETE PLUS HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('�Qu� es?',
	    'Nuestro paquete te ofrece 100 gu�as de env�o prepagadas con Tarifa �nica a todo el pa�s, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, �nuestra tarifa es la m�s barata del mercado! Ahorra y optimiza con nuestras gu�as prepagadas que ofrecen una ayuda invaluable para tu negocio. �Tienes una gran cantidad de env�os de manera continua? Estas gu�as son ideales para ti. Simplifica tus procesos de env�o, obt�n la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. �Haz que tus env�os sean m�s rentables y eficientes hoy mismo!',
		1,'PAQUETE PLUS',14,1,GETDATE(),'SYS-BHERRERA'),
	  ('�C�mo Funciona?',
	   'Compra en la tienda virtual y recibe las gu�as en tu correo electronico. Prepara tus paquetes, completa la informaci�n de env�o y entr�galos en las +90 agencias express center o puedes solicitar la recolecci�n a tu casa u oficina. Rastrea el progreso del env�o con el n�mero de gu�a proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles log�sticos. Adquiere tu Paquete Plus y podr�s obtener tus gu�as prepagadas de 100 env�os con tarifa �nica a todo el pa�s a L92.62 c/u.',
	   2,'PAQUETE PLUS',14,1,GETDATE(),'SYS-BHERRERA'),
	  ('Aplican restricciones',
	  'En caso de que tu env�o exceda el peso, +L3.19.00 por libra adicional, consulta los t�rminos y condiciones.',
	  5,'PAQUETE PLUS',14,1,GETDATE(),'SYS-BHERRERA')

/*********PAQUETE GOLD HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('�Qu� es?',
	   'Nuestro paquete te ofrece 200 gu�as de env�o prepagadas con Tarifa �nica a todo el pa�s, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, �nuestra tarifa es la m�s barata del mercado! Ahorra y optimiza con nuestras gu�as prepagadas que ofrecen una ayuda invaluable para tu negocio. �Tienes una gran cantidad de env�os de manera continua? Estas gu�as son ideales para ti. Simplifica tus procesos de env�o, obt�n la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. �Haz que tus env�os sean m�s rentables y eficientes hoy mismo!',
	   1,'PAQUETE GOLD',15,1,GETDATE(),'SYS-BHERRERA'),
	  ('�C�mo Funciona?','Compra en la tienda virtual y recibe las gu�as en tu correo electronico. Prepara tus paquetes, completa la informaci�n de env�o y entr�galos en las +90 agencias express center o puedes solicitar la recolecci�n a tu casa u oficina. Rastrea el progreso del env�o con el n�mero de gu�a proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles log�sticos. Adquiere tu Paquete Gold y podr�s obtener tus gu�as prepagadas de 200 env�os con tarifa �nica a todo el pa�s a L86.23 c/u.  ',
	   2,'PAQUETE GOLD',15,1,GETDATE(),'SYS-BHERRERA'),
	  ('Aplican restricciones',
	   'En caso de que tu env�o exceda el peso, +L3.19.00 por libra adicional, consulta los t�rminos y condiciones.',
	   5,'PAQUETE GOLD',15,1,GETDATE(),'SYS-BHERRERA')

/*********PLAN AMIGO HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('�Qu� es?',
	   'El Plan Amigo es una oportunidad �nica para ahorrar en tus env�os a nivel nacional. Obt�n un 10% de descuento sobre la tarifa vigente en todos tus env�os, ya sea en servicio C.O.D o Est�ndar. Este plan recompensa tu lealtad al ofrecerte tarifas mejoradas seg�n el servicio y destino. ��nete ahora y disfruta de tarifas m�s econ�micas mientras env�as con confianza!',
	    1,'PLAN AMIGO',16,1,GETDATE(),'SYS-BHERRERA'),
	   ('�C�mo Funciona?',
	    'Simplemente reg�strate en nuestro Plan Amigo y autom�ticamente comenzar�s a disfrutar de un 10% de descuento en todos tus env�os a nivel nacional. No hay tarifas ocultas ni complicados procesos. Solo env�a tus paquetes como lo har�as normalmente, y el descuento se aplicar� autom�ticamente a la tarifa est�ndar. �As� de simple es comenzar a ahorrar con nuestro Plan Amigo!',
		2,'PLAN AMIGO',16,1,GETDATE(),'SYS-BHERRERA'),
	   ('Aplican restricciones',
	    'En caso de que tu env�o exceda el peso, +L3.19.00 por libra adicional, consulta los t�rminos y condiciones.',
		5,'PLAN AMIGO',16,1,GETDATE(),'SYS-BHERRERA')

/*********PAQUETE PETIT HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('�Qu� es?',
	   'Nuestro paquete te ofrece 25 gu�as de env�o prepagadas con Tarifa �nica a todo el pa�s, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, �nuestra tarifa es la m�s barata del mercado! Ahorra y optimiza con nuestras gu�as prepagadas que ofrecen una ayuda invaluable para tu negocio. �Tienes una gran cantidad de env�os de manera continua? Estas gu�as son ideales para ti. Simplifica tus procesos de env�o, obt�n la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. �Haz que tus env�os sean m�s rentables y eficientes hoy mismo!',
	   1,'PAQUETE PETIT',17,1,GETDATE(),'SYS-EVASQUEZ'),
	  ('�C�mo Funciona?',
	   'Compra en la tienda virtual y recibe las gu�as en tu correo electr�nico. Prepara tus paquetes, completa la informaci�n de env�o y entr�galos en las +90 agencias express center o puedes solicitar la recolecci�n a tu casa u oficina. Rastrea el progreso del env�o con el n�mero de gu�a proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles log�sticos. Adquiere tu Paquete Petit y podr�s obtener tus gu�as prepagadas de 25 env�os con tarifa �nica a todo el pa�s a L105.39 c/u.',
	   2,'PAQUETE PETIT',17,1,GETDATE(),'SYS-EVASQUEZ'),
	  ('Aplican restricciones',
	   'En caso de que tu env�o exceda el peso, +L3.19.00 por libra adicional, consulta los t�rminos y condiciones.',
	   5,'PAQUETE PETIT',17,1,GETDATE(),'SYS-EVASQUEZ')

/*********PAQUETE PLATINO HN********************/
INSERT INTO CatSubscriptionDescription (Title, Description, Position,Type,CatSubscriptionId,RowStatus,DateCreated,TokenCreated)
VALUES('�Qu� es?',
	   'Nuestro paquete te ofrece 400 gu�as de env�o prepagadas con Tarifa �nica a todo el pa�s, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, �nuestra tarifa es la m�s barata del mercado! Ahorra y optimiza con nuestras gu�as prepagadas que ofrecen una ayuda invaluable para tu negocio. �Tienes una gran cantidad de env�os de manera continua? Estas gu�as son ideales para ti. Simplifica tus procesos de env�o, obt�n la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. �Haz que tus env�os sean m�s rentables y eficientes hoy mismo!',
	   1,'PAQUETE PLATINO',18,1,GETDATE(),'SYS-AIXCHOP'),
	  ('�C�mo Funciona?',
	   'Compra en la tienda virtual y recibe las gu�as en tu correo electr�nico. Prepara tus paquetes, completa la informaci�n de env�o y entr�galos en las +90 agencias express center o puedes solicitar la recolecci�n a tu casa u oficina. Rastrea el progreso del env�o con el n�mero de gu�a proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles log�sticos. Adquiere tu Paquete Platino y podr�s obtener tus gu�as prepagadas de 400 env�os con tarifa �nica a todo el pa�s a L79.84 c/u.',
	   2,'PAQUETE PLATINO',18,1,GETDATE(),'SYS-AIXCHOP'),
	  ('Aplican restricciones',
	   'En caso de que tu env�o exceda el peso, +L3.19.00 por libra adicional, consulta los t�rminos y condiciones.',
	   5,'PAQUETE PLATINO',18,1,GETDATE(),'SYS-EVASQUEZ')