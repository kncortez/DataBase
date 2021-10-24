USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[SetServiceTokenGuideData]    Script Date: 19/10/2021 12:31:34 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[SetServiceTokenGuideData]
@GuideSerie NVARCHAR(2) = '',
@GuideNumber INT = -1,
@GuideToken NVARCHAR(50),
@Latitude DECIMAL(18,15),
@Longitude DECIMAL(18,15),
@StartTime NVARCHAR(20),
@EndTime NVARCHAR(20),

@NewProvince NVARCHAR(100) = '',
@NewTown NVARCHAR(100) = '',
@NewZone NVARCHAR(100) = '',
@NewAddress NVARCHAR(600) = '',
@NewTownshipID INT = -1,
@NewSettlementID BIGINT = -1

AS
BEGIN
	DECLARE @UpdatedSDFG BIT = 0;
	DECLARE @UpdatedDO BIT = 0;

	BEGIN TRANSACTION
	BEGIN TRY
		UPDATE [dbo].[ServiceDataForGuide]
		SET 
			DateUsed = GETDATE(),
			Latitude = @Latitude,
			Longitude = @Longitude,
			ProviderModule = (SELECT [ModIdModule] FROM [CatModule] WHERE [ModName]LIKE'%Landing Delivery Page%'),
			StartTime = CAST( @StartTime AS TIME ),
			EndTime= CAST ( @EndTime AS TIME ),
			TokenUpdated = 'SYS-HERMESROUTESLanding',
			DateUpdated = GETDATE()
		FROM [dbo].[ServiceDataForGuide] SDFG
		INNER JOIN [dbo].[DeliveryOrder] DO
		ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
		WHERE SDFG.GuideToken = @GuideToken
		--AND SDFG.GuideSerie = @GuideSerie
		--AND SDFG.GuideNumber = @GuideNumber
		AND DO.StatusOrderId IN (1,2,10,11,15) -- Solicitado, Recolectado, En Inventario, Arribó a las instalaciones, Generado

		IF @@ROWCOUNT > 0
		BEGIN
			SET @UpdatedSDFG = 1
		END
		
		-- FLUJO SI ES ENTREGA 
		IF(ISNULL(@NewProvince,'')!='' AND ISNULL(@NewTown,'')!='' AND ISNULL(@NewAddress,'')!='' AND ISNULL(@NewTownshipID,-1)!=-1 )
		BEGIN
			UPDATE [dbo].[DeliveryOrder]
			SET 
				Receiver_Address = @NewAddress,
				Receiver_Department = @NewProvince,
				Receiver_Town = @NewTown,
				ReceiverIdTownship = @NewTownshipID,
				Receiver_Zone = IIF( ISNULL(@NewZone,'')!='', @NewZone, Receiver_Zone ),
				ReceiverIdSettlement = IIF( ISNULL(@NewSettlementID,-1)!=-1,@NewSettlementID,ReceiverIdSettlement)
			FROM [dbo].[ServiceDataForGuide] SDFG
			INNER JOIN [dbo].[DeliveryOrder] DO
			ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
			WHERE SDFG.GuideToken = @GuideToken
			--AND DO.Guide_Number = @GuideNumber
			--AND DO.Guide_Serie = @GuideSerie
			AND SDFG.IsDelivery = 1
		END

		IF @@ROWCOUNT > 0
		BEGIN
			SET @UpdatedDO = 1
		END

		IF (@UpdatedSDFG = 0)
		BEGIN
			DECLARE @jsonResultError NVARCHAR(MAX) 
			set @jsonResultError =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Error":"No se actualizaron los datos"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResultError +  ']') jsonResultError 
			ROLLBACK TRANSACTION;
		END

	END TRY
	BEGIN CATCH
		DECLARE @jsonResultError2 NVARCHAR(MAX) 
		set @jsonResultError2 =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":500,' 
							+ '"Error":"'+ERROR_MESSAGE()+'"}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResultError2 +  ']') jsonResultError2 
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


