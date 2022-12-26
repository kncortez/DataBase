-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-08>
-- Description:	< Retorna el guías las cuales han sido alertadas por hub >
-- =============================================
CREATE PROCEDURE [dbo].[GetAlertedGuidesToTrack_BNHL]

	@TargetHub TblExtPlatTextParameterList READONLY,
	@Finalized BIT = 1
AS
BEGIN

	DECLARE @PickUpTypeId BIGINT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WHERE STSM.Name = 'Recolección');
	DECLARE @DeliveryTypeId BIGINT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WHERE STSM.Name = 'Entrega');
	-- DECLARE @ReturnTypeId BIGINT = (SELECT TOP 1 STSM.IdSubTypeServiceManagment FROM [DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WHERE STSM.Name = 'Devolución');

	DECLARE @ModuleID INT = (SELECT TOP 1 CM.ModIdModule FROM [DeliveryBackOffice].[dbo].[CatModule] CM WHERE CM.ModPath = 'AlertedGuideMonitor');

	IF (@Finalized = 1)
	BEGIN
		-- SELECT ENTREGAS
		SELECT
			ISNULL(DSC.Hub,'N/A') 'Hub'
			,CONCAT(DO.Guide_Serie,DO.Guide_Number) 'Guide'
			,SO.OrderDescription 'Status'
			,STSM.Name 'AlertType'
			,DOA.AlertDescription 'AlertDescription'
			,RTRIM(LTRIM(CONCAT(DO.Sender_FirstName,' ',Sender_LastName))) 'SenderName'
			,ISNULL(DO.Sender_Phone,'') 'SenderPhones'
			,DO.Sender_Address 'SenderAddress'
			,ISNULL(DO.IndicationsToSendOrigin,'') 'EspecialInstructionsSender'
			,RTRIM(LTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName))) 'ReceiverName'
			,ISNULL(DO.Receiver_Phone,'') 'ReceiverPhone'
			,DO.Receiver_Address 'ReceiverAddress'
			,ISNULL(DO.IndicationsToSendDestination,'') 'EspecialInstructionsReceiver'
			,DOA.IdDeliveryOrderAlert 'AlertID'
			,DO.Sender_Town 'SenderTown'
			,DO.Sender_Department 'SenderDepartment'
			,DO.Receiver_Town 'ReceiverTown'
			,DO.Receiver_Department 'ReceiverDepartment'
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			INNER JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
			ON
			DO.StatusOrderId = SO.StatusOrderId
			INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH(NOLOCK)
			ON
			DO.Guide_Serie = DOA.GuideSerie
			AND
			DO.Guide_Number = DOA.GuideNumber
			AND
			DOA.RowStatus = 1
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK)
			ON
			DOA.ServiceTypeId = STSM.IdSubTypeServiceManagment
			inner JOIN
			[DeliveryBackOffice].[dbo].[FinalStatusByModule] DSBM WITH(NOLOCK)
			ON
			DSBM.ModuleId = @ModuleID
			AND
			DSBM.StatusOrderId = DO.StatusOrderId
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
			ON
			DO.ReceiverIdTownship = Twn.IdTownship
			OR
			(
				ISNULL(DO.ReceiverIdTownship, 0) = 0
				AND
				DO.Receiver_Town = Twn.TownshipName COLLATE Latin1_General_CI_AI
			)
			LEFT JOIN (
				SELECT
					DSC.HeaderCode,
					MAX(DSC.Hub) 'Hub'
				FROM
					[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
				GROUP BY
					DSC.HeaderCode
			) DSC
			ON Twn.HeaderCode = DSC.HeaderCode
			INNER JOIN
				@TargetHub TH
				ON
					ISNULL(DSC.Hub,'N/A') = TH.TextParameter COLLATE Latin1_General_CI_AI
		WHERE
			STSM.IdSubTypeServiceManagment = @DeliveryTypeId
		UNION
		-- SELECT RECOLECCIONES
		SELECT
			ISNULL(DSC.Hub,'N/A') 'Hub'
			,CONCAT(DO.Guide_Serie,DO.Guide_Number) 'Guide'
			,SO.OrderDescription 'Status'
			,STSM.Name 'AlertType'
			,DOA.AlertDescription 'AlertDescription'
			,RTRIM(LTRIM(CONCAT(DO.Sender_FirstName,' ',Sender_LastName))) 'SenderName'
			,ISNULL(DO.Sender_Phone,'') 'SenderPhones'
			,DO.Sender_Address 'SenderAddress'
			,ISNULL(DO.IndicationsToSendOrigin,'') 'EspecialInstructionsSender'
			,RTRIM(LTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName))) 'ReceiverName'
			,ISNULL(DO.Receiver_Phone,'') 'ReceiverPhone'
			,DO.Receiver_Address 'ReceiverAddress'
			,ISNULL(DO.IndicationsToSendDestination,'') 'EspecialInstructionsReceiver'
			,DOA.IdDeliveryOrderAlert 'AlertID'
			,DO.Sender_Town 'SenderTown'
			,DO.Sender_Department 'SenderDepartment'
			,DO.Receiver_Town 'ReceiverTown'
			,DO.Receiver_Department 'ReceiverDepartment'
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			INNER JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
			ON
			DO.StatusOrderId = SO.StatusOrderId
			INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH(NOLOCK)
			ON
			DO.Guide_Serie = DOA.GuideSerie
			AND
			DO.Guide_Number = DOA.GuideNumber
			AND
			DOA.RowStatus = 1
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK)
			ON
			DOA.ServiceTypeId = STSM.IdSubTypeServiceManagment
			INNER JOIN
			[DeliveryBackOffice].[dbo].[FinalStatusByModule] DSBM WITH(NOLOCK)
			ON
			DSBM.ModuleId = @ModuleID
			AND
			DSBM.StatusOrderId = DO.StatusOrderId
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
			ON
			DO.SenderIdTownship = Twn.IdTownship
			OR
			(
				ISNULL(DO.SenderIdTownship, 0) = 0
				AND
				DO.Sender_Town = Twn.TownshipName COLLATE Latin1_General_CI_AI
			)
			LEFT JOIN (
				SELECT
					DSC.HeaderCode,
					MAX(DSC.Hub) 'Hub'
				FROM
					[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
				GROUP BY
					DSC.HeaderCode
			) DSC
			ON Twn.HeaderCode = DSC.HeaderCode
			INNER JOIN
				@TargetHub TH
				ON
					ISNULL(DSC.Hub,'N/A') = TH.TextParameter COLLATE Latin1_General_CI_AI
		WHERE
			STSM.IdSubTypeServiceManagment = @PickUpTypeId
	
		-- SELECT DEVOLICIONES
	END
	ELSE
	BEGIN

		-- SELECT ENTREGAS
		SELECT
			ISNULL(DSC.Hub,'N/A') 'Hub'
			,CONCAT(DO.Guide_Serie,DO.Guide_Number) 'Guide'
			,SO.OrderDescription 'Status'
			,STSM.Name 'AlertType'
			,DOA.AlertDescription 'AlertDescription'
			,RTRIM(LTRIM(CONCAT(DO.Sender_FirstName,' ',Sender_LastName))) 'SenderName'
			,ISNULL(DO.Sender_Phone,'') 'SenderPhones'
			,DO.Sender_Address 'SenderAddress'
			,ISNULL(DO.IndicationsToSendOrigin,'') 'EspecialInstructionsSender'
			,RTRIM(LTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName))) 'ReceiverName'
			,ISNULL(DO.Receiver_Phone,'') 'ReceiverPhone'
			,DO.Receiver_Address 'ReceiverAddress'
			,ISNULL(DO.IndicationsToSendDestination,'') 'EspecialInstructionsReceiver'
			,DOA.IdDeliveryOrderAlert 'AlertID'
			,DO.Sender_Town 'SenderTown'
			,DO.Sender_Department 'SenderDepartment'
			,DO.Receiver_Town 'ReceiverTown'
			,DO.Receiver_Department 'ReceiverDepartment'
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			INNER JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
			ON
			DO.StatusOrderId = SO.StatusOrderId
			INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH(NOLOCK)
			ON
			DO.Guide_Serie = DOA.GuideSerie
			AND
			DO.Guide_Number = DOA.GuideNumber
			AND
			DOA.RowStatus = 1
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK)
			ON
			DOA.ServiceTypeId = STSM.IdSubTypeServiceManagment
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[FinalStatusByModule] DSBM WITH(NOLOCK)
			ON
			DSBM.ModuleId = @ModuleID
			AND
			DSBM.StatusOrderId = DO.StatusOrderId
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
			ON
			DO.ReceiverIdTownship = Twn.IdTownship
			OR
			(
				ISNULL(DO.ReceiverIdTownship, 0) = 0
				AND
				DO.Receiver_Town = Twn.TownshipName COLLATE Latin1_General_CI_AI
			)
			LEFT JOIN (
				SELECT
					DSC.HeaderCode,
					MAX(DSC.Hub) 'Hub'
				FROM
					[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
				GROUP BY
					DSC.HeaderCode
			) DSC
			ON Twn.HeaderCode = DSC.HeaderCode
			INNER JOIN
				@TargetHub TH
				ON
					ISNULL(DSC.Hub,'N/A') = TH.TextParameter COLLATE Latin1_General_CI_AI
		WHERE
			STSM.IdSubTypeServiceManagment = @DeliveryTypeId
			AND
			DSBM.IdFinalStatusByModule IS NULL
		UNION
		-- SELECT RECOLECCIONES
		SELECT
			ISNULL(DSC.Hub,'N/A') 'Hub'
			,CONCAT(DO.Guide_Serie,DO.Guide_Number) 'Guide'
			,SO.OrderDescription 'Status'
			,STSM.Name 'AlertType'
			,DOA.AlertDescription 'AlertDescription'
			,RTRIM(LTRIM(CONCAT(DO.Sender_FirstName,' ',Sender_LastName))) 'SenderName'
			,ISNULL(DO.Sender_Phone,'') 'SenderPhones'
			,DO.Sender_Address 'SenderAddress'
			,ISNULL(DO.IndicationsToSendOrigin,'') 'EspecialInstructionsSender'
			,RTRIM(LTRIM(CONCAT(DO.Receiver_FirstName,' ',DO.Receiver_LastName))) 'ReceiverName'
			,ISNULL(DO.Receiver_Phone,'') 'ReceiverPhone'
			,DO.Receiver_Address 'ReceiverAddress'
			,ISNULL(DO.IndicationsToSendDestination,'') 'EspecialInstructionsReceiver'
			,DOA.IdDeliveryOrderAlert 'AlertID'
			,DO.Sender_Town 'SenderTown'
			,DO.Sender_Department 'SenderDepartment'
			,DO.Receiver_Town 'ReceiverTown'
			,DO.Receiver_Department 'ReceiverDepartment'
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			INNER JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK)
			ON
			DO.StatusOrderId = SO.StatusOrderId
			INNER JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA WITH(NOLOCK)
			ON
			DO.Guide_Serie = DOA.GuideSerie
			AND
			DO.Guide_Number = DOA.GuideNumber
			AND
			DOA.RowStatus = 1
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM WITH(NOLOCK)
			ON
			DOA.ServiceTypeId = STSM.IdSubTypeServiceManagment
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[FinalStatusByModule] DSBM WITH(NOLOCK)
			ON
			DSBM.ModuleId = @ModuleID
			AND
			DSBM.StatusOrderId = DO.StatusOrderId
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
			ON
			DO.SenderIdTownship = Twn.IdTownship
			OR
			(
				ISNULL(DO.SenderIdTownship, 0) = 0
				AND
				DO.Sender_Town = Twn.TownshipName COLLATE Latin1_General_CI_AI
			)
			LEFT JOIN (
				SELECT
					DSC.HeaderCode,
					MAX(DSC.Hub) 'Hub'
				FROM
					[DeliveryBackOffice].[dbo].[DumpServiceCoverage] DSC WITH(NOLOCK)
				GROUP BY
					DSC.HeaderCode
			) DSC
			ON Twn.HeaderCode = DSC.HeaderCode
			INNER JOIN
				@TargetHub TH
				ON
					ISNULL(DSC.Hub,'N/A') = TH.TextParameter COLLATE Latin1_General_CI_AI
		WHERE
			STSM.IdSubTypeServiceManagment = @PickUpTypeId
			AND
			DSBM.IdFinalStatusByModule IS NULL

		-- SELECT DEVOLICIONES
	END

END