USE DeliveryBackOffice
GO

BEGIN TRANSACTION
BEGIN TRY

	INSERT INTO [dbo].[CatProductImage]
			   ([CatProductImageSmallImageURL]
			   ,[CatProductImageLargeImageURL]
			   ,[CatProductImageOrder]
			   ,[RowStatus]
			   ,[TokenCreated]
			   ,[DateCreated]
			   ,[TokenUpdated]
			   ,[DateUpdated]
			   ,[CatSubscriptionId]
			   ,[CatMembershipId]
			   ,[CatProductImageBigImageURL]
			   ,[CatProductImageXXXLImageURL])
		 VALUES

	--INSERT INTO CatProductImage VALUES
	('https://forzadelivery.com/images/Tienda/basicoh-500-347.jpg'	,'https://forzadelivery.com/images/Tienda/basicoh-1200-722.jpg'		,1	,1		,'SYS-BHERRERA'	,GETDATE(),	NULL	,NULL	,13		,NULL	,'https://forzadelivery.com/images/Tienda/basicoh-2103-521.jpg'		,NULL),
	('https://forzadelivery.com/images/Tienda/goldh-500-347.jpg'		,'https://forzadelivery.com/images/Tienda/goldh-1200-722.jpg'	,2	,1		,'SYS-BHERRERA'	,GETDATE(),	NULL	,NULL	,15		,NULL	,'https://forzadelivery.com/images/Tienda/goldh-2103-521.jpg'		,NULL),
	('https://forzadelivery.com/images/Tienda/plush-500-347.jpg'		,'https://forzadelivery.com/images/Tienda/plush-1200-722.jpg'	,3	,1		,'SYS-BHERRERA'	,GETDATE(),	NULL	,NULL	,14		,NULL	,'https://forzadelivery.com/images/Tienda/plus-2103-521.jpg'		,NULL),
	('https://forzadelivery.com/images/Tienda/clubh-500-347.jpg'		,'https://forzadelivery.com/images/Tienda/clubh-1200-722.jpg'	,4	,1		,'SYS-BHERRERA'	,GETDATE(),	NULL	,NULL	,NULL	,3		,'https://forzadelivery.com/images/Tienda/clubh-2103-521.jpg'		,NULL),
	('https://forzadelivery.com/images/Tienda/petith-500-347.jpg'	,'https://forzadelivery.com/images/Tienda/petit-1200-722.jpg'		,5	,1		,'SYS-BHERRERA'	,GETDATE(),	NULL	,NULL	,17		,NULL	,'https://forzadelivery.com/images/Tienda/petith-2103-521.jpg'		,NULL),
	('https://forzadelivery.com/images/Tienda/amigoh-500-347.jpg'	,'https://forzadelivery.com/images/Tienda/amigoh-1200-722.jpg'		,6	,1		,'SYS-BHERRERA'	,GETDATE(),	NULL	,NULL	,16		,NULL	,'https://forzadelivery.com/images/Tienda/amigoh-2103-521.jpg'		,NULL),
	('https://forzadelivery.com/images/Tienda/platinoh-500-347.jpg'	,'https://forzadelivery.com/images/Tienda/platinoh-1200-722.jpg'	,7	,1		,'SYS-BHERRERA'	,GETDATE(),	NULL	,NULL	,18		,NULL	,'https://forzadelivery.com/images/Tienda/platinoh-2103-521.jpg'	,NULL),
	('https://forzadelivery.com/images/Tienda/pro-500-347.jpg'		,'https://forzadelivery.com/images/Tienda/pro-1200-722.jpg'			,8	,1		,'SYS-AIXCHOP'	,GETDATE(),	NULL	,NULL	,20		,NULL	,'https://forzadelivery.com/images/Tienda/pro-2103-521.jpg'			,NULL)
	COMMIT TRANSACTION;
END TRY
BEGIN CATCH
	SELECT ERROR_MESSAGE()
	ROLLBACK TRANSACTION
END CATCH


	