-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Obtiene datos basicos para actualizar la ubicación de un servicio de entrega para una guía en landing page.>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Cambio de flujo para retornar enlace de tracking y mejora de mensaje cuando guía esta en estado no actualizable.>
-- =============================================

CREATE PROCEDURE [dbo].[GetServiceTokenGuide]
	@GuideSerie NVARCHAR(2) = '',
	@GuideNumber INT = -1,
	@GuideToken NVARCHAR(50)
AS
BEGIN
	-- Variables de control de flujo
	DECLARE @IsDelivery AS BIT = 0;
	DECLARE @IsPickup AS BIT = 0;
	DECLARE @IsVisitPoint AS BIT = 0;
	DECLARE @VisitPointExists AS BIT = 0;

	-- Variables de respuesta
	DECLARE @jsonResult NVARCHAR(MAX);

	SET @IsDelivery = (
		SELECT [IsDelivery] 
		FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
		WHERE SDFG.GuideToken = @GuideToken
	);

	IF (@IsDelivery = 1) -- Servicio es de entrega
	BEGIN
		BEGIN TRY
			set @jsonResult = (SELECT STUFF(( 
								SELECT  
								',{"IdResult":200,"receiverAddress":"' +  DO.Receiver_Address + '",' +
								'"serviceType":"Delivery"' + ',' +
								'"updatedData":' + IIF( SDFG.DateUsed IS NULL, '0', '1') + ',' +
								'"trackingForza":"https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) + '/",' +
								'"Province":"'+ DO.Receiver_Department + '",' +
								'"Township":"'+ DO.Receiver_Town + '",' +
								'"deliveryType":"'+ ISNULL(DO.TypeService,'TDA') + '"' +
								+ '}'

								FROM [dbo].[DeliveryOrder] DO WITH(NOLOCK)
								INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
								ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
								WHERE SDFG.GuideToken = @GuideToken
								AND DO.StatusOrderId IN (1,2,10,11,15,21) -- Solicitado, Recolectado, En Inventario, Arribó a las instalaciones, Generado, Recibido en EXC
								AND SDFG.IsDelivery = 1
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
								) )

			-- Guía en estado no modificable
			IF @jsonResult IS NULL
			BEGIN

				set @jsonResult =(SELECT STUFF(( 
								SELECT  
								',{"IdResult":206' + ',' +
								'"serviceType":"Delivery"' + ',' +
								'"trackingForza":"https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) + '"'
								+ '}'

								FROM [dbo].[DeliveryOrder] DO WITH(NOLOCK)
								INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
								ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
								WHERE SDFG.GuideToken = @GuideToken
								AND SDFG.IsDelivery = 1
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
								) )
			END
			-- Ultimo caso de error
			IF @jsonResult IS NULL
			BEGIN

				set @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":204,' 
								+ '"Message":" No se encontraron registros validos."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			END
			select ('[' + @jsonResult +  ']') jsonResult 
		END TRY
		BEGIN CATCH
			set @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Error":"'+ERROR_MESSAGE()+'"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResult +  ']') jsonResultError 
		END CATCH
	END
	-- Si es token de incidencias
	ELSE IF EXISTS (SELECT TOP 1 1 FROM ConfirmationOfIncidence coi WITH (NOLOCK) WHERE coi.ConfirmationOfIncidentToken = @GuideToken AND coi.RowStatus = 1)
	BEGIN
		BEGIN TRY
			set @jsonResult = (SELECT STUFF(( 
								SELECT  
								',{"IdResult":200,"receiverAddress":"' +  (CASE WHEN do.IsLastMileReturn = 1 THEN  do.Sender_Address ELSE do.Receiver_Address END) + '",' +
								'"serviceType":"Incidence"' + ',' +
								'"trackingForza":"https://forzadelivery.com/rastreo/' + do.Guide_Serie + CAST(do.Guide_Number AS NVARCHAR) + '/",' +
								'"Province":"'+ (CASE WHEN do.IsLastMileReturn = 1 THEN  do.Sender_Department ELSE do.Receiver_Department END) + '",' +
								'"Township":"'+ (CASE WHEN do.IsLastMileReturn = 1 THEN  do.Sender_Town ELSE do.Receiver_Town END) + '",' +
								'"confirmationOfIncidenceId":"'+ CAST(coi.IdConfirmationOfIncidence AS VARCHAR) + '",' +
								'"courierLatitude":"'+ ISNULL(da.Latitude, '') + '",' +
								'"courierLongitude":"'+ ISNULL(da.Longitude, '') + '",' +
								'"incidenceDescription":"'+ ISNULL(cti.DescriptionIncidence, '') + '",' +
								+ '}'

								FROM ConfirmationOfIncidence coi WITH(NOLOCK)
								INNER JOIN DeliveryAttempt da WITH(NOLOCK)
									ON coi.IdConfirmationOfIncidence = da.ConfirmationOfIncidenceId
								INNER JOIN DeliveryOrder do WITH(NOLOCK)
									ON do.Guide_Serie = da.Guide_Serie AND do.Guide_Number = da.Guide_Number
								LEFT JOIN CatTypeIncidence cti WITH(NOLOCK)
									ON da.ID_Incident = cti.IdIncidenceType
								WHERE coi.ConfirmationOfIncidentToken = @GuideToken
								AND coi.RowStatus = 1
								AND coi.IsConfirmed <> 1
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
								) )

			IF @jsonResult IS NULL
			BEGIN

				set @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":204,' 
								+ '"Message":" No se encontraron registros validos."}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			END

			select ('[' + @jsonResult +  ']') jsonResult 
		END TRY
		BEGIN CATCH
			set @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":500,' 
								+ '"Error":"'+ERROR_MESSAGE()+'"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			select ('[' + @jsonResult +  ']') jsonResultError 
		END CATCH
	END
	ELSE -- Otro tipo de token
	BEGIN
		/* OTROS FLUJOS - POR IMPLEMENTAR */

		SET @jsonResult =(
						SELECT STUFF(( 
						SELECT '{{"IdResult":204,' 
						+ '"Message":" No se encontraron registros validos."}' 
						FOR XML PATH(''), TYPE
						).value('.', 'varchar(max)'),1,1,'') )
		SELECT ('[' + @jsonResult +  ']') jsonResult 
	END
END
