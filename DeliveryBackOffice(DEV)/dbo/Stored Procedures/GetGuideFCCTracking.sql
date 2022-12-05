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
-- Author:		<Edelman,Vásquez>
-- Create date: <2022-11-17>
-- Description:	<Modificación para mostrar tags y valores de reemplazo en plantillas>
-- =============================================
-- =============================================
CREATE PROCEDURE [dbo].[GetGuideFCCTracking] 
	@GuideNumber INT,
	@GuideSerie NVARCHAR(2) = 'FD'
AS
BEGIN
	
	SET NOCOUNT ON;
	
	-- Variables "configurables"
	DECLARE @Datetext NVARCHAR(100)
	DECLARE @Datetext2 NVARCHAR(100)
	DECLARE @Exc NVARCHAR(300)
	DECLARE @GoodResponseMessage NVARCHAR(MAX)= CONCAT('Estimado cliente, la guía FD ', Cast(@GuideNumber AS varchar),' se encuentra en el estado <STATUS> desde el <DATE>, gracias por usar nuestros servicios.');
	DECLARE @FailureResponseMessage NVARCHAR(300) = 'Estimado cliente, ha ocurrido un error al procesar su solicitud, por favor, intente de nuevo más tarde.';
	
	DECLARE @ResponseTable AS TABLE(
		GuideNumber INT,
		GuideStatus INT,
		GuideStatusDescription NVARCHAR(50),
		GuideStatusDate DATETIME,
		GuideStatusMesseage NVARCHAR(500),
		TownShipName NVARCHAR(100),
		ProvidencePickup NVARCHAR(100),
		HUB NVARCHAR(100),
		EXC NVARCHAR(100),
		Incidence NVARCHAR(100),
		ReceiverName NVARCHAR(100),
		ProvidenceDelivery NVARCHAR(100),
		NamePersonSending NVARCHAR(100),
		TownshipDelivery NVARCHAR(100),
		GuideSerie NVARCHAR(2),
	    Client NVARCHAR(50) --NUEVO BNHL
	);
	DECLARE @TagsTable AS TABLE(
	   TagName NVARCHAR(50),
	   TagValue  NVARCHAR(200)
	
	
	);
	DECLARE @ExternalTypeId INT = (
		SELECT
			TOP 1
				CST.IdCatStatusType
		FROM
			[DeliveryBackOffice].[dbo].[CatStatusType] CST WITH (NOLOCK)
		WHERE
			CST.StatusType = 'Externo' COLLATE Latin1_General_CI_AI
	)
	
	SET @Exc= (SELECT
				TOP 1
				DescriptionOfClient
			FROM
				[DeliveryBackOffice].[dbo].[TokenLog] TL WITH (NOLOCK)
				INNER JOIN
					[DeliveryBackOffice].[dbo].[RegisterUser] RU WITH (NOLOCK)
					ON
						TL.TknIdUser = RU.UsrIdUser
				INNER JOIN
					[DeliveryBackOffice].[dbo].[VisitPointByUser] VPU WITH (NOLOCK)
					ON
						RU.UsrIdUser = VPU.RegisterUserID
				INNER JOIN
					[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
					ON
						VPU.IdVisitPointClient = VPC.IdVisitPointClient
						WHERE VPC.CodeOfReference=(SELECT  TOP 1 ISNULL(a.Sender_ID, a.Receiver_ID)  FROM dbo.DeliveryOrder a WITH(NOLOCK)  WHERE a.Guide_Number=@GuideNumber))
	BEGIN TRY
		INSERT INTO
		@ResponseTable
		(   GuideNumber,
			GuideStatus,
			GuideStatusDescription ,
			GuideStatusDate ,
			GuideStatusMesseage ,
			TownShipName ,
			ProvidencePickup ,
			HUB,
			EXC,
			Incidence,
			ReceiverName,
			ProvidenceDelivery,
			NamePersonSending,
			TownshipDelivery,
			GuideSerie,
			Client --NUEVO BNHL
		)
		SELECT 
			TOP 1  
				 DOD.Guide_Number
				,DO.StatusOrderId
				,SO.OrderDescription
				,DOD.DateCreated
				,SO.StatusMessage
				,TS.TownshipName
				,DO.Sender_Department
				,HL.HubName
				,@Exc
				,I.NameIncidence AS Incidence
				,COALESCE(DO.Receiver_FirstName,'') +' '+COALESCE(DO.Receiver_LastName,'') 
				,DO.Sender_Department
				,COALESCE(Sender_FirstName,'')+' '+COALESCE(DO.Sender_LastName,'')
				,(SELECT TownshipName FROM [dbo].[Township] WITH(NOLOCK) WHERE IdTownship= DO.ReceiverIdTownship)
				,DO.Guide_Serie
				,COALESCE(DO.Sender_FirstName,'') + COALESCE(DO.Sender_LastName,'') Client --NUEVO BNHL
		From 
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK) 
		     INNER JOIN 
			 [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
			 ON DO.Guide_Serie = DOD.Guide_Serie  AND DO.Guide_Number = DOD.Guide_Number
			 LEFT JOIN 
			 [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
			 ON DO.StatusOrderId = SO.StatusOrderId
			 LEFT JOIN 
			 [DeliveryBackOffice].[dbo].[CatStatusType] CST WITH (NOLOCK)
			 ON SO.CatStatusTypeId = CST.IdCatStatusType
			 LEFT JOIN
			 [DeliveryBackOffice].[dbo].[Township] TS WITH (NOLOCK)
			 ON DO.SenderIdTownship = TS.IdTownship
			 LEFT JOIN (
				SELECT
					HeaderCode,
					MAX(DSC.Hub) 'Hub'
				FROM
					[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH (NOLOCK)
				GROUP BY
					DSC.HeaderCode
			) DSC
			 ON TS.HeaderCode= DSC.HeaderCode
			 LEFT JOIN
			 [DeliveryBackOffice].[dbo].[HubLogistics] HL WITH (NOLOCK)
			 ON DSC.Hub = HL.HubAbbreviation
			 OUTER APPLY (
				SELECT
					TOP 1
						I.NameIncidence
				FROM
					[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH (NOLOCK)
					LEFT JOIN 
					[DeliveryBackOffice].[dbo].[CatTypeIncidence] I WITH (NOLOCK)
					ON DA.ID_Incident= I.IdIncidenceType
				WHERE
					DA.Guide_Serie = DO.Guide_Serie
					AND
					DA.Guide_Number = DO.Guide_Number
				ORDER BY
					DA.Date_Created DESC
			 ) I
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
		   SET LANGUAGE Spanish
			SELECT @Datetext=RT.GuideStatusDate FROM @ResponseTable RT
			declare @mes nvarchar(10) 
			declare @diafecha nvarchar(10)
			declare @anio nvarchar(10)=YEAR(CAST(@Datetext AS datetime))
		    declare @diaf nvarchar(10)=DAY(CAST(@Datetext AS datetime))
			
			DECLARE @dia INT
			SET @dia = 1
			SELECT @mes= DATENAME(month, DATEADD(day, @dia-1, CAST(@Datetext AS datetime)))
			SELECT @diafecha =datename(weekday, @Datetext) 
           SET @Datetext2 = @diafecha+' '+@diaf+' de '+@mes +' de '+@anio
			SELECT
				TOP 1
					1 [blnResult]
					,RT.GuideStatusDescription 
					,RT.GuideStatusMesseage [messageResult]
					,@FailureResponseMessage [errorMessageResult]
					,RT.GuideNumber
					,RT.GuideStatus
					,RT.GuideStatusDate
					,@Datetext2 [DateText]
					,RT.HUB Hub
					,RT.EXC
					,RT.Incidence
					,RT.ReceiverName
					,RT.TownShipName
					,RT.ProvidencePickup
					,RT.ProvidenceDelivery
					,RT.TownshipDelivery
				    ,RT.Client --NUEVO BNHL
					
			FROM
				@ResponseTable RT
         
		
		 INSERT INTO @TagsTable(TagName,TagValue)
		        SELECT  A.Tag
				        ,CASE 
						     WHEN A.Tag='<GuideSerie>'  THEN 'FD'
							 WHEN A.Tag='<GuideNumber>' THEN  CAST(B.GuideNumber AS VARCHAR)
							 WHEN A.Tag='<GuideStatus>' THEN  B.GuideStatusDescription
						     WHEN A.Tag='<StatusDate>' THEN  @Datetext2
							 WHEN A.Tag='<TownshipDelivery>' THEN B.TownShipName
							 WHEN A.Tag='<TownshipPickup>' THEN  B.TownShipName
							 WHEN A.Tag='<Incidence>' THEN B.Incidence
							 WHEN A.Tag='<NamePersonReceives>' THEN B.ReceiverName
							 WHEN A.Tag='<NamePersonSending>' THEN B.NamePersonSending
							 WHEN A.Tag='<ProvidenceDelivery>' THEN B.ProvidenceDelivery
							 WHEN A.Tag='<ProvidencePickup>' THEN B.ProvidencePickup
							 WHEN A.Tag='<NameHubOrigin>' THEN B.HUB
							 WHEN A.Tag='<NameExc>' THEN B.EXC
							 WHEN A.Tag='<Client>' THEN B.Client
						ELSE '' END TagValue
				FROM [DeliveryBackOffice].[dbo].[TagsVariables] A WITH(NOLOCK) 
				CROSS JOIN @ResponseTable B
		   SELECT TagName, TagValue FROM  @TagsTable
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