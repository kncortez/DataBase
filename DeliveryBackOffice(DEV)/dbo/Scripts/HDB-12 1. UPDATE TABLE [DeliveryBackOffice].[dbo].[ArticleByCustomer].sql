UPDATE
	ABC
SET
	ABC.MassWeight = 60,
	ABC.AbcTokenCreated = 'SYS-ARUIZ',
	ABC.AbcDateUpdated = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[ArticleByCustomer] ABC WITH(NOLOCK)
WHERE
	ABC.Code LIKE 'EXP%'
	AND
	ABC.Code NOT IN (
		'EXP080',
		'EXP079',
		'EXP078',
		'EXP077',
		'EXP076'
	)
	