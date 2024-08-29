
--SE REALIZA ESTE CAMBIO DEBIDO A QUE EN EL COTIZADOR HAY UN  FIx 20250603, EL CUAL NECESITA LA DESCRIPCION
--FECHA DE CAMBIO 8/8/2024
--SE LE AVISO A DON EDELMAN DEL CAMBIO YA QUE EL INGRESO EL DATO

UPDATE DeliveryBackOffice.dbo.CatProductCategory
SET TechnicalDescription = 'Paquetes'
WHERE IdCatProductCategory = 9

-- SE AGREGO 20/08/2024 PARA MODIFICAR LOS PLANES Y MEMBRESIAS

UPDATE DeliveryBackOffice.dbo.CatProductCategory
SET TechnicalDescription = 'Planes'
WHERE IdCatProductCategory = 10

UPDATE DeliveryBackOffice.dbo.CatProductCategory
SET TechnicalDescription = 'Membresías'
WHERE IdCatProductCategory = 8

