-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetGuideFromPhoneNumberFCCTracking] 
@Phone AS NVARCHAR(20)

AS
BEGIN
DECLARE @es NVarChar(1) SET @es = ''
DECLARE @p1 NVarChar(10) SET @p1 = '(+502)'
DECLARE @p2 NVarChar(10) SET @p2 = '(502)'
DECLARE @p3 NVarChar(10) SET @p3 = '502'
DECLARE @p4 NVarChar(10) SET @p4 = '-'

IF (SELECT LEN(@Phone) ) > 8
   BEGIN
		SET @Phone = RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE(@Phone  COLLATE Latin1_General_BIN,  
									       	   @p1, @es ),@p2,@es),@p3 ,@es),@p4,@es ))); 
	END;

	SELECT TOP 5
		         DO.Sender_FirstName +' '+ DO.Sender_LastName AS SENDER_NAME
				,DO.Sender_Address
				,DO.Sender_Phone
				,ISNULL(DO.Sender_Mail,'N/D') AS Sender_Mail
				,DO.Guide_Serie
				,DO.Guide_Number
				,DO.StatusOrderId
				,SO.OrderDescription
				,DO.DateCreated
				
		From 
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
			INNER JOIN 
				[DeliveryBackOffice].[dbo].[StatusOrder] SO WITH (NOLOCK)
				On 
					DO.StatusOrderId = SO.StatusOrderId	
		WHERE 
		  SUBSTRING(RTRIM(LTRIM(REPLACE(REPLACE(REPLACE(REPLACE( DO.Sender_Phone COLLATE Latin1_General_BIN,
		  @p1, @es ),@p2,@es),@p3 ,@es),@p4,@es ))),0,7) = SUBSTRING(@Phone,0,7)  	
		ORDER BY
			DO.DateCreated DESC

END