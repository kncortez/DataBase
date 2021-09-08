USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_dsms_UpdateBatchSent]    Script Date: 08/09/2021 13:57:21 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Borja, Cesar>
-- Create date: <2020-09-18>
-- Description:	<Update sent sms>
-- Last Update: <2021-09-08>
-- Last Update Author: <RUIZ, ANDRES>
-- =============================================
ALTER PROCEDURE [dbo].[sps_dsms_UpdateBatchSent]
	@SentId int=0,
	@BatchId bigint=0,
	@ElementId int = 1001
AS
BEGIN
	SET NOCOUNT ON;

    update [DeliveryBackOffice].[dbo].[SMS_Sent]
	set Sent=1, TokenUpdate='SYS-SERVICE_SentUpdate',UpdatedDatetime=GETDATE(), SentTypeStatus = (CASE WHEN @ElementId = 1001 THEN 2 WHEN @ElementId = 1002 THEN  1 ELSE 0 END)
	where Sent_Batch_Id=@BatchId

	select SCOPE_IDENTITY() 'Scop'
END
