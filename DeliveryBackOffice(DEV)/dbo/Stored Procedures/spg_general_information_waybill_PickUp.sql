

-- =============================================
-- Author:		<Edelman Vasquez>
-- Create date: <06/Junio/2023>
-- Description:	<Obtener información relevante de la guía para aceptar o rechazar evidencia de recolecciones>
-- =============================================
CREATE PROCEDURE [dbo].[spg_general_information_waybill_PickUp]
	-- Add the parameters for the stored procedure here
	
	@IdService INT
AS
BEGIN
	SET NOCOUNT ON;

	
			SELECT SM.IdServiceManagement IdService,
			   SR.First_Name +' '+ SR.Last_Name  AS Courier,
			   SP.SenderName AS CustomerName,
			   CSS.[Name]  AS StatusService,
				DOPD.GuideSerie + CONVERT(Nvarchar(20),DOPD.GuideNumber) Guide,
						 COUNT(DOPaux.Detail) AS PiecePickUp,
						 SM.PuSignaturePath,
						 	 COUNT(DISTINCT   CASE
								WHEN SM.ServiceStatusId = 3 THEN
									DOPD.GuideNumber
								ELSE
									NULL
							END
						) AS Guías_Recolectadas
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
		SR.First_Name,
		Last_Name,
		SM.PuSignaturePath



		
			SELECT 
						 COUNT(DOPaux.Detail) AS TotalPiezas
						
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
		SR.ID
		
END