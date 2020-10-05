use DeliveryBackOffice
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<BORJA, CESAR>
-- Create date: <2020-08-25>
-- Description:	<GET PhoneBook>
-- =============================================
CREATE PROCEDURE spg_dsms_PhoneBook 
	@MaxDeliveryDate DATETIME = '2020-06-09'
AS
BEGIN
	SET NOCOUNT ON;
		
	declare @LastUpdate datetime= dateadd(MINUTE,-30,@MaxDeliveryDate)
	
	declare @ToUpdate as table (_Series nvarchar(50), _Number int)
 
	  insert into @ToUpdate
	  SELECT DISTINCT do.[Guide_Serie]
		  ,do.[Guide_Number]
	  FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] do with(nolock)
	  left join [DeliveryBackOffice].[dbo].[SMS_Sent] ss with(nolock)
	  on do.Guide_Serie=ss.Sent_Guide_Series and do.Guide_Number=ss.Sent_Guide_Number
	  where do.DateCreatedInSystem>=@LastUpdate
	  and do.StatusOrderId=11
	  and ss.Sent_Guide_Series is null
	  and isnull(ss.Sent,1)=1

	declare @PhoneBook as table (
	_FirstName nvarchar(300),
	_LastName nvarchar(300),
	_Phone nvarchar(500),
	_Address nvarchar(500),
	_Town nvarchar(100),
	_Department nvarchar(100),
	_ReceiverID int,
	_DeliveryDate datetime,
	_Series nvarchar(25),
	_Number int
	)
	insert into @PhoneBook
	SELECT
		do.Receiver_FirstName, 
		do.Receiver_LastName,
		do.Receiver_Phone,
		do.Receiver_Address,
		do.Receiver_Town,
		do.Receiver_Department,
		do.Receiver_ID,
		do.Delivery_Max_Date,
		do.Guide_Serie,
		do.Guide_Number
	FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
	left join @ToUpdate tu on do.Guide_Serie=tu._Series and do.Guide_Number=tu._Number
	where not tu._Number is null
	and not tu._Series is null
	--WHERE CONVERT(VARCHAR, do.Delivery_Max_Date, 23) = CONVERT(VARCHAR, @MaxDeliveryDate, 23)

	declare @TopBatchId bigint=0
	select @TopBatchId=isnull(MAX(st.Sent_Batch_Id),0)+1
	from DeliveryBackOffice.dbo.SMS_Sent st with(nolock)

	select 
		 pb._FirstName
		,pb._LastName
		,replace(replace(replace(replace(replace(replace(ltrim(rtrim(pb._Phone)),'''',';'),'"',';'),' ',';'),'/',';'),',',';'),'-',(case when CHARINDEX('-', LTRIM(RTRIM(pb._Phone)))>8 then';'else ''end))'_Phone'
		--,pb._Phone
		--,pb._Address
		,replace(replace(replace(replace(replace(replace(ltrim(rtrim(pb._Address)),'  ',' '),' , ',','),', ',','),' ,',','),'zona ','Zona'),'avenida','Ave.')'_Address'
		,pb._Town
		,pb._Department
		,pb._ReceiverID
		,pb._DeliveryDate
		,@TopBatchId'TopBatchId'
		,pb._Series
		,pb._Number
	from @PhoneBook pb 

	INSERT INTO [dbo].[SMS_Sent]
			   ([Sent_Guide_Series]
			   ,[Sent_Guide_Number]
			   ,[Sent_Batch_Id]
			   ,[TokenCreated]
			   ,[CreatedDatetime]
			   )
			(
				select 
					 pb._Series
					,pb._Number
					,@TopBatchId
					,'SYS-SMSService'
					,GETDATE()
				from @PhoneBook pb 
			)

	update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
	set UpdateStatus=0
	where ElementId=1001

	
END
GO
