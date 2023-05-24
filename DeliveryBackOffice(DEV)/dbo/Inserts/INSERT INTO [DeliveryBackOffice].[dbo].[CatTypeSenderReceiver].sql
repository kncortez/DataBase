IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeSenderReceiver] CTSR  WITH(NOLOCK) WHERE [CTSR].[TypeName] = 'SUPERVISOR DE RUTA'  COLLATE Latin1_General_CI_AI  ) )
BEGIN

	INSERT INTO	[DeliveryBackOffice].[dbo].[CatTypeSenderReceiver]
	(
		[TypeName],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated]
	)
	VALUES
	(   
		N'SUPERVISOR DE RUTA',       -- TypeName - nvarchar(30)
		1,      -- RowStatus - bit
		N'SYS-ARUIZ',       -- TokenCreated - nvarchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - nvarchar(50)
		NULL       -- DateUpdated - datetime
	)
    
END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeSenderReceiver] CTSR  WITH(NOLOCK) WHERE [CTSR].[TypeName] = 'JEFE DE RUTA'  COLLATE Latin1_General_CI_AI  ) )
BEGIN

	INSERT INTO	[DeliveryBackOffice].[dbo].[CatTypeSenderReceiver]
	(
		[TypeName],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated]
	)
	VALUES
	(   
		N'JEFE DE RUTA',       -- TypeName - nvarchar(30)
		1,      -- RowStatus - bit
		N'SYS-ARUIZ',       -- TokenCreated - nvarchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - nvarchar(50)
		NULL       -- DateUpdated - datetime
	)

END


IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeSenderReceiver] CTSR  WITH(NOLOCK) WHERE [CTSR].[TypeName] = 'CUSTODIO'  COLLATE Latin1_General_CI_AI  ) )
BEGIN
    
	INSERT INTO	[DeliveryBackOffice].[dbo].[CatTypeSenderReceiver]
	(
		[TypeName],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated]
	)
	VALUES
	(   
		N'CUSTODIO',       -- TypeName - nvarchar(30)
		1,      -- RowStatus - bit
		N'SYS-ARUIZ',       -- TokenCreated - nvarchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - nvarchar(50)
		NULL       -- DateUpdated - datetime
	)

END