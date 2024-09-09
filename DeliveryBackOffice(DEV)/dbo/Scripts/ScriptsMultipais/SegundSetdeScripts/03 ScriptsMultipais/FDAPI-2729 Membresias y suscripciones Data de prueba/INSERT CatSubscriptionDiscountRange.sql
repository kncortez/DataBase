--script pendiente
DECLARE @CatSubscription1 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Básico' AND IdCountry = 'HN')
DECLARE @CatSubscription2 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Plus' AND IdCountry = 'HN')
DECLARE @CatSubscription3 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Gold' AND IdCountry = 'HN')
DECLARE @CatSubscription4 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Plan Amigo' AND IdCountry = 'HN')
DECLARE @CatSubscription5 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Petit' AND IdCountry = 'HN')
DECLARE @CatSubscription6 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Platino' AND IdCountry = 'HN')

INSERT INTO CatSubscriptionDiscountRange (CatSubscriptionId, 
										  DiscountLowServiceRange, 
										  ValueTypeId, 
										  DiscountValue,
										  RowStatus,
										  TokenCreated,
										  DateCreated)

		VALUES(@CatSubscription1, 160.43,1,0.00,1,'SYS-BHERRERA',GETDATE()),
			  (@CatSubscription2, 320.86,1,0.00,1,'SYS-BHERRERA',GETDATE()),
			  (@CatSubscription3, 641.73,1,0.00,1,'SYS-BHERRERA',GETDATE()),
			  (@CatSubscription4, 0,1,10,1,'SYS-BHERRERA',GETDATE()),
			  (@CatSubscription5, 80.22,1,0.00,1,'SYS-BHERRERA',GETDATE()),
			  (@CatSubscription6, 1283.46,1,0.00,1,'SYS-BHERRERA',GETDATE())