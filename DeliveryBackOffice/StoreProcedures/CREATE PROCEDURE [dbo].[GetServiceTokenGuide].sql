USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[GetServiceTokenGuide]    Script Date: 19/10/2021 12:30:50 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[GetServiceTokenGuide]
@GuideSerie NVARCHAR(2) = '',
@GuideNumber INT = -1,
@GuideToken NVARCHAR(50)
AS
BEGIN
-- Obtener el tipo de servicio (Entrega o Recolección)
DECLARE @ServiceType AS BIT = (SELECT [IsDelivery] 
							FROM [dbo].[ServiceDataForGuide] SDFG
							WHERE SDFG.GuideToken = @GuideToken
							--AND SDFG.GuideNumber = @GuideNumber
							--AND SDFG.GuideSerie = @GuideSerie
							);

IF (@ServiceType = 1) -- Servicio es de entrega
BEGIN
	BEGIN TRY
		DECLARE @jsonResult NVARCHAR(MAX) 
		set @jsonResult = (SELECT STUFF(( 
							SELECT  
							',{"IdResult":200,"receiverAddress":"' +  DO.Receiver_Address + '",' +
							'"serviceType":"Delivery"' + ',' +
							'"updatedData":' + IIF( SDFG.DateUsed IS NULL, '0', '1') + ',' +
							'"trackingForza":"https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) + '/",' +
							'"deliveryType":"'+ ISNULL(DO.TypeService,'TDA') + '"' +
							+ '}'

							FROM [dbo].[DeliveryOrder] DO
							INNER JOIN [dbo].[ServiceDataForGuide] SDFG
							ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
							WHERE SDFG.GuideToken = @GuideToken
							--AND DO.Guide_Number = @GuideNumber
							--AND DO.Guide_Serie = @GuideSerie
							AND DO.StatusOrderId IN (1,2,10,11,15) -- Solicitado, Recolectado, En Inventario, Arribó a las instalaciones, Generado
							AND SDFG.IsDelivery = 1
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
		DECLARE @jsonResultErrror NVARCHAR(MAX) 
		set @jsonResultErrror =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":500,' 
							+ '"Error":"'+ERROR_MESSAGE()+'"}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResultErrror +  ']') jsonResultErrror 
	END CATCH
END
ELSE -- Servicio es de recolección
BEGIN
	BEGIN TRY
		DECLARE @jsonResult2 NVARCHAR(MAX) 
		set @jsonResult2 = (SELECT STUFF(( 
							SELECT  
							',{"IdResult":200,"receiverAddress":"' +  DO.Sender_Address + '",' +
							'"serviceType":"Recollection"' + ',' +
							'"trackingForza":"https://forzadelivery.com/rastreo/' + DO.Guide_Serie + CAST(DO.Guide_Number AS NVARCHAR) + '/",' +
							'"updatedData":' + IIF( SDFG.DateUpdated IS NULL, '0', '1') 
							+ '}'

							FROM [dbo].[DeliveryOrder] DO
							INNER JOIN [dbo].[ServiceDataForGuide] SDFG
							ON DO.Guide_Serie = SDFG.GuideSerie AND DO.Guide_Number = SDFG.GuideNumber
							WHERE SDFG.GuideToken = @GuideToken
							--AND DO.Guide_Number = @GuideNumber
							--AND DO.Guide_Serie = @GuideSerie
							AND DO.StatusOrderId IN (1,15) -- Solicitado, Generado
							AND SDFG.IsDelivery = 0
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
							) )
		IF @jsonResult2 IS NULL
		BEGIN

			set @jsonResult2 =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":204,' 
							+ '"Message":" No se encontraron registros validos."}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		END
		select ('[' + @jsonResult2 +  ']') jsonResult 
	END TRY
	BEGIN CATCH
		DECLARE @jsonResultErrror2 NVARCHAR(MAX) 
		set @jsonResultErrror2 =(
							SELECT STUFF(( 
							SELECT '{{"IdResult":500,' 
							+ '"Message":" No se encontraron registros"}' 
							FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,'') )
		select ('[' + @jsonResultErrror2 +  ']') jsonResultErrror 
	END CATCH
END
END
GO


