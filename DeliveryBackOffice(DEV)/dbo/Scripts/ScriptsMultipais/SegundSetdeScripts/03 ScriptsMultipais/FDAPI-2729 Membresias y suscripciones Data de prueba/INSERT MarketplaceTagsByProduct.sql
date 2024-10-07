--pendiente
--7
DECLARE @MarketProduct INT = (SELECT IdMarketplaceProductTags FROM MarketplaceProductTags WHERE MarketplaceProductTagsName = 'TODOS LOS PRODUCTOS' AND IdCountry = 'HN')
--5
DECLARE @MarketProduct2 INT = (SELECT IdMarketplaceProductTags FROM MarketplaceProductTags WHERE MarketplaceProductTagsName = 'LO MÁS VENDIDO' AND IdCountry = 'HN')
--6
DECLARE @MarketProduct3 INT = (SELECT IdMarketplaceProductTags FROM MarketplaceProductTags WHERE MarketplaceProductTagsName = 'NOVEDADES' AND IdCountry = 'HN')

--Suscripciones
--13
DECLARE @CatSubscriptionId INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Básico' AND IdCountry = 'HN')
--14
DECLARE @CatSubscriptionId2 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Plus' AND IdCountry = 'HN')
--17
DECLARE @CatSubscriptionId3 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Petit' AND IdCountry = 'HN')
--15
DECLARE @CatSubscriptionId4 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Gold' AND IdCountry = 'HN')
--18
DECLARE @CatSubscriptionId5 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Paquete Platino' AND IdCountry = 'HN')
--16
DECLARE @CatSubscriptionId6 INT = (SELECT IdCatSubscription FROM CatSubscription WHERE SubscriptionName = 'Plan Amigo' AND IdCountry = 'HN')


--Membresias
DECLARE @CatMembershipId INT = (SELECT IdCatMembership FROM CatMembership WHERE MembershipName = 'Club Forza' AND IdCountry = 'HN')


INSERT INTO MarketplaceTagsByProduct (MarketplaceProductTagsId,RowStatus,TokenCreated,DateCreated, CatSubscriptionId, CatMembershipId, Position)
VALUES(@MarketProduct,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId,NULL,3),	
	  (@MarketProduct2,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId2,NULL,6),
	  (@MarketProduct2,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId3,NULL,2),
	  (@MarketProduct,1,'SYS-BHERRERA',GETDATE(),NULL,@CatMembershipId,3),
	  (@MarketProduct,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId,NULL,3),
	  (@MarketProduct,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId2,NULL,6),
	  (@MarketProduct,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId4,NULL,4),
	  (@MarketProduct3,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId5,NULL,5),
	  (@MarketProduct,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId6,NULL,6),
      (@MarketProduct,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId3,NULL,2),
	  (@MarketProduct,1,'SYS-BHERRERA',GETDATE(),@CatSubscriptionId5,NULL,5)