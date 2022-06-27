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
