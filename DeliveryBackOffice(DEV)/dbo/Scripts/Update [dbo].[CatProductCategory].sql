--Actualziar categoria

Update [dbo].[CatProductCategory]
Set CatProductCategoryName='Guías Prepago',
    CatProductCategoryDescription='Guías Prepago',
	TokenUpdated='sys-evasquez',
	DateUpdated=GETDATE()
Where CatProductCategoryName='Paquetes'


Update [dbo].[CatProductCategory]
Set CatProductCategoryName='Planes de Descuento',
    CatProductCategoryDescription='Planes de Descuento',
	TokenUpdated='sys-evasquez',
	DateUpdated=GETDATE()
Where CatProductCategoryName='Planes'