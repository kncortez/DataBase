


CREATE FUNCTION [dbo].[fn_get_courier]
    (
      @GuideSerie NVARCHAR(2),
	  @GuideNumber INT
    )
   RETURNS VARCHAR(MAX)
AS

BEGIN

	DECLARE @information VARCHAR(MAX) 

	SELECT @information = COALESCE(@information + ', ','') + Courier
	FROM   (SELECT DISTINCT sr.CUI + ' - ' + sr.First_Name + ' ' + sr.Last_Name + ' - ' + sr.Phone as Courier
				FROM DeliveryBackOffice.dbo.DeliveryAttempt att with (nolock)
				LEFT JOIN DeliveryBackOffice.dbo.SenderReceiver sr ON sr.ID = att.ID_Courier
				WHERE att.Guide_Serie = @GuideSerie AND att.Guide_Number = @GuideNumber) wh
	
RETURN @information
END