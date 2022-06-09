
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-11-02>
-- Description:	< Devuelve el listado de piezas de lote de servicios para un servicio (actualmente solo servicios de recolección) >
-- =============================================

CREATE PROCEDURE [dbo].[GetServiceBatchStatus]
	@IdServiceBatch INT = 0,
	@CourierToken NVARCHAR(50) = '',
	@PageNumber INT = 1
AS
BEGIN
	-- Asegurar minimo de pagina
	IF (@PageNumber <= 0)
	BEGIN
		SET @PageNumber = 1
	END

	-- Json de salida
	DECLARE @JsonResult VARCHAR(MAX) = ''

	-- Variables de lote de servicios
	DECLARE @BatchExists BIT = ISNULL(( SELECT 1 FROM DeliveryBackOffice.dbo.ServiceBatch SB WHERE SB.IdServiceBatch = @IdServiceBatch ), 0)
	DECLARE @BatchStatus BIT = 0;
	DECLARE @BatchCount INT = 0;

	-- Variables para verificación de Courierman
	DECLARE @TokenStatus INT  = (SELECT TOP 1 RowStatus FROM LogTokenPOD WHERE LogTokenPOD LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)
	DECLARE @TokenLife INT = (SELECT TOP 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) FROM LogTokenPOD WHERE LogTokenPOD  LIKE '%' + @CourierToken + '%' ORDER BY DateCreated DESC)

	IF (@TokenStatus = 1 AND @TokenLife <= 8)
	BEGIN
		BEGIN TRY
			IF (@BatchExists = 1)
			BEGIN
				SET @BatchStatus =	ISNULL((
										SELECT SB.RowStatus FROM [DeliveryBackOffice].[dbo].[ServiceBatch] SB WHERE SB.IdServiceBatch = @IdServiceBatch
									),0)
				IF (@BatchStatus = 1)
				BEGIN
					DECLARE @PageOffset INT = (@PageNumber - 1) * 25
					SET @JsonResult =	(
											SELECT STUFF(( 
												SELECT  
												',{' + 
												'"Id":"' + CAST( CONCAT( SBD.GuideSerie, CAST(SBD.GuideNumber AS NVARCHAR), '-', SBD.PieceNumber ) AS NVARCHAR ) + '"' +
												+ '}'
												FROM [dbo].[ServiceBatchDetail] SBD
												JOIN [dbo].[ServiceBatch] SB
												ON SBD.ServiceBatchId = SB.IdServiceBatch
												WHERE SBD.ServiceBatchId = @IdServiceBatch
												AND SBD.RowStatus = 1
												AND SB.RowStatus = 1
												ORDER BY SBD.IdServiceBatchDetail ASC
												OFFSET @PageOffset ROWS FETCH NEXT 25 ROWS ONLY
												FOR XML PATH(''), TYPE
											).value('.', 'varchar(max)'),1,1,'')
										)
					SELECT ('[' + @JsonResult +  ']') JsonResult 
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
				END
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
		END CATCH
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