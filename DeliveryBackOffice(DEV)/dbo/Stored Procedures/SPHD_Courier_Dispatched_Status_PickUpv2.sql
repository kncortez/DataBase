


-- =============================================
-- Author:		 <Edelman Vasquez>
-- Create date:  <08/Junio/2023>
-- Description:	 <Listado de afiliados y su status actual sobre recolección>
-- =============================================
-- Author:		 <Brandon Pedroza>
-- Create date:  <21/Mayo/2024>
-- Description:	 <Se agrega validacion para filtrar por pais correspondiente al courier>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_Courier_Dispatched_Status_PickUpv2]
	@DispatchedDate DATE,
	@IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
	SET NOCOUNT ON;


SELECT SR.ID AS ID_Courier,
       SR.First_Name + ' ' + SR.Last_Name AS Nombre_Courier,
	     COUNT(DISTINCT SM.IdServiceManagement) AS Cantidad_de_Servicios,
		 COUNT(DISTINCT   CASE
                        WHEN SM.ServiceStatusId = 3 THEN
                            SM.IdServiceManagement
                        ELSE
                            NULL
                    END
                ) AS Servicios_Recolectados,
		 COUNT(DISTINCT   CASE
                        WHEN SM.ServiceStatusId = 3 THEN
                            DOPD.GuideNumber
                        ELSE
                            NULL
                    END
                ) AS Guías_Recolectadas,

			 COUNT(DISTINCT   CASE
                        WHEN SM.ServiceStatusId = 4 THEN
                            SM.IdServiceManagement
                        ELSE
                            NULL
                    END
                ) AS Servicio_con_Incidencias,
				 COUNT(DOPaux.Detail) AS Piezas_Recolectadas
		FROM [DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH (NOLOCK) ON SP.SchedulePickupId = SM.IdSchedulePickup
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPaymentDetail] DOPD WITH (NOLOCK) ON SP.SchedulePickupId = DOPD.IdHeaderRecolection
			INNER JOIN [DeliveryBackOffice].[DBO].[SenderReceiver] SR WITH (NOLOCK) ON SM.IdPuCourrier = SR.ID
			INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] DOPaux WITH (NOLOCK) ON [DOPaux].[GuideSerie] = [DOPD].[GuideSerie] AND [DOPaux].[GuideNumber] = [DOPD].[GuideNumber]
			WHERE CONVERT(DATE, SM.DateCreated) = @DispatchedDate
			AND (SR.IdCountry = @IdCountry OR (SR.IdCountry IS NULL AND @IdCountry ='GT'))
			GROUP BY SR.ID, SR.First_Name, SR.Last_Name
END