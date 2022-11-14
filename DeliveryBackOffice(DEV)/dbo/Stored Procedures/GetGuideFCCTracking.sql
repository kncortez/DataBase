-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-05-23>
-- Description:	< Devuelve los estados publicos de la guía para rastrear el progreso en el ciclo de vida >
-- =============================================
-- =============================================
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-11-07>
-- Description:	<Modificación para reemplazar plantillas en cada uno de los mensajes por estado>
-- =============================================

CREATE PROCEDURE [dbo].[GetGuideFCCTracking] 
	@GuideNumber INT,
	@GuideSerie NVARCHAR(2) = 'FD'

AS
BEGIN
	
-- interfering with SELECT statements.
--<municipio>
--<departamento>
--<HUB_EXC>
--<incidencia>
	SET NOCOUNT ON;
	
	-- Variables "configurables"
	DECLARE @Datetext NVARCHAR(100)
	DECLARE @Datetext2 NVARCHAR(100)
	DECLARE @GoodResponseMessage NVARCHAR(MAX) = CONCAT('Estimado cliente, la guía FD ', Cast(@GuideNumber AS varchar),' se encuentra en el estado <STATUS> desde el <DATE>, gracias por usar nuestros servicios.');
	DECLARE @FailureResponseMessage NVARCHAR(300) = 'Estimado cliente, ha ocurrido un error al procesar su solicitud, por favor, intente de nuevo más tarde.';
	
	DECLARE @ResponseTable AS TABLE(
		GuideNumber INT,
		GuideStatus INT,
		GuideStatusDescription NVARCHAR(50),
		GuideStatusDate DATETIME,
		GuideStatusMesseage NVARCHAR(500),
		TownShipName NVARCHAR(100),
		Departament NVARCHAR(100),
		HUB_EXC NVARCHAR(100),
		Incidencia NVARCHAR(100),
		ReceiverName NVARCHAR(100)
	);

	DECLARE @ExternalTypeId INT = (
		SELECT
			TOP 1
				CST.IdCatStatusType
		FROM
			[DeliveryBackOffice].[dbo].[CatStatusType] CST
		WHERE
			CST.StatusType = 'Externo' COLLATE Latin1_General_CI_AI
	)

	BEGIN TRY

		INSERT INTO
			@ResponseTable
				(GuideNumber, 
				 GuideStatus, 
				 GuideStatusDescription, 
				 GuideStatusDate, 
				 GuideStatusMesseage, 
				 TownShipName, 
				 Departament, 
				 HUB_EXC, 
				 Incidencia, 
				 ReceiverName
			)
		SELECT 
			TOP 1  
				DOD.Guide_Number
				,DOD.StatusOrderId
				,SO.OrderDescription
				,DOD.DateCreated
				,SO.StatusMessage
				,TS.TownshipName
				,DO.Sender_Department
				,HL.HubName
				,I.[Description] AS Incidence
				,DO.Receiver_FirstName 
				
		From 
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK) 
		     INNER JOIN 
			 [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
			 ON DO.Guide_Serie = DOD.Guide_Serie  AND DO.Guide_Number = DOD.Guide_Number
			 LEFT JOIN 
			 [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
			 ON DOD.StatusOrderId = SO.StatusOrderId
			 LEFT JOIN 
			 [DeliveryBackOffice].[dbo].[CatStatusType] CST WITH (NOLOCK)
			 ON SO.CatStatusTypeId = CST.IdCatStatusType
			 LEFT JOIN
			 [DeliveryBackOffice].[dbo].[Township] TS WITH (NOLOCK)
			 ON DO.SenderIdTownship = TS.IdTownship
			 LEFT JOIN
			 [DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH (NOLOCK)
			 ON TS.HeaderCode= DSC.HeaderCode
			 LEFT JOIN
			 [DeliveryBackOffice].[dbo].[HubLogistics] HL WITH (NOLOCK)
			 ON DSC.Hub = HL.HubAbbreviation
			 LEFT JOIN 
			 [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
			 ON DO.Guide_Number = DA.Guide_Number
			 LEFT JOIN 
			 [DeliveryBackOffice].[dbo].[Incident] I WITH (NOLOCK)
			 ON DA.ID_Incident= I.ID
		Where 
			DOD.Guide_Number = @GuideNumber
			AND
			DOD.Guide_Serie = @GuideSerie
			AND 
			CST.IdCatStatusType = @ExternalTypeId
		ORDER BY
			DOD.DateCreated DESC

		IF( EXISTS (SELECT TOP 1 1 FROM @ResponseTable) )
		BEGIN
		
			SELECT @Datetext=RT.GuideStatusDate FROM @ResponseTable RT

			declare @mes nvarchar(10) 
			declare @diafecha nvarchar(10)
			declare @anio nvarchar(10)=YEAR(CAST(@Datetext AS datetime))
		    declare @diaf nvarchar(10)=DAY(CAST(@Datetext AS datetime))



			SET LANGUAGE Spanish
			DECLARE @dia INT
			SET @dia = 1
			SELECT @mes= DATENAME(month, DATEADD(day, @dia-1, CAST(@Datetext AS datetime)))
			SELECT @diafecha =datename(weekday, @Datetext) 




           SET @Datetext2 = @diafecha+' '+@diaf+' de '+@mes +' de '+@anio


			SELECT
				TOP 1
					1 [blnResult]
					,CASE 
					     WHEN RT.GuideStatusDescription = 'Recolectado'   THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<municipio>',RT.TownShipName)
					     WHEN RT.GuideStatusDescription = 'Intento de entrega fallida'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<catálogo_de_incidencias>', ISNULL(RT.Incidencia,''))
						 WHEN RT.GuideStatusDescription = 'Intento de entrega fallida'   THEN REPLACE (REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<municipio>',RT.TownShipName),'<departamento>',RT.Departament)
						 WHEN RT.GuideStatusDescription = 'Entregado'   THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<nombre_persona_recibe>', RT.ReceiverName)
						 WHEN RT.GuideStatusDescription = 'Retornado al origen'   THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'Retornado a forza'   THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'En Inventario'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'Arribó a las instalaciones'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'En Tránsito'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'Traslado a Express Center'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'Recibido En Express Center'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'Entregado En Express Center'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'Devuelto en Express Center'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'Reenviado al Hub origen para devolución'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 WHEN RT.GuideStatusDescription = 'Inventario de devoluciones'  THEN REPLACE (REPLACE (REPLACE(RT.GuideStatusMesseage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2),'<Nombre completo del HUB/EXC>', RT.Incidencia)
						 ELSE REPLACE (REPLACE(@GoodResponseMessage,'<STATUS>',RT.GuideStatusDescription),'<DATE>', @Datetext2)
					END [messageResult]
					,@FailureResponseMessage [errorMessageResult]
					,RT.GuideNumber
					,RT.GuideStatus
					,RT.GuideStatusDate
					,RT.GuideStatusDescription
					
			FROM
				@ResponseTable RT

		END
		ELSE
		BEGIN

			SELECT
				0 [blnResult] -- Indica que no existe un último estado publico posible de retornar
				,@FailureResponseMessage [messageResult]
		END
	END TRY
	BEGIN CATCH
	
		SELECT
			0 [blnResult] -- Indica que no existe un último estado publico posible de retornar
			,@FailureResponseMessage [messageResult]

	END CATCH
END