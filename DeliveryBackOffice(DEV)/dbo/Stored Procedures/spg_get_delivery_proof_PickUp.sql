

-- =============================================
-- Author:		<Author,Edelman>
-- Create date: <Create Date,06-Junio-2023>
-- Description:	<Description,obtener imagen de evidencia de recolección>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_delivery_proof_PickUp]
	-- Add the parameters for the stored procedure here
	
	@IdService INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
			SELECT SM.IdServiceManagement ID,
			   SP.SenderName AS CustomerName,
			   CSS.[Name]  AS StatusService,
				DOPD.GuideSerie + CONVERT(Nvarchar(20),DOPD.GuideNumber) Guide,
						 COUNT(DOPaux.Detail) AS PiecePickUp,
						 IsNUll(SM.PuSignaturePath,'') AS Path_Incident,
				(select cast('' as xml).value('xs:base64Binary(sql:column("[PuSignaturePath]"))', 'varchar(max)')) AS Image_Incident,
			IsNull(SM.PuSignaturePath,'')	AS Path_Signature,
			SM.DateCreated AS   [Date_Photo]
		FROM [DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH (NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH (NOLOCK)
		   ON SP.SchedulePickupId = SM.IdSchedulePickup 
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK)
		   ON SP.SchedulePickupId = DOPD.IdHeaderRecolection
		INNER JOIN [DeliveryBackOffice].[DBO].[SenderReceiver] SR WITH (NOLOCK)
		 ON SM.IdPuCourrier = SR.ID
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOPaux WITH (NOLOCK)
		 ON                [DOPaux].[GuideSerie] = [DOPD].[GuideSerie]
							AND
							[DOPaux].[GuideNumber] = [DOPD].[GuideNumber]
		INNER JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH (NOLOCK)
		ON SM.ServiceStatusId = CSS.IdServiceStatus
		WHERE SM.IdServiceManagement = @IdService
		GROUP BY 
		SR.ID,
		SR.First_Name,
		SR.Last_Name,
		SM.ServiceStatusId ,
		SP.SenderName,
		CSS.[Name],
		DOPD.GuideSerie,
		DOPD.GuideNumber,
		SM.IdServiceManagement,
		SM.DateCreated,
		SM.PuSignaturePath
   
END