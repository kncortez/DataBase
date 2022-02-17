USE [DeliveryBackOffice]
GO

/****** Object:  UserDefinedFunction [dbo].[fn_get_last_information_attempt]    Script Date: 8/11/2021 16:15:35 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		Cano, Carlos
-- Create date: 2020-11-30
-- Description:	Devuelve información relacionada con la entrega POD en PowerBI
-- =============================================
CREATE FUNCTION [dbo].[fn_get_last_information_attempt_without_accepted]
(
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
)
RETURNS 
@AttemptInfo TABLE 
(
	-- Add the column definitions for the TABLE variable here
	Courier_Fullname NVARCHAR(MAX), 
	Date_Delivered DATETIME
)
AS
BEGIN
	
	INSERT @AttemptInfo
	SELECT TOP 1 
		 ISNULL(sr.First_Name,'') + ' ' + ISNULL(sr.Last_Name,'') AS Courier_Fullname
		,att.Date_Created AS Date_Delivered
	FROM DeliveryBackOffice.dbo.DeliveryAttempt att WITH(NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = att.ID_Courier
	WHERE att.Guide_Serie = @GuideSerie AND att.Guide_Number = @GuideNumber
	AND att.Delivered = 1 --AND att.Accepted = 1
	ORDER BY att.Date_Created DESC
		
	RETURN 
END
GO


