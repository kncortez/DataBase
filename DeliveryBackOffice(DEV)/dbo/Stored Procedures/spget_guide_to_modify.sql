

CREATE PROCEDURE [dbo].[spget_guide_to_modify]
	@Guide NVARCHAR(50)
AS
BEGIN

--DECLARE @Guide NVARCHAR(50) = 'FD107310';
DECLARE @StatusClient INT = 1;
DECLARE @CountryId VARCHAR(2) = 'GT';
DECLARE @IdKindOfVPClient INT = 1;

SELECT CONCAT(do.Guide_Serie,do.Guide_Number) Guide,
	   IIF(LTRIM(RTRIM(ISNULL(do.Sender_FirstName, ''))) = '', LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))), IIF(LTRIM(RTRIM(ISNULL(do.Sender_LastName, ''))) = '', LTRIM(RTRIM(do.Sender_FirstName)), CONCAT(LTRIM(RTRIM(do.Sender_FirstName)), ' ', LTRIM(RTRIM(do.Sender_LastName))))) SenderName,
	   IIF(LTRIM(RTRIM(ISNULL(do.Receiver_FirstName, ''))) = '', LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))), IIF(LTRIM(RTRIM(ISNULL(do.Receiver_LastName, ''))) = '', LTRIM(RTRIM(do.Receiver_FirstName)), CONCAT(LTRIM(RTRIM(do.Receiver_FirstName)), ' ', LTRIM(RTRIM(do.Receiver_LastName))))) ReceiverName,
	   ISNULL(do.Receiver_Address, '') ReceiverAddress,
	   ISNULL(do.Receiver_Department, '') ReceiverDepartment,
	   ISNULL(do.Receiver_Town, '') ReceiverTown,
	   ISNULL(do.Receiver_Zone, '') ReceiverZone,
	   ISNULL(do.Receiver_Phone, '') ReceiverPhone,
	   ISNULL(do.IndicationsToSendDestination, '') IndicationsToSendDestination,
	   ISNULL(do.Receiver_ID, 0) ReceiverId,
	   ISNULL(
			  (
			   SELECT ISNULL(vpc.DescriptionOfClient, '')
			   FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH(NOLOCK)
			   WHERE vpc.StatusClient = @StatusClient
			   AND vpc.CountryId = @CountryId
			   AND vpc.IdKindOfVPClient = @IdKindOfVPClient
			   AND vpc.CodeOfReference = ISNULL(do.Receiver_ID, 0)
			  ), ''
			 ) ReceiverIdName,
	   ISNULL(do.Sender_ID, 0) SenderId
FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
WHERE CONCAT(do.Guide_Serie,do.Guide_Number) = @Guide
AND do.StatusOrderId NOT IN (5, 7, 14, 22, 23);

END