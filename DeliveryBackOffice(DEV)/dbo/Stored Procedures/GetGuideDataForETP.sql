
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
		ServiceCustomerPhone NVARCHAR(100),
		ServiceDestinyAddress NVARCHAR(600),
		IsReturn BIT,
		DeliveryToken NVARCHAR(50),
		ServicePrice DECIMAL(18,2),
		ServiceSerie NVARCHAR(2),
		ServiceNumber INT,
		DescriptionIncidence NVARCHAR(500)
	);

	BEGIN TRY

		INSERT INTO @ResponseTable
			(CourierName, CourierPhones, ServiceDestinyName, ServiceCustomerName, ServiceDestinyPhone, ServiceCustomerPhone, ServiceDestinyAddress, IsReturn, DeliveryToken, ServiceSerie, ServiceNumber,DescriptionIncidence)
		SELECT
			TOP 1
				ISNULL(LTRIM(RTRIM(CONCAT(SR.First_Name, ' ', SR.Last_Name))), '') 'CourierName',
				ISNULL(SR.Phone,'') 'CourierPhones',
				LTRIM(RTRIM(CONCAT(DO.Receiver_FirstName, ' ', DO.Receiver_LastName))) 'ServiceDestinyName',
				LTRIM(RTRIM(CONCAT(DO.Sender_FirstName, ' ', DO.Sender_LastName))) 'ServiceCustomerName',
				DO.Receiver_Phone 'ServiceDestinyPhone',
				DO.Sender_phone 'ServiceCustomerPhone',
				DO.Receiver_Address 'ServiceDestinyAddress',
				ISNULL(DO.IsLastMileReturn, 0) 'IsReturn',
				SDFG.GuideToken 'DeliveryToken',
				DO.Guide_Serie,
				DO.Guide_Number,
				CTI.DescriptionIncidence
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
			LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryAttempt] DA
			    ON
			        DO.Guide_Serie = DA.Guide_Serie
					AND
					DO.Guide_Number = DA.Guide_Number
			LEFT JOIN [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI
			     ON DA.ID_Incident = CTI.IdIncidenceType AND CTI.RowStatus=1
		WHERE
			DO.Guide_Serie = @GuideSerie
			AND
			DO.Guide_Number = @GuideNumber
		ORDER BY
			RP.DateCreated DESC

		-- Obtener precio de la guía
		BEGIN TRY
		
			-- Guía para revisar precio
			DECLARE @GUIDECONCAT NVARCHAR(MAX) = CONCAT(@GuideSerie, CONVERT(NVARCHAR(MAX), @GuideNumber));

			-- Monto a pagar de la guía
			DECLARE @BrainProcessedGuides TABLE (
				GuideSerie NVARCHAR(2),
				GuideNumber INT,
				IsCollect BIT,
				Price DECIMAL(18, 2),
				COD DECIMAL(18, 2),
				AmountPaid DECIMAL(18, 2),
				CODPaid DECIMAL(18, 2),
				CODIsPaid BIT,
				PaymentTime INT,
				TimeSequence INT,
				FelNumber NVARCHAR(50),
				IsPaid BIT,
				IsCustomer INT,
				ConditionPayment NVARCHAR(200),
				HaveCredit BIT,
				CollectCOD BIT,
				ReturnRate DECIMAL(5, 2),
				AmountToPay DECIMAL(18, 2),
				CODAmount DECIMAL(18, 2),
				ReturnRates DECIMAL(5, 2)
			);
			DECLARE @AmountToPay DECIMAL (18, 2)

			-- Guía para devolución
			IF( ISNULL((SELECT TOP 1 RT.IsReturn FROM @ResponseTable RT), 0) = 1 )
			BEGIN

				-- Revisar como devolución
				INSERT INTO @BrainProcessedGuides
				EXEC [dbo].[spws_get_guide_pending_payment] @GUIDECONCAT, -- Guías recibidas
															3,            -- Tiempo de pago 3 - En entrega
															1,            -- 1 - es retorno
															'',           -- Codeapp
															1,            -- Identificador de modulo donde proviene
															'';       -- Token de courier
				SELECT @AmountToPay  = bpg.AmountToPay
				FROM  @BrainProcessedGuides bpg

			END
			ELSE 
			BEGIN

				-- Revisar como entrega
				INSERT INTO @BrainProcessedGuides
				EXEC [dbo].[spws_get_guide_pending_payment] @GUIDECONCAT, -- Guías recibidas
															3,            -- Tiempo de pago 3 - En entrega
															0,            -- 1 - es retorno
															'',           -- Codeapp
															1,            -- Identificador de modulo donde proviene
															'';       -- Token de courier
				SELECT @AmountToPay  = bpg.AmountToPay
				FROM  @BrainProcessedGuides bpg

			END

			UPDATE
				@ResponseTable
			SET
				ServicePrice = @AmountToPay
			WHERE
				ServiceSerie = @GuideSerie
				AND
				ServiceNumber = @GuideNumber


		END TRY
		BEGIN CATCH
		END CATCH

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
				RT.ServiceCustomerPhone,
				RT.ServiceDestinyAddress,
				RT.IsReturn,
				RT.DeliveryToken,
				ISNULL(RT.ServicePrice, 0) 'ServicePrice',
				RT.DescriptionIncidence
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