USE [DeliveryBackOffice]
GO

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [dbo].[CatContainerSubtype] CCS  WITH(NOLOCK)  WHERE CCS.[ContainerSubtypeName] = 'CAJA'  COLLATE Latin1_General_CI_AI  ) )
BEGIN
    
	INSERT INTO [dbo].[CatContainerSubtype]
		(
			[ContainerSubtypeName]
			,[RowStatus]
			,[DateCreated]
			,[TokenCreated]
		)
		VALUES
		(
			'CAJA'
			,1
			,GETDATE()
			,'SYS-ARUIZ'
		)

END

IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [dbo].[CatContainerSubtype] CCS  WITH(NOLOCK)  WHERE CCS.[ContainerSubtypeName] = 'PISO'  COLLATE Latin1_General_CI_AI  ) )
BEGIN
    
	INSERT INTO [dbo].[CatContainerSubtype]
		(
			[ContainerSubtypeName]
			,[RowStatus]
			,[DateCreated]
			,[TokenCreated]
		)
		VALUES
		(
			'PISO'
			,1
			,GETDATE()
			,'SYS-ARUIZ'
		)

END


IF ( NOT EXISTS ( SELECT TOP 1 1 FROM [dbo].[CatContainerSubtype] CCS  WITH(NOLOCK)  WHERE CCS.[ContainerSubtypeName] = 'VIRTUAL'  COLLATE Latin1_General_CI_AI  ) )
BEGIN
    
	INSERT INTO [dbo].[CatContainerSubtype]
		(
			[ContainerSubtypeName]
			,[RowStatus]
			,[DateCreated]
			,[TokenCreated]
		)
		VALUES
		(
			'VIRTUAL'
			,1
			,GETDATE()
			,'SYS-ARUIZ'
		)

END

