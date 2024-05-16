
-----## Paquete Básico 9

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 50 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.
Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    Position = 1
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND  Title='¿Qué es?'
AND CS.SubscriptionName='Paquete Básico' COLLATE Latin1_General_CI_AI


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a Q31.00 c/u.
',
    Position = 2
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='¿Cómo Funciona?'
AND CS.SubscriptionName='Paquete Básico' COLLATE Latin1_General_CI_AI

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='50 guías a Q31 c/u.;Tarifa única en todo el país.;Costo único para todos tus clientes.;  Hasta 10 libras; La tarifa más barata del mercado.;Vigencia de 6 meses.',
    Position = 3
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='Beneficios'
AND CS.SubscriptionName='Paquete Básico' COLLATE Latin1_General_CI_AI


-----## Paquete Plus 10

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 100 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.
Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    Position = 1
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='¿Qué es?'
AND CS.SubscriptionName='Paquete Plus' COLLATE Latin1_General_CI_AI


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Plus y podrás obtener tus guías prepagadas de 100 envíos con tarifa única a todo el país a Q29.00 c/u.',
    Position = 2
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND  Title='¿Cómo Funciona?'
AND CS.SubscriptionName='Paquete Plus' COLLATE Latin1_General_CI_AI

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='100 guías a Q29 c/u.; Tarifa única en todo el país.;Costo único para todos tus clientes.;  Hasta 10 libras; La tarifa más barata del mercado.;Vigencia de 6 meses.',
    Position = 3
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND  Title='Beneficios'
AND CS.SubscriptionName='Paquete Plus' COLLATE Latin1_General_CI_AI


-----## Paquete gold 11

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 200 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.
Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
    Position = 1
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND  Title='¿Qué es?'
AND CS.SubscriptionName='Paquete Gold' COLLATE Latin1_General_CI_AI


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Gold y podrás obtener tus guías prepagadas de 200 envíos con tarifa única a todo el país a Q27.00 c/u.
',
    Position = 2
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND  Title='¿Cómo Funciona?'
AND CS.SubscriptionName='Paquete Gold' COLLATE Latin1_General_CI_AI

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='200 guías a Q27 c/u.; La tarifa más barata del mercado.;  Costo único para todos tus clientes.;  Tarifa única en todo el país.; Hasta 10 libras;  Vigencia de 6 meses.',
    Position = 3
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND  Title='Beneficios'
AND CS.SubscriptionName='Paquete Gold' COLLATE Latin1_General_CI_AI



-----## Plan Amigo 12

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='El Plan Amigo es una oportunidad única para ahorrar en tus envíos a nivel nacional. Obtén un 10% de descuento sobre la tarifa vigente en todos tus envíos, ya sea en servicio C.O.D o Estándar. Este plan recompensa tu lealtad al ofrecerte tarifas mejoradas según el servicio y destino. ¡Únete ahora y disfruta de tarifas más económicas mientras envías con confianza!',
    Position = 1
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND  Title='¿Qué es?'
AND CS.SubscriptionName='Plan Amigo' COLLATE Latin1_General_CI_AI


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Simplemente regístrate en nuestro Plan Amigo y automáticamente comenzarás a disfrutar de un 10% de descuento en todos tus envíos a nivel nacional. No hay tarifas ocultas ni complicados procesos. Solo envía tus paquetes como lo harías normalmente, y el descuento se aplicará automáticamente a la tarifa estándar. ¡Así de simple es comenzar a ahorrar con nuestro Plan Amigo!',
    Position = 2
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND  Title='¿Cómo Funciona?'
AND CS.SubscriptionName='Plan Amigo' COLLATE Latin1_General_CI_AI

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.;Precio de acuerdo a tipo de servicio y destino.;  Desde la primer guía, de acuerdo al consumo.;  Permite servicio Collect Q 4.00;  Hasta 10 libras.;  +3.8% C.O.D. con "Acreditamiento Inmediato".;',
    Position = 3
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='Beneficios'
AND CS.SubscriptionName='Plan Amigo' COLLATE Latin1_General_CI_AI


-----## Plan Petit 18

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 25 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.
Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!"',
    Position = 1
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='¿Qué es?'
AND CS.SubscriptionName='Paquete Petit' COLLATE Latin1_General_CI_AI




UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a Q33.00 c/u.
',
    Position = 2
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='¿Cómo Funciona?'
AND CS.SubscriptionName='Paquete Petit' COLLATE Latin1_General_CI_AI

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='25 guías a Q33 c/u.;  Tarifa única en todo el país.;  Costo único para todos tus clientes. ; Hasta 10 libras;  La tarifa más barata del mercado.;  Vigencia de 6 meses.',
    Position = 3
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='Beneficios'
AND CS.SubscriptionName='Paquete Petit' COLLATE Latin1_General_CI_AI



-----## Plan Paquete Platino 19

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Nuestro paquete te ofrece 400 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.
Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!',
 Position = 1
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='¿Qué es?'
AND CS.SubscriptionName='Paquete Platino' COLLATE Latin1_General_CI_AI


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Compra en la tienda virtual y recibe las guías en tu correo electronico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Platino y podrás obtener tus guías prepagadas de 400 envíos con tarifa única a todo el país a Q25.00 c/u.
',
    Position = 2
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='¿Cómo Funciona?'
AND CS.SubscriptionName='Paquete Platino' COLLATE Latin1_General_CI_AI

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='400 guías a Q25 c/u.;  Tarifa única en todo el país.;  Costo único para todos tus clientes.;  Hasta 10 libras; La tarifa más barata del mercado.;  Vigencia de 6 meses.',
    Position = 3
