USE [DeliveryBackOffice]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<BORJA, CESAR>
-- Create date: <2020-08-31>
-- Description:	<SET SMS RECEIVED FROM A PERSON>
-- =============================================
CREATE PROCEDURE sps_dsms_sms_received
	  @Message_ID	bigint
	, @Message	nvarchar(500)
	, @MSisdn	nvarchar(50)
	, @Short_Number	nvarchar(50)
	, @Type	nvarchar(50)
	, @Status	nvarchar(50)
	, @Datetime	datetime
	, @Token	nvarchar(50)
		
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO [dbo].[SMS_Received]
           ([SMS_Message_ID]
           ,[SMS_Message]
           ,[SMS_MSisdn]
           ,[SMS_Short_Number]
           ,[SMS_Type]
           ,[SMS_Status]
           ,[SMS_Datetime]
           ,[SMS_TokenCreated]
           ,[SMS_TokenCreatedDatetime]
           )
     VALUES
           (
		     @Message_ID	
		   , @Message
		   , @MSisdn
		   , @Short_Number
		   , @Type
		   , @Status
		   , @Datetime
		   , @Token
		   , GETDATE()
           )

	SELECT SCOPE_IDENTITY() 'IDENTITY'
END
GO
