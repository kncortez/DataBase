CREATE PROCEDURE [dbo].[spUpdateGuidesByMSJ] 
AS
BEGIN


	declare @ListSMS as table (
	ID int IDENTITY (1, 1),
	SMS_ID bigint,
	SMS_Message nvarchar(500),
	SMS_MSisdn nvarchar(50)
	)

	declare @LastSMSID as bigint
	
	--Obtener último valor procesado
	select @LastSMSID = MAX(SmsId) from DeliveryBackOffice.dbo.GuidesBySMS		
    set @LastSMSID = COALESCE(@LastSMSID,0)

	select @LastSMSID

	if (@LastSMSID = 0)
	BEGIN
	  insert into @ListSMS
	   select SMS_ID,SMS_Message,SMS_MSisdn 
	  from DeliveryBackOffice.dbo.SMS_Received SMR
	  where CAST(SMS_TokenCreatedDatetime as date) >= CAST('2021-04-26' as date)
	  order by SMS_ID desc
	END
	ELSE
	BEGIN
	   insert into @ListSMS
	   select SMS_ID,SMS_Message,SMS_MSisdn 
	  from DeliveryBackOffice.dbo.SMS_Received SMR
	  where SMR.SMS_ID > @LastSMSID
	END

	select * from @ListSMS

	DECLARE @CountList int = (select count(1) from @ListSMS)
	DECLARE @IdentityElements INT = 1
	DECLARE @Phone varchar(50) 
	DECLARE @SmsID bigint

	while (@CountList > 0)
	BEGIN
	 select @Phone = SMS_MSisdn,@SmsID = SMS_ID  from @ListSMS
	 where ID = @IdentityElements

	 insert into DeliveryBackOffice.dbo.GuidesBySMS
	 (SmsId,GuideSerie,GuideNumber,RowStatus,TokenCreated,DateCreated)
		select
		SMSID,Guide_Serie,Guide_Number,1,'SYSTEM-SENDER',getdate()
		from
		(
		select 
			@SmsID SMSID,
			dc.Guide_Serie,
			dc.Guide_number,
			ltrim(rtrim(sp.items )) _phone
			--,Receiver_Phone
		  from DeliveryBackOffice.dbo.DeliveryOrder dc outer apply 
		  DeliveryBackOffice.dbo.fn_Splits(replace(replace(replace(replace(replace(replace(replace
		  (ltrim(rtrim(dc.Receiver_Phone)),'''','||')
		  ,'"','||'),' ','||'),'/','||'),';','||'),',','||'),'-',
		  (case when CHARINDEX('-', LTRIM(RTRIM(dc.Receiver_Phone)))>8 then'||'else ''end))
		  ,'||') sp
		  where dc.Receiver_Phone like '%' +substring(@Phone,4,len(@Phone)) + '%'
		) Lst			
		where Lst._phone =  substring(@Phone,4,len(@Phone))
		and
		not exists 
		(  select 1 from DeliveryBackOffice.dbo.GuidesBySMS GBS 
		   where Lst.Guide_Serie = GBS.GuideSerie 
		   and Lst.Guide_number = GBS.GuideNumber
		   and Lst.SMSID = GBS.SmsId
		)

	 insert into DeliveryBackOffice.dbo.GuidesBySMS
	 (SmsId,GuideSerie,GuideNumber,RowStatus,TokenCreated,DateCreated)
		select distinct
		SMSID,null,null,1,'SYSTEM-SENDER-NODATA',getdate()
		from
		(
		select  
			@SmsID SMSID,
			Guide_Serie,
			Guide_Number,
			ltrim(rtrim(sp.items )) _phone
			--,Receiver_Phone
		  from DeliveryBackOffice.dbo.DeliveryOrder dc outer apply 
		  DeliveryBackOffice.dbo.fn_Splits(replace(replace(replace(replace(replace(replace(replace
		  (ltrim(rtrim(dc.Receiver_Phone)),'''','||')
		  ,'"','||'),' ','||'),'/','||'),';','||'),',','||'),'-',
		  (case when CHARINDEX('-', LTRIM(RTRIM(dc.Receiver_Phone)))>8 then'||'else ''end))
		  ,'||') sp
		  where dc.Receiver_Phone like '%' +substring(@Phone,4,len(@Phone)) + '%'
		) Lst			
		where Lst._phone =  substring(@Phone,4,len(@Phone))		
		and exists 
		(  select 1 from DeliveryBackOffice.dbo.GuidesBySMS GBS 
		   where Lst.Guide_Serie = GBS.GuideSerie 
		   and Lst.Guide_number = GBS.GuideNumber
		   and Lst.SMSID != GBS.SMSID
		)
		set @IdentityElements = @IdentityElements +1
		set @CountList = @CountList -1

	END
	

END