FROM [dbo].[CatSubscriptionDescription] CSA
INNER JOIN DBO.CatSubscription CS
ON CSA.CatSubscriptionId = CS.IdCatSubscription
WHERE CSA.RowStatus=1
AND Title='Beneficios'
AND CS.SubscriptionName='Paquete Platino' COLLATE Latin1_General_CI_AI


-----## Membresía club forza 1

UPDATE  CSA
SET [Description]='La membresía del Club Forza es un exclusivo programa de beneficios diseñado para fidelizar a nuestros clientes que realizan envíos frecuentes. Reconocemos y premiamos la preferencia con acumulación de puntos y beneficios en comercios afiliados. Únete al Club Forza y disfruta de los beneficios que Forza te puede brindar.',
    Position = 1,
	TokenUpdated='SYS-EVASQUEZ',
     DateUpdated=GETDATE()
FROM [dbo].[CatMembershipDescription] CSA
INNER JOIN DBO.CatMembership CS
ON CSA.CatMembershipId = CS.IdCatMembership
WHERE CSA.RowStatus=1
AND Title='¿Qué es?'
AND CS.MembershipName='Club Forza' COLLATE Latin1_General_CI_AI




UPDATE  [dbo].[CatMembershipDescription]
SET [Description]='Al unirte al Club Forza con tu membresia por Q 20.00 al Club Forza, obtienes acceso instántaneo a una serie de beneficios exclusivos. Simplemente realiza tus envíos como de costumbre y automáticamente recibirás acumulación de puntos para envíos gratis. Además, disfrutarás de beneficios adicionales como promociones en comercios afiliados. ¡Únete hoy mismo y comienza a aprovechar todas las ventajas que ofrece el Club Forza!',
    Position = 2,
	TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatMembershipDescription] CSA
INNER JOIN DBO.CatMembership CS
ON CSA.CatMembershipId = CS.IdCatMembership
WHERE CSA.RowStatus=1
AND Title='¿Cómo Funciona?'
AND CS.MembershipName='Club Forza' COLLATE Latin1_General_CI_AI



UPDATE  [dbo].[CatMembershipDescription]
SET Rowstatus=0,
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatMembershipDescription] CSA
INNER JOIN DBO.CatMembership CS
ON CSA.CatMembershipId = CS.IdCatMembership
WHERE CSA.RowStatus=1
AND Title='¿Qué otros Beneficios obtienes?'
AND CS.MembershipName='Club Forza' COLLATE Latin1_General_CI_AI

UPDATE  [dbo].[CatMembershipDescription]
SET Rowstatus=0,
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE()
FROM [dbo].[CatMembershipDescription] CSA
INNER JOIN DBO.CatMembership CS
ON CSA.CatMembershipId = CS.IdCatMembership
WHERE CSA.RowStatus=1
AND Title='Disfruta de más beneficios'
AND CS.MembershipName='Club Forza' COLLATE Latin1_General_CI_AI

UPDATE CMA
SET 
MembershipAttributeDescription='Acumulación de puntos para envíos gratis',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE(),
CatMembershipAttributeIcon = 'fa fa-truck fa-2x'
FROM [dbo].[catmembershipattribute] CMA
INNER JOIN [DBO].[CatMembership] CM
ON CMA.CatMembershipId = CM.IdCatMembership
WHERE 
CMA.MembershipAttributeDescription='1 año de vigencia'
AND CMA.RowStatus=1


UPDATE CMA
SET 
MembershipAttributeDescription='Promociones en comercios Afiliados',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE(),
CatMembershipAttributeIcon = 'fa fa-shopping-cart fa-2x'
FROM [dbo].[catmembershipattribute] CMA
INNER JOIN [DBO].[CatMembership] CM
ON CMA.CatMembershipId = CM.IdCatMembership
WHERE 
CMA.MembershipAttributeDescription='10% de descuento en las tarifas bases vigentes de acuerdo al tipo de destino para servicios Estándar o COD.'
AND CMA.RowStatus=1


UPDATE CMA
SET 
MembershipAttributeDescription='Recolecciones SIN COSTO',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE(),
CatMembershipAttributeIcon = 'fa fa-check-circle fa-2x'
FROM [dbo].[catmembershipattribute] CMA
INNER JOIN [DBO].[CatMembership] CM
ON CMA.CatMembershipId = CM.IdCatMembership
WHERE 
CMA.MembershipAttributeDescription='Descuento desde la primer guía, sin tener que comprar saldo, ideal para clientes que envían de 10 a 15 envíos mensuales.'
AND CMA.RowStatus=1



UPDATE CMA
SET 
MembershipAttributeDescription='Envío de devoluciones SIN COSTO',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE(),
CatMembershipAttributeIcon = 'fa fa-check-circle fa-2x'
FROM [dbo].[catmembershipattribute] CMA
INNER JOIN [DBO].[CatMembership] CM
ON CMA.CatMembershipId = CM.IdCatMembership
WHERE 
CMA.MembershipAttributeDescription='El envío lo puede pagar el remitente o puedes solicitar el servicio cobrar al destinatario (collect + Q 4.00).'
AND CMA.RowStatus=1


UPDATE CMA
SET 
MembershipAttributeDescription='Pagos de reclamo en 24 horas',
TokenUpdated='SYS-EVASQUEZ',
DateUpdated=GETDATE(),
CatMembershipAttributeIcon = 'fa fa-check-circle fa-2x'
FROM [dbo].[catmembershipattribute] CMA
INNER JOIN [DBO].[CatMembership] CM
ON CMA.CatMembershipId = CM.IdCatMembership
WHERE 
CMA.MembershipAttributeDescription='Generas tu guía desde el portal web y puedes llevar tu envío a cualquiera de las Agencias Express Center o solicitar una recolección.'
AND CMA.RowStatus=1







