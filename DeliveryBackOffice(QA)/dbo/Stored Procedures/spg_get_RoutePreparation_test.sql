

-- =============================================
-- Author:		<Bidcar, Herrera>
-- Create date: <2020-05-27>
-- Description:	<Devuelve información para preparación de ruta>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_RoutePreparation_test]

		@Token AS VARCHAR(50)    = 'ad1a2328ed27ea99622f68deae5d9976',
		@Rol AS BIGINT 			 =  1,
		@Zone AS VARCHAR(100) = '',
		@Department AS VARCHAR(100) = '',
		@Town AS VARCHAR(100) ='',
		@Manifest AS VARCHAR(50) = '',
		@DateSettlement AS VARCHAR(50) = '',
		@HideOrigin BIT = 0, -- status 6
		@HideForza BIT = 0 -- status 8
AS
--
--exec [dbo].[spg_get_RoutePreparation] @Manifest = 'FM1003'
BEGIN
/*
	declare @Guias as table(Guide nvarchar(150),	
							Name nvarchar(300),	
							Address nvarchar(300),	
							Zone nvarchar(150),	
							Town nvarchar(150),	
							Department	nvarchar(150),
							DateSettlement	datetime,
							Receiver_Alternant_Address	nvarchar(200),
							Delivery_Max_Date	datetime,
							Courier_Route	nvarchar(150),
							Courier_Name	nvarchar(200),
							Dispatched_Date	datetime,
							Manifest_Number	nvarchar(150),
							Date_Created	datetime,
							Sender_Fullname	nvarchar(200),
							Ticket_Number	nvarchar(150),
							Pieces_Dry	int,
							Pieces_Cold	int,
							Status_Order_Id	nvarchar(150),
							Receiver_Phone	nvarchar(150),
							Package_Type	nvarchar(150),
							Rack_Position varchar(150),
							Contact_Confirmed bit,
							Contact_Instructions nvarchar(200)						
							)
							*/
		--insert into @Guias
		SELECT  			 
			serv.Guide_Serie +  CAST(serv.Guide_Number AS VARCHAR) Guide,		
			serv.Receiver_FirstName + ' '+ serv.Receiver_LastName 'Name',
			serv.Receiver_Address 'Address',
			serv.Receiver_Zone 'Zone',
			serv.Receiver_Town Town,
			serv.Receiver_Department Department,
			'' DateSettlement,
			serv.Receiver_Alternant_Address,
			serv.Delivery_Max_Date Delivery_Max_Date,
			serv.Courier_Route Courier_Route,
			serv.Courier_Name Courier_Name,
			serv.Dispatched_Date Dispatched_Date,
			serv.Manifest_Serie + CAST(serv.Manifest_Number AS VARCHAR) as Manifest_Number,
			serv.DateCreated as Date_Created,
			serv.Sender_FirstName + ' ' + serv.Sender_LastName as Sender_Fullname,
			serv.Ticket_Number as Ticket_Number,
			serv.Pieces_Dry as Pieces_Dry,
			serv.Pieces_Cold as Pieces_Cold,
			(SELECT so.OrderDescription FROM StatusOrder so WHERE so.StatusOrderId = serv.StatusOrderId) as Status_Order_Id,
			serv.Receiver_Phone as Receiver_Phone,
			(SELECT p.Package_Name FROM Package p WHERE p.Package_Type = serv.Package_Type) as Package_Type,
		
			(SELECT DeliveryBackOffice.dbo.fn_get_rackposition(serv.Guide_Serie, serv.Guide_Number)) as Rack_Position,
			ISNULL(serv.Contact_Confirmed, 0) as Contact_Confirmed,
			serv.Contact_Instructions

		    ,serv.Guide_Serie
			,serv.Guide_Number
		into #Guias
		FROM DeliveryBackOffice.DBO.DeliveryOrder serv WITH (NOLOCK)
		JOIN DeliveryBackOffice.dbo.StatusOrder sta ON sta.StatusOrderId = serv.StatusOrderId
		WHERE 
		serv.StatusOrderId <> 7 AND -- ocultar los servicios anulados
		serv.StatusOrderId <> 5 AND -- ocultar los servicios entregados
		serv.Manifest_Number <> 999 AND -- ocultar primer servicio (semilla)
		( -- ocultar las guías que tengan en su historia retornado al origen
			@HideOrigin = 0
			OR
			serv.Guide_Number NOT IN (
				SELECT distinct [Guide_Number] FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] where StatusOrderId = 6
			)
		) AND
		( -- ocultar las guías que tengan en su historia retornado a Forza
			@HideForza = 0
			OR
			serv.Guide_Number NOT IN (
				SELECT distinct [Guide_Number] FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] where StatusOrderId = 8
			)
		) AND
		(@Zone = '' OR Receiver_Zone = @Zone)  AND
		(@Department = '' OR Receiver_Department = @Department ) AND
		(@Town = '' OR Receiver_Town = @Town) AND		
		(
		 @Manifest = '' OR 
		  (
		  Manifest_Serie +  CAST(Manifest_Number AS VARCHAR) = @Manifest		   
		  )
		 )  
		

		 --declare @CleanData as table(_number nvarchar(50), _name nvarchar(300), _phone nvarchar(50))
		  --insert into #CleanData
		  select 
			dc.Guide _number,
			dc.Name _name,
			ltrim(rtrim(sp.items )) _phone

			,dc.Guide_Serie
			,dc.Guide_Number
		  into #CleanData
		  from #Guias dc outer apply 
		  DeliveryBackOffice.dbo.fn_Splits(replace(replace(replace(replace(replace(replace(replace(ltrim(rtrim(dc.Receiver_Phone)),'''','||')
		  ,'"','||'),' ','||'),'/','||'),';','||'),',','||'),'-',(case when CHARINDEX('-', LTRIM(RTRIM(dc.Receiver_Phone)))>8 then'||'else ''end))
		  ,'||') sp



		  
		 --declare @completed as table(guide_number nvarchar(50), namereceiver nvarchar(300), phonereceiver nvarchar(50), sms_message nvarchar(300))
		  --insert into @completed
		  select 
			c._number guide_number,
			c._name namereceiver,
			c._phone phonereceiver,
			r.SMS_Message sms_message

			,c.Guide_Serie _Guide_Serie
			,c.Guide_Number _Guide_Number
		   into #completed		 
		  from #CleanData c
		  left join DeliveryBackOffice.dbo.SMS_Received r with(nolock)		  
		  on CONCAT('502',c._phone) 
		  collate SQL_Latin1_General_CP1_CI_AS = r.SMS_MSisdn 
		  collate SQL_Latin1_General_CP1_CI_AS
		  GROUP BY c._number,
				   c._name,
				   c._phone,
				   r.SMS_Message		
				   ,c.Guide_Serie
				   ,c.Guide_Number

				 
		 --declare @JointTable as table(Guide_Number nvarchar(150), Receiver_Name nvarchar(250), Alter_Address nvarchar(500))
		 --insert into @JointTable
		 select distinct c.guide_number Guide_Number, 
				c.namereceiver Receiver_Name, 
				STUFF(( SELECT  '| ' + CONVERT(VARCHAR,B.sms_message)  +' '
							FROM    #completed B
							WHERE   --B.guide_number = c.guide_number
							B._Guide_Serie = c._Guide_Serie
							and B._Guide_Number = c._Guide_Number
						  FOR
							XML PATH('')
						  ), 1, 1, '') AS Alter_Address
						  ,c._Guide_Serie
						  ,c._Guide_Number
		 into #JointTable
		 from #completed c
		 
		 				
		select g.Guide ,	
			g.Name ,	
			g.Address ,	
			g.Zone ,	
			g.Town ,	
			g.Department	,
			g.DateSettlement	,
			g.Receiver_Alternant_Address	,
			jt.Alter_Address,
			g.Delivery_Max_Date	,
			g.Courier_Route	,
			g.Courier_Name	,
			g.Dispatched_Date	,
			g.Manifest_Number	,
			g.Date_Created	,
			g.Sender_Fullname	,
			g.Ticket_Number	,
			g.Pieces_Dry	,
			g.Pieces_Cold	,
			g.Status_Order_Id	,
			g.Receiver_Phone	,
			g.Package_Type	,
			g.Rack_Position ,
			g.Contact_Confirmed,
			g.Contact_Instructions			
		from #Guias g
		--left 
		join #JointTable jt
--		on g.Guide=jt.Guide_Number
		on g.Guide_Serie = jt._Guide_Serie
		and g.Guide_Number = jt._Guide_Number
				
END
