

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
		   RES.[NextSteps]
	FROM 
		(SELECT
			0 [EventID],
			do.Guide_Serie + CAST(do.Guide_Number AS VARCHAR) as [OrderId], -- guide [Field3]
			do.Receiver_FirstName + ' ' + do.Receiver_LastName as [CustomerFullname], -- receiver fullname  [Field2]
			 CONVERT(varchar,do.Delivery_Max_Date ,120) as [EstimatedDeliveryDate], --[Field5],
			'' [CourierName], --[Field9]
			'' [StageId], -- status order id
			'' [StageDate], -- date of status id
			'' [StageTitle], -- status order name
			'web' [StageSource],
			'' as [StageDescription], --detail description or observations in events
			ISNULL([NameOfReceiver],'') as NameOfReceiver,
			ISNULL(Sender_FirstName + ' ' + Sender_LastName, '') as Place,
			NULL NextSteps
		FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
		WHERE do.Guide_Serie = @Guide_Serie AND do.Guide_Number = @Guide_Number
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
			'' as NameOfReceiver,
			'' as Place,
			so.NextSteps NextSteps
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
