DECLARE @IdCatSct INT=(
			SELECT IdCatSubscription 
				FROM CatSubscription 
				WHERE SubscriptionName = 'Paquete Petit')

Insert Into CatSubscriptionDescription (Title, Description, Position, Type, CatSubscriptionId, RowStatus,DateCreated, TokenCreated) Values
('¿Qué es?','Paquete de 25 guías de envío prepagadas con Tarifa única a todo el país. Son ideales para negocios que tienen una gran cantidad de envíos de manera continua.',
1, 'PAQUETE PETIT',@IdCatSct,1,GETDATE(),'ELOPEZ')

Insert Into CatSubscriptionDescription (Title, Description, Position, Type, CatSubscriptionId, RowStatus,DateCreated, TokenCreated) Values
('¿Cómo Funciona?','Adquiere tu Paquete Petit y podrás obtener tus guías prepago de 25 envíos con tarifa única a todo el país a Q32.00 c/u.',
1, 'PAQUETE PETIT',@IdCatSct,2,GETDATE(),'ELOPEZ')

Insert Into CatSubscriptionDescription (Title, Description, Position, Type, CatSubscriptionId, RowStatus,DateCreated, TokenCreated) Values
('Beneficios','Tarifa única a todo el país.;25 guías a Q32 c/u.;No se permite servicio Collect.;Hasta 10 Libras.;+3.5% C.O.D. con ''Acreditamiento Inmediato'';+Q 1.00 libra extra.',
1, 'PAQUETE PETIT',@IdCatSct,3,GETDATE(),'ELOPEZ')