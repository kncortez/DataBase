DECLARE @IdCatSct INT=(
			SELECT IdCatSubscription 
				FROM CatSubscription 
				WHERE SubscriptionName = 'Paquete Petit')

Insert into CatSubscriptionAtribute (CatSubscriptionId, CatAttributeId, SubscriptionAttributeValue,
SubscriptionAttributeDescription,SubscriptionAttributePosition,RowStatus, TokenCreated, DateCreated,SubscriptionAttributeDescriptionLong)values
(@IdCatSct,1,1,'25 envíos incluidos </br> Q.32 cada uno.',1,1,'ELOPEZ',GETDATE(),'25 envíos incluidos </br> Q.32 cada uno.')

Insert into CatSubscriptionAtribute (CatSubscriptionId, CatAttributeId, SubscriptionAttributeValue,
SubscriptionAttributeDescription,SubscriptionAttributePosition,RowStatus, TokenCreated, DateCreated,SubscriptionAttributeDescriptionLong)values
(@IdCatSct,1,1,'Tarifa única a todo el país.',2,1,'ELOPEZ',GETDATE(),'Tarifa única a todo el país.')

Insert into CatSubscriptionAtribute (CatSubscriptionId, CatAttributeId, SubscriptionAttributeValue,
SubscriptionAttributeDescription,SubscriptionAttributePosition,RowStatus, TokenCreated, DateCreated,SubscriptionAttributeDescriptionLong)values
(@IdCatSct,1,1,'No se permite servicio Collect.',3,1,'ELOPEZ',GETDATE(),'No se permite servicio Collect.')

Insert into CatSubscriptionAtribute (CatSubscriptionId, CatAttributeId, SubscriptionAttributeValue,
SubscriptionAttributeDescription,SubscriptionAttributePosition,RowStatus, TokenCreated, DateCreated,SubscriptionAttributeDescriptionLong)values
(@IdCatSct,1,1,'Hasta 10 Libras.',4,1,'ELOPEZ',GETDATE(),'Hasta 10 Libras.')

Insert into CatSubscriptionAtribute (CatSubscriptionId, CatAttributeId, SubscriptionAttributeValue,
SubscriptionAttributeDescription,SubscriptionAttributePosition,RowStatus, TokenCreated, DateCreated,SubscriptionAttributeDescriptionLong)values
(@IdCatSct,1,1,'+3.5% C.O.D. con ''Acreditamiento Inmediato''',5,1,'ELOPEZ',GETDATE(),'+3.5% C.O.D. con ''Acreditamiento Inmediato''')

Insert into CatSubscriptionAtribute (CatSubscriptionId, CatAttributeId, SubscriptionAttributeValue,
SubscriptionAttributeDescription,SubscriptionAttributePosition,RowStatus, TokenCreated, DateCreated,SubscriptionAttributeDescriptionLong)values
(@IdCatSct,1,1,' +Q 1.00 libra extra.',6,1,'ELOPEZ',GETDATE(),' +Q 1.00 libra extra.')