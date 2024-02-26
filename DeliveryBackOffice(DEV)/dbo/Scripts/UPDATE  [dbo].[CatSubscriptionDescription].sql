


-----## Paquete Básico 9

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Paquete de 50 guías de envío prepagadas con Tarifa única a todo el país. Son ideales para negocios que tienen una gran cantidad de envíos de manera continua.',
    Position = 1
WHERE Title='¿Qué es?'
AND CatSubscriptionId=9


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Adquiere tu Paquete Básico y podrás obtener tus guías prepago de 50 envíos con tarifa única a todo el país a Q31.00 c/u.',
    Position = 2
WHERE Title='¿Cómo Funciona?'
AND CatSubscriptionId=9

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='50 guías a Q31 c/u.;  Costo único para todos tus clientes.;  Tarifa única en todo el país.;  La tarifa más barata del mercado.;  Vigencia de 6 meses.',
    Position = 3
WHERE Title='Beneficios'
AND CatSubscriptionId=9

-----## Paquete Plus 10

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Paquete de 100 guías de envío prepagadas con Tarifa única a todo el país. Son ideales para negocios que tienen una gran cantidad de envíos de manera continua.',
    Position = 1
WHERE Title='¿Qué es?'
AND CatSubscriptionId=10


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Adquiere tu Paquete Plus y podrás obtener tus guías prepago de 100 envíos con tarifa única a todo el país a Q29.00 c/u.',
    Position = 2
WHERE Title='¿Cómo Funciona?'
AND CatSubscriptionId=10

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='100 guías a Q29 c/u.;  Costo único para todos tus clientes.;  Tarifa única en todo el país.;  La tarifa más barata del mercado.;  Vigencia de 6 meses.',
    Position = 3
WHERE Title='Beneficios'
AND CatSubscriptionId=10




-----## Paquete gold 11

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Paquete de 200 guías de envío prepagadas con Tarifa única a todo el país. Son ideales para negocios que tienen una gran cantidad de envíos de manera continua.',
    Position = 1
WHERE Title='¿Qué es?'
AND CatSubscriptionId=11


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Adquiere tu Paquete Gold y podrás obtener tus guías prepago de 200 envíos con tarifa única a todo el país a Q27.00 c/u.',
    Position = 2
WHERE Title='¿Cómo Funciona?'
AND CatSubscriptionId=11

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='200 guías a Q27 c/u.;  Costo único para todos tus clientes.;  Tarifa única en todo el país.;  La tarifa más barata del mercado.;  Vigencia de 6 meses.',
    Position = 3
WHERE Title='Beneficios'
AND CatSubscriptionId=11



-----## Plan Amigo 12

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Plan diseñado para brindar 10% de descuento en los envíos a todo el país sobre la tarifa vigente. Este plan está diseñado pra recompensar la lealtad al ofrecer acceso a una mejor tarifa de acuerdo al tipo de servicio y destino.',
    Position = 1
WHERE Title='¿Qué es?'
AND CatSubscriptionId=12


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Adquiere tu Plan Amigos aprovechando la oferta promocional por Q 1.00 (Precio Regular Q 98.00), podras obtener beneficios donde obtienes 10% de descuento en tus envíos a todo el país sobre la tarifa vigente.',
    Position = 2
WHERE Title='¿Cómo Funciona?'
AND CatSubscriptionId=12

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Descuento del 10% en envíos a nivel nacional sobre tarifa vigente.;Precio de acuerdo a tipo de servicio y destino.;  Desde la primer guía, de acuerdo al consumo.;  Permite servicio Collect Q 4.00;  Hasta 10 libras.;  +3.8% C.O.D. con "Acreditamiento Inmediato".;  +Q 1.00 libra extra.',
    Position = 3
WHERE Title='Beneficios'
AND CatSubscriptionId=12


Select * from dbo.CatSubscriptionDescription
where CatSubscriptionId=18
AND RowStatus=1
-----## Plan Petit 18

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Paquete de 25 guías de envío prepagadas con Tarifa única a todo el país. Son ideales para negocios que tienen una gran cantidad de envíos de manera continua.',
    Position = 1
WHERE Title='¿Qué es?'
AND CatSubscriptionId=14


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Adquiere tu Paquete Petit y podrás obtener tus guías prepago de 25 envíos con tarifa única a todo el país a Q33.00 c/u.',
    Position = 2
WHERE Title='¿Cómo Funciona?'
AND CatSubscriptionId=14

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='25 guías a Q33 c/u.;  Costo único para todos tus clientes.;  Tarifa única en todo el país.;  La tarifa más barata del mercado.;  Vigencia de 6 meses.  ',
    Position = 3
WHERE Title='Beneficios'
AND CatSubscriptionId=14



-----## Plan Paquete Platino 19

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Paquete de 400 guías de envío prepagadas con Tarifa única a todo el país. Son ideales para negocios que tienen una gran cantidad de envíos de manera continua.'
WHERE Title='¿Qué es?'
AND CatSubscriptionId=15


UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='Adquiere tu Paquete Platino y podrás obtener tus guías prepago de 400 envíos con tarifa única a todo el país a Q25.00 c/u.',
    Position = 2
WHERE Title='¿Cómo Funciona?'
AND CatSubscriptionId=15

UPDATE  [dbo].[CatSubscriptionDescription]
SET [Description]='400 guías a Q25 c/u.;  Costo único para todos tus clientes.;  Tarifa única en todo el país.;  La tarifa más barata del mercado.;  Vigencia de 6 meses.',
    Position = 3
WHERE Title='Beneficios'
AND CatSubscriptionId=15


-----## Membresía club forza 1

UPDATE  [dbo].[CatMembershipDescription]
SET [Description]='Es un club de beneficios para impulsar a emprendedores y clientes que realizan envíos frecuentes, premiando su preferencia a través de descuentos, beneficios y acceso a paquetes de Guías prepago con tarifa única a todo el pais.',
    Position = 1
WHERE Title='¿Qué es?'
AND CatMembershipId = 1


UPDATE  [dbo].[CatMembershipDescription]
SET [Description]='Adquiere tu membresia por Q 20.00 al Club Forza y podras obtener acumula puntos para envíos gratis y otros beneficios en comercios afiliados.',
    Position = 2
WHERE Title='¿Cómo Funciona?'
AND CatMembershipId = 1

UPDATE  [dbo].[CatMembershipDescription]
SET [Description]='Acumulación de puntos para envíos gratis.;Beneficios en comercios Afiliados;Recolecciones SIN COSTO.;Envío de devoluciones SIN COSTO.;Pagos de reclamo en 24 horas.',
    Position = 3
WHERE Title='¿Qué otros Beneficios obtienes?'
AND CatMembershipId = 1

UPDATE  [dbo].[CatMembershipDescription]
SET [Description]='Puedes comprar el plan amigo que te brinda 10% de descuento en tus envíos ó puedes comprar paquetes de guías prepagadas que más te convenga según el volumen de envíos que realices para obtener precio con tárifa unica a todo el pais.',
    Position = 4
WHERE Title='Disfruta de más beneficios'
AND CatMembershipId = 1





