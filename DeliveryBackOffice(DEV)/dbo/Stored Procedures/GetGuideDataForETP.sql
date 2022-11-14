
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-10-21>
-- Description:	< Obtiene la información de una guía para solicitar ETP a Courier.>
-- =============================================

CREATE PROCEDURE [dbo].[GetGuideDataForETP]
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN

	DECLARE @ResponseTable AS TABLE (
		CourierName NVARCHAR(200),
		CourierPhones NVARCHAR(50),
		ServiceDestinyName NVARCHAR(200),
		ServiceCustomerName NVARCHAR(200),
		ServiceDestinyPhone NVARCHAR(100),
		ServiceDestinyAddress NVARCHAR(600),
		IsReturn BIT,
		DeliveryToken NVARCHAR(50)
	);

	BEGIN TRY

		INSERT INTO @ResponseTable
			(CourierName, CourierPhones, ServiceDestinyName, ServiceCustomerName, ServiceDestinyPhone, ServiceDestinyAddress, IsReturn, DeliveryToken)
		SELECT
			TOP 1
				ISNULL(LTRIM(RTRIM(CONCAT(SR.First_Name, ' ', SR.Last_Name))), '') 'CourierName',
				ISNULL(SR.Phone,'') 'CourierPhones',
				LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName, ' ', DO.Receiver_LastName))) 'ServiceDestinyName',
				LTRIM(RTRIM(CONCAT(DO.Sender_FirstName, ' ', DO.Sender_LastName))) 'ServiceCustomerName',
				DO.Receiver_Phone 'ServiceCustomerPhone',
				DO.Receiver_Address 'ServiceDestinyAddress',
				ISNULL(DO.IsLastMileReturn, 0) 'IsReturn',
				SDFG.GuideToken 'DeliveryToken'
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[RoutePreparationDetail] RPD WITH(NOLOCK)
				ON
					DO.Guide_Serie = RPD.Guide_Serie
					AND
					DO.Guide_Number = RPD.Guide_Number
					AND
					RPD.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[RoutePreparation] RP WITH(NOLOCK)
				ON
					RPD.RoutePreparationId = RP.IdRoutePreparation
					AND
					RP.RowStatus = 1
					AND
					RP.DateRoutePreparation = CAST(GETDATE() AS DATE)
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceManagementDetail] SMD WITH(NOLOCK)
				ON
					SMD.IdServiceManagementDetail = RPD.ServiceManagementDetailId
					AND
					SMD.RowStatus = 1
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceManagement] SM WITH(NOLOCK)
				ON
					SMD.ServiceManagement = SM.IdServiceManagement
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[RouteAssigment] RA WITH(NOLOCK)
				ON
					SM.IdPuRouteAssigment = RA.IdRouteAssigment
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH(NOLOCK)
				ON
					RA.IdCurrierMan = SR.ID
			LEFT JOIN
				[DeliveryBackOffice].[dbo].[ServiceDataForGuide] SDFG WITH(NOLOCK)
				ON
					DO.Guide_Serie = SDFG.GuideSerie
					AND
					DO.Guide_Number = SDFG.GuideNumber
					AND
					SDFG.IsDelivery = 1
		WHERE
			DO.Guide_Serie = @GuideSerie
			AND
			DO.Guide_Number = @GuideNumber
		ORDER BY
			RP.DateCreated DESC

		IF(EXISTS(SELECT TOP 1 1 FROM @ResponseTable))
		BEGIN

			SELECT
				200 ResponseCode

			SELECT
				RT.CourierName,
				RT.CourierPhones,
				RT.ServiceDestinyName,
				RT.ServiceCustomerName,
				RT.ServiceDestinyPhone,
				RT.ServiceDestinyAddress,
				RT.IsReturn,
				RT.DeliveryToken
			FROM
				@ResponseTable RT
			
		END
		ELSE
		BEGIN

			SELECT
				404 ResponseCode

		END

	END TRY
	BEGIN CATCH

		SELECT
			500 ResponseCode

	END CATCH

END