




-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <01/11/2020>
-- Description:	<Detalle de rastreo en web services para el cliente>
-- =============================================
CREATE PROCEDURE [dbo].[spg_status_order_detail_wbs]
	@Guide_Serie NVARCHAR(2),
	@Guide_Number BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	SELECT RES.[EventID],
		   RES.[OrderId],
		   --RES.[PreparationDate],
		   --RES.[DifferenceStarted],
		   RES.[CustomerFullname],
		   RES.[OriginAdress],
		   RES.[OriginLatitude],
		   RES.[OriginLongitude],
		   RES.[DestinyAddress],
		   RES.[DestintyLatitude],
		   RES.[DestinyLongitude],
		   RES.[EstimatedDeliveryDate],
		   RES.[CourierName],
		   RES.[StageId],
		   RES.[StageDate],
		   RES.[StageTitle],
		   RES.[StageSource],
		   RES.[StageDescription],
		   RES.[ImagePath],
		   RES.[NameOfReceiver],
		   RES.[Place],
		   RES.[ManifestNumber],
		   RES.[Latitude],
		   RES.[Longitude]
	FROM 
		(SELECT
			0 [EventID],
			do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) as [OrderId], -- guide [Field3]
			--CONVERT(varchar,do.Preparation_Date ,103) as [PreparationDate],   --[Field6],
			--'Iniciada hace ' + 
			--RIGHT(CONVERT(CHAR(5), 10000 + CONVERT(VARCHAR(4), FLOOR(DATEDIFF(ss, do.Preparation_Date, GETDATE()) / (24 * 3600)))), 4) + 'd ' +
			--RIGHT(CONVERT(CHAR(3), 100 + CONVERT(VARCHAR(2), DATEDIFF(ss, do.Preparation_Date, GETDATE()) % (24 * 3600) / 3600)), 2) + 'h ' +
			--RIGHT(CONVERT(CHAR(3), 100 + CONVERT(VARCHAR(2), DATEDIFF(ss, do.Preparation_Date, GETDATE()) % 3600 / 60)), 2) + 'm ' +
			--RIGHT(CONVERT(CHAR(3), 100 + CONVERT(VARCHAR(2), DATEDIFF(ss, do.Preparation_Date, GETDATE()) % 60)), 2) + 's' [DifferenceNowStarted], --[Field1]
			isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as [CustomerFullname], -- receiver fullname  [Field2]
			do.Sender_Address as [OriginAdress], -- sender address   [Field8]
			'' as [OriginLatitude],
			'' as [OriginLongitude],
			do.Receiver_Address as [DestinyAddress], -- receiver address  [Field4]
			'' as [DestintyLatitude],
			'' as [DestinyLongitude],
			 CONVERT(varchar,do.Delivery_Max_Date ,120) as [EstimatedDeliveryDate], --[Field5],
				--FORMAT(do.Delivery_Max_Date, 'dddd', 'es-es') + ', '  + CONVERT(varchar,do.Delivery_Max_Date,106) as [EstimatedDeliveryDate], 
				--FORMAT(do.Delivery_Max_Date, 'U', 'es-es')  --[Field5] Otra opcion con hora
			'' [CourierName], --[Field9]
			'' [StageId], -- status order id
			'' [StageDate], -- date of status id
			'' [StageTitle], -- status order name
			'web' [StageSource],
			'' as [StageDescription], --detail description or observations in events
			'' as [ImagePath],
			ISNULL([NameOfReceiver],do.Receiver_FirstName) as NameOfReceiver,
			ISNULL(Sender_FirstName,'') + ' ' + isnull(Sender_LastName,'') as Place ,
			do.Manifest_Serie + CAST(do.Manifest_Number AS VARCHAR) as [ManifestNumber],
			da.Latitude,
			da.Longitude
		FROM DeliveryBackOffice.dbo.DeliveryOrder do with(nolock)
		LEFT JOIN DeliveryBackOffice.dbo.DeliveryAttempt da with(nolock) 
		on da.Guide_Serie = do.Guide_Serie and da.Guide_Number = do.Guide_Number
		WHERE do.Guide_Serie = @Guide_Serie AND do.Guide_Number = @Guide_Number
		UNION
		SELECT 
			ROW_NUMBER() OVER (ORDER BY dod.DateCreated ASC)  AS EventID,
			dod.Guide_Serie + CAST(dod.Guide_Number AS VARCHAR) as [OrderId], -- guide [Field3]
			--'' [PreparationDate],   --[Field6],
			--'' [DifferenceStarted], --[Field1]
			'' [CustomerFullname], -- receiver fullname  [Field2]
			'' [OriginAdress], -- sender address   [Field8]
			'' [OriginLatitude],
			'' [OriginLongitude],
			'' [DestinyAddress], -- receiver address  [Field4]
			'' [DestintyLatitude],
			'' [DestinyLongitude],
			'' [EstimatedDeliveryDate], --[Field5],
			'' [CourierName], --[Field9]
			Cast(dod.StatusOrderId as nvarchar) as [StageId], -- status order id
			dod.DateCreated as [StageDate], -- date of status id
			so.OrderDescription as [StageTitle], -- status order name
			'web' as [StageSource],
			(CASE
                 WHEN dod.StatusOrderId IN ( 6, 8) THEN
                     ISNULL(dod.Observations, '')
                 WHEN dod.StatusOrderId IN ( 12 ) THEN
                     ISNULL(
                     (
                         SELECT TOP 1
								   (SELECT '[ ' + 
											DeliveryBackOffice.dbo.[CapitalizeFirstLetter](LOWER(courier.First_Name) + ' '+LOWER(courier.Last_Name)) +
											' ]'
								   FROM dbo.SenderReceiver courier WHERE courier.ID = da.ID_Courier ) + ' ' + 
								   I.DescriptionIncidence  + ' ' + ISNULL(dod.Observations,'')
							FROM DeliveryBackOffice.dbo.CatTypeIncidence I 
								JOIN DeliveryBackOffice.dbo.DeliveryAttempt da 
									ON da.ID_Incident = I.IdIncidenceType
                         WHERE dod.Guide_Serie = da.Guide_Serie
                               AND dod.Guide_Number = da.Guide_Number
                         ORDER BY da.Date_Created DESC
                     ),
                     ''
                           )
                 WHEN dod.StatusOrderId IN ( 15 ) THEN
                     ''
				ELSE
					ISNULL(dod.Observations, '')
             END
            ) AS [StageDescription],
			--(CASE ROW_NUMBER() OVER (ORDER BY dod.DateCreated ASC) WHEN 1 THEN
			--														ISNULL(
			--															ISNULL(
			--																   (SELECT TOP 1 
			--																		'data:image/jpeg;base64,' + (select cast('' as xml).value('xs:base64Binary(sql:column("[Proof_Dry]"))', 'varchar(max)'))
			--																	FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp with(nolock)
			--																	JOIN DeliveryBackOffice.dbo.DeliveryAttempt da with(nolock) ON da.Guide_Serie = dp.Guide_Serie AND da.Guide_Number = dp.Guide_Number AND da.Verified = 1 AND da.Accepted = 1
			--																	WHERE dp.Guide_Serie = dod.Guide_Serie AND dp.Guide_Number = dod.Guide_Number ORDER BY Date_Photo DESC)
			--																   ,
			--																   (Cast(DeliveryBackOffice.dbo.fn_get_document_image_url(dod.Guide_Serie + CAST(dod.Guide_Number AS VARCHAR)) as VARCHAR(300)))
			--															),'')
			--													   ELSE '' END) as [ImagePath],
			'' as [ImagePath],
			'' as NameOfReceiver,
			'' as Place,
			'' as [ManifestNumber],
			'' as Latitude,
			'' as Longitude
		FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod with(nolock) --on do.[Guide_Serie] =  dod.Guide_Serie and do.[Guide_Number] = dod.Guide_Number
		   JOIN DeliveryBackOffice.dbo.StatusOrder so with(nolock) on so.StatusOrderId = dod.StatusOrderId
		WHERE dod.Guide_Serie = @Guide_Serie and dod.Guide_Number = @Guide_Number
		) RES
		ORDER BY RES.[EventID], RES.[StageDate] ASC
	
END
  


