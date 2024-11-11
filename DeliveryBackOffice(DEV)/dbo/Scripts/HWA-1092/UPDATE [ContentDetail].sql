UPDATE cd set ContentDetailPageURL = 'https://forzadelivery.com/gt/servicio-de-agencia-a-agencia/'
-- SELECT * 
FROM [DeliveryBackOffice].[dbo].[ContentDetail] cd
	INNER JOIN [DeliveryBackOffice].[dbo].[ContentTitle] ct
		ON cd.ContentTitleId = ct.IdContentTitle
WHERE ct.CountryId = 'GT'
	AND cd.ContentDetailTitle = 'Servicio Agencia - Agencia'

UPDATE cd set ContentDetailPageURL = 'https://forzadelivery.com/gt/material-de-empaque/'
--SELECT * 
FROM [DeliveryBackOffice].[dbo].[ContentDetail] cd
	INNER JOIN [DeliveryBackOffice].[dbo].[ContentTitle] ct
		ON cd.ContentTitleId = ct.IdContentTitle
WHERE ct.CountryId = 'GT'
	AND cd.ContentDetailTitle = 'Material de Empaque'

UPDATE cd set ContentDetailPageURL = 'https://forzadelivery.com/hn/servicio-de-agencia-a-agencia/'
--SELECT * 
FROM [DeliveryBackOffice].[dbo].[ContentDetail] cd
	INNER JOIN [DeliveryBackOffice].[dbo].[ContentTitle] ct
		ON cd.ContentTitleId = ct.IdContentTitle
WHERE ct.CountryId = 'HN'
	AND cd.ContentDetailTitle = 'Servicio Agencia - Agencia'

UPDATE cd set ContentDetailPageURL = 'https://forzadelivery.com/hn/material-de-empaque/'
--SELECT *  
FROM [DeliveryBackOffice].[dbo].[ContentDetail] cd
	INNER JOIN [DeliveryBackOffice].[dbo].[ContentTitle] ct
		ON cd.ContentTitleId = ct.IdContentTitle
WHERE ct.CountryId = 'HN'
	AND cd.ContentDetailTitle = 'Material de Empaque'