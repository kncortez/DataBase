-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2022-10-05>
-- Description:	<Devuelve toda la información de un servicio basado en su identificador y el tipo>
-- =============================================
CREATE PROCEDURE [dbo].[GetPickupServiceDataByID]
	-- Add the parameters for the stored procedure here
	@IdServiceManagement INT
AS
BEGIN

	DECLARE @ServiceData AS TABLE (
		ServiceId INT,
		ServiceCustomerName NVARCHAR(200),
		ServiceVisitPointDescription NVARCHAR(500),
		ServiceAddress NVARCHAR(600)
	);

	BEGIN TRY

		INSERT INTO @ServiceData
			(ServiceId, ServiceCustomerName, ServiceVisitPointDescription, ServiceAddress)
		SELECT 
			TOP 1
				 SM.IdServiceManagement
				,SP.SenderName
				,VPC.DescriptionOfClient
				,SP.AddressPickup
		FROM 
			[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
			INNER JOIN
				[DeliveryBackOffice].[dbo].[SchedulePickup] SP WITH(NOLOCK)
				ON
					SM.IdSchedulePickup = SP.SchedulePickupId
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH(NOLOCK)
				ON
					SP.SenderId = VPC.CodeOfReference
					AND
					SP.SenderId != 0
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[Customer] Cu WITH(NOLOCK)
				ON
					VPC.CustomerID = Cu.IdCustomer
		WHERE 
			SM.IdServiceManagement = @IdServiceManagement

		IF(EXISTS(SELECT TOP 1 1 FROM @ServiceData))
		BEGIN
		
			SELECT
				200 [ResponseCode],
				'Información recuperada exitosamente.' [ResponseMessage]

			SELECT
				SD.ServiceId,
				SD.ServiceCustomerName,
				SD.ServiceVisitPointDescription,
				SD.ServiceAddress
			FROM
				@ServiceData SD

		END
		ELSE
		BEGIN

			SELECT
				400 [ResponseCode],
				'No se pudo recuperar información.' [ResponseMessage]
			
		END

	END TRY
	BEGIN CATCH

		SELECT
			500 [ResponseCode],
			'Error en el sistema.' [ResponseMessage]
			
	END CATCH
END