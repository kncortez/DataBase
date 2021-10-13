USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spget_guide_to_modify]    Script Date: 12/10/2021 15:49:38 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[spget_guide_to_modify]
	@Guide NVARCHAR(50)
AS
BEGIN

--DECLARE @Guide NVARCHAR(50) = 'FD510014';

SELECT CONCAT(do.Guide_Serie,do.Guide_Number) Guide,
	   IIF(LTRIM(RTRIM(ISNULL(do.Sender_FirstName, ''))) = '', LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))), IIF(LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))) = '', LTRIM(RTRIM(do.Sender_FirstName)), CONCAT(LTRIM(RTRIM(do.Sender_FirstName)), ' ', LTRIM(RTRIM(do.Sender_LastName))))) SenderName,
	   IIF(LTRIM(RTRIM(ISNULL(do.Receiver_FirstName, ''))) = '', LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))), IIF(LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))) = '', LTRIM(RTRIM(do.Receiver_FirstName)), CONCAT(LTRIM(RTRIM(do.Receiver_FirstName)), ' ', LTRIM(RTRIM(do.Receiver_LastName))))) ReceiverName,
	   ISNULL(do.Receiver_Address, '') ReceiverAddress,
	   ISNULL(do.Receiver_Department, '') ReceiverDepartment,
	   ISNULL(do.Receiver_Town, '') ReceiverTown,
	   ISNULL(do.Receiver_Zone, '') ReceiverZone,
	   ISNULL(do.Receiver_Phone, '') ReceiverPhone,
	   ISNULL(do.IndicationsToSendDestination, '') IndicationsToSendDestination,
	   ISNULL(do.Receiver_ID, 0) ReceiverId
FROM DeliveryBackOffice.dbo.DeliveryOrder do
WHERE CONCAT(do.Guide_Serie,do.Guide_Number) = @Guide
AND do.StatusOrderId <> 7;

END

GO


