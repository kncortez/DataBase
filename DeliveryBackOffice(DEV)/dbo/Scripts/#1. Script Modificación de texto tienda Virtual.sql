update [dbo].[CatSubscriptionDescription]
set Description='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Petit y podrás obtener tus guías prepagadas de 25 envíos con tarifa única a todo el país a Q33.00 c/u.'
where RowStatus=1
and Type ='PAQUETE PETIT'
and Title='¿Cómo Funciona?'


update [dbo].[CatSubscriptionDescription]
set Description='Nuestro paquete te ofrece 25 guías de envío prepagadas con Tarifa única a todo el país, lo que significa que puedes enviar tus productos a cualquier destino sin preocuparte por tarifas variables.  Pero eso no es todo, ¡nuestra tarifa es la más barata del mercado! Ahorra y optimiza con nuestras guías prepagadas que ofrecen una ayuda invaluable para tu negocio. ¿Tienes una gran cantidad de envíos de manera continua? Estas guías son ideales para ti. Simplifica tus procesos de envío, obtén la tranquilidad de una tarifa fija y la comodidad de un proceso simplificado. ¡Haz que tus envíos sean más rentables y eficientes hoy mismo!'
where RowStatus=1
and Description like '%"%'
and Type ='PAQUETE PETIT'

update[dbo].[CatSubscriptionDescription]
set Description='En caso de que tu envío exceda el peso, +Q1.00 por libra adicional, consulta los términos y condiciones.'
where RowStatus=1
and Description='En caso de que tu envío exceda el peso, +Q1.00 por libra adicional, consulta los terminos y condiciones.'



update [dbo].[CatSubscriptionDescription]
set Description='Compra en la tienda virtual y recibe las guías en tu correo electrónico. Prepara tus paquetes, completa la información de envío y entrégalos en las +90 agencias express center o puedes solicitar la recolección a tu casa u oficina. Rastrea el progreso del envío con el número de guía proporcionado para una experiencia sin complicaciones. Ahorra tiempo y esfuerzo al centrarte en hacer crecer tu negocio mientras nosotros nos encargamos de los detalles logísticos. Adquiere tu Paquete Básico y podrás obtener tus guías prepagadas de 50 envíos con tarifa única a todo el país a Q31.00 c/u.'
where RowStatus=1
and Type ='PLAN BÁSICO'
and Title='¿Cómo Funciona?'