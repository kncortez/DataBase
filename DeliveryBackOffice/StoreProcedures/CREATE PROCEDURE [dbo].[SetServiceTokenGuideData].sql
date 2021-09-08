USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[SetServiceTokenGuideData]    Script Date: 08/09/2021 14:20:52 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[SetServiceTokenGuideData]
@GuideSerie NVARCHAR(2),
@GuideNumber INT,
@GuideToken NVARCHAR(50),
@Latitude DECIMAL(18,15),
@Longitude DECIMAL(18,15),
@StartTime NVARCHAR(20),
@EndTime NVARCHAR(20)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE [dbo].[ServiceDataForGuide]
		SET DateUsed = GETDATE(),
			Latitude = @Latitude,
			Longitude = @Longitude,
			ProviderModule = (SELECT [ModIdModule] FROM [CatModule] WHERE [ModName]LIKE'%Landing Delivery Page%'),
			StartTime = CAST( @StartTime AS DATETIME ),
			EndTime= CAST ( @EndTime AS DATETIME )
		FROM [dbo].[ServiceDataForGuide] SDFG
		INNER JOIN [dbo].[DeliveryOrder] DO
		ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
		WHERE SDFG.GuideToken = @GuideToken
		AND SDFG.GuideSerie = @GuideSerie
		AND SDFG.GuideNumber = @GuideNumber
		AND DO.StatusOrderId IN (1,2,10,11,15) -- Solicitado, Recolectado, En Inventario, Arribó a las instalaciones, Generado
		IF @@ROWCOUNT = 0
		BEGIN
		DECLARE @jsonResult2 NVARCHAR(MAX) 
			set @jsonResult2 =(
								SELECT STUFF(( 
								SELECT ',{"IdResult":400,' 
								+ '"Error":"Datos de guía ya expiraron."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResult2 +  ']') jsonResult 
			ROLLBACK TRANSACTION;
		END
	END TRY
	BEGIN CATCH
		DECLARE @jsonResultErrror NVARCHAR(MAX) 
		set @jsonResultErrror =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":500,' 
							+ '"Error":"'+ERROR_MESSAGE()+'"}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResultErrror +  ']') jsonResultErrror 
		ROLLBACK TRANSACTION;
	END CATCH
	IF @@TRANCOUNT > 0
	BEGIN
		COMMIT TRANSACTION;
		DECLARE @jsonResult NVARCHAR(MAX) 
		set @jsonResult =(
							SELECT STUFF(( 
							SELECT ',{"IdResult":200,' 
							+ '"Success":"Exito ingresando datos de entrega."}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResult +  ']') jsonResult 
	END
END