USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[GetAlertedGuidesToTrack]    Script Date: 10/12/2021 15:39:25 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2021-12-08>
-- Description:	< Retorna el guías las cuales han sido alertadas por hub >
-- =============================================
CREATE PROCEDURE [dbo].[GetAlertedGuidesToTrack]
	@TargetHub TblExtPlatTextParameterList READONLY,
	@Finalized BIT = 0
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
			dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 1) 'Hub'
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
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
			JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO
			ON
			DO.StatusOrderId = SO.StatusOrderId
			JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA
			ON
			DO.Guide_Serie = DOA.GuideSerie
			AND
			DO.Guide_Number = DOA.GuideNumber
			AND
			DOA.RowStatus = 1
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM
			ON
			DOA.ServiceTypeId = STSM.IdSubTypeServiceManagment
			JOIN
			[DeliveryBackOffice].[dbo].[FinalStatusByModule] DSBM
			ON
			DSBM.ModuleId = @ModuleID
			AND
			DSBM.StatusOrderId = DO.StatusOrderId
		WHERE
			STSM.IdSubTypeServiceManagment = @DeliveryTypeId
			AND
			REPLACE(ISNULL(dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 1),'N/A'),' ','') IN (SELECT REPLACE(TextParameter,' ','') FROM @TargetHub)
		UNION
		-- SELECT RECOLECCIONES
		SELECT
			dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 2) 'Hub'
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
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
			JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO
			ON
			DO.StatusOrderId = SO.StatusOrderId
			JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA
			ON
			DO.Guide_Serie = DOA.GuideSerie
			AND
			DO.Guide_Number = DOA.GuideNumber
			AND
			DOA.RowStatus = 1
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM
			ON
			DOA.ServiceTypeId = STSM.IdSubTypeServiceManagment
			JOIN
			[DeliveryBackOffice].[dbo].[FinalStatusByModule] DSBM
			ON
			DSBM.ModuleId = @ModuleID
			AND
			DSBM.StatusOrderId = DO.StatusOrderId
		WHERE
			STSM.IdSubTypeServiceManagment = @PickUpTypeId
			AND
			REPLACE(ISNULL(dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 2),'N/A'),' ','') IN (SELECT REPLACE(TextParameter,' ','') FROM @TargetHub)
	
		-- SELECT DEVOLICIONES
	END
	ELSE
	BEGIN

		-- SELECT ENTREGAS
		SELECT
			dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 1) 'Hub'
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
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
			JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO
			ON
			DO.StatusOrderId = SO.StatusOrderId
			JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA
			ON
			DO.Guide_Serie = DOA.GuideSerie
			AND
			DO.Guide_Number = DOA.GuideNumber
			AND
			DOA.RowStatus = 1
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM
			ON
			DOA.ServiceTypeId = STSM.IdSubTypeServiceManagment
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[FinalStatusByModule] DSBM
			ON
			DSBM.ModuleId = @ModuleID
			AND
			DSBM.StatusOrderId = DO.StatusOrderId
			AND
			DSBM.IdFinalStatusByModule IS NULL
		WHERE
			STSM.IdSubTypeServiceManagment = @DeliveryTypeId
			AND
			REPLACE(ISNULL(dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 1),'N/A'),' ','') IN (SELECT REPLACE(TextParameter,' ','') FROM @TargetHub)
		UNION
		-- SELECT RECOLECCIONES
		SELECT
			dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 2) 'Hub'
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
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO
			JOIN
			[DeliveryBackOffice].[dbo].[StatusOrder] SO
			ON
			DO.StatusOrderId = SO.StatusOrderId
			JOIN
			[DeliveryBackOffice].[dbo].[DeliveryOrderAlert] DOA
			ON
			DO.Guide_Serie = DOA.GuideSerie
			AND
			DO.Guide_Number = DOA.GuideNumber
			AND
			DOA.RowStatus = 1
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[SubTypeServiceManagment] STSM
			ON
			DOA.ServiceTypeId = STSM.IdSubTypeServiceManagment
			LEFT JOIN
			[DeliveryBackOffice].[dbo].[FinalStatusByModule] DSBM
			ON
			DSBM.ModuleId = @ModuleID
			AND
			DSBM.StatusOrderId = DO.StatusOrderId
			AND
			DSBM.IdFinalStatusByModule IS NULL
		WHERE
			STSM.IdSubTypeServiceManagment = @PickUpTypeId
			AND
			REPLACE(ISNULL(dbo.FnReviewServiceTargetHub(DO.Guide_Serie, DO.Guide_Number, 2),'N/A'),' ','') IN (SELECT REPLACE(TextParameter,' ','') FROM @TargetHub)
	
		-- SELECT DEVOLICIONES
	END

END
GO


