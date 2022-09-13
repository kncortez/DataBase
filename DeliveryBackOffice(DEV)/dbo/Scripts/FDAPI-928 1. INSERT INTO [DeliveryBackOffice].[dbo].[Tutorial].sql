IF (NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Tutorial] Tut WITH(NOLOCK) WHERE Tut.TutorialName = 'Creación de guías' COLLATE Latin1_General_CI_AI AND Tut.RowStatus = 1))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[Tutorial]
		(TutorialName, TutorialDescription, DateCreated,TokenCreated)
	VALUES
		('Creación de guías', 'Tutorial de creación de guías estándar y estándar COD en portal web', GETDATE(), 'SYS-ARUIZ')

END

IF (NOT EXISTS (SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[Tutorial] Tut WITH(NOLOCK) WHERE Tut.TutorialName = 'Guía de nuevo portal' COLLATE Latin1_General_CI_AI AND Tut.RowStatus = 1))
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[Tutorial]
		(TutorialName, TutorialDescription, DateCreated,TokenCreated)
	VALUES
		('Guía de nuevo portal', 'Tutorial inicial de nuevo portal web', GETDATE(), 'SYS-ARUIZ')

END