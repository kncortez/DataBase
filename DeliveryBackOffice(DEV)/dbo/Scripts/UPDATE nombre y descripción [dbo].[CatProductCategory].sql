--- Cambiar el texto de la categoría Paquetes por Guías Prepago
UPDATE [dbo].[CatProductCategory]
SET  CatProductCategoryName = 'Guías Prepago',
     CatProductCategoryDescription='Guías Prepago',
	 TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE() 
WHERE CatProductCategoryName='Paquetes'

--Cambiar el texto de la categoría Planes por Planes de Descuento
UPDATE [dbo].[CatProductCategory]
SET  CatProductCategoryName = 'Planes de Descuento',
     CatProductCategoryDescription='Planes de Descuento',
	 TokenUpdated='SYS-EVASQUEZ',
	  DateUpdated=GETDATE() 
WHERE CatProductCategoryName='Planes'