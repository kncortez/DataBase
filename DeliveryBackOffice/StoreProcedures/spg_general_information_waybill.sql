USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spg_general_information_waybill]    Script Date: 9/16/2020 8:13:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Cano,Carlos>
-- Create date: <13/Agosto/2020>
-- Description:	<Obtener información relevante de la guía para aceptar o rechazar evidencia>
-- =============================================
ALTER PROCEDURE [dbo].[spg_general_information_waybill]
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
		do.Receiver_Alternant_FullName
	FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
	WHERE do.Guide_Serie = @GuideSerie AND do.Guide_Number = @GuideNumber

	SELECT 
		SUBQ.ID_Courier,
		SUBQ.Courier_Name,
		SUM(CAST(SUBQ.Pieces_Dry AS INT)) AS Pieces_Dry,
		SUM(CAST(SUBQ.Pieces_Cold AS INT)) AS Pieces_Cold
	FROM (
		SELECT
			da.ID_Courier,
			sr.First_Name + ' ' + sr.Last_Name AS Courier_Name,
			CAST(da.Dry AS INT) AS Pieces_Dry,
			CAST(da.Cold AS INT) AS Pieces_Cold
		FROM DeliveryBackOffice.dbo.DeliveryAttempt da
		JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = da.ID_Courier
		WHERE da.Guide_Serie = @GuideSerie AND da.Guide_Number = @GuideNumber
	) AS SUBQ
	GROUP BY SUBQ.ID_Courier, SUBQ.Courier_Name
	
END
