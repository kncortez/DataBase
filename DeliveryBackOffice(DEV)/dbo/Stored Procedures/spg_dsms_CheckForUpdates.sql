-- =============================================
-- Author:		<Borja, Cesar>
-- Create date: <2020-09-18>
-- Description:	<Checks for updates made to tha configures table>
-- =============================================
CREATE PROCEDURE [dbo].[spg_dsms_CheckForUpdates]
	@ElementId int=1001
AS
BEGIN
	SET NOCOUNT ON;

	SELECT 
		TOP 1 
			SMSUE.Id
			,SMSUE.UpdateStatus
			,SMSUE.UpdateDateTime
	FROM 
		[DeliveryBackOffice].[dbo].[SMS_UpdatedElements] SMSUE WITH(NOLOCK)
	WHERE
		SMSUE.RowStatus=1
		AND
		SMSUE.ElementId=@ElementId
END
