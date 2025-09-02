-- =============================================
-- Author:		<BORJA, CESAR>
-- Create date: <2020-08-25>
-- Description:	<GET PhoneBook>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-07-31>
-- Description:	<Se agrega el pais a la respuesta de la consulta>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-11-20>
-- Description:	<Se agrega el nuevo estado en ruta para el envio de WhatsApp del tracking>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-08-04>
-- Description:	<Se hace la configuración para que se pueda enviar mensajes de Whatsapp mediante Concepto Móvil, se discriminan contactos CORPORATIVOS, y se separan algunos campos que estaban concatenados, manteniendo los que estaban concatenados por si son útiles en otras herramientas>
-- =============================================
-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2025-08-06>
-- Description:	<Se agrega el campo NirPhone.>
-- =============================================
-- =============================================
-- Author:		<Bilkar Morataya>
-- Create date: <2025-08-28>
-- Description:	<Se agrega campos RegxMovilPhone y WhatsappNumber.>
-- =============================================
--exec [dbo].[spg_dsms_PhoneBook] 
--@MaxDeliveryDate = '2022-03-09 17:21:42.180',@ElementId = 1001

CREATE PROCEDURE [dbo].[spg_dsms_PhoneBook] 
	@MaxDeliveryDate DATETIME = '2025-05-06',
	@ElementId INT = 1001
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @CustomerCorporative INT,
			@ConditionPayment INT

	SET @CustomerCorporative = 
	(
		SELECT IdCustomerType 
		FROM CustomerType WITH(NOLOCK)
		WHERE Description = 'CORPORATIVO'
	)

	SET @ConditionPayment = 
	(
		SELECT IdConditionOfPayment 
		FROM CatConditionOfPayment WITH(NOLOCK)
		WHERE ConditionOfPayment = 'CONTADO'
	)
		
	declare @LastUpdate datetime=  dateadd(MINUTE,-200,@MaxDeliveryDate)

	declare @ToUpdate as table (_Series nvarchar(50), _Number int)

	  insert into @ToUpdate
	  SELECT DISTINCT do.[Guide_Serie]
		  ,do.[Guide_Number]
	  FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] do with(nolock)
	  left join [DeliveryBackOffice].[dbo].[SMS_Sent] ss with(nolock)
	  on do.Guide_Serie=ss.Sent_Guide_Series and do.Guide_Number=ss.Sent_Guide_Number
	  where do.DateCreatedInSystem>=@LastUpdate
	  and   CAST(do.DateCreatedInSystem as date)>=CAST('2022-03-07' as date)
	  and (
		(do.StatusOrderId=11 and (@ElementId = 1001 or @ElementId = 1002) and ISNULL(ss.SentTypeStatus,0) = 0 and ISNULL(ss.Sent,0) = 0)
		/*or
		(do.StatusOrderId=2 and @ElementId = 1002 and ISNULL(ss.SentTypeStatus,0) = 0 and ISNULL(ss.Sent,0) = 0) */
	  )
	  and not exists
		  (
		  select 1 from DeliveryBackOffice.dbo.DeliveryOrderDetail DOR2 with(nolock)
		  where do.Guide_Serie = DOR2.Guide_Serie
		  and do.Guide_Number = DOR2.Guide_Number
		  and StatusOrderId in (5,7,22,30,14,24,25/*,4,IIF(@ElementId = 1002,11,0)*/)
		  AND do.RowStatus = 1 --solo estado activos
	  )
	  and not exists
	  (
		SELECT 1 FROM DeliveryBackOffice.dbo.SMS_Sent SS2 with(nolock)
		WHERE SS2.Sent_Guide_Number = do.Guide_Number
		AND SS2.Sent_Guide_Series = do.Guide_Serie
		AND ISNULL(SS2.SentTypeStatus,0) IN (0,1,2,3)
	  )


	INSERT INTO @ToUpdate
	SELECT DISTINCT
		do.[Guide_Serie],
		do.[Guide_Number]
	FROM DeliveryOrder DO WITH (NOLOCK)
	INNER JOIN DeliveryOrderDetail DOD WITH(NOLOCK)
		ON DO.Guide_Serie = DOD.Guide_Serie
		  AND DO.Guide_Number = DOD.Guide_Number
	WHERE DOD.DateCreatedInSystem >= @LastUpdate
		  and CAST(dod.DateCreatedInSystem as date) >= CAST('2022-03-07' as date)
		  AND DOD.StatusOrderId = 4


	declare @PhoneBook as table (
	_FirstName nvarchar(300),
	_LastName nvarchar(300),
	_Phone nvarchar(500),
	_Address nvarchar(600),
	_Town nvarchar(100),
	_Department nvarchar(100),
	_ReceiverID int,
	_DeliveryDate datetime,
	_Series nvarchar(25),
	_Number int,
	_OriginName nvarchar(100),
	_Link nvarchar(100),
	_LandingLink nvarchar(200),
	_IdCountry NVARCHAR(2),
	_StatusOrderId INT
	,_DeliveryETA DATETIME
	,_CustomerName NVARCHAR(150)
	,_Courier NVARCHAR(150)
	,_TypeVehicle NVARCHAR(200)
	,_InsuranceAmount NVARCHAR(300)
    ,_Currency NVARCHAR(300)
	,_Amount NVARCHAR(300)
	,_CODAmount NVARCHAR(300)
	,_VehicleType NVARCHAR(300)
	,_VehiclePlate NVARCHAR(300)
	,_NirPhone NVARCHAR(3)
    ,_RegxMovilPhone NVARCHAR(50)
	,__WhatsappNumber NVARCHAR(15)
	)
	insert into @PhoneBook
	--SELECT TOP 1 --TMP BNHL
	SELECT DISTINCT
		IIF(do.Receiver_FirstName = '',do.Receiver_Alternant_FullName,do.Receiver_FirstName),
		do.Receiver_LastName,
		do.Receiver_Phone,
		do.Receiver_Address,
		do.Receiver_Town,
		do.Receiver_Department,
		do.Receiver_ID,
		do.Delivery_Max_Date,
		do.Guide_Serie,
		do.Guide_Number
		,RTRIM(LTRIM(ISNULL(/*IIF(do.Sender_ID <> 0,VPC.DescriptionOfClient,*/do.Sender_FirstName +' ' + do.Sender_LastName /*)*/,'') ))
		,' https://forzadelivery.com/rastreo/' + do.Guide_Serie
		  + convert(varchar,do.Guide_Number)
		, IIF(SDFG.GuideToken IS NOT NULL, CONCAT( ' https://forzadelivery.io/' , SDFG.GuideToken ),'')
		,ISNULL(do.SenderCountryId,'GT')
		,DOD.StatusOrderId
		,CASE
		  WHEN SO.OrderDescription = 'Entregado' THEN
           (
               SELECT TOP 1
                   CAST(DateCreated AS DATE)
               FROM DeliveryOrderDetail D WITH (NOLOCK)
               WHERE D.Guide_Serie = DO.Guide_Serie
                     AND D.Guide_Number = DO.Guide_Number
                     --AND D.StatusOrderId = @StatusDelivered
               ORDER BY D.DateCreated DESC
           )
           WHEN SO.OrderDescription = 'En ruta' THEN
               CAST(GETDATE() AS DATE)
           WHEN SO.OrderDescription = 'En ruta'
                AND DO.DeliveryETA < GETDATE() THEN
               CAST(DATEADD(DAY, 1, GETDATE()) AS DATE)
		   WHEN SO.OrderDescription != 'En ruta'
                AND DO.DeliveryETA > GETDATE() THEN
               IIF(DO.DeliveryETA IS NULL, CAST (GETDATE() AS DATE), CAST(DO.DeliveryETA AS DATE))
           ELSE
               IIF(DO.DeliveryETA IS NULL, CAST (GETDATE() AS DATE), CAST(DO.DeliveryETA AS DATE))
       END AS DeliveryETA,
	   --CS.Name AS CustomerName,
	    CASE WHEN CS.IdCustomerType = 1 THEN COALESCE(tbl.UsrNickName,'')
	   ELSE COALESCE(VPC.DescriptionOfClient,'') END CustomerName,
	   CONCAT(SR.First_Name,' ',SR.Last_Name) AS Courier,
	   CONCAT('en el vehículo tipo *',CTV.Name,'* con placa *',CVE.Plate,'*.') AS TypeVehicle,
	   CASE
           WHEN DO.IsCollect = 1 THEN
               CONCAT(
                         'Debes cancelar el Monto *',
                         CCU.Symbol,
                         '.',
                         (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)),
                         '* al recibir tu paquete o en la opción de pagar envío.'
                     )
           WHEN CS.IdCustomerType = @CustomerCorporative
                AND CCD.IdConditionOfPayment != @ConditionPayment THEN
               ' '
           WHEN (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)) > 0 THEN
               CONCAT(
                         'Debes cancelar el Monto *',
                         CCU.Symbol,
                         '.',
                         (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)),
                         '* al recibir tu paquete o en la opción de pagar envío.'
                     )
           ELSE
               ' '
       END AS InsuranceAmount,
	   CCU.Symbol,
	    (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)) AS Amount,
	    CO.CODAmount,
        CTV.Name,
       CVE.Plate,
	   DPC.PrefixNumber,
	    DPC.RegxMovilPhone,
	    DPC.WhatsappNumber
	FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
	left join @ToUpdate tu  on do.Guide_Serie=tu._Series and do.Guide_Number=tu._Number
	LEFT JOIN DeliveryOrderDetail DOD WITH (NOLOCK) ON tu._Series = DOD.Guide_Serie AND tu._Number = DOD.Guide_Number
	left join DeliveryBackOffice.dbo.VisitPointClient VPC with(nolock) ON VPC.CodeOfReference = do.Sender_ID
	left join DeliveryBackOffice.dbo.ServiceDataForGuide SDFG with(nolock) ON do.Guide_Serie = SDFG.GuideSerie and do.Guide_Number = SDFG.GuideNumber and SDFG.IsDelivery = 1 AND  SDFG.IsInRoute = 0
	INNER JOIN StatusOrder SO WITH (NOLOCK)
		ON SO.StatusOrderId = DO.StatusOrderId
	LEFT JOIN DeliverySettlementDetail DSD WITH(NOLOCK)
		ON DO.Guide_Number = DSD.Guide_Number
		  AND DO.Guide_Serie = DSD.Guide_Serie
	LEFT JOIN DeliveryOrderBySettlement DOS WITH(NOLOCK)
		ON DSD.ID_DeliveryOrderBySettlement = DOS.ID
	LEFT JOIN CatVehicle CVE WITH(NOLOCK)
		ON DOS.CatVehicleId = CVE.IdVehicle
	LEFT JOIN SenderReceiver SR WITH(NOLOCK)
		ON SR.ID = DOS.ID_Courier
	LEFT JOIN CatTypeVehicle CTV WITH(NOLOCK)
		ON CVE.IdTypeVehicle = CTV.IdTypeVehicle
	LEFT JOIN Customer CS WITH(NOLOCK)
		ON DO.IdCustomer = CS.IdCustomer
	LEFT JOIN CatConditionOfPayment CCD WITH (NOLOCK)
		ON CS.ConditionOfPaymentID = CCD.IdConditionOfPayment
	INNER JOIN DeliveryCurrency DC WITH(NOLOCK)
		ON DO.SenderCountryId = DC.Currency_IdCountry
	INNER JOIN CatCurrencyCOD CCU WITH(NOLOCK)
		ON CCU.IdCatCurrencyCOD = DC.IdCurrencyCOD
	LEFT JOIN SMS_Sent SMS WITH(NOLOCK)
		ON SMS.Sent_Guide_Number = DO.Guide_Number
		AND Sent_Guide_Series = DO.Guide_Serie
	LEFT JOIN Cost CO WITH(NOLOCK)
		ON DO.Guide_Serie = CO.GuideSerie
			AND DO.Guide_Number = CO.GuideNumber
	LEFT JOIN DeliveryBackOffice.dbo.DefaultValuesPerCountry DPC WITH(NOLOCK)
		ON DO.ReceiverCountryId = DPC.IdCountry
	OUTER APPLY(
	 SELECT top 1  UsrNickName FROM DeliveryBackOffice.dbo.Account A1 WITH(NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount A2 WITH(NOLOCK)
	ON A1.AccIdAccount = A2.RuaIdAccount AND A2.RuaRowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser A3 WITH(NOLOCK)
	ON A3.UsrIdUser = A2.RuaIdUser AND A3.UsrRowStatus = 1
	WHERE A1.IdCustomer = CS.IdCustomer AND A1.AccRowStatus = 1
	)TBL
	where not tu._Number is null
	and not tu._Series is null
	AND CS.IdCustomerType <> @CustomerCorporative
	AND DOD.StatusOrderId = 11
	AND DC.DefaultPerCountry = 1
	AND NOT EXISTS
	(
		SELECT TOP 1 1 FROM DeliveryBackOffice.dbo.SMS_Sent SS2 with(nolock)
		WHERE SS2.Sent_Guide_Number = do.Guide_Number
		AND SS2.Sent_Guide_Series = do.Guide_Serie
		AND StatusOrderId = 11
	)
	UNION ALL
	SELECT DISTINCT
		IIF(do.Receiver_FirstName = '',do.Receiver_Alternant_FullName,do.Receiver_FirstName),
		do.Receiver_LastName,
		do.Receiver_Phone,
		do.Receiver_Address,
		do.Receiver_Town,
		do.Receiver_Department,
		do.Receiver_ID,
		do.Delivery_Max_Date,
		do.Guide_Serie,
		do.Guide_Number
		,RTRIM(LTRIM(ISNULL(/*IIF(do.Sender_ID <> 0,VPC.DescriptionOfClient,*/do.Sender_FirstName +' ' + do.Sender_LastName /*)*/,'') ))
		,' https://forzadelivery.com/rastreo/' + do.Guide_Serie
		  + convert(varchar,do.Guide_Number)
		, IIF(SDFG.GuideToken IS NOT NULL, CONCAT( ' https://forzadelivery.io/' , SDFG.GuideToken ),'')
		,ISNULL(do.SenderCountryId,'GT')
		,DOD.StatusOrderId
		,CASE
		  WHEN SO.OrderDescription = 'Entregado' THEN
           (
               SELECT TOP 1
                   CAST(DateCreated AS DATE)
               FROM DeliveryOrderDetail D WITH (NOLOCK)
               WHERE D.Guide_Serie = DO.Guide_Serie
                     AND D.Guide_Number = DO.Guide_Number
                     --AND D.StatusOrderId = @StatusDelivered
               ORDER BY D.DateCreated DESC
           )
           WHEN SO.OrderDescription = 'En ruta' THEN
               CAST(GETDATE() AS DATE)
           WHEN SO.OrderDescription = 'En ruta'
                AND DO.DeliveryETA < GETDATE() THEN
               CAST(DATEADD(DAY, 1, GETDATE()) AS DATE)
		   WHEN SO.OrderDescription != 'En ruta'
                AND DO.DeliveryETA > GETDATE() THEN
               IIF(DO.DeliveryETA IS NULL, GETDATE(), CAST(DO.DeliveryETA AS DATE))
           ELSE
               IIF(DO.DeliveryETA IS NULL, GETDATE(), CAST(DO.DeliveryETA AS DATE))
       END AS DeliveryETA,
	   --CS.Name AS CustomerName,
	   CASE WHEN CS.IdCustomerType = 1 THEN COALESCE(tbl.UsrNickName,'')
	   ELSE COALESCE(VPC.DescriptionOfClient,'') END CustomerName,
	   CONCAT(SR.First_Name,' ',SR.Last_Name) AS Courier,
	   CONCAT('en el vehículo tipo *',CTV.Name,'* con placa *',CVE.Plate,'*.') AS TypeVehicle,
	   CASE
           WHEN DO.IsCollect = 1 THEN
               CONCAT(
                         'Debes cancelar el Monto *',
                         CCU.Symbol,
                         '.',
                         (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)),
                         '* al recibir tu paquete o en la opción de pagar envío.'
                     )
           WHEN CS.IdCustomerType = @CustomerCorporative
                AND CCD.IdConditionOfPayment != @ConditionPayment THEN
               ' '
           WHEN (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)) > 0 THEN
               CONCAT(
                         'Debes cancelar el Monto *',
                         CCU.Symbol,
                         '.',
                         (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)),
                         '* al recibir tu paquete o en la opción de pagar envío.'
                     )
           ELSE
               ' '
       END AS InsuranceAmount,
	    CCU.Symbol,
	    (DO.PriceShippment - ISNULL(CO.TotalAmountPaid, 0)) AS Amount,
	    CO.CODAmount,
        CTV.Name,
       CVE.Plate,
	   DPC.PrefixNumber,
	   DPC.RegxMovilPhone,
	    DPC.WhatsappNumber
	FROM DeliveryBackOffice.dbo.DeliveryOrder do WITH(NOLOCK)
	left join @ToUpdate tu  on do.Guide_Serie=tu._Series and do.Guide_Number=tu._Number
	LEFT JOIN DeliveryOrderDetail DOD WITH (NOLOCK) ON tu._Series = DOD.Guide_Serie AND tu._Number = DOD.Guide_Number
	left join DeliveryBackOffice.dbo.VisitPointClient VPC with(nolock) ON VPC.CodeOfReference = do.Sender_ID
	left join DeliveryBackOffice.dbo.ServiceDataForGuide SDFG with(nolock) ON do.Guide_Serie = SDFG.GuideSerie and do.Guide_Number = SDFG.GuideNumber and SDFG.IsDelivery = 1 AND  SDFG.IsInRoute = 0
	INNER JOIN StatusOrder SO WITH (NOLOCK)
		ON SO.StatusOrderId = DO.StatusOrderId
	LEFT JOIN DeliverySettlementDetail DSD WITH(NOLOCK)
		ON DO.Guide_Number = DSD.Guide_Number
		  AND DO.Guide_Serie = DSD.Guide_Serie
	LEFT JOIN DeliveryOrderBySettlement DOS WITH(NOLOCK)
		ON DSD.ID_DeliveryOrderBySettlement = DOS.ID
	LEFT JOIN CatVehicle CVE WITH(NOLOCK)
		ON DOS.CatVehicleId = CVE.IdVehicle
	LEFT JOIN SenderReceiver SR WITH(NOLOCK)
		ON SR.ID = DOS.ID_Courier
	LEFT JOIN CatTypeVehicle CTV WITH(NOLOCK)
		ON CVE.IdTypeVehicle = CTV.IdTypeVehicle
	LEFT JOIN Customer CS WITH(NOLOCK)
		ON DO.IdCustomer = CS.IdCustomer
	LEFT JOIN CatConditionOfPayment CCD WITH (NOLOCK)
		ON CS.ConditionOfPaymentID = CCD.IdConditionOfPayment
	INNER JOIN DeliveryCurrency DC WITH(NOLOCK)
		ON DO.SenderCountryId = DC.Currency_IdCountry
	INNER JOIN CatCurrencyCOD CCU WITH(NOLOCK)
		ON CCU.IdCatCurrencyCOD = DC.IdCurrencyCOD
	LEFT JOIN SMS_Sent SMS WITH(NOLOCK)
		ON SMS.Sent_Guide_Number = DO.Guide_Number AND Sent_Guide_Series = DO.Guide_Serie
	LEFT JOIN Cost CO WITH(NOLOCK)
		ON DO.Guide_Serie = CO.GuideSerie
			AND DO.Guide_Number = CO.GuideNumber
	LEFT JOIN DeliveryBackOffice.dbo.DefaultValuesPerCountry DPC WITH(NOLOCK)
		ON DO.ReceiverCountryId = DPC.IdCountry
	OUTER APPLY
	(
	select top 1 UsrNickName from DeliveryBackOffice.dbo.Account A1 WITH(NOLOCK)
	LEFT JOIN DeliveryBackOffice.dbo.RolByUserByAccount A2 WITH(NOLOCK)
	ON A1.AccIdAccount = A2.RuaIdAccount AND A2.RuaRowStatus = 1
	LEFT JOIN DeliveryBackOffice.dbo.RegisterUser A3 WITH(NOLOCK)
	ON A3.UsrIdUser = A2.RuaIdUser AND A3.UsrRowStatus = 1
	where A1.IdCustomer = CS.IdCustomer AND A1.AccRowStatus = 1
	)TBL
	where not tu._Number is null
	and not tu._Series is null
	AND CS.IdCustomerType <> @CustomerCorporative
	AND DOD.StatusOrderId = 4
	AND DC.DefaultPerCountry = 1
	AND NOT EXISTS
	(
		SELECT TOP 1 1 FROM DeliveryBackOffice.dbo.SMS_Sent SS2 with(nolock)
		WHERE SS2.Sent_Guide_Number = do.Guide_Number
		AND SS2.Sent_Guide_Series = do.Guide_Serie
		AND StatusOrderId = 4
	)

	declare @TopBatchId bigint=0
	select @TopBatchId=isnull(MAX(st.Sent_Batch_Id),0)+1
	from DeliveryBackOffice.dbo.SMS_Sent st with(nolock)

	declare @CleanPhoneBook as table (
	_FirstName nvarchar(300),
	_LastName nvarchar(300),
	_Phone nvarchar(500),
	_Address nvarchar(500),
	_Town nvarchar(100),
	_Department nvarchar(100),
	_ReceiverID int,
	_DeliveryDate datetime,
	_Series nvarchar(25),
	_Number int,
	_OriginName nvarchar(100),
	_Link nvarchar(100),
	_LandingLink nvarchar(200),
	_IdCountry NVARCHAR(2),
	_StatusOrderId INT
	,_DeliveryETA DATETIME
	,_CustomerName NVARCHAR(150)
	,_Courier NVARCHAR(150)
	,_TypeVehicle NVARCHAR(200)
	,_InsuranceAmount NVARCHAR(300)
	,_Currency NVARCHAR(5)
	,_Amount NVARCHAR(300)
	,_CODAmount NVARCHAR(300)
	,_VehicleType NVARCHAR(300)
	,_VehiclePlate NVARCHAR(300)
	,_NirPhone NVARCHAR(3)
	,_RegxMovilPhone NVARCHAR(50)
	,__WhatsappNumber NVARCHAR(15)
	)
	insert into @CleanPhoneBook
	select
		 pb._FirstName
		,pb._LastName
		,replace(replace(replace(replace(replace(replace(ltrim(rtrim(pb._Phone)),'''',';'),'"',';'),' ',';'),'/',';'),',',';'),'-',(case when CHARINDEX('-', LTRIM(RTRIM(pb._Phone)))>8 then';'else ''end))'_Phone'
		--,pb._Phone
		--,pb._Address
		,replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(ltrim(rtrim(pb._Address)),'  ',' '),' , ',','),', ',','),' ,',','),'zona ','z'),'avenida','Ave.'),','+pb._Department,''),'colonia','col.'),'Residencial','Resid.'),'carretera','ctra.'),'manzana','mz.')'_Address'
		--replace(replace(replace(replace(replace(replace(replace(ltrim(rtrim(pb._Address)),'  ',' '),' , ',','),', ',','),' ,',','),'zona ','z'),'avenida','Ave.'),','+pb._Department,'') '_Address'
		,pb._Town
		,pb._Department
		,pb._ReceiverID
		,pb._DeliveryDate
		,pb._Series
		,pb._Number
		,pb._OriginName
		,pb._Link
		,pb._LandingLink
		,pb._IdCountry
		,pb._StatusOrderId
		,pb._DeliveryETA
		,pb._CustomerName
		,pb._Courier
		,pb._TypeVehicle
		,pb._InsuranceAmount
	    ,pb._Currency
	    ,pb._Amount
        ,pb._CODAmount,
         pb._VehicleType
        ,pb._VehiclePlate
		,pb._NirPhone
	    ,pb._RegxMovilPhone
	    ,pb._WhatsappNumber
	from @PhoneBook pb

	--select TOP 1 --TEMP BNHL
	select
		 pb._FirstName
		,pb._LastName
		--,'54743119' _Phone
		,pb._Phone --TEMP BNHL
		,(case when LEN(pb._Address)>45
		  then substring(pb._Address,1,45)
		  else pb._Address end)'_Address'
		,pb._Town
		,pb._Department
		,pb._ReceiverID
		,pb._DeliveryDate
		,@TopBatchId'TopBatchId'
		,pb._Series
		,pb._Number
		,pb._OriginName
		,pb._Link
		,pb._LandingLink
		,pb._IdCountry
		,pb._StatusOrderId
		,pb._DeliveryETA
		,pb._CustomerName
		,pb._Courier
		,pb._TypeVehicle
		,pb._InsuranceAmount
	    ,pb._Currency
	    ,pb._Amount
	    ,pb._CODAmount
        ,pb._VehicleType
        ,pb._VehiclePlate
		,pb._NirPhone
	    ,pb._RegxMovilPhone
	    ,pb._WhatsappNumber
	from @CleanPhoneBook pb

	INSERT INTO [dbo].[SMS_Sent]
			   ([Sent_Guide_Series]
			   ,[Sent_Guide_Number]
			   ,[SentTypeStatus]
			   ,[Sent_Batch_Id]
			   ,[TokenCreated]
			   ,[CreatedDatetime]
			   ,[StatusOrderId]
			   )
			(
				select
					 pb._Series
					,pb._Number
					,0
					,@TopBatchId
					,'SYS-SMSService'
					,GETDATE()
					,pb._StatusOrderId
				from @PhoneBook pb
			)

	update [DeliveryBackOffice].[dbo].[SMS_UpdatedElements]
	set UpdateStatus=0
	where ElementId=@ElementId

END
go

