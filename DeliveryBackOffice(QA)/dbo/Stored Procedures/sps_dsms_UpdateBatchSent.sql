-- =============================================
-- Author:		<Borja, Cesar>
-- Create date: <2020-09-18>
-- Description:	<Update sent sms>
-- Last Update: <2021-09-08>
-- Last Update Author: <RUIZ, ANDRES>
-- =============================================
CREATE PROCEDURE [dbo].[sps_dsms_UpdateBatchSent]
	@SentId int=0,
	@BatchId bigint=0,
	@ElementId int = 1001
AS
BEGIN
	SET NOCOUNT ON;

    update [DeliveryBackOffice].[dbo].[SMS_Sent]
	set Sent=1, TokenUpdate='SYS-SERVICE_SentUpdate',UpdatedDatetime=GETDATE(), SentTypeStatus = 3
	where Sent_Batch_Id=@BatchId

	select SCOPE_IDENTITY() 'Scop'
END
