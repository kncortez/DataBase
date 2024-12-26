-- =============================================
-- Author:      <Juan Ramirez>
-- Create date: <2024-12-19>
-- Description: <Se agregaron indices para el servicio de COD>
-- =============================================
CREATE NONCLUSTERED COLUMNSTORE INDEX NCI_DeliveryOrder
ON DeliveryOrder (idCustomer, VisitPointClientPortfolioId,DateCreated);

CREATE NONCLUSTERED INDEX NCI_DeliveryOrderIsReturn
ON DeliveryOrder (idCustomer, VisitPointClientPortfolioId,DateCreated,IsReturn);
