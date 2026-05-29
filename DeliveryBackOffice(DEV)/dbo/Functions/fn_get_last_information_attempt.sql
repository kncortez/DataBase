
-- =============================================
-- Author:		Cano, Carlos
-- Create date: 2020-11-30
-- Description:	Devuelve información relacionada con la entrega POD en PowerBI
-- =============================================
CREATE FUNCTION [dbo].[fn_get_last_information_attempt]
(
	@GuideSerie NVARCHAR(2),
	@GuideNumber INT
)
RETURNS 
@AttemptInfo TABLE 
(
	-- Add the column definitions for the TABLE variable here
	Courier_Fullname NVARCHAR(150), 
	Date_Delivered DATETIME
)
AS
BEGIN
	
	INSERT @AttemptInfo
	SELECT TOP 1 
		 isnull(sr.First_Name,'') + ' ' + isnull(sr.Last_Name,'') as Courier_Fullname
		,att.Date_Created as Date_Delivered
	FROM DeliveryBackOffice.dbo.DeliveryAttempt att with(nolock)
	LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = att.ID_Courier
	WHERE att.Guide_Serie = @GuideSerie AND att.Guide_Number = @GuideNumber
	AND att.Delivered = 1 AND att.Accepted = 1
	ORDER BY att.Date_Created DESC
		
	RETURN 
END