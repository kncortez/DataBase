
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-11-02>
-- Description:	< Devuelve el id de lote de servicios para un servicio o lo genera de ser necesario (actualmente solo servicios de recolección) >
-- =============================================

CREATE PROCEDURE [dbo].[SetServiceCheckIn]
	@IdServiceManagement INT = 0,
	@CourierToken NVARCHAR(50) = '',
	@ServiceType NVARCHAR(20) = ''
AS
BEGIN
	-- Json de salida
	DECLARE @JsonResult VARCHAR(MAX) = ''

	-- Variables de lote de servicios
	DECLARE @BatchExists BIT = ISNULL(( SELECT 1 FROM DeliveryBackOffice.dbo.ServiceBatch SB WHERE SB.ServiceManagementId = @IdServiceManagement ),0)
	DECLARE @BatchId INT = 0;
	DECLARE @BatchStatus BIT = 0;
	DECLARE @BatchCount INT = 0;

	-- Variables para verificación de Courierman
	DECLARE @TokenStatus INT  = (SELECT TOP 1 RowStatus FROM LogTokenPOD WHERE LogTokenPOD LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)
	DECLARE @TokenLife INT = (SELECT TOP 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) FROM LogTokenPOD WHERE LogTokenPOD  LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)

	IF (@TokenStatus = 1 AND @TokenLife <= 8)
	BEGIN
		BEGIN TRANSACTION
			BEGIN TRY
				IF (@BatchExists = 1)
				BEGIN
					SET @BatchStatus =	ISNULL((
											SELECT SB.RowStatus FROM [DeliveryBackOffice].[dbo].[ServiceBatch] SB WHERE SB.ServiceManagementId = @IdServiceManagement
										),0)
					IF(@BatchStatus = 1)
					BEGIN
						SET @BatchId =	ISNULL((
											SELECT SB.IdServiceBatch FROM [DeliveryBackOffice].[dbo].[ServiceBatch] SB WHERE SB.ServiceManagementId = @IdServiceManagement AND SB.RowStatus = 1
										),0)
						SET @BatchCount =	ISNULL((
											SELECT COUNT(*) 
											FROM [DeliveryBackOffice].[dbo].[ServiceBatchDetail] SBD 
											JOIN [DeliveryBackOffice].[dbo].[ServiceBatch] SB
											ON
											SBD.ServiceBatchId = SB.IdServiceBatch
											WHERE SBD.ServiceBatchId = @BatchId AND SBD.RowStatus = 1 AND SB.RowStatus = 1
										),0)
					END
				END
				ELSE
				BEGIN

					INSERT INTO DeliveryBackOffice.dbo.ServiceBatch(
						ServiceManagementId,
						RowStatus,
						TokenCreated,
						DateCreated
					)
					VALUES(
						@IdServiceManagement,
						1,
						@CourierToken,
						GETDATE()
					)

					SET @BatchStatus = 1;
					SET @BatchId =	ISNULL((
										SELECT SB.IdServiceBatch FROM [DeliveryBackOffice].[dbo].[ServiceBatch] SB WHERE SB.ServiceManagementId = @IdServiceManagement AND SB.RowStatus = 1
									),0)
					SET @BatchCount =	ISNULL((
											SELECT COUNT(*) 
											FROM [DeliveryBackOffice].[dbo].[ServiceBatchDetail] SBD 
											JOIN [DeliveryBackOffice].[dbo].[ServiceBatch] SB
											ON
											SBD.ServiceBatchId = SB.IdServiceBatch
											WHERE SBD.ServiceBatchId = @BatchId AND SBD.RowStatus = 1 AND SB.RowStatus = 1
										),0)
				END
			END TRY
			BEGIN CATCH
				SET @JsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":500,' 
									+ '"Message":"Error en la transacción."}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
				ROLLBACK TRANSACTION;
			END CATCH

			IF (@BatchStatus = 1)
			BEGIN
				IF(@BatchId > 0)
				BEGIN
					COMMIT TRANSACTION;
					SET @JsonResult =	(
											SELECT STUFF(( 
												SELECT  
												',{"IdResult":200' + ',' +
												'"IdServiceBatch":' + CAST( @BatchId AS NVARCHAR ) + ',' +
												'"PiecesCount":'+ CAST( @BatchCount AS NVARCHAR ) + '' +
												+ '}'

												FOR XML PATH(''), TYPE
											).value('.', 'varchar(max)'),1,1,'')
										)
					SELECT ('[' + @JsonResult +  ']') JsonResult 
				END
				ELSE
				BEGIN
					SET @JsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":404,' 
									+ '"Message":"No existe lote de servicios."}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
					SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
					ROLLBACK TRANSACTION;
				END
			END
			ELSE
			BEGIN
				SET @JsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":406,' 
								+ '"Message":"Lote de servicios ya fue procesado."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
				SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
				ROLLBACK TRANSACTION;
			END
		--END TRANSACTION
	END
	ELSE
	BEGIN
		SET @JsonResult =(
						SELECT STUFF(( 
						SELECT '{{"IdResult":401,' 
						+ '"Message":"Token de repartidor expirado."}' 
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,'') )
		SELECT ('[' + @JsonResult +  ']') ErrorJsonResult 
	END
END