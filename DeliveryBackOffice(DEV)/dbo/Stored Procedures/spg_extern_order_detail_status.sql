

-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <13/06/2020>
-- Description:	<Detalle de rastreo en pagina web tracking externa para el cliente, sin datos sensibles>
-- =============================================
CREATE PROCEDURE [dbo].[spg_extern_order_detail_status]
	@Guide_Serie NVARCHAR(2),
	@Guide_Number BIGINT,
	@Receiver_Phone NVARCHAR(100) = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @GuideOrderTemp AS TABLE(
		Guide_Serie NVARCHAR(2),
		Guide_Number INT,
		SenderName NVARCHAR(200),
		Sender_Address NVARCHAR(600),
		ReceiverName NVARCHAR(200),
		Receiver_Address NVARCHAR(600),
		Manifest_Serie NVARCHAR(2),
		Manifest_Number INT,
		NameOfReceiver NVARCHAR(200),
		Delivery_Max_Date DATETIME,
		Receiver_Phone NVARCHAR(100)
	);

	-- Variables de datos de entrega
	DECLARE @GuideDeliveryLatitude NVARCHAR(20) = '';
	DECLARE @GuideDeliveryLongitude NVARCHAR(20) = '';
	DECLARE @GuideDeliveryCourierAttempt NVARCHAR(200) = '';

	SELECT
		TOP 1
			@GuideDeliveryLatitude = DA.Latitude,
			@GuideDeliveryLongitude = DA.Longitude,
			@GuideDeliveryCourierAttempt = LTRIM(RTRIM(CONCAT(LTRIM(RTRIM(SR.First_Name)), ' ', LTRIM(RTRIM(SR.Last_Name)))))
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryAttempt] DA WITH(NOLOCK)
		INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryProof] DP WITH(NOLOCK)
			ON
				DA.Guide_Number = DP.Guide_Number
				AND
				DA.Guide_Serie = DP.Guide_Serie
		INNER JOIN
			[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
			ON
				DA.ID_Courier = SR.ID
	WHERE
		DA.Guide_Serie = @Guide_Serie
		AND
		DA.Guide_Number = @Guide_Number
		AND
		DA.Delivered = 1
	ORDER BY
		DA.Date_Created DESC

	-- Datos de guía
	INSERT INTO
		@GuideOrderTemp
		(Guide_Serie, Guide_Number, SenderName, Sender_Address, ReceiverName, Receiver_Address, Manifest_Serie, Manifest_Number, NameOfReceiver, Delivery_Max_Date, Receiver_Phone)
	SELECT
		TOP 1
			DO.Guide_Serie
			, DO.Guide_Number
			, LTRIM(RTRIM(ISNULL(DO.Sender_FirstName, '') + ' ' + ISNULL(DO.Sender_LastName, '')))
			, Sender_Address
			, LTRIM(RTRIM(ISNULL(DO.Receiver_FirstName, '') + ' ' + ISNULL(DO.Receiver_LastName, '')))
			, DO.Receiver_Address
			, DO.Manifest_Serie
			, DO.Manifest_Number
			, DO.NameOfReceiver
			, DO.Delivery_Max_Date
			, LTRIM(RTRIM(DO.Receiver_Phone))
	FROM
		[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
	WHERE
		DO.Guide_Serie = @Guide_Serie
		AND
		DO.Guide_Number = @Guide_Number;
	
	--Control para mostrar imagenes
	DECLARE @IsPhoneValid BIT = CASE WHEN @Receiver_Phone IS NOT NULL AND LTRIM(RTRIM(@Receiver_Phone)) = ( SELECT
			Receiver_Phone
		FROM @GuideOrderTemp) THEN 1
		ELSE 0
	END

	SELECT RES.[EventID],
		   RES.[OrderId],
		   RES.[CustomerFullname],
		   RES.[EstimatedDeliveryDate],
		   RES.[CourierName],
		   RES.[StageId],
		   RES.[StageDate],
		   RES.[StageTitle],
		   RES.[StageSource],
		   RES.[StageDescription],
		   RES.[NameOfReceiver],
		   RES.[Place],
		   RES.[NextSteps],
		   RES.[ImagePath],
		   RES.[Dry],
		   RES.[Cold],
		   RES.[Latitude],
		   RES.[Longitude]
	FROM 
		(SELECT
			0 [EventID],
			do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) as [OrderId], -- guide [Field3]
			do.ReceiverName as [CustomerFullname], -- receiver fullname  [Field2]
			 CONVERT(varchar,do.Delivery_Max_Date ,120) as [EstimatedDeliveryDate], --[Field5],
			'' [CourierName], --[Field9]
			'' [StageId], -- status order id
			'' [StageDate], -- date of status id
			'' [StageTitle], -- status order name
			'web' [StageSource],
			'' as [StageDescription], --detail description or observations in events
			ISNULL([NameOfReceiver],'') as NameOfReceiver,
			ISNULL(do.SenderName, '') as Place,
			NULL NextSteps,
			'' ImagePath,
			'' Dry,
			'' Cold,
			'' Latitude,
			'' Longitude
		FROM @GuideOrderTemp do
		UNION
		SELECT DISTINCT
			RANK() OVER(PARTITION BY  dod.Guide_Number ORDER BY dod.StatusOrderId ASC) AS EventID , 
			dod.Guide_Serie + CAST(dod.Guide_Number AS VARCHAR) as [OrderId], -- guide [Field3]
			'' [CustomerFullname], -- receiver fullname  [Field2]
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
				ELSE
					so.StatusOrderTrackingDescription
             END
            ) AS [StageDescription],
			(CASE WHEN dod.StatusOrderId = 5 THEN (SELECT TOP 1 NameOfReceiver FROM @GuideOrderTemp) ELSE '' END) AS NameOfReceiver,
			'' as Place,
			so.NextSteps NextSteps,
			(CASE WHEN dod.StatusOrderId = 5 AND @IsPhoneValid = 1THEN
                     ISNULL(
                               ISNULL(
                               (
                                   SELECT TOP 1
                                          'data:image/jpeg;base64,'
                                          +
                                          (
                                              SELECT CAST('' AS XML).value(
                                                                              'xs:base64Binary(sql:column("PICTURE"))',
                                                                              'varchar(max)'
                                                                          )
                                          )
                                   FROM
                                   (
                                       SELECT IIF([dp].[Proof_Dry] = 0x,
                                                  dp.Proof_Cold,
                                                  ISNULL([Proof_Dry], [Proof_Incident])) AS PICTURE,
                                              Date_Photo
                                       FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
                                           INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                               ON da.Guide_Serie = dp.Guide_Serie
                                                  AND da.Guide_Number = dp.Guide_Number
												  AND da.Delivered = 1
                                       WHERE dp.Guide_Serie = 'FD'
                                             AND dp.Guide_Number = @Guide_Number
                                             AND
                                             (
                                                 dp.Proof_Incident != 0x
                                                 OR dp.Proof_Incident IS NULL
                                             )
                                   ) L1
                                   ORDER BY L1.Date_Photo DESC
                               ),
                               (CAST(DeliveryBackOffice.dbo.fn_get_document_image_url(dod.Guide_Serie
                                                                                      + CAST(dod.Guide_Number AS VARCHAR)
                                                                                     ) AS VARCHAR(300))
                               )
                                     ),
                               ''
                           )
                 ELSE
                     ''
             END
            ) AS [ImagePath],
			(CASE WHEN dod.StatusOrderId = 5 AND @IsPhoneValid = 1THEN 
				(SELECT TOP 1
					IIF([dp].[Path_Dry] = '', dp.Path_Dry,ISNULL([Path_Dry], [Path_Dry]))
						FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
							INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
								ON da.Guide_Serie = dp.Guide_Serie
									AND da.Guide_Number = dp.Guide_Number
									AND da.Delivered = 1
						WHERE dp.Guide_Serie = 'FD'
								AND dp.Guide_Number = @Guide_Number order By dp.Date_Photo desc)
			ELSE '' END) AS [Dry],
			(CASE WHEN dod.StatusOrderId = 5 AND @IsPhoneValid = 1THEN 
				(SELECT TOP 1
					IIF([dp].[Path_Cold] = '', dp.Path_Cold,ISNULL([Path_Cold], [Path_Cold]))
                        FROM [DeliveryBackOffice].[dbo].[DeliveryProof] dp WITH (NOLOCK)
                            INNER JOIN DeliveryBackOffice.dbo.DeliveryAttempt da WITH (NOLOCK)
                                ON da.Guide_Serie = dp.Guide_Serie
                                    AND da.Guide_Number = dp.Guide_Number
									AND da.Delivered = 1
                        WHERE dp.Guide_Serie = 'FD'
                                AND dp.Guide_Number = @Guide_Number order By dp.Date_Photo desc)
			ELSE '' END) AS [Cold],
            (CASE WHEN dod.StatusOrderId = 5 AND @IsPhoneValid = 1THEN @GuideDeliveryLatitude ELSE '' END) AS Latitude,
            (CASE WHEN dod.StatusOrderId = 5 AND @IsPhoneValid = 1THEN @GuideDeliveryLongitude ELSE '' END) AS Longitude
		 FROM dbo.DeliveryOrderDetail dod WITH(NOLOCK)
            INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH(NOLOCK)
                ON so.StatusOrderId = dod.StatusOrderId
        WHERE dod.Guide_Serie = @Guide_Serie
              AND dod.Guide_Number = @Guide_Number
        GROUP BY CONVERT(DATE, dod.DateCreated),
                 dod.Guide_Serie,
                 dod.Guide_Number,
                 dod.StatusOrderId,
                 dod.UserCreated,
                 dod.Observations,
                 so.OrderDescription,
				 so.NextSteps,
				so.StatusOrderTrackingDescription
		) RES
		ORDER BY RES.[StageDate] ASC, RES.[EventID]
	
END
