USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_address]    Script Date: 11/02/2021 11:49:17 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

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


	set @jsonResult = (SELECT STUFF(( 
				select 
			 ',{"CodeOfReference":"' + convert( varchar,	isnull(vpc.CodeOfReference,0))  + '",' +
				'"Sender":"' +  isnull(isnull(spk.SenderName,vpc.DescriptionOfClient), 'N/A') + '",' +
				'"Address":"' +  concat( ISNULL( isnull(spk.AddressPickup , vpc.Address) ,'N/A'), ' ' , vpc.Town , ' ' , vpc.Department) + '",' +
				'"Phone":"' +  isnull( isnull(spk.SenderPhone , vpc.Phone)  ,'N/A') + '",' +
				'"Pieces":"' + convert(varchar,(isnull(spk.QuantityOverDimensionedPackage ,0) + isnull(spk.QuantityOverDimensionedPackage ,0) )) + '",' +
				'"Schedule":"' +   concat( substring( CONVERT(varchar, spk.StartDate  ,8),0,6) , ' - ',  substring(CONVERT(varchar, spk.EndDate  ,8),0,6)  ) + '",' +
				'"Photo":"' + '#'  + '",' +
				'"Latitude":"' + '0'  + '",' +
				'"Longitude":"' + '0'  + '",' +
				'"Precision":"' + '0'  + 
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

END

