USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spws_get_services]    Script Date: 29/01/2021 10:43:16 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO





-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-17>
-- Description:	<Devuelve el listado de GUIAS asiganadas a una cuenta>
-- =============================================


ALTER PROCEDURE [dbo].[spws_get_services]
	-- Add the parameters for the stored procedure here
	--@StartDate DATETIME,
	--@EndDate DATETIME ,
	@Token VARCHAR(200),
	@IdAccount bigint,
	 --@Filter as nvarchar(50) = 'FD'
	 @Filter int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

if(@Filter = -1)
begin
	SET NOCOUNT ON;
	
	DECLARE @jsonResult NVARCHAR(MAX) 

	declare @IdUser bigint  = (select top 1 t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)



	set @jsonResult = (SELECT STUFF(( 
							select  
						  ',{"Guide":"' +   isnull(concat(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",' +
							'"RequestDate":"' + isnull( convert(varchar,ord.DateCreated,20), 'N/A')  + '",' +
							--'"Source":"' + isnull(twn.TownshipName,'N/A')  + '",' +
							--'"Destiny":"' + isnull(twd.TownshipName,'N/A') + '",' +
							'"NameofSender":"' + isnull(CAST(upper(isnull(ord.Sender_FirstName,'')) AS VARCHAR)+' '+ CAST(upper(isnull(ord.Sender_LastName,'')) AS varchar),'N/A')  + '",' +
							'"NameReceiver":"' + isnull(CAST(upper(isnull(ord.Receiver_FirstName,'')) AS VARCHAR) +' '+ CAST(upper(isnull(ord.Receiver_LastName,'')) AS VARCHAR),'N/A' ) + '",' +
							'"DateRecoleccion":"' + isnull(CAST(convert(varchar, ord.Preparation_Date,20 ) AS varchar), 'N/A')  + '",' +
							'"DateProgramadaEntrega":"' + isnull(CAST(convert( varchar, ord.Shipping_Date,20)as varchar), 'N/A')  + '",' +
							'"CurrencySymbol":"' +convert( varchar, 'Q.')  +  '",' +
							--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
							'"PrecioServicio":"' + CONVERT(varchar,cast( coalesce(ord.PriceShippment ,'0')as money),1)   + '",' +
							'"CollectOnDelivery":"' + CONVERT(varchar,cast(coalesce(ord.Collect_OnDelivery,'0')as money),1)   + '",' +
							'"IdStatus":' + CONVERT(varchar, coalesce(sto.StatusOrderId ,'0'))   + ',' +
							'"Status":"' + isnull(convert( varchar, sto.OrderDescription) , 'N/A') +  '",' +
							'"WayToPay":"' + isnull(convert( varchar,CASE WHEN ord.IsCollect = 1 THEN 'DESTINO' ELSE 'ORIGEN' END) ,'N/A') +  '",' +
							'"TypePayment":"' + isnull(convert( varchar, CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END),'N/A')  +  '",' +
							'"CollectDelivery":"' + isnull(CONVERT(varchar,CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') + --'",' +
						
							+ '"}'

						from dbo.DeliveryOrder ord
						join dbo.StatusOrder sto on sto.StatusOrderId =  ord.StatusOrderId
					   
					--select convert(varchar ,cast(2000 as money),1) from 
					


						 where ord.Sender_ID in(select ua.CodeOfReference from dbo.RolByUserByAccount  rua
					    inner join dbo.UserAddress ua on ua.UadIdAccount = rua.RuaIdAccount
						where rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser and rua.RuaRowStatus = 1 and ua.CodeOfReference is not null) or (ord.Sender_ID = 0 and ord.IdCustomer = (select Top 1 IdCustomer from Account  where AccIdAccount = @IdAccount))

					--	where ord.Sender_ID = 4244
						--and (ord.DateCreated between @StartDate and @EndDate)
						--and (@Filter = '-1' or concat(ord.Guide_Serie,ord.Guide_Number)   like '%'+@Filter+ '%'
						--	or twn.TownshipName like '%'+@Filter+ '%'
						--	or twd.TownshipName like '%'+@Filter+ '%' )
					
					

					FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )
									print 'ingresa2'
										print @jsonResult

		-- retornar resultado en formato json
	If @jsonResult is null 

	begin

		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se econtraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		select ('[' + @jsonResult +  ']') jsonResult

end



IF(@Filter = 1)
begin
	SET NOCOUNT ON;

	DECLARE @jsonResult1 NVARCHAR(MAX) 

	declare @IdUser1 bigint  = (select top 1 t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)



	set @jsonResult = (SELECT STUFF(( 
							select  
						  ',{"Guide":"' +   isnull(concat(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",' +
							'"RequestDate":"' + isnull( convert(varchar,ord.DateCreated,20), 'N/A')  + '",' +
							--'"Source":"' + isnull(twn.TownshipName,'N/A')  + '",' +
							--'"Destiny":"' + isnull(twd.TownshipName,'N/A') + '",' +
							'"NameofSender":"' + isnull(CAST(upper(isnull(ord.Sender_FirstName,'')) AS VARCHAR)+' '+ CAST(upper(isnull(ord.Sender_LastName,'')) AS varchar),'N/A')  + '",' +
							'"NameReceiver":"' + isnull(CAST(upper(isnull(ord.Receiver_FirstName,'')) AS VARCHAR) +' '+ CAST(upper(isnull(ord.Receiver_LastName,'')) AS VARCHAR),'N/A' ) + '",' +
							'"DateRecoleccion":"' + isnull(CAST(convert(varchar, ord.Preparation_Date,20 ) AS varchar), 'N/A')  + '",' +
							'"DateProgramadaEntrega":"' + isnull(CAST(convert( varchar, ord.Shipping_Date,20)as varchar), 'N/A')  + '",' +
							'"CurrencySymbol":"' +convert( varchar, 'Q.')  +  '",' +
							--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
							'"PrecioServicio":"' + CONVERT(varchar,cast( coalesce(ord.PriceShippment ,'0')as money),1)   + '",' +
							'"CollectOnDelivery":"' + CONVERT(varchar,cast(coalesce(ord.Collect_OnDelivery,'0')as money),1)   + '",' +
							'"IdStatus":' + CONVERT(varchar, coalesce(sto.StatusOrderId ,'0'))   + ',' +
							'"Status":"' + isnull(convert( varchar, sto.OrderDescription) , 'N/A') +  '",' +
							'"WayToPay":"' + isnull(convert( varchar,CASE WHEN ord.IsCollect = 1 THEN 'DESTINO' ELSE 'ORIGEN' END) ,'N/A') +  '",' +
							'"TypePayment":"' + isnull(convert( varchar, CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END),'N/A')  +  '",' +
							'"CollectDelivery":"' + isnull(CONVERT(varchar,CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') + --'",' +
						
							+ '"}'

						from dbo.DeliveryOrder ord
						join dbo.Township twn on twn.IdTownship = ord.SenderIdTownship
						join dbo.Township twd on twd.IdTownship = ord.ReceiverIdTownship
						join dbo.StatusOrder sto on sto.StatusOrderId =  ord.StatusOrderId
						 where ord.Sender_ID in(select ua.CodeOfReference from dbo.RolByUserByAccount  rua
					    inner join dbo.UserAddress ua on ua.UadIdAccount = rua.RuaIdAccount
						where (rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser1 and rua.RuaRowStatus = 1 and ua.CodeOfReference is not null) or (ord.Sender_ID = 0 and ord.IdCustomer = (select Top 1 IdCustomer from Account  where AccIdAccount = @IdAccount)))
				
				
					--	where ord.Sender_ID = 4244
						--and (ord.DateCreated between @StartDate and @EndDate)
						--and (@Filter = '-1' or concat(ord.Guide_Serie,ord.Guide_Number)   like '%'+@Filter+ '%'
						--	or twn.TownshipName like '%'+@Filter+ '%'
						--	or twd.TownshipName like '%'+@Filter+ '%' )

						and  ord.StatusOrderId = 15

					FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )

		-- retornar resultado en formato json
	If @jsonResult is null 

	begin

		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se econtraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		select ('[' + @jsonResult +  ']') jsonResult


end

if(@Filter = 2)
begin
	SET NOCOUNT ON;

	DECLARE @jsonResult2 NVARCHAR(MAX) 

	declare @IdUser2 bigint  = (select top 1 t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)



	set @jsonResult = (SELECT STUFF(( 
							select  
							 ',{"Guide":"' +   isnull(concat(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",' +
							'"RequestDate":"' + isnull( convert(varchar,ord.DateCreated,20), 'N/A')  + '",' +
							--'"Source":"' + isnull(twn.TownshipName,'N/A')  + '",' +
							--'"Destiny":"' + isnull(twd.TownshipName,'N/A') + '",' +
							'"NameofSender":"' + isnull(CAST(upper(isnull(ord.Sender_FirstName,'')) AS VARCHAR)+' '+ CAST(upper(isnull(ord.Sender_LastName,'')) AS varchar),'N/A')  + '",' +
							'"NameReceiver":"' + isnull(CAST(upper(isnull(ord.Receiver_FirstName,'')) AS VARCHAR) +' '+ CAST(upper(isnull(ord.Receiver_LastName,'')) AS VARCHAR),'N/A' ) + '",' +
							'"DateRecoleccion":"' + isnull(CAST(convert(varchar, ord.Preparation_Date,20 ) AS varchar), 'N/A')  + '",' +
							'"DateProgramadaEntrega":"' + isnull(CAST(convert( varchar, ord.Shipping_Date,20)as varchar), 'N/A')  + '",' +
							'"CurrencySymbol":"' +convert( varchar, 'Q.')  +  '",' +
							--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
							'"PrecioServicio":"' + CONVERT(varchar,cast( coalesce(ord.PriceShippment ,'0')as money),1)   + '",' +
							'"CollectOnDelivery":"' + CONVERT(varchar,cast(coalesce(ord.Collect_OnDelivery,'0')as money),1)   + '",' +
							'"IdStatus":' + CONVERT(varchar, coalesce(sto.StatusOrderId ,'0'))   + ',' +
							'"Status":"' + isnull(convert( varchar, sto.OrderDescription) , 'N/A') +  '",' +
							'"WayToPay":"' + isnull(convert( varchar,CASE WHEN ord.IsCollect = 1 THEN 'DESTINO' ELSE 'ORIGEN' END) ,'N/A') +  '",' +
							'"TypePayment":"' + isnull(convert( varchar, CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END),'N/A')  +  '",' +
							'"CollectDelivery":"' + isnull(CONVERT(varchar,CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') + --'",' +
						
							+ '"}'

						from dbo.DeliveryOrder ord
						join dbo.Township twn on twn.IdTownship = ord.SenderIdTownship
						join dbo.Township twd on twd.IdTownship = ord.ReceiverIdTownship
						join dbo.StatusOrder sto on sto.StatusOrderId =  ord.StatusOrderId
						 where ord.Sender_ID in(select ua.CodeOfReference from dbo.RolByUserByAccount  rua
					    inner join dbo.UserAddress ua on ua.UadIdAccount = rua.RuaIdAccount
						where (rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser2 and rua.RuaRowStatus = 1 and ua.CodeOfReference is not null) or (ord.Sender_ID = 0 and ord.IdCustomer = (select Top 1 IdCustomer from Account  where AccIdAccount = @IdAccount)))
					--	where ord.Sender_ID = 4244
						--and (ord.DateCreated between @StartDate and @EndDate)
						--and (@Filter = '-1' or concat(ord.Guide_Serie,ord.Guide_Number)   like '%'+@Filter+ '%'
						--	or twn.TownshipName like '%'+@Filter+ '%'
						--	or twd.TownshipName like '%'+@Filter+ '%' )
						and ord.StatusOrderId not in (15,5,7) and ord.StatusOrderId > 0

					FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )

		-- retornar resultado en formato json
	If @jsonResult is null 

	begin

		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se econtraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		select ('[' + @jsonResult +  ']') jsonResult

end


if(@Filter = 3)
begin

	SET NOCOUNT ON;

	DECLARE @jsonResult3 NVARCHAR(MAX) 

	declare @IdUser3 bigint  = (select top 1 t.TknIdUser from TokenLog t
						where t.TknIdToken = @Token)



	set @jsonResult = (SELECT STUFF(( 
							select  
							 ',{"Guide":"' +   isnull(concat(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",' +
							'"RequestDate":"' + isnull( convert(varchar,ord.DateCreated,20), 'N/A')  + '",' +
							--'"Source":"' + isnull(twn.TownshipName,'N/A')  + '",' +
							--'"Destiny":"' + isnull(twd.TownshipName,'N/A') + '",' +
							'"NameofSender":"' + isnull(CAST(upper(isnull(ord.Sender_FirstName,'')) AS VARCHAR)+' '+ CAST(upper(isnull(ord.Sender_LastName,'')) AS varchar),'N/A')  + '",' +
							'"NameReceiver":"' + isnull(CAST(upper(isnull(ord.Receiver_FirstName,'')) AS VARCHAR) +' '+ CAST(upper(isnull(ord.Receiver_LastName,'')) AS VARCHAR),'N/A' ) + '",' +
							'"DateRecoleccion":"' + isnull(CAST(convert(varchar, ord.Preparation_Date,20 ) AS varchar), 'N/A')  + '",' +
							'"DateProgramadaEntrega":"' + isnull(CAST(convert( varchar, ord.Shipping_Date,20)as varchar), 'N/A')  + '",' +
							'"CurrencySymbol":"' +convert( varchar, 'Q.')  +  '",' +
							--'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
							'"PrecioServicio":"' + CONVERT(varchar,cast( coalesce(ord.PriceShippment ,'0')as money),1)   + '",' +
							'"CollectOnDelivery":"' + CONVERT(varchar,cast(coalesce(ord.Collect_OnDelivery,'0')as money),1)   + '",' +
							'"IdStatus":' + CONVERT(varchar, coalesce(sto.StatusOrderId ,'0'))   + ',' +
							'"Status":"' + isnull(convert( varchar, sto.OrderDescription) , 'N/A') +  '",' +
							'"WayToPay":"' + isnull(convert( varchar,CASE WHEN ord.IsCollect = 1 THEN 'DESTINO' ELSE 'ORIGEN' END) ,'N/A') +  '",' +
							'"TypePayment":"' + isnull(convert( varchar, CASE WHEN ord.IsCollect = 1 THEN 'EFECTIVO' ELSE 'TARJETA' END),'N/A')  +  '",' +
							'"CollectDelivery":"' + isnull(CONVERT(varchar,CASE WHEN ord.IsCollect = 1 THEN 'SI' ELSE 'NO' END), 'N/A') + --'",' +
						
							+ '"}'

						from dbo.DeliveryOrder ord
						join dbo.Township twn on twn.IdTownship = ord.SenderIdTownship
						join dbo.Township twd on twd.IdTownship = ord.ReceiverIdTownship
						join dbo.StatusOrder sto on sto.StatusOrderId =  ord.StatusOrderId
						 where ord.Sender_ID in(select ua.CodeOfReference from dbo.RolByUserByAccount  rua
					    inner join dbo.UserAddress ua on ua.UadIdAccount = rua.RuaIdAccount
						where (rua.RuaIdAccount = @IdAccount and rua.RuaIdUser = @IdUser3 and rua.RuaRowStatus = 1 and ua.CodeOfReference is not null) or (ord.Sender_ID = 0 and ord.IdCustomer = (select Top 1 IdCustomer from Account  where AccIdAccount = @IdAccount)))
					--	where ord.Sender_ID = 4244
						--and (ord.DateCreated between @StartDate and @EndDate)
						--and (@Filter = '-1' or concat(ord.Guide_Serie,ord.Guide_Number)   like '%'+@Filter+ '%'
						--	or twn.TownshipName like '%'+@Filter+ '%'
						--	or twd.TownshipName like '%'+@Filter+ '%' )
						and ord.StatusOrderId = 5

					FOR XML PATH(''), TYPE
							).value('.', 'varchar(max)'),1,1,''
									) )

		-- retornar resultado en formato json
	If @jsonResult is null 

	begin

		set @jsonResult =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se econtraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		select ('[' + @jsonResult +  ']') jsonResult

end



END



GO


