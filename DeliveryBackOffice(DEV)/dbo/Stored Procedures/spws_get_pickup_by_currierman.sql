
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-01-08>
-- Description:	<Devuelve el listado de Direcciones asiganadas a una cuenta>
-- =============================================

CREATE PROCEDURE [dbo].[spws_get_pickup_by_currierman]
	-- Add the parameters for the stored procedure here
	@Token VARCHAR(200),
	@IdCurrier bigint,
	@DateRoute date 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @jsonResult NVARCHAR(MAX) 

	-- TOD VALIDAR TOKEN DE CUERRIERMAN
	--declare @IdCurrier bigint  = (select top 1 t.TknIdUser from TokenLog t
				--		where t.TknIdToken = @Token)

	DECLARE @jsonToken NVARCHAR(MAX)
	 declare @TokenAct int  = (select top 1 RowStatus from LogTokenPOD where LogTokenPOD LIKE '%' + @Token + '%' order by DateCreated desc)
     declare @hourtoken int = (select DATEDIFF(HOUR, DateCreated, GETDATE() ) as horas from LogTokenPOD where LogTokenPOD  LIKE '%' + @Token + '%')
	

	if (@TokenAct = 1 and @hourtoken <= 8)
		begin 


						set @jsonResult = (SELECT STUFF(( 
							select 
									',{"CodeOfReference":"' + convert( varchar,	isnull(vpc.CodeOfReference,0))  + '",' +
									'"IdPickup":"' +  isnull( convert(varchar,spk.SchedulePickupId) , '-1') + '",' +
									'"ServiceManagementId":"' +  isnull( convert(varchar,sma.IdServiceManagement) , 'N/A') + '",' +
									'"Sender":"' +  isnull(isnull(spk.SenderName,vpc.DescriptionOfClient), 'N/A') + '",' +
									'"Address":"' +  concat( ISNULL( isnull(spk.AddressPickup , vpc.Address) ,'N/A'), ' ' , vpc.Town , ' ' , vpc.Department) + '",' +
									'"Phone":"' +  isnull( isnull(spk.SenderPhone , vpc.Phone)  ,'N/A') + '",' +
									'"Pieces":"' + CONVERT(varchar,isnull((select (sum(isnull(ord.Pieces_Dry,0))+ sum(isnull(ord.Pieces_Cold,0))) pieces
																from dbo.DeliveryOrderPaymentDetail pay
																	left join dbo.DeliveryOrder ord on ord.Guide_Serie = pay.GuideSerie and ord.Guide_Number = pay.GuideNumber
																where pay.IdHeaderRecolection = spk.SchedulePickupId),0))  + '",' +
									'"ScheduleStart":"' +    substring( CONVERT(varchar, spk.StartDate  ,8),0,6)  + '",' +
									'"ScheduleEnd":"' +     substring(CONVERT(varchar, spk.EndDate  ,8),0,6)   + '",' +
									'"Photo":"' + '#'  + '",' +
									'"Latitude":"' + '0'  + '",' +
									'"Longitude":"' + '0'  + '",' +
									'"Precision":"' + '0'  +  '",' +
									'"Status":"' + convert(varchar,isnull(sma.ServiceStatusId,1))  +
										+ '"}'
									from dbo.RouteAssigment ras
									left join dbo.ServiceManagement sma on sma.IdPuRouteAssigment = ras.IdRouteAssigment
									left join dbo.SchedulePickup spk on spk.SchedulePickupId = sma.IdSchedulePickup
									left join dbo.VisitPointClient vpc on vpc.CodeOfReference = spk.SenderId 
										where ras.IdCurrierMan= @IdCurrier and ras.DateOfRoute = @DateRoute
					
								FOR XML PATH(''), TYPE
									).value('.', 'varchar(max)'),1,1,''
											) )
					
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
						
		else if(@TokenAct = 0 or @TokenAct is null or @hourtoken > 8)
		begin 
			  print 'token inválido'
					SET @jsonToken = (
				   SELECT STUFF((
		   			SELECT  
					',{"IdResult":' + '403' + ',' +
					'"DescriptionError":"' + 'Token inválido'  + '"' +	  	  
					'}' 
					FOR XML PATH(''), TYPE
				   ).value('.', 'varchar(max)'),1,1,''
		   					  ) 
				   )
					 select '['+ @jsonToken + ']' jsonToken
	
				   return
		end
END

