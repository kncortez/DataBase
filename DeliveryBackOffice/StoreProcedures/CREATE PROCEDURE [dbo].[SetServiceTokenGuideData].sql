
CREATE PROCEDURE [dbo].[SetServiceTokenGuideData]
@GuideSerie NVARCHAR(2),
@GuideNumber INT,
@GuideToken NVARCHAR(50),
@Latitude DECIMAL(18,15),
@Longitude DECIMAL(18,15),
@StartTime NVARCHAR(10),
@EndTime NVARCHAR(10)
AS
BEGIN
	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE [dbo].[ServiceDataForGuide]
		SET DateUsed = GETDATE(),
		Latitude = @Latitude,
		Longitude = @Longitude,
		startTime = CAST( @StartTime AS TIME ),
		endTime = CAST ( @EndTime AS TIME )
		WHERE Guide_Token = @GuideToken
		AND Guide_Serie = @GuideSerie
		AND Guide_Number = @GuideNumber
		AND endTime IS NULL
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
							+ '"Message":"'+ERROR_MESSAGE()+'"}' 
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
GO


