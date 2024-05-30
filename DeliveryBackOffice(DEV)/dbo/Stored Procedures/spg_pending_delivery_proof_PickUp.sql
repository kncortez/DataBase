

-- =============================================
-- Author:		<Edelman>
-- Create date: <06 Junio 2023>
-- Description:	<Lista todas las pruebas pendientes Recolección>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <21-05-2024>
-- Description:	<Se agrega parametro que indica pais de origen del servicio>
-- =============================================
CREATE PROCEDURE [dbo].[spg_pending_delivery_proof_PickUp]
	-- Add the parameters for the stored procedure here
	@IdCourier INT,
	@DispatchedDate DATE=NULL,
	@IdCountry NVARCHAR(2)='GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
			SELECT SM.IdServiceManagement ID_Servicio,
			   SP.SenderName AS Nombre_Cliente,
			   CSS.[Name]  AS Estado_de_Servicio,
				 COUNT(DISTINCT   CASE
								WHEN SM.ServiceStatusId = 3 THEN
									DOPD.GuideNumber
								ELSE
									NULL
							END
						) AS Guías_Recolectadas,
						 COUNT(DOPaux.Detail) AS Piezas_Recolectadas
						 ,PR.IdCountry AS Pais_Origen
						-- SM.PuSignaturePath Evidencia
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
		INNER JOIN [DeliveryBackOffice].[dbo].[Township] TW WITH(NOLOCK)
			ON [TW].[IdTownship] = [SP].[TownshipId]
		INNER JOIN [DeliveryBackOffice].[dbo].[Province] PR WITH(NOLOCK)
			ON [PR].[IdProvince] = [TW].[IdProvince]
		INNER JOIN [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH (NOLOCK)
		ON SM.ServiceStatusId = CSS.IdServiceStatus
		WHERE SM.DateCreated >= @DispatchedDate And SR.ID = @IdCourier
		AND (PR.IdCountry = @IdCountry OR (SP.TownshipId IS NULL AND @IdCountry ='GT'))
		GROUP BY 
		SR.ID,
		SR.First_Name,
		SR.Last_Name,
		SM.ServiceStatusId ,
		SP.SenderName,
		CSS.[Name],
		SM.IdServiceManagement,
		PR.IdCountry

END