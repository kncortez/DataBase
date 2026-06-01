

-- =============================================
-- Author:		<Cano,Carlos>
-- Create date: <13/Agosto/2020>
-- Description:	<Obtener información relevante de la guía para aceptar o rechazar evidencia>
-- =============================================
CREATE PROCEDURE [dbo].[spg_general_information_waybill]
	-- Add the parameters for the stored procedure here
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
AS
BEGIN
	SET NOCOUNT ON;
	
	SELECT 
		do.Guide_Serie,
		do.Guide_Number,
		do.Receiver_FirstName + ' ' + do.Receiver_LastName AS Receiver_Name,
		do.Receiver_Address,
		do.Receiver_Zone,
		do.Receiver_Town,
		do.Receiver_Department,
		do.Receiver_Phone,
		do.Receiver_Email,
		do.Receiver_SocialSecurity_ID,
		do.Sender_FirstName + ' ' + do.Sender_LastName AS Sender_Name,
		do.Sender_Address,
		do.Sender_Zone,
		do.Sender_Town,
		do.Sender_Department,
		do.Receiver_Alternant_FullName,
		do.Collect_OnDelivery,
		do.Pieces_Dry,
		do.Pieces_Cold,
		do.Receiver_CUI
	FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
	WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

	SELECT 
		SUBQ.ID_Courier,
		SUBQ.Courier_Name,
		SUM(CAST(SUBQ.Pieces_Dry AS INT)) AS Pieces_Dry,
		SUM(CAST(SUBQ.Pieces_Cold AS INT)) AS Pieces_Cold,	
		Latitude,
		Longitude
	FROM (
		SELECT
			da.ID_Courier,
			da.Longitude,
			da.Latitude,
			sr.First_Name + ' ' + sr.Last_Name AS Courier_Name,
			CAST(da.Dry AS INT) AS Pieces_Dry,
			CAST(da.Cold AS INT) AS Pieces_Cold
		FROM DeliveryBackOffice.dbo.DeliveryAttempt da with (nolock)
		INNER JOIN DeliveryBackOffice.dbo.SenderReceiver sr with (nolock) ON sr.ID = da.ID_Courier
		WHERE da.Guide_Serie = @GuideSerie AND da.Guide_Number = @GuideNumber
	) AS SUBQ
	GROUP BY SUBQ.ID_Courier, SUBQ.Courier_Name, Latitude, Longitude
	ORDER BY Latitude desc, Longitude desc
	--HAVING Latitude > ''

	SELECT SUM(CAST(da.Dry AS INT)) + SUM(CAST(da.Cold AS INT)) AS TotalPieces
	FROM DeliveryBackOffice.dbo.DeliveryAttempt da with (nolock)
	WHERE da.Guide_Serie = @GuideSerie AND da.Guide_Number = @GuideNumber
END