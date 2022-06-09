-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-01-03>
-- Description:	< Obtiene datos basicos para actualizar la ubicación de un servicio de entrega para una guía en landing page.>
-- =============================================
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-04-21>
-- Description:	< Obtiene datos de un punto de visita de cliente para landing page. >
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
								SELECT '{{"IdResult":204,' +
								'"serviceType":"Delivery"' + ',' +
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
		/* FLUJO PARA RECOLECCIONES - POR IMPLEMENTAR */

		DECLARE @VisitPointID INT = -1;

		SELECT
			@VisitPointExists = 1
			,@IsVisitPoint = 1
			,@VisitPointID = VPC.CodeOfReference
		FROM
			[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
		WHERE
			VPC.VisitPointToken = @GuideToken COLLATE Latin1_General_CI_AI

		IF(@IsVisitPoint = 1 AND @VisitPointExists = 1)
		BEGIN
			BEGIN TRY
				SET @jsonResult = (SELECT STUFF(( 
									SELECT  
										',{"IdResult":200,"receiverAddress":"' +  VPC.Address + '",' +
										'"serviceType":"Visitpoint"' + ',' +
										'"Province":"'+ VPC.Department + '",' +
										'"Township":"'+ VPC.Town + '"' +
										+ '}'

										FROM 
											[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
										WHERE
											VPC.CodeOfReference = @VisitPointID
											AND
											GETDATE() <= VPC.VisitPointTokenExpiration
											AND
											VPC.StatusClient = 1
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
									) )
				IF @jsonResult IS NULL
				BEGIN
					SET @jsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":206,'  +
									'"serviceType":"Visitpoint"' + ',' +
									+ '"Message":" No se encontraron registros validos."}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				END
				SELECT ('[' + @jsonResult +  ']') jsonResult 
			END TRY
			BEGIN CATCH
				SET @jsonResult =(
									SELECT STUFF(( 
									SELECT '{{"IdResult":500,' 
									+ '"Error":"'+ERROR_MESSAGE()+'"}' 
									FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,'') )
				SELECT ('[' + @jsonResult +  ']') jsonResultError 
			END CATCH
		END
		ELSE
		BEGIN
			SET @jsonResult =(
								SELECT STUFF(( 
								SELECT '{{"IdResult":404,' 
								+ '"Error":"Sin datos que mostrar"}' 
								FOR XML PATH(''), TYPE
								).value('.', 'varchar(max)'),1,1,'') )
			SELECT ('[' + @jsonResult +  ']') jsonResultError 
		END
	END
END
