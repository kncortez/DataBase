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
	DECLARE @IsDeliveryOnRoute AS BIT = 0;
	DECLARE @IsPickup AS BIT = 0;
	DECLARE @IsVisitPoint AS BIT = 0;
	DECLARE @VisitPointExists AS BIT = 0;

	-- Variables de respuesta
	DECLARE @jsonResult NVARCHAR(MAX);
	
	SET @IsDelivery = (
		SELECT TOP 1 (CASE WHEN SDFG.[IsDelivery] = 1 AND SDFG.IsInRoute = 0 THEN 1 ELSE 0 END) 
		FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
		WHERE SDFG.GuideToken = @GuideToken
		ORDER BY SDFG.DateCreated DESC
	);
	
	SET @IsDeliveryOnRoute = (
		SELECT TOP 1 (CASE WHEN SDFG.[IsDelivery] = 1 AND SDFG.IsInRoute = 1 THEN 1 ELSE 0 END) 
		FROM [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
		WHERE SDFG.GuideToken = @GuideToken
		ORDER BY SDFG.DateCreated DESC
	);

	IF (@IsDeliveryOnRoute = 1)
	BEGIN

		BEGIN TRY
			set @jsonResult = (SELECT STUFF(( 
								SELECT  
								',{"IdResult":200,"receiverAddress":"' +  DO.Receiver_Address + '",' +
								'"serviceType":"DeliveryInRoute"' + ',' +
								'"updatedData":' + IIF( SDFG.DateUsed IS NULL, '0', '1') + ',' +
								'"DeliveryAttempt":' + ISNULL(CAST(DA.ID AS NVARCHAR), 'null') + ',' +
								'"RoutePreparation":' + ISNULL(CAST(RPD.IdRoutePreparation AS NVARCHAR), 'null') + ',' +
								'"DeliverySettlement":' + ISNULL(CAST(RPD.DeliveryOrderBySettlementId AS NVARCHAR), 'null') + ',' +
								'"trackingForza":"https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) + '/",' +
								'"Province":"'+ DO.Receiver_Department + '",' +
								'"Township":"'+ DO.Receiver_Town + '",' +
								'"deliveryType":"'+ ISNULL(DO.TypeService,'STD') + '"' +
								+ '}'

								FROM [dbo].[DeliveryOrder] DO WITH(NOLOCK)
								INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
								ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
								OUTER APPLY (
									SELECT
										TOP 1
											DAaux.ID
											,DAaux.Delivered
											,DAaux.ID_Incident
											,DAaux.ID_Proof
									FROM
										[DeliveryBackOffice].[dbo].[DeliveryAttempt] DAaux WITH(NOLOCK)
									WHERE
										DAaux.Guide_Serie = DO.Guide_Serie
										AND
										DAaux.Guide_Number = DO.Guide_Number
										AND
										DAaux.Date_Created >= CAST(GETDATE() AS DATE)
									ORDER BY
										DAaux.Date_Created DESC
								) DA
								OUTER APPLY (
									SELECT
										TOP 1
											RP.IdRoutePreparation
											,DOBS.ID 'DeliveryOrderBySettlementId'
									FROM
										[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
										INNER JOIN
											[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
											ON
												RPD.RoutePreparationId = RP.IdRoutePreparation
												AND
												RP.DateRoutePreparation = CAST(GETDATE() AS DATE)
												AND
												RP.RowStatus = 1
										INNER JOIN
											[DeliveryBackOffice].[dbo].[DeliveryOrderBySettlement] DOBS WITH(NOLOCK)
											ON
												RP.DeliveryOrderBySettlementId = DOBS.ID
									WHERE
										RPD.Guide_Serie = DO.Guide_Serie
										AND
										RPD.Guide_Number = DO.Guide_Number
										AND
										RPD.RowStatus = 1
									ORDER BY
										RP.DateCreated DESC
								) RPD
								WHERE SDFG.GuideToken = @GuideToken
								AND DO.StatusOrderId IN (4,18) -- En ruta, en ruta para devolución
								AND SDFG.IsDelivery = 1
								AND SDFG.IsInRoute = 1
								AND SDFG.DateUsed IS NULL
								ORDER BY
								SDFG.DateCreated DESC
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,''
								) )
								
			-- Guía en estado no modificable
			IF @jsonResult IS NULL
			BEGIN

				set @jsonResult =(SELECT STUFF(( 
								SELECT  
								',{"IdResult":206' + ',' +
								'"serviceType":"DeliveryInRoute"' + ',' +
								'"trackingForza":"https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) + '"'
								+ '}'

								FROM [dbo].[DeliveryOrder] DO WITH(NOLOCK)
								INNER JOIN [dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
								ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
								WHERE SDFG.GuideToken = @GuideToken
								AND SDFG.IsDelivery = 1
								AND SDFG.IsInRoute = 1
								ORDER BY
								SDFG.DateCreated DESC
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
	ELSE IF (@IsDelivery = 1) -- Servicio es de entrega
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
