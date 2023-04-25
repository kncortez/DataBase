USE [DeliveryBackOffice];
GO

-- Dar de baja a incidencias de entrega anteriores
UPDATE
	[CTI]
SET
	[CTI].[RowStatus] = 0
	,[CTI].[TokenUpdated] = 'SYS-ARUIZ'
	,[CTI].[DateUpdated] = GETDATE()
FROM
	[DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) 
WHERE
	[CTI].[ServiceType] = 'DELIVERY'  COLLATE Latin1_General_CI_AI 

-- Nuevas incidencias de entrega
IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Datos de dirección de entrega incorrectos'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Datos de dirección de entrega incorrectos',      -- NameIncidence - varchar(200)
		'Datos de dirección de entrega incorrectos',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		0,   -- IsForcedIncidence - bit
		1,   -- ValidatesLocation - bit
		1,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)

END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'No hay nadie en destino'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'No hay nadie en destino',      -- NameIncidence - varchar(200)
		'No hay nadie en destino',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		0,   -- IsForcedIncidence - bit
		1,   -- ValidatesLocation - bit
		1,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)

END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Destinatario solicita otra fecha de entrega'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Destinatario solicita otra fecha de entrega',      -- NameIncidence - varchar(200)
		'Destinatario solicita otra fecha de entrega',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		0,   -- IsForcedIncidence - bit
		1,   -- ValidatesLocation - bit
		1,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)

END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Destinatario no presentó documento de identificación'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Destinatario no presentó documento de identificación',      -- NameIncidence - varchar(200)
		'Destinatario no presentó documento de identificación',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		0,   -- IsForcedIncidence - bit
		1,   -- ValidatesLocation - bit
		1,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)

END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Tiempo de espera excedido'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Tiempo de espera excedido',      -- NameIncidence - varchar(200)
		'Tiempo de espera excedido',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		0,   -- IsForcedIncidence - bit
		1,   -- ValidatesLocation - bit
		1,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)

END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Destinatario rechaza paquete'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Destinatario rechaza paquete',      -- NameIncidence - varchar(200)
		'Destinatario rechaza paquete',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		0,   -- IsForcedIncidence - bit
		0,   -- ValidatesLocation - bit
		1,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)
    
END


IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Remitente solicita devolución'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Remitente solicita devolución',      -- NameIncidence - varchar(200)
		'Remitente solicita devolución',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		1,   -- IsForcedIncidence - bit
		0,   -- ValidatesLocation - bit
		0,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)

END


IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Envío fuera de ruta'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Envío fuera de ruta',      -- NameIncidence - varchar(200)
		'Envío fuera de ruta',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		1,   -- IsForcedIncidence - bit
		0,   -- ValidatesLocation - bit
		0,   -- HasConfirmationProcess - bit
		0    -- NotifiesOrigin - bit
	)

END


IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Paquete dañado'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Paquete dañado',      -- NameIncidence - varchar(200)
		'Paquete dañado',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		1,   -- IsForcedIncidence - bit
		0,   -- ValidatesLocation - bit
		0,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)

END


IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Paquete extraviado'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN

	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Paquete extraviado',      -- NameIncidence - varchar(200)
		'Paquete extraviado',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		1,   -- IsForcedIncidence - bit
		0,   -- ValidatesLocation - bit
		0,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)
    
END


IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'No dio tiempo a realizar la entrega'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'No dio tiempo a realizar la entrega',      -- NameIncidence - varchar(200)
		'No dio tiempo a realizar la entrega',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		1,   -- IsForcedIncidence - bit
		0,   -- ValidatesLocation - bit
		0,   -- HasConfirmationProcess - bit
		0    -- NotifiesOrigin - bit
	)

END


IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) WHERE [CTI].[NameIncidence] = 'Cliente solicita entrega en un express center'  COLLATE Latin1_General_CI_AI AND [CTI].[RowStatus] = 1 AND [CTI].[ServiceType] = 'DELIVERY' ) )
BEGIN
    
	INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
	(
		[NameIncidence],
		[DescriptionIncidence],
		[RowStatus],
		[TokenCreated],
		[DateCreated],
		[TokenUpdated],
		[DateUpdated],
		[ServiceType],
		[OrderId],
		[Code],
		[IncidenceClasificationId],
		[IsForcedIncidence],
		[ValidatesLocation],
		[HasConfirmationProcess],
		[NotifiesOrigin]
	)
	VALUES
	(   
		'Cliente solicita entrega en un express center',      -- NameIncidence - varchar(200)
		'Cliente solicita entrega en un express center',      -- DescriptionIncidence - varchar(200)
		1,      -- RowStatus - bit
		'SYS-ARUIZ',        -- TokenCreated - varchar(50)
		GETDATE(), -- DateCreated - datetime
		NULL,      -- TokenUpdated - varchar(50)
		NULL,      -- DateUpdated - datetime
		'DELIVERY',      -- ServiceType - nvarchar(25)
		1,      -- OrderId - int
		NULL,      -- Code - int
		NULL,      -- IncidenceClasificationId - int
		0,   -- IsForcedIncidence - bit
		0,   -- ValidatesLocation - bit
		1,   -- HasConfirmationProcess - bit
		1    -- NotifiesOrigin - bit
	)

END
