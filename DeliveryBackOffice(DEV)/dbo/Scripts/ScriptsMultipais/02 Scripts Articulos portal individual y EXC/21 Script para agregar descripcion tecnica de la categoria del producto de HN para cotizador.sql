
--SE REALIZA ESTE CAMBIO DEBIDO A QUE EN EL COTIZADOR HAY UN  FIx 20250603, 
--EL CUAL NECESITA LA DESCRIPCION

UPDATE DeliveryBackOffice.dbo.CatProductCategory
SET TechnicalDescription = 'Paquetes'
WHERE CatProductCategoryName = 'Guías Prepago' AND IdCountry = 'HN'

UPDATE DeliveryBackOffice.dbo.CatProductCategory
SET TechnicalDescription = 'Planes'
WHERE CatProductCategoryName = 'Planes de Descuento' AND IdCountry = 'HN'

UPDATE DeliveryBackOffice.dbo.CatProductCategory
SET TechnicalDescription = 'Membresías'
WHERE CatProductCategoryName = 'Membresías' AND IdCountry = 'HN'
