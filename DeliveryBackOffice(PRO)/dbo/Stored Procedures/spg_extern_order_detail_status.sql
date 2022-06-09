

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <13/06/2020>
-- Description:	<Detalle de rastreo en pagina web tracking externa para el cliente, sin datos sensibles>
-- =============================================
CREATE PROCEDURE [dbo].[spg_extern_order_detail_status]
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
		   --RES.[OriginAdress],
		   --RES.[OriginLatitude],
		   --RES.[OriginLongitude],
		   --RES.[DestinyAddress],
		   --RES.[DestintyLatitude],
		   --RES.[DestinyLongitude],
		   RES.[EstimatedDeliveryDate],
		   RES.[CourierName],
		   RES.[StageId],
		   RES.[StageDate],
		   RES.[StageTitle],
		   RES.[StageSource],
		   RES.[StageDescription],
		   --RES.[ImagePath],
		   RES.[NameOfReceiver],
		   RES.[Place]--,
		   --RES.[ManifestNumber]
	FROM 
		(SELECT
			0 [EventID],
			do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) as [OrderId], -- guide [Field3]
			do.Receiver_FirstName + ' ' + do.Receiver_LastName as [CustomerFullname], -- receiver fullname  [Field2]
			--do.Sender_Address as [OriginAdress], -- sender address   [Field8]
			--'' as [OriginLatitude],
			--'' as [OriginLongitude],
			--do.Receiver_Address as [DestinyAddress], -- receiver address  [Field4]
			--'' as [DestintyLatitude],
			--'' as [DestinyLongitude],
			 CONVERT(varchar,do.Delivery_Max_Date ,120) as [EstimatedDeliveryDate], --[Field5],
				--FORMAT(do.Delivery_Max_Date, 'dddd', 'es-es') + ', '  + CONVERT(varchar,do.Delivery_Max_Date,106) as [EstimatedDeliveryDate], 
				--FORMAT(do.Delivery_Max_Date, 'U', 'es-es')  --[Field5] Otra opcion con hora
			'' [CourierName], --[Field9]
			'' [StageId], -- status order id
			'' [StageDate], -- date of status id
			'' [StageTitle], -- status order name
			'web' [StageSource],
			'' as [StageDescription], --detail description or observations in events
			--'' as [ImagePath],
			ISNULL([NameOfReceiver],'') as NameOfReceiver,
			ISNULL(Sender_FirstName + ' ' + Sender_LastName, '') as Place -- ,
			--do.Manifest_Serie + CAST(do.Manifest_Number AS VARCHAR) as [ManifestNumber]
		FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
		WHERE do.Guide_Serie = @Guide_Serie AND do.Guide_Number = @Guide_Number
		UNION
		SELECT DISTINCT
			--ROW_NUMBER() OVER (ORDER BY dod.DateCreated ASC)  AS EventID,
			RANK() OVER(PARTITION BY  dod.Guide_Number ORDER BY dod.StatusOrderId ASC) AS EventID , 
			dod.Guide_Serie + CAST(dod.Guide_Number AS VARCHAR) as [OrderId], -- guide [Field3]
			--'' [PreparationDate],   --[Field6],
			--'' [DifferenceStarted], --[Field1]
			'' [CustomerFullname], -- receiver fullname  [Field2]
			--'' [OriginAdress], -- sender address   [Field8]
			--'' [OriginLatitude],
			--'' [OriginLongitude],
			--'' [DestinyAddress], -- receiver address  [Field4]
			--'' [DestintyLatitude],
			--'' [DestinyLongitude],
			'' [EstimatedDeliveryDate], --[Field5],
			'' [CourierName], --[Field9]
			Cast(dod.StatusOrderId as nvarchar) as [StageId], -- status order id
			(MAX(dod.DateCreated)) as [StageDate], -- date of status id
			so.OrderDescription as [StageTitle], -- status order name
			'web' as [StageSource],
			 (CASE
                 WHEN dod.StatusOrderId IN ( 6, 8 ) THEN
                     ISNULL(dod.Observations, '')
                 WHEN dod.StatusOrderId IN ( 12 ) THEN
                     ISNULL(
                     (
                         SELECT TOP 1
								   I.DescriptionIncidence
							FROM DeliveryBackOffice.dbo.CatTypeIncidence  I  WITH(NOLOCK)
								JOIN DeliveryBackOffice.dbo.DeliveryAttempt da  WITH(NOLOCK)
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
					''
             END
            ) AS [StageDescription],
			--(CASE ROW_NUMBER() OVER (ORDER BY dod.DateCreated ASC) WHEN 1 THEN
			--															ISNULL(Cast(DeliveryBackOffice.dbo.fn_get_document_image_url(dod.Guide_Serie + 
			--																												  CAST(dod.Guide_Number AS VARCHAR)) as VARCHAR(300)),'')
			--													   ELSE '' END) as [ImagePath],
			'' as NameOfReceiver,
			'' as Place--,
			--'' as [ManifestNumber]
		 FROM dbo.DeliveryOrderDetail dod WITH(NOLOCK)
            JOIN DeliveryBackOffice.dbo.StatusOrder so WITH(NOLOCK)
                ON so.StatusOrderId = dod.StatusOrderId
        WHERE dod.Guide_Serie = @Guide_Serie
              AND dod.Guide_Number = @Guide_Number
        --ORDER BY DateCreated
        GROUP BY CONVERT(DATE, dod.DateCreated),
                 dod.Guide_Serie,
                 dod.Guide_Number,
                 dod.StatusOrderId,
                 dod.UserCreated,
                 dod.Observations,
                 so.OrderDescription
		) RES
		ORDER BY RES.[StageDate] ASC, RES.[EventID]
	
END
