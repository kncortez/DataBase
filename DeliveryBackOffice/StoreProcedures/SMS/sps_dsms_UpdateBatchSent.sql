use DeliveryBackOffice
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Borja, Cesar>
-- Create date: <2020-09-18>
-- Description:	<Update sent sms>
-- =============================================
CREATE PROCEDURE sps_dsms_UpdateBatchSent
	@SentId int=0,
	@BatchId bigint=0
AS
BEGIN
	SET NOCOUNT ON;

    update [DeliveryBackOffice].[dbo].[SMS_Sent]
	set Sent=1, TokenUpdate='SYS-SERVICE_SentUpdate',UpdatedDatetime=GETDATE()
	where Sent_Batch_Id=@BatchId

	select SCOPE_IDENTITY() 'Scop'
END
GO
