USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[sps_dsms_sms_received]    Script Date: 9/12/2020 18:52:45 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<BORJA, CESAR>
-- Create date: <2020-08-31>
-- Description:	<SET SMS RECEIVED FROM A PERSON>
-- =============================================
ALTER PROCEDURE [dbo].[sps_dsms_sms_received]
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

	BEGIN TRY  

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

		SELECT cast(SCOPE_IDENTITY() as nvarchar) [IDENTITY]
				,'' AS [ErrorNumber]  
				,'' AS ErrorState  
				,'' AS ErrorProcedure  
				,'' AS ErrorLine  
				,'' AS ErrorMessage; 
		     
	END TRY  
	BEGIN CATCH  
		SELECT   '0' [IDENTITY]
				,Cast(ERROR_NUMBER() as nvarchar) AS [ErrorNumber]  
				,Cast(ERROR_STATE() as nvarchar) AS ErrorState  
				,Cast(ERROR_PROCEDURE() as nvarchar) AS ErrorProcedure  
				,Cast(ERROR_LINE() as nvarchar) AS ErrorLine  
				,Cast(ERROR_MESSAGE() as nvarchar) AS ErrorMessage; 
	END CATCH  

END
