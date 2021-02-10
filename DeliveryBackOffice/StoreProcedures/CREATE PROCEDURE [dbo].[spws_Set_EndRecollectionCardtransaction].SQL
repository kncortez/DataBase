USE DeliveryBackOffice
GO
CREATE PROCEDURE [dbo].[spws_Set_EndRecollectionCardtransaction]
@Type as int = -1
,@System						as int			      	
,@CardNumber					as nvarchar(50)	  	  	
,@TypeCardNumber				as nvarchar(5)	      	
,@Currency						as int			      	
,@Ammount						as decimal(18,2)      	= NULL	
,@OrderNumber					as nvarchar(38)	  		= ''
,@Signature						as nvarchar(100)	  	=NULL	
,@CustomerReference				as int				  	
,@ReferenceNumber				as varchar(50)	      	= ''
,@ECIIndicator					as varchar(2)	      	= ''
,@Authenticationresult			as varchar(1)	      	= ''
,@TransactionStain				as varchar(50)	      	= ''
,@CAVV							as nvarchar(50)	  		= ''
,@ReasonCode					as nvarchar(50)	  		= NULL
,@ReasonDescription				as nvarchar(100)	  	= NULL
,@StatusSend					as int				  	= NULL
,@RowStatus						as bit				  	= 1
,@TokenCreated					as nvarchar(50)	  		= ''
,@DateCreated					as datetime		  		
,@TokenUpdated					as nvarchar(50)	  		= NULL
,@DateUpdated			 		as datetime		  		= NULL
AS
BEGIN
	DECLARE @IdTransaction BIGINT= 0
	IF	(@Type = 1)--OK
	BEGIN
	SELECT 

		@IdTransaction 	= isnull([IdTransaction],0)			
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
		WHERE OrderNumber = @OrderNumber
	
		if (@IdTransaction > 0 ) 
		begin 
			update DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
			 SET 
								
				CardNumber				= @CardNumber				
		,		TypeCardNumber			= @TypeCardNumber
		,		Ammount					= @Ammount	
		,		[Signature]				= @Signature				
		,		ReferenceNumber			= @ReferenceNumber		
										
													
											  
							
		,		ReasonCode				= @ReasonCode				
		,		ReasonDescription		= @ReasonDescription		
		,		StatusSend				= @StatusSend				
		,		RowStatus				= @RowStatus				
		,		TokenUpdated			= @TokenUpdated			
		,		DateUpdated				= @DateUpdated
			 where IdTransaction = @IdTransaction
			 AND OrderNumber = @OrderNumber
			 And (StatusSend <> 1 or StatusSend is null)
		end 
		INSERT INTO DenariusLog_Dev.dbo.LOG_Http_Interceptor 
		([TypeOfUse], 
		[IdSystem], 
		[EntityObjectName], 
		[TransactionID], 
		[RQ_Method], 
		[RQ_Uri], 
		[RQ_Service], 
		[RQ_Header], 
		[RQ_Body], 
		[RQ_Object], 
		[RQ_Datetime], 
		[RQ_LauValue], 
		[RQ_Token], 
		[RQ_IdOrder], 
		[RS_Service], 
		[RS_StatusCode], 
		[RS_ReasonPhrase], 
		[RS_ReasonCode], 
		[RS_ReasonCodeMessage], 
		[RS_Header], 
		[RS_Body], 
		[RS_Object], 
		[RS_Datetime], 
		[RS_IdOrder], 
		[RS_LauValue], 
		[RS_Token])
		VALUES(
		'Push'																
		,@System  																
		,'DeliveryBackOffice.dbo.CreditCardTransaction' 					
		,@IdTransaction														
		,'SOAP'																
		,'https://ecm.firstatlanticcommerce.com/PGService/Services.svc'		
		,1 																	
		,null 																
		,null 																
		,null																
		,@DateCreated														
		,null																
		,null 																
		,@IdTransaction 																	
		,2 																	
		,0 																	
		,null 		 														
		,@ReasonCode 														
		,@ReasonDescription													
		,null 																
		,null 																
		, null 																
		,@DateCreated														
		,@OrderNumber														
		,null 																
		,@TokenUpdated														
		)
	END
	else IF (@Type = 2) --V/M NO COMPLETED
	BEGIN 
	SELECT 
		@IdTransaction 	= isnull([IdTransaction],0)			
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
		WHERE OrderNumber = @OrderNumber
	
		if (@IdTransaction > 0 ) 
		begin 
			update DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
			 SET 
				CardNumber				= @CardNumber				
		,		TypeCardNumber			= @TypeCardNumber
		,		Ammount					= @Ammount	
		,		[Signature]				= @Signature				
		,		ReferenceNumber			= @ReferenceNumber		
		,		Authenticationresult	= @Authenticationresult	
		,		TransactionStain		= @TransactionStain		
		,		ReasonCode				= @ReasonCode				
		,		ReasonDescription		= @ReasonDescription		
		,		StatusSend				= @StatusSend				
		,		RowStatus				= @RowStatus				
		,		TokenUpdated			= @TokenUpdated			
		,		DateUpdated				= @DateUpdated
			 where IdTransaction = @IdTransaction
			 AND OrderNumber = @OrderNumber
			 And (StatusSend <> 1 or StatusSend is null)
		end 
		INSERT INTO DenariusLog_Dev.dbo.LOG_Http_Interceptor 
		([TypeOfUse], 
		[IdSystem], 
		[EntityObjectName], 
		[TransactionID], 
		[RQ_Method], 
		[RQ_Uri], 
		[RQ_Service], 
		[RQ_Header], 
		[RQ_Body], 
		[RQ_Object], 
		[RQ_Datetime], 
		[RQ_LauValue], 
		[RQ_Token], 
		[RQ_IdOrder], 
		[RS_Service], 
		[RS_StatusCode], 
		[RS_ReasonPhrase], 
		[RS_ReasonCode], 
		[RS_ReasonCodeMessage], 
		[RS_Header], 
		[RS_Body], 
		[RS_Object], 
		[RS_Datetime], 
		[RS_IdOrder], 
		[RS_LauValue], 
		[RS_Token])
		VALUES(
		'Push'																
		,@System  																
		,'DeliveryBackOffice.dbo.CreditCardTransaction' 					
		,@IdTransaction														
		,'SOAP'																
		,'https://ecm.firstatlanticcommerce.com/PGService/Services.svc'		
		,1 																	
		,null 																
		,null 																
		,null																
		,@DateCreated														
		,null																
		,null 																
		,@IdTransaction 																	
		,2 																	
		,0 																	
		,null 		 														
		,@ReasonCode 														
		,@ReasonDescription													
		,null 																
		,null 																
		, null 																
		,@DateCreated														
		,@OrderNumber														
		,null 																
		,@TokenUpdated														
		)
	END 
	else IF (@Type = 3) --V/M COMPLETED 
	BEGIN 
	SELECT 
		@IdTransaction 	= isnull([IdTransaction],0)			
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
		WHERE OrderNumber = @OrderNumber
	    
	END 
	select 200 Code,'Success' Description
	
END


