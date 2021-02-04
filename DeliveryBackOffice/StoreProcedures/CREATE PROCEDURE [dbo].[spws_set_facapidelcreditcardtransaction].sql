Use DeliveryBackOffice
Go 
CREATE PROCEDURE [dbo].[spws_set_facapidelcreditcardtransaction]
@Type as int = -1
,@System							as int			      	
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
	IF	(@Type = 1)
	BEGIN
	SELECT 
		@IdTransaction 	= isnull([IdTransaction],0)			
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
		WHERE OrderNumber = @OrderNumber
		and  cast(@DateCreated AS DATE)  = CAST(DateCreated AS DATE) 
		if (@IdTransaction = 0)
		Begin 
		insert into DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
		(
		[System]					
		,CardNumber				
		,TypeCardNumber			
		,Currency				
		,Ammount				
		,OrderNumber			
		,[Signature]				
		,CustomerReference		
		,ReferenceNumber		
		,ECIIndicator			
		,Authenticationresult	
		,TransactionStain		
		,CAVV					
		,ReasonCode				
		,ReasonDescription		
		,StatusSend				
		,RowStatus				
		,TokenCreated			
		,DateCreated			
		,TokenUpdated			
		,DateUpdated	
		)
		values
		(
		@System					
		,@CardNumber				
		,@TypeCardNumber			
		,@Currency				
		,@Ammount				
		,@OrderNumber			
		,@Signature				
		,@CustomerReference		
		,@ReferenceNumber		
		,@ECIIndicator			
		,@Authenticationresult	
		,@TransactionStain		
		,@CAVV					
		,@ReasonCode				
		,@ReasonDescription		
		,@StatusSend				
		,@RowStatus				
		,@TokenCreated			
		,@DateCreated			
		,@TokenUpdated			
		,@DateUpdated	
		)
		SET @IdTransaction = isnull(@@Identity,0)
		end 
		else if (@IdTransaction > 0 )
		begin 
			update DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
			 SET 
				[System]				= @System					
		,		CardNumber				= @CardNumber				
		,		TypeCardNumber			= @TypeCardNumber
		,		Currency				= @Currency
		,		Ammount					= @Ammount
		,		OrderNumber				= @OrderNumber			
		,		[Signature]				= @Signature				
		,		CustomerReference		= @CustomerReference		
		,		ReferenceNumber			= @ReferenceNumber		
		,		ECIIndicator			= @ECIIndicator			
		,		Authenticationresult	= @Authenticationresult	
		,		TransactionStain		= @TransactionStain		
		,		CAVV					= @CAVV					
		,		ReasonCode				= @ReasonCode				
		,		ReasonDescription		= @ReasonDescription		
		,		StatusSend				= @StatusSend				
		,		RowStatus				= @RowStatus				
		,		TokenCreated			= @TokenCreated			
		,		DateCreated				= @DateCreated			
		,		TokenUpdated			= @TokenUpdated			
		,		DateUpdated				= @DateUpdated
			 where IdTransaction = @IdTransaction
			 AND OrderNumber = @OrderNumber
			 And StatusSend <> 1
			 AND cast(@DateCreated AS DATE)  = CAST(DateCreated AS DATE)

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
	,15  																
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
	,1 																	
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
	ELSE IF (@Type = 2)
	BEGIN
		SELECT 
		@IdTransaction 		= [IdTransaction]			
		FROM DeliveryBackOffice.dbo.CreditCardTransactionByCustomer WITH(NOLOCK)
		WHERE OrderNumber = @OrderNumber

		update DeliveryBackOffice.dbo.CreditCardTransactionByCustomer
		 SET ReasonCode = @ReasonCode
		  ,ReasonDescription = @ReasonDescription
		  ,DateUpdated = @DateUpdated
		  ,TokenUpdated = @TokenUpdated
		  ,ECIIndicator = @ECIIndicator
		  ,Authenticationresult = @Authenticationresult
		  ,TransactionStain	 = @TransactionStain	
		  ,CAVV = @CAVV	
		  ,StatusSend = @StatusSend
		 where IdTransaction = @IdTransaction
		 AND OrderNumber = @OrderNumber
		 AND StatusSend <> 1
		 AND cast(@DateUpdated AS DATE)  = CAST(DateCreated AS DATE)

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
		,15  															
		,'DeliveryBackOffice.dbo.CreditCardTransaction' 				
		,@IdTransaction													
		,'SOAP'															
		,'https://ecm.firstatlanticcommerce.com/PGService/Services.svc'	
		,1 																
		,null 															
		,null 															
		,null															
		,@DateUpdated													
		,null															
		,null 															
		,1 																
		,2 																
		,0 																
		,null 															
		,@ReasonCode 													
		,@ReasonDescription												
		,null 															
		,null 															
		,null															
		,@DateUpdated													
		,@OrderNumber												
		,null 															
		,@TokenUpdated													
		)
	END
	select 200 Code,'Success' Description
	
END