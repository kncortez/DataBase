/* =================================================
   SP:        [dbo].[spg_status_order_detail_wbs]
   Propósito: <Detalle de rastreo en web services para el cliente>
   Autor:     <Edwin Ramirez>
   Historia:  <>
   Fecha:     2020-11-01
=== CHANGELOG ================================
2024-07-24 | Historia/épica: <Se agrega CommentOnIncident para devolver el comentario que el piloto ingreso al momento de crear la incidencia> | Autor: Tito García |
=========================================== 
2025-07-29 | Historia/épica: <Se hace reingeniería del SP para optimizar y modularizar , es más eficiente (+24%) y más escalable> | Autor: Josue Villagrán> |
=========================================== 
2026-03-18 | Historia/épica: FDAPI-5953 | Autor: Mario Herrarte |
=========================================== */
CREATE PROCEDURE [dbo].[spg_status_order_detail_wbs]
	@Guide_Serie NVARCHAR(2),
	@Guide_Number BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
DECLARE @DeliveryOrder TABLE (	
	Guide_Serie NVARCHAR(100),
	Guide_Number DECIMAL(38,0),
	Sender_FirstName NVARCHAR(100),
	Sender_LastName NVARCHAR(100),
	Receiver_FirstName NVARCHAR(100),
	Receiver_LastName NVARCHAR(100),
	OriginAdress NVARCHAR(255),
	DestinyAddress NVARCHAR(255),
	Delivery_Max_Date DATETIME,
	NameOfReceiver NVARCHAR(400),
	Manifest_Serie NVARCHAR(50),
	Manifest_Number INT
);

DECLARE @DeliveryOrderDetail TABLE (
	DateCreated DATETIME,
	Guide_Serie NVARCHAR(100),
	Guide_Number DECIMAL(38,0),
	StatusOrderId TINYINT,
	StageDate DATETIME,
	Observations NVARCHAR(500),
	OrderDescription NVARCHAR(500) 
);

DECLARE @DeliveryAttempt TABLE (
	Guide_Serie NVARCHAR(100),
	Guide_Number DECIMAL(38,0),
	First_Name NVARCHAR(100),
	Last_Name NVARCHAR(100),
	DescriptionIncidence NVARCHAR(255),
	Latitude VARCHAR(50),
	Longitude VARCHAR(50),
	Observations NVARCHAR(500) ,
	CommentOnIncident NVARCHAR(500) 
);

DECLARE @DelayTracking INT = (
	SELECT Value FROM ConfigParams WHERE Name = 'DelayTracking'
);
	
	INSERT INTO @DeliveryOrder
	SELECT 
		do.Guide_Serie,
		do.Guide_Number,
		DO.Sender_FirstName,
		DO.Sender_LastName,
		do.Receiver_FirstName,
		do.Receiver_LastName,
		do.Sender_Address as OriginAdress,
		do.Receiver_Address as DestinyAddress,
		do.Delivery_Max_Date,
		do.NameOfReceiver, 
		do.Manifest_Serie,
		do.Manifest_Number
	FROM DeliveryBackOffice.dbo.DeliveryOrder do  WITH(NOLOCK) 
	WHERE do.Guide_Serie = @Guide_Serie 
	  AND do.Guide_Number = @Guide_Number

	INSERT INTO @DeliveryOrderDetail
	SELECT  
		DOD.DateCreated,
		DOD.Guide_Serie,
		DOD.Guide_Number,
		DOD.StatusOrderId,
		DOD.DateCreated AS StageDate,
		DOD.Observations,
		SO.OrderDescription
	FROM DeliveryBackOffice.dbo.DeliveryOrderDetail dod WITH(NOLOCK)
	INNER JOIN DeliveryBackOffice.dbo.StatusOrder so WITH(NOLOCK) 
		ON so.StatusOrderId = dod.StatusOrderId
	WHERE dod.Guide_Serie = @Guide_Serie 
	  AND dod.Guide_Number = @Guide_Number
	  AND dod.DateCreated < DATEADD(MINUTE, -@DelayTracking, GETDATE());

	  INSERT INTO @DeliveryAttempt
		SELECT TOP 1
			DA.Guide_Serie,
			DA.Guide_Number,
			CUR.First_Name,
			CUR.Last_Name,
			INC.DescriptionIncidence,
			DA.Latitude,
			DA.Longitude,
			Observations,
			CommentOnIncident
		FROM @DeliveryOrderDetail DET
		LEFT JOIN  DeliveryBackOffice.dbo.DeliveryAttempt DA WITH (NOLOCK) 
			ON DA.Guide_Serie =DET.Guide_Serie
			AND DA.Guide_Number = DET.Guide_Number
		LEFT JOIN  DeliveryBackOffice.dbo.CatTypeIncidence INC WITH (NOLOCK)
			ON DA.ID_Incident = INC.IdIncidenceType
		LEFT JOIN dbo.SenderReceiver CUR  WITH(NOLOCK) 
			ON CUR.ID = DA.ID_Courier
		LEFT JOIN [dbo].[ConfirmationOfIncidence] COI WITH(NOLOCK) 
			    ON da.ConfirmationOfIncidenceId = COI.IdConfirmationOfIncidence
		WHERE DA.Guide_Serie = @Guide_Serie 
			AND DA.Guide_Number = @Guide_Number



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
		   RES.[Longitude],
		   RES.[CommentOnIncident]
	FROM 
		(SELECT
			0 [EventID],
			do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) as [OrderId], -- guide [Field3]
			isnull(do.Receiver_FirstName,'') + ' ' + isnull(do.Receiver_LastName,'') as [CustomerFullname], -- receiver fullname  [Field2]
			OriginAdress, -- sender address   [Field8]
			'' as [OriginLatitude],
			'' as [OriginLongitude],
			DestinyAddress, -- receiver address  [Field4]
			'' as [DestintyLatitude],
			'' as [DestinyLongitude],
			 CONVERT(varchar,do.Delivery_Max_Date ,120) as [EstimatedDeliveryDate], --[Field5],
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
			da.Longitude,
			'' AS [CommentOnIncident]
		FROM @DeliveryOrder do 
		LEFT JOIN @DeliveryAttempt da 
		on da.Guide_Serie = do.Guide_Serie and da.Guide_Number = do.Guide_Number
		
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
			OrderDescription as [StageTitle], -- status order name
			'web' as [StageSource],
			(CASE
                 WHEN dod.StatusOrderId IN ( 6, 8) THEN
                     ISNULL(dod.Observations, '')
                 WHEN dod.StatusOrderId IN ( 12 ) THEN
                     ISNULL(
                     ( 
						SELECT '[ ' + DeliveryBackOffice.dbo.[CapitalizeFirstLetter](LOWER(First_Name) + ' '+LOWER(Last_Name)) + ' ] '+ 
												   DescriptionIncidence  + ' ' + ISNULL(Observations,'')
						FROM @DeliveryAttempt ),
                     ''
                           )
                 WHEN dod.StatusOrderId IN ( 15 ) THEN
                     ''
				ELSE
					ISNULL(dod.Observations, '')
             END
            ) AS [StageDescription],
			'' as [ImagePath],
			'' as NameOfReceiver,
			'' as Place,
			'' as [ManifestNumber],
			'' as Latitude,
			'' as Longitude,
			CommentOnIncident
		FROM @DeliveryOrderDetail DOD
		LEFT JOIN @DeliveryAttempt DA ON DOD.Guide_Serie = DA.Guide_Serie AND DOD.Guide_Number = DA.Guide_Number 
		) RES
		ORDER BY RES.[EventID], RES.[StageDate] ASC	
END
