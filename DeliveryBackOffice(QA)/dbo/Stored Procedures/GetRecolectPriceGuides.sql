-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recotizacion>
-- =============================================
CREATE PROCEDURE [dbo].[GetRecolectPriceGuides]	
	@TblDeliveryOrdersList AS [TblDeliveryOrdersList] READONLY	
AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY
	
	DECLARE @jsonResult NVARCHAR(MAX)
	DECLARE @Pickup_CreditCard_Rate DECIMAL
	DECLARE @FinalPickup_Rate DECIMAL

	--Obtener diferencia en horas de la solicitud de recolección y la hora actual
	DECLARE @DiffHours int = (select top 1 DATEDIFF(hour, getdate(),StartDate ) AS DateDiff from @TblDeliveryOrdersList)

	DECLARE @DiffMinutes int = (select top 1 DATEDIFF(minute, getdate(),StartDate ) AS DateDiff from @TblDeliveryOrdersList)

	print '@DiffHours__'
	print @DiffHours

	print '@DiffMinutes__'
	print @DiffMinutes % 60

	--Obtener comisión collect
	Declare @PickupRate decimal
	select @PickupRate = CAST(Value AS DECIMAL)
	from DeliveryBackOffice.dbo.CatToCharge
	where Name = 
	CASE 
	 WHEN @DiffHours > 24 
	  THEN 'PickupRateSpecial' 
	 WHEN @DiffHours = 24 and @DiffMinutes % 60 > 0	  
	  THEN 'PickupRateSpecial'
	ELSE 'PickupRate' END 
	
	print cast( @PickupRate as varchar)
	--Obtener comisión por pago con tarjeta 
	DECLARE @CreditCardRate DECIMAL
	SELECT @CreditCardRate = CAST(Value AS DECIMAL)
	FROM DeliveryBackOffice.dbo.CatToCharge
	WHERE Name = 'CreditCardRate'

	--SELECT *
	--FROM DeliveryBackOffice.dbo.CatToCharge
	--WHERE Name = 'CreditCardRate'
	
	SET @Pickup_CreditCard_Rate =   @PickupRate + @CreditCardRate ;
	
	--Actualizar guías que no están completas
	UPDATE DSch
	SET 
	 DSch.TypeofInOutMoneyId = trq.IdWayToPayment	
	,DSch.PayTypeId = trq.IdTypePayment
	,DSch.TimePlaId = trq.IdTimePayment
	,DSch.ShipmentCompleted = 1	
	FROM DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch
	INNER JOIN
	@TblDeliveryOrdersList trq
	ON trq.ShipmentCompleted = 0
	and trq.Guide_Serie = DSch.GuideSerie
	and trq.Guide_Number = DSch.GuideNumber
	
	--UPDATE Sch
	--SET Sch.AmountPickup = case 
	--when trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 and trq.IdTypePayment = 1 
	--then @Pickup_CreditCard_Rate
	--else @PickupRate END
	--FROM DeliveryBackOffice.dbo.SchedulePickup Sch
	--JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch
	--on Sch.SchedulePickupId = DSch.IdHeaderRecolection
	--JOIN @TblDeliveryOrdersList trq
	--ON 
	--trq.Guide_Serie = DSch.GuideSerie
	--and trq.Guide_Number = DSch.GuideNumber
	----and trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 
	

	IF @PickupRate != 0
	BEGIN
	
		SET @FinalPickup_Rate = (SELECT TOP 1
	case 
	when trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 and trq.IdTypePayment = 1 
	then @Pickup_CreditCard_Rate	
	--WHEN trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 and trq.IdTypePayment = 1 AND DSch.TransaccionFAC IS NOT NULL
	--THEN CASE WHEN Sch.AmountPickup 
	else  @PickupRate END 
	FROM DeliveryBackOffice.dbo.SchedulePickup Sch
	JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch
	on Sch.SchedulePickupId = DSch.IdHeaderRecolection
	JOIN @TblDeliveryOrdersList trq
	ON 
	trq.Guide_Serie = DSch.GuideSerie
	and trq.Guide_Number = DSch.GuideNumber
	--and trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 
	--WHERE Sch.AmountPickup = 0
	ORDER BY 1 DESC)
	--A cada solicitud de recolección ponerle el costo y agregar el costo por pago con tarjeta
	UPDATE Sch
	SET Sch.AmountPickup = @FinalPickup_Rate
	FROM DeliveryBackOffice.dbo.SchedulePickup Sch
	JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch
	on Sch.SchedulePickupId = DSch.IdHeaderRecolection
	JOIN @TblDeliveryOrdersList trq
	ON 
	trq.Guide_Serie = DSch.GuideSerie
	and trq.Guide_Number = DSch.GuideNumber
	--and trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 
	
	END
	ELSE
	BEGIN
	
		SET @FinalPickup_Rate = (SELECT TOP 1
	case 
	when trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 and trq.IdTypePayment = 1 AND DSch.TransaccionFAC IS NULL
	then @Pickup_CreditCard_Rate	
	--WHEN trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 and trq.IdTypePayment = 1 AND DSch.TransaccionFAC IS NOT NULL
	--THEN CASE WHEN Sch.AmountPickup 
	else  @PickupRate END 
	FROM DeliveryBackOffice.dbo.SchedulePickup Sch
	JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch
	on Sch.SchedulePickupId = DSch.IdHeaderRecolection
	JOIN @TblDeliveryOrdersList trq
	ON 
	trq.Guide_Serie = DSch.GuideSerie
	and trq.Guide_Number = DSch.GuideNumber
	--and trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 
	--WHERE Sch.AmountPickup = 0
	ORDER BY 1 DESC)

	UPDATE Sch
	SET Sch.AmountPickup = @FinalPickup_Rate
	FROM DeliveryBackOffice.dbo.SchedulePickup Sch
	JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch
	on Sch.SchedulePickupId = DSch.IdHeaderRecolection
	JOIN @TblDeliveryOrdersList trq
	ON 
	trq.Guide_Serie = DSch.GuideSerie
	and trq.Guide_Number = DSch.GuideNumber
	--and trq.IdWayToPayment = 2 and trq.IdTimePayment = 1 
	--WHERE Sch.AmountPickup = 0
	END
	----------------

	UPDATE  DSch
	SET DSch.TypeofInOutMoneyId = trq.IdWayToPayment	
	,DSch.PayTypeId = trq.IdTypePayment
	,DSch.TimePlaId = trq.IdTimePayment
	FROM DeliveryBackOffice.dbo.SchedulePickup Sch
	JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch
	on Sch.SchedulePickupId = DSch.IdHeaderRecolection
	JOIN @TblDeliveryOrdersList trq
	ON 
	trq.Guide_Serie = DSch.GuideSerie
	and trq.Guide_Number = DSch.GuideNumber
	--and trq.IdWayToPayment = 2 

		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
			select ERROR_MESSAGE()
			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' +  convert(varchar,'')    +',' 
				+ '"Message":"' + convert( nvarchar(max),ERROR_MESSAGE()) + '"}'
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)
			RETURN 
		END CATCH;
		IF @@TRANCOUNT > 0 BEGIN
			COMMIT TRANSACTION;
		END
		

     declare @TotalAmmount  decimal (18,2) = 0
	--Sumar monto por cada recolección
	 

	select @TotalAmmount= SUM(coalesce(Sch.AmountPickup,0)) 
	FROM DeliveryBackOffice.dbo.SchedulePickup Sch
	where 
	EXISTS(
	 select 1 from DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch	      
	  INNER JOIN @TblDeliveryOrdersList trq
	  ON 
		 trq.Guide_Serie = DSch.GuideSerie
	     and trq.Guide_Number = DSch.GuideNumber
	     where  Sch.SchedulePickupId = DSch.IdHeaderRecolection
	)

	--select *
	--FROM DeliveryBackOffice.dbo.SchedulePickup Sch
	--where 
	--EXISTS(
	-- select 1 from DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch	      
	--  INNER JOIN @TblDeliveryOrdersList trq
	--  ON 
	--	 trq.Guide_Serie = DSch.GuideSerie
	--     and trq.Guide_Number = DSch.GuideNumber
	--     where  Sch.SchedulePickupId = DSch.IdHeaderRecolection
	--)

	print 'totalamount' + cast(@TotalAmmount as varchar)

	declare @TotalShippment  decimal (18,2) = 0
	
	


	--Sumar pagos a efectuar ahora
	select @TotalShippment = SUM(coalesce(DOR.PriceShippment,0)) 
	FROM DeliveryBackOffice.dbo.DeliveryOrder DOR
	INNER JOIN DeliveryBackOffice.dbo.DeliveryOrderPaymentDetail DSch
	on Dsch.GuideSerie = DOR.Guide_Serie
	and dsch.GuideNumber = DOR.Guide_Number
	INNER JOIN @TblDeliveryOrdersList trq
	ON 
	trq.Guide_Serie = DSch.GuideSerie
	and trq.Guide_Number = DSch.GuideNumber
	and trq.IdTypePayment = 1 --Contado
	and trq.IdTimePayment = 1 --Pagar ahora
	and trq.IdWayToPayment = 2 --TARJETA
	and DSch.TransaccionFAC is null --Pagar ahora que no se pagó en la generación de envíos
	where DOR.Guide_Serie = trq.Guide_Serie
	and DOR.Guide_Number = trq.Guide_Number	
	and NOT EXISTS
	(
	 select * from DeliveryBackOffice.dbo.CreditCardTransactionByCustomer ccb
	 where ccb.OrderNumber = trq.Guide_Serie + convert(varchar,trq.Guide_Number) 
	 --where ccb.ProductNumber = trq.Guide_Number
	 --and ccb.SerieNumber = trq.Guide_Serie
	)

	
	print '@TotalAmmount' + cast(@TotalAmmount as varchar)
	print '@TotalShippment' + cast(@TotalShippment as varchar)


	SET @TotalAmmount = COALESCE(@TotalAmmount,0) + COALESCE(@TotalShippment,0)

	DECLARE @jsonResult1 NVARCHAR(MAX) 
	set @jsonResult1 = (SELECT STUFF(( 
	select
			 ',{"SumaTotal":"' +  Isnull(CONVERT(varchar , @TotalAmmount ), '0.00')  + --'",' +
						+ '"}'
		
	 FOR XML PATH(''), TYPE
	  ).value('.', 'varchar(max)'),1,1,''
		) )
	

	If @jsonResult1 is null 

	begin

		set @jsonResult1 =(
					SELECT STUFF(( 
					SELECT '{{"IdResult":500,' 
					+ '"Message":" No se encontraron registros"}' 
		
					FOR XML PATH(''), TYPE
					).value('.', 'varchar(max)'),1,1,''
						  ) 
					)
	end

		select ('[' + @jsonResult1 +  ']') jsonResult1
			
			set @jsonResult =(
				SELECT STUFF(( 
				SELECT '{"IdResult":' + convert(varchar,'')    +',' 
				+ '"Message":"' + '' + '"}' 
				FOR XML PATH(''), TYPE
				).value('.', 'varchar(max)'),1,1,''
					  ) 
			)

		
				select ('[{' + @jsonResult +  ']') jsonResult

END

