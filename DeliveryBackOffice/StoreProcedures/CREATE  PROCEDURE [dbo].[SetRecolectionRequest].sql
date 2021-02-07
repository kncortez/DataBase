drop procedure [dbo].[SetRecolectionRequest]
drop type [dbo].[TblDeliveryOrdersList]
CREATE TYPE [dbo].[TblDeliveryOrdersList] AS TABLE(
	[RowNumber] [int] NOT NULL,
	[Guide_Serie] [nvarchar](2) NULL,
	[Guide_Number] [int] NULL,
	[PriceShippment] [decimal](14, 2) NULL,
	[IdWayToPayment] [int] NULL,
	[IdTypePayment] [int] NULL,
	[IdTimePayment] [int] NULL,
	[IsCollect] [bit] NULL,
	[AmmountToPay] [decimal](14, 2) NULL,
	[PaymentRecollections] [decimal](14, 2) NULL,
	[PaymentNow] [decimal](14, 2) NULL,
	[PaymentDelivery] [decimal](14, 2) NULL,
	[StartDate] [datetime] NULL,
	[EndDate] [datetime] NULL,
	[ShipmentCompleted] [bit] NULL,
	[RecollectionCompleted] [bit] NULL,
	[PaidGuide] [bit] NULL,
	[TransaccionFAC] [varchar] (100) NULL,
	[IdHeaderRecolection] [int] null
	)
	USE [DeliveryBackOffice]
GO




/****** Object:  StoredProcedure [dbo].[SetRecolectionRequest]    Script Date: 6/02/2021 15:02:08 ******/
USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[SetRecolectionRequest]    Script Date: 07/02/2021 16:00:57 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


--drop procedure [dbo].[SetRecolectionRequest]
CREATE  PROCEDURE [dbo].[SetRecolectionRequest]
@TblDeliveryOrdersList AS [TblDeliveryOrdersList] READONLY,
@IdStatus as int,
@Token as nvarchar(100),
@IdAccount as int = null,
@InstructionsCurrier as nvarchar (300) = null,
@PartDimensions as int  = 1,
@Regularpiezer  as int  =  1,
--@StartDate as datetime = null,
--@EndDate as datetime  = null,
@WeightEstimated as decimal (18,2) = null,
@BigPackages as bit = false 

AS
BEGIN
BEGIN TRANSACTION
	BEGIN TRY

	--acutalizar precios, estado y collect

	update dbo.DeliveryOrder 
		set PriceShippment = t.PriceShippment, StatusOrderId = @IdStatus, IsCollect = t.IsCollect
	from dbo.DeliveryOrder ord
	inner join @TblDeliveryOrdersList t on t.Guide_Number = ord.Guide_Number and t.Guide_Serie = ord.Guide_Serie

	-- insertar checkpoint de solicitado.
	
	insert into dbo.DeliveryOrderDetail
	( [Guide_Serie]
	,[Guide_Number]
      ,[StatusOrderId]
      ,[UserCreated]
      ,[DateCreated]
      ,[DateCreatedInSystem]
      ,[Observations]
      ,[Temperature_Celsius])
	select Guide_Serie
	,Guide_Number
	,@IdStatus
	,@Token
	,GETDATE()
	,null
	,null
	,null
	from @TblDeliveryOrdersList

	  insert into dbo.SchedulePickup(AccountId, StartDate , EndDate,EstimatedWeight, IsLargePackage, QuantityRegularPackages, QuantityOverDimensionedPackage, SpecialInstructions, RowStatus,TokenCreated, DateCreated, TokenUpdated, DateUpdated)
	  values(@IdAccount, (select top 1 StartDate from @TblDeliveryOrdersList), (select top 1 EndDate from @TblDeliveryOrdersList),@WeightEstimated, @BigPackages, @Regularpiezer,@PartDimensions, @InstructionsCurrier,1, @Token, getdate(), null, null)

	  declare @transaction int = (select top 1 SchedulePickupId from dbo.SchedulePickup order by SchedulePickupId desc )
	  declare @startdates datetime = (select top  1 StartDate from dbo.SchedulePickup order by SchedulePickupId desc)
	  declare @enddates datetime = (select top  1 EndDate from dbo.SchedulePickup order by SchedulePickupId desc)

	insert into dbo.DeliveryOrderPaymentDetail
	([GuideNumber]
      ,[GuideSerie]
      ,[PayTypeId]
      ,[TypeofInOutMoneyId]
      ,[TimePlaId]
      ,[amount]
	  ,[PaymentRecollections]
	  ,[PaymentNow]
	  ,[PaymentDelivery]
	  ,[StartDate]
	  ,[EndDate]
	  ,[ShipmentCompleted]
	  ,[RecollectionCompleted]
	  ,[PaidGuide]
      ,[TokenCreated]
      ,[DateCreated]
      ,[TokenUpdated]
      ,[DateUpdated]
	  ,[TransaccionFAC]
	  ,[IdHeaderRecolection]
	  )
	  select Guide_Number 
	,Guide_Serie
	,IdTypePayment
	,IdWayToPayment
	,IdTimePayment
	,AmmountToPay
	,PaymentRecollections
	,PaymentNow
	,PaymentDelivery
	,StartDate
	,EndDate
	,ShipmentCompleted
	,RecollectionCompleted
	,PaidGuide
	,@Token
	,getdate()
	,null
	,null
	,null
	,@transaction
	  from @TblDeliveryOrdersList

	
	END TRY
	
	BEGIN CATCH
			 DECLARE @jsonOutput NVARCHAR(MAX) 
			    SET @jsonOutput =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
					',{"Status":"' + ERROR_MESSAGE() + '"}'
	
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput +  ']') jsonOutput 
					ROLLBACK TRANSACTION
			
				END CATCH;
			
				IF @@TRANCOUNT > 0
		BEGIN
					COMMIT TRANSACTION;
			
			 DECLARE @jsonOutput1 NVARCHAR(MAX) 
			    SET @jsonOutput1 =  
			  ( 
			 
			SELECT ''+ STUFF(( 
			
			SELECT 
			  ',{"Status":"Cambios realizados exitosamente"}'
			  
			
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput1 +  ']') jsonOutput1
				END
			
END
GO