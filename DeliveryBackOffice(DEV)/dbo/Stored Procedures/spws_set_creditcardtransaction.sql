-- =============================================
CREATE PROCEDURE [dbo].[spws_set_creditcardtransaction]
	@Type as int = -1, --1 Crear transacción
	@System as int = -1,
	@CardNumber as nvarchar(20) = '',
	@TypeCardNumber as nvarchar(50) = '',
	@Ammount as decimal(18,2) = 0,
	@Currency as int = 0,
	@OrderNumber as nvarchar(38),
	@Signature	 as nvarchar(100) = '',
	@CustomerReference as nvarchar(50) = '',
	@ReferenceNumber as nvarchar(50) = '',
	@ECIIndicator as nvarchar(2) = '',
	@Authenticationresult as nvarchar(1) = null,
	@TransactionStain as nvarchar(50) = null,
	@CAVV as nvarchar(50) = '',
	@RQ_Object nvarchar(4000) = '',
	@RQ_Datetime as datetime = null,
	@ReasonCode as int=null,
	@ReasonCodeDescription as varchar(100)=null,
	@ResponseCode as VARCHAR(100)=null,
	@RS_Object as nvarchar(4000)='',
	@RS_Datetime as datetime,
	@RS_Token as nvarchar(4000)
AS
BEGIN
	DECLARE @IdTransaction BIGINT= 0

	if (@Type = 1) --Insertar registro
	BEGIN
	 SELECT @IdTransaction = IdTransaction FROM CreditCardTransaction WHERE OrderNumber = @OrderNumber
	 IF (@IdTransaction>0)
	 BEGIN
	  PRINT 'Existe registro'	  
	  --PENDIENTE VALIDAR SI VAMOS ACTUALIZAR ALGO 
	 END
	 ELSE
	 BEGIN
	 PRINT 'Creación registro'
	  insert into DeliveryBackOffice.dbo.CreditCardTransaction
	  (
	   [System], [CardNumber], [TypeCardNumber], [Ammount], [Currency], [OrderNumber], [Signature], [CustomerReference], [ReferenceNumber], [ECIIndicator], [Authenticationresult], [TransactionStain], [CAVV], [DatetimeCreated], [DatetimeUpdated]
	   ,[ReasonCode],[ReasonCodeDescription]
	  )
	  values
	  (
	   @System,@CardNumber,@TypeCardNumber,@Ammount,@Currency,@OrderNumber,@Signature,@CustomerReference,@ReferenceNumber,@ECIIndicator,@Authenticationresult,@TransactionStain,@CAVV,getdate(),null
	   ,@ReasonCode
	   ,@ReasonCodeDescription
	  )
	  SET @IdTransaction = @@Identity
	 END

	 --Insertar log
	insert into DenariusLog_Dev.dbo.LOG_Http_Interceptor
	([TypeOfUse], [IdSystem], [EntityObjectName], [TransactionID], [RQ_Method], [RQ_Uri], [RQ_Service], [RQ_Header], [RQ_Body], [RQ_Object], [RQ_Datetime], [RQ_LauValue], [RQ_Token], [RQ_IdOrder], [RS_Service], [RS_StatusCode], [RS_ReasonPhrase], [RS_ReasonCode], [RS_ReasonCodeMessage], [RS_Header], [RS_Body], [RS_Object], [RS_Datetime], [RS_IdOrder], [RS_LauValue], [RS_Token]
	)
	SELECT
	'Push' [TypeOfUse], 15 [IdSystem], 'DeliveryBackOffice.dbo.CreditCardTransaction' [EntityObjectName]
	 ,@IdTransaction [TransactionID],'SOAP' [RQ_Method],'https://ecm.firstatlanticcommerce.com/PGService/Services.svc' [RQ_Uri]
	 ,1 [RQ_Service],null [RQ_Header], null [RQ_Body],@RQ_Object [RQ_Object], @RQ_Datetime [RQ_Datetime]
	 ,null [RQ_LauValue], null[RQ_Token],@OrderNumber [RQ_IdOrder],2 [RS_Service], 0 [RS_StatusCode]
	 ,@ResponseCode [RS_ReasonPhrase],@ReasonCode [RS_ReasonCode],@ReasonCodeDescription [RS_ReasonCodeMessage]
	 ,null [RS_Header], null[RS_Body], @RS_Object [RS_Object],@RS_Datetime [RS_Datetime],@ReferenceNumber [RS_IdOrder]
	 ,null [RS_LauValue], @RS_Token [RS_Token]
--	  FROM [DenariusLog_Dev].[dbo].[LOG_Http_Interceptor]


	END
	else if (@Type = 2) --recibir confirmación 3DSecure
	BEGIN
      SELECT @IdTransaction = IdTransaction FROM CreditCardTransaction WHERE OrderNumber = @OrderNumber
	  update DeliveryBackOffice.dbo.CreditCardTransaction
	  set ECIIndicator = @ECIIndicator,
	      Authenticationresult = @Authenticationresult,
	      TransactionStain = @TransactionStain,
	      CAVV = @CAVV,
	      DatetimeUpdated = getdate(),
		  Signature = @Signature,
		  ReasonCode = @ReasonCode,
		  ReasonCodeDescription = @ReasonCodeDescription
	  where @OrderNumber = OrderNumber
	  and cast(getdate() as date) = cast(DatetimeCreated as date)
	
	  --Insertar log
	  insert into DenariusLog_Dev.dbo.LOG_Http_Interceptor
	  ([TypeOfUse], [IdSystem], [EntityObjectName], [TransactionID], [RQ_Method], [RQ_Uri], [RQ_Service], [RQ_Header], [RQ_Body], [RQ_Object], [RQ_Datetime], [RQ_LauValue], [RQ_Token], [RQ_IdOrder], [RS_Service], [RS_StatusCode], [RS_ReasonPhrase], [RS_ReasonCode], [RS_ReasonCodeMessage], [RS_Header], [RS_Body], [RS_Object], [RS_Datetime], [RS_IdOrder], [RS_LauValue], [RS_Token]
	  )
	  SELECT
	  'Push' [TypeOfUse], 15 [IdSystem], 'DeliveryBackOffice.dbo.CreditCardTransaction' [EntityObjectName]
	   ,@IdTransaction [TransactionID],'SOAP' [RQ_Method],'https://ecm.firstatlanticcommerce.com/PGService/Services.svc' [RQ_Uri]
	   ,1 [RQ_Service],null [RQ_Header], null [RQ_Body],@RQ_Object [RQ_Object], @RQ_Datetime [RQ_Datetime]
	   ,null [RQ_LauValue], null[RQ_Token],@OrderNumber [RQ_IdOrder],2 [RS_Service], 0 [RS_StatusCode]
	   ,@ResponseCode [RS_ReasonPhrase],@ReasonCode [RS_ReasonCode],@ReasonCodeDescription [RS_ReasonCodeMessage]
	   ,null [RS_Header], null[RS_Body], @RS_Object [RS_Object],@RS_Datetime [RS_Datetime],@ReferenceNumber [RS_IdOrder]
	   ,null [RS_LauValue], @RS_Token [RS_Token]

	END

	select 200 Code,'Success' Description

END
