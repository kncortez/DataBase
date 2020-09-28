use DeliveryBackOffice
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Borja, Cesar>
-- Create date: <2020-09-18>
-- Description:	<Checks for updates made to tha configures table>
-- =============================================
CREATE PROCEDURE spg_dsms_CheckForUpdates
	@ElementId int=1001
AS
BEGIN
	SET NOCOUNT ON;
	select top 1 ue.Id, ue.UpdateStatus, ue.UpdateDateTime
	from [DeliveryBackOffice].[dbo].[SMS_UpdatedElements] ue with(nolock)
	where ue.RowStatus=1
	and ue.ElementId=@ElementId
END
GO
