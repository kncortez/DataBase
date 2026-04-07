use DeliveryBackOffice


INSERT INTO dbo.ConfigParams ([Name], Description, Value, Status, CreateDate, IdCountry)
VALUES('EmailByPickupGT',	'Correo Recoleccion Generico Guatemala',	'recolecionesgt@forzadelivery.com',	1,	GETDATE(), 'GT'	),

('EmailByPickupHN',	'Correo Recoleccion Generico Honduras',	'recoleccioneshn@forzadelivery.com',	1,	GETDATE(), 'HN'	),

('EmailByPickupSV',	'Correo Recoleccion Generico El Salvador',	'recoleccionessv@forzadlievery.com',	1,	GETDATE(), 'SV'	)