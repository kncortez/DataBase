USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[GetSettlementArrivedPickUpGuidesRabbit]    Script Date: 21/03/2022 09:43:09 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Oscar Morales>
-- Create date: <2022-03-17>
-- Description:	<Obtiene detalle para manifiesto de recolección Rabbit>
-- =============================================
ALTER PROCEDURE [dbo].[GetSettlementArrivedPickUpGuidesRabbit]
	-- Add the parameters for the stored procedure here
	@Phone NVARCHAR(50),
	@SettlementSequence BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @SettlementPickupStationId INT

	SELECT
	   @SettlementPickupStationId = IdSettlementPickupStation
	FROM SenderReceiver sr
	JOIN SettlementPickupStation sps
		ON sps.CouriermanId = sr.ID
	WHERE sr.Phone LIKE '%'+@Phone+'%'
		AND sps.TransactionDate = CAST(GETDATE() AS DATE)
		AND sps.RowStatus = 'TRUE'

	IF @SettlementPickupStationId IS NOT NULL
	BEGIN
	
		DECLARE @Services TABLE (ServiceManagementId BIGINT NULL
		,SenderFullname NVARCHAR(201)
		,SenderAddress NVARCHAR(200)
		,SenderZone NVARCHAR(100)
		,SenderTown NVARCHAR(100)
		,SenderDepartament NVARCHAR(100)
		,SenderPhone NVARCHAR(100))
	
		INSERT INTO @Services
		SELECT
			spsd.ServiceManagementId
			,ISNULL(do.Sender_FirstName,'') + ' ' + ISNULL(do.Sender_LastName,'') SenderFullname
			,do.Sender_Address SenderAddress
			,CONVERT(VARCHAR,  ISNULL(do.Sender_Zone,0)) SenderZone
			,do.Sender_Town SenderTown
			,do.Sender_Department SenderDepartament
			,do.Sender_Phone SenderPhone
		FROM SettlementPickupStationDetail spsd
		JOIN ServiceManagement sm
			ON sm.IdServiceManagement = spsd.ServiceManagementId
		JOIN SchedulePickup sp
			ON sp.SchedulePickupId = sm.IdSchedulePickup
		JOIN DeliveryOrderPaymentDetail dopd
			ON dopd.IdHeaderRecolection = sp.SchedulePickupId
		JOIN DeliveryOrder do
			ON do.Guide_Serie = dopd.GuideSerie
			AND do.Guide_Number = dopd.GuideNumber
		WHERE spsd.SettlementPickupStationId = @SettlementPickupStationId
		AND spsd.SettlementSequence = @SettlementSequence
		AND spsd.RowStatus = 'TRUE'
		AND spsd.TokenSettlement IS NOT NULL --Liquidado
		AND do.StatusOrderId = 20

		SELECT 
			ServiceManagementId
			,(SELECT TOP 1 SenderFullname FROM @Services s WHERE s.ServiceManagementId = spsd.ServiceManagementId) SenderFullname
			,(SELECT TOP 1 SenderAddress FROM @Services s WHERE s.ServiceManagementId = spsd.ServiceManagementId) SenderAddress
			,(SELECT TOP 1 SenderZone FROM @Services s WHERE s.ServiceManagementId = spsd.ServiceManagementId) SenderZone
			,(SELECT TOP 1 SenderTown FROM @Services s WHERE s.ServiceManagementId = spsd.ServiceManagementId) SenderTown
			,(SELECT TOP 1 SenderDepartament FROM @Services s WHERE s.ServiceManagementId = spsd.ServiceManagementId) SenderDepartament
			,(SELECT TOP 1 SenderPhone FROM @Services s WHERE s.ServiceManagementId = spsd.ServiceManagementId) SenderPhone
			,(SELECT COUNT(1) FROM @Services s WHERE s.ServiceManagementId = spsd.ServiceManagementId) Guides
			,spsd.Price Amount
		FROM SettlementPickupStationDetail spsd
		WHERE spsd.SettlementPickupStationId = @SettlementPickupStationId
		AND spsd.SettlementSequence = @SettlementSequence
		AND spsd.RowStatus = 'TRUE'
		AND spsd.TokenSettlement IS NOT NULL --Liquidado
		AND EXISTS(SELECT TOP 1 1 FROM @Services WHERE ServiceManagementId = spsd.ServiceManagementId) --Validar que tenga guías el servicio

	END
END
