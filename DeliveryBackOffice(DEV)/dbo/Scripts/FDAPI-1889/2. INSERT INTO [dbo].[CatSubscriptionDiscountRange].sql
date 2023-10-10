DECLARE @IdCatSct INT=(
			SELECT IdCatSubscription 
				FROM CatSubscription 
				WHERE SubscriptionName = 'Paquete Petit')

Insert into CatSubscriptionDiscountRange (CatSubscriptionId,DiscountLowServiceRange,ValueTypeId,DiscountValue,RowStatus, TokenCreated, DateCreated)
values(@IdCatSct,25,1,0,1,'ELOPEZ',GETDATE())
