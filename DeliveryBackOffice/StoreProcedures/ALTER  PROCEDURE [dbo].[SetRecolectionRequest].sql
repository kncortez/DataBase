USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[SetRecolectionRequest]    Script Date: 05/02/2021 12:03:51 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

--drop procedure [dbo].[SetRecolectionRequest]
ALTER  PROCEDURE [dbo].[SetRecolectionRequest]
@TblDeliveryOrdersList AS [TblDeliveryOrdersList] READONLY,
@IdStatus as int,
@Token as nvarchar(100)

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

	insert into dbo.DeliveryOrderPaymentDetail
	([GuideNumber]
      ,[GuideSerie]
      ,[PayTypeId]
      ,[TypeofInOutMoneyId]
      ,[TimePlaId]
      ,[amount]
      ,[TokenCreated]
      ,[DateCreated]
      ,[TokenUpdated]
      ,[DateUpdated])
	  select Guide_Number 
	,Guide_Serie
	,IdTypePayment
	,IdWayToPayment
	,IdTimePayment
	,AmmountToPay
	,@Token
	,getdate()
	,null
	,null
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
			  ',{"Status":"Se realizo con exito sus cambios "}'
			  
			
			  FOR XML PATH(''), TYPE 
			  ) 
			  .value('.', 'varchar(max)'),1,1,'' 
			              ) + '' 
			  ) 
			 
				select ('[' + @jsonOutput1 +  ']') jsonOutput1
				END
			
END
GO


