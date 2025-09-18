-- =============================================
-- Author:		Emilio Orozco
-- Create date: 13/11/2023
-- Description:	Guarda la información de la preparación de un abastecimiento.
-- Test:
-- normal: EXEC [dbo].[sps_ddesk_ATMProvisionDetail] 'DA061222508291',5000,129322,1,'1',80834521,null,'HN',7,2,42,10,'1',5000,'VE1993255',1,5000,5000.00,0.00,'102735-emilio.orozco','ESPECIAL',null,1,null,'0',5,105239425,1,1,0,'normal';
-- reciclyer: EXEC [dbo].[sps_ddesk_ATMProvisionDetail] 'DA061222508291',5000,129322,1,'1',80834521,null,'HN',7,2,42,10,'1',5000,'VE1993255',1,5000,5000.00,0.00,'102735-emilio.orozco','ESPECIAL',null,1,null,'0',5,105239425,1,1,0,'recycler';
-- =============================================
CREATE PROCEDURE [dbo].[sps_ddesk_ATMProvisionDetail]
--declare
	@bagId varchar(50) = ''--maletin de lona donde van los bines
	,@amountBag money = 0
	,@visitpointId bigint = 0
	,@binNumber int = 0
	,@binBarCode varchar(20)= ''
	,@servicePetitionId int = 0
	,@serviceDefinitionId bigint = 0
	,@country varchar(2)=''
	,@station int = 0
	,@currencyId int = 0
	,@moneyId int = 0
	,@pieces int = 0
	,@binMark varchar(50)--marchamo de cada bin
	,@binAmount money
	,@provisionVoucher varchar(200)='VE141120231704'
	,@provisionBagsCount int = 0
	,@provisionTotalVoucher money = 0
	,@provisionCashLocal float
	,@provisionCashDolar float
	,@preparationToken varchar(50)
	,@deliveryType varchar(15) = 'ESPECIAL'
	,@returnVoucher varchar(200)='VE141120231704'
	,@returnBagsCount int = 0
	,@returnBagId varchar(50) = ''
	,@purgeBagId varchar(50) = ''
	,@tableNumber int = 0
	,@masterServiceId bigint = 0
	,@row int = 1
	,@exchangeRate money
	,@preloadId bigint
	,@atmType varchar(10) = 'normal'
AS
BEGIN
	
	SET NOCOUNT ON;
	declare @moneyExists int = null
	,@denominationExists int = null
	,@outProvisionDetailId bigint = 0

	--VALIDAR QUE el tipo de moneda exista.
	select @moneyExists = c.CUR_IdCurrency 
	from DenariusWeb_Dev.dbo.Currency c
	where c.CUR_IdCurrency = @currencyId

	if(ISNULL(@moneyExists,0) = 0)begin
		set @outProvisionDetailId = 0
		set @serviceDefinitionId = 0
		select @outProvisionDetailId as 'ProvisionDetailId', @serviceDefinitionId 'ServiceDefinitionId', 0 as 'Success', 'Moneda no existe.' AS 'Message'

		return
	end

	--VALIDAR que la denominación exista y pertenezca a la moneda.
	SELECT @denominationExists = m.MON_IdMoney
	FROM DenariusWeb_Dev.dbo.Money m
	where m.MON_IdCurrency = @currencyId
	and m.MON_IdMoney = @moneyId

	if(ISNULL(@denominationExists,0) = 0)begin
		set @outProvisionDetailId = 0
		set @serviceDefinitionId = 0
		select @outProvisionDetailId as 'ProvisionDetailId', @serviceDefinitionId 'ServiceDefinitionId', 0 as 'Success', 'Denominación incorrecta.' AS 'Message'

		return
	end



	if(@row = 1) begin
		---- tabla para confirmación de los VE, para que entity framework, no lo devuelva como respuesta.
		declare @table as table(
			voucher varchar(200),
			result bit,
			message varchar(200)
		)

		
		declare @recievedFrom nvarchar(300) = null
		,@recievedFromCode bigint
		,@DeliverTo nvarchar(300) = null
		,@DeliverToCode bigint
		,@clientCardcode varchar(50)
		,@route varchar(10)
		,@receptorId int
		,@receptorName varchar(50)
		,@routeAssigmentId bigint = null
		,@serviceDate datetime
		
		-- buscar info en corporate, para crear el service definition y vouchers
		select @recievedFrom = ms.LMS_OriginName, @recievedFromCode = ms.LMS_OriginCode
		,@DeliverTo = ms.LMS_DestinationName, @DeliverToCode = ms.LMS_DestinationCode, @clientCardcode = ms.LMS_BillingCardCode
		,@route = ms.LMS_RouteDelivery, @serviceDate = ms.LMS_ServiceDate
		from DenariusCorporate_Dev.dbo.LGT_Master_Service ms
		where ms.LMS_ServiceId = @masterServiceId
		-- con los valores de la master service, busca el route assigment, sino lo deja en null
		select @routeAssigmentId = ra.ASG_id
		from denariusdesktop_dev.dbo.ADM_MNG_RouteAssignment ra
		where asg_country = @country
		and asg_station = @station
		and ASG_RouteCode = @route
		and CONVERT(date, ASG_Date) = CONVERT(date,@serviceDate)

		--buscar en la service petition, quien es el receptor
		select @receptorName = p.SRV_ATMIdUserReceptor, @receptorId = p.SRV_ATMReceptor
		from DenariusDesktop_Dev.dbo.SYS_MNG_ServicePetitions p
		where p.SRV_IdPetition = @servicePetitionId

		---- cambiar el estado en la service petition y la estación
		update DenariusDesktop_Dev.dbo.SYS_MNG_ServicePetitions
		set SRV_ATMStatus = 1002
		,SRV_Station = @station
		where SRV_IdPetition = @servicePetitionId	

		---- cambiar también la estación en la master service y service petition, en caso de que pertenezcan a otra
		update DenariusCorporate_Dev.dbo.LGT_Master_Service
		set LMS_Station = @station
		where LMS_ServiceId = @masterServiceId

		---- si no existe service Definition(el parametro viene null), buscar primero por el petition id, si no, crear el registro.
		declare @serviceTypeProvision int = 13
		,@specifications varchar(1000) = null
		,@atmStatus tinyint = 0
		,@defStatus int = 0
		,@ATMLockState bit = 0
		,@scan int = 1

		if(isnull(@serviceDefinitionId,0)=0)begin
			select @serviceDefinitionId = d.DEF_ServiceDefIdCode, @specifications = d.DEF_Specifications
			from DenariusDesktop_Dev.dbo.ADM_MNG_RouteServiceDefinition d
			where d.DEF_ServicePetition = @servicePetitionId
		end

		if(isnull(@serviceDefinitionId,0)=0)begin	
			set @specifications = 'Creado en Preparación de Abastecimiento ATM, a la ruta: '+@route+', y fecha en ruta: '+ CONVERT(varchar, CONVERT(date, @serviceDate))
			insert into DenariusDesktop_Dev.dbo.ADM_MNG_RouteServiceDefinition
			([DEF_RouteVisitPoint],[DEF_ServiceType],[DEF_Country],[DEF_Station],[DEF_DateTime],[DEF_Status]
			,[DEF_Specifications],[DEF_AcceptanceStatus],[DEF_ServicePetition],[DEF_ATMStatus],[DEF_ATMLockState]
			,[DEF_ATMPreparationDate],[DEF_ATMPrintState],[DEF_ATMDischargeType],[DEF_AtmPreparationDateIni],DEF_Scan
			,DEF_RouteCode,DEF_ATMIdUserReceptor,DEF_ATMReceptor,DEF_IdRouteAssignment,DEF_DateInRoute,DEF_DateDueService,DEF_SequenceInRoute)
			values(@visitpointId,@serviceTypeProvision,@country,@station,GETDATE(),@defStatus
			,@specifications,@defStatus,@servicePetitionId,@atmStatus,@ATMLockState
			,GETDATE(),@defStatus,@atmStatus,GETDATE(), @scan
			,@route, @receptorName, @receptorId, @routeAssigmentId, CONVERT(date,@serviceDate),CONVERT(date, @serviceDate),0)

			--set @serviceDefinitionId = @@IDENTITY
			select @serviceDefinitionId = IDENT_CURRENT('DenariusDesktop_Dev.dbo.ADM_MNG_RouteServiceDefinition')
		end
		else begin
			set @specifications = @specifications + ' Actualizado desde Preparación de Abastecimiento, ruta: '+@route+', receptor: '+@receptorName+', fecha: '+ CONVERT(varchar,GETDATE())
			update DenariusDesktop_Dev.dbo.ADM_MNG_RouteServiceDefinition
			set [DEF_ATMPreparationDate] = GETDATE(), [DEF_AtmPreparationDateIni] = GETDATE()
			,DEF_ATMIdUserReceptor = @receptorName, DEF_ATMReceptor = @receptorId, DEF_RouteCode = @route, DEF_IdRouteAssignment = @routeAssigmentId
			,DEF_Specifications = @specifications
			where DEF_ServiceDefIdCode = @serviceDefinitionId
			and DEF_Country = @country
			and DEF_Station = @station
		end


		---- tiene que existir el VOUCHER DE ABASTECIMIENTO, si no ingresarlo y confirmar su uso si es VE
		DECLARE @isSpecialService int = 0
		,@existsvoucher bit = 0

		if(UPPER(@deliveryType) = 'ESPECIAL')BEGIN
			SET @isSpecialService = 1
		END
	
		-- Se verificó en otro sp, que no exista.
		--select @existsvoucher =  1
		--from DenariusDesktop_Dev.[dbo].[VRD_ValueRegistrationForm] v
		--where v.FMD_ID = @provisionVoucher

		--if(isnull(@existsvoucher,0) = 0) begin
		insert into DenariusDesktop_Dev.[dbo].[VRD_ValueRegistrationForm]
		([FMD_ID],[FMD_OrdinarySpecialSrv],[FMD_FormDate],[FMD_Country],[FMD_Station],FMD_Route,FMD_ReceivedFrom
		,[FMD_AmountBagsLetters],[FMD_AmountBags],[FMD_TotalNum]
		,[FMD_TotalLeters], [FMD_RecievedFrom], [FMD_RecievedFromCode]
		,[FMD_DeliverTo], [FMD_DeliverToCode], [FMD_FormCreated], [FMD_Observation]
		,FMD_RouteServiceDefinition, FMD_Client, [FMD_ServicePetitionCode], [FMD_LocalCashCoin], [FMD_DolarCash],FMD_IsReturn,FMD_SCAN)
		values(@provisionVoucher,@isSpecialService,GETDATE(),@country,@station,@route,@recievedFrom
		,UPPER([DenariusBilling_Dev].dbo.[ConvertirNumero] (@provisionBagsCount)),@provisionBagsCount, @provisionTotalVoucher
		,UPPER([DenariusBilling_Dev].dbo.[ConvertirNumero] (@provisionTotalVoucher)),@recievedFrom, @recievedFromCode
		,@DeliverTo, @DeliverToCode, GETDATE(), 'Voucher de Abastecimiento, creado al preparar el servicio. Con origen: '+@recievedFrom+', y destino: '+@DeliverTo+'. Con el id de corporativo: '+CONVERT(varchar,@masterServiceId)+'. '
		,@serviceDefinitionId, @clientCardcode, @servicePetitionId, @provisionCashLocal, @provisionCashDolar,0,1)
		--end
	
		insert into @table
		exec DenariusWeb_Dev.[dbo].sps_dweb_usedElectronicVoucher @voucherId = @provisionVoucher

		if(LOWER(@atmType) = 'normal') begin
			---- buscar el VOUCHER DE DESCARGA, si no existe, crearlo y confirmar su uso si es VE
			--se verificó en otro sp, que el voucher no exista.
			--set @existsvoucher = 0
			--select @existsvoucher =  1
			--from DenariusDesktop_Dev.[dbo].[VRD_ValueRegistrationForm] v
			--where v.FMD_ID = @returnVoucher
	
			--if(isnull(@existsvoucher,0) = 0) begin
			insert into DenariusDesktop_Dev.[dbo].[VRD_ValueRegistrationForm]
			([FMD_ID],[FMD_OrdinarySpecialSrv],[FMD_FormDate],[FMD_Country],[FMD_Station],FMD_Route,FMD_ReceivedFrom
			,[FMD_AmountBagsLetters],[FMD_AmountBags],[FMD_TotalNum]
			,[FMD_TotalLeters], [FMD_RecievedFrom], [FMD_RecievedFromCode]
			,[FMD_DeliverTo], [FMD_DeliverToCode], [FMD_FormCreated], [FMD_Observation]
			,FMD_RouteServiceDefinition, FMD_Client, [FMD_ServicePetitionCode], [FMD_LocalCashCoin], [FMD_DolarCash],FMD_IsReturn)
			values(@returnVoucher,@isSpecialService,GETDATE(),@country,@station,@route,@DeliverTo
			,UPPER([DenariusBilling_Dev].dbo.[ConvertirNumero] (@returnBagsCount)),@returnBagsCount, 0
			,UPPER([DenariusBilling_Dev].dbo.[ConvertirNumero] (0)),@DeliverTo, @DeliverToCode
			,@recievedFrom, @recievedFromCode, GETDATE(), 'Voucher de Descarga, creado al preparar el servicio. Con origen: '+@DeliverTo+', y destino: '+@recievedFrom+'. Con el id de corporativo: '+ CONVERT(varchar,@masterServiceId)+'. '
			,@serviceDefinitionId, @clientCardcode, @servicePetitionId, 0, 0,0)
			--end
		
			insert into @table
			exec DenariusWeb_Dev.[dbo].sps_dweb_usedElectronicVoucher @voucherId = @returnVoucher
		end
		
		---- buscar	BOLSA O MARCHAMO DE PURGA, si no existe, crearla
		--se verificó en otro sp, que no exista.
		--declare @existsPurgeBag bit = 0

		--select @existsPurgeBag =  1
		--from DenariusDesktop_Dev.[dbo].[VRD_DescriptBagValue] b
		--where b.DBV_IdBag = @purgeBagId

		---- SE ELIMINÓ LA CREACIÓN DE MARCHAMO DE PURGA, porque en operación GT,
		---- utilizan varias veces la misma bolsa con zipper.
		----if(isnull(@existsPurgeBag,0) = 0) begin
		--insert into DenariusDesktop_Dev.[dbo].[VRD_DescriptBagValue]
		--([DBV_IdBag],[DBV_IdValueReg],[DBV_AmountNum],[DBV_AmountLetters],[DBA_AuxRouteServiceDefinition],[DBV_Type])
		--values(@purgeBagId,@returnVoucher,0,UPPER([DenariusBilling_Dev].dbo.[ConvertirNumero] (0)),@serviceDefinitionId,4)

		----crearla también en master service material
		--insert into DenariusCorporate_Dev.dbo.LGT_Master_Service_Material(
		--[MSM_FK_MasterService_Id], [MSM_ValueRegistrationForm], [MSM_MaterialCode], [MSM_FK_TypeOfMaterial_Id]
		--,[MSM_GrandTotalAmount],[MSM_LocalAmount],[MSM_USDAmount],[MSM_USDExchangeRate],[MSM_Country],[MSM_Station]
		--,[MSM_Status], [MSM_TokeInsertId], [MSM_TokenInsertDatetime])
		--values(@masterServiceId, @returnVoucher, @purgeBagId, 4
		--,0, 0, 0, @exchangeRate, @country, @station
		--,1, @preparationToken, GETDATE() )
		----end
	end-- fin row = 1

	

	---- tiene que existir la BOLSA O MARCHAMO DE ABASTECIMIENTO, si no, ingresarla.
	declare @existsbag bit = 0

	select @existsbag =  1
	from DenariusDesktop_Dev.[dbo].[VRD_DescriptBagValue] b
	where b.DBV_IdBag = @bagId

	if(isnull(@existsbag,0) = 0) begin
		insert into DenariusDesktop_Dev.[dbo].[VRD_DescriptBagValue]
		([DBV_IdBag],[DBV_IdValueReg],[DBV_AmountNum],[DBV_AmountLetters],[DBA_AuxRouteServiceDefinition],[DBV_Type],DBV_SCAN)
		values(@bagId,@provisionVoucher,@amountBag,UPPER([DenariusBilling_Dev].dbo.[ConvertirNumero] (@amountBag)),@serviceDefinitionId,1,0)

		--crearla también en master service material
		insert into DenariusCorporate_Dev.dbo.LGT_Master_Service_Material(
		[MSM_FK_MasterService_Id], [MSM_ValueRegistrationForm], [MSM_MaterialCode], [MSM_FK_TypeOfMaterial_Id]
		,[MSM_GrandTotalAmount],[MSM_LocalAmount],[MSM_USDAmount],[MSM_USDExchangeRate],[MSM_Country],[MSM_Station]
		,[MSM_Status], [MSM_TokeInsertId], [MSM_TokenInsertDatetime])
		values(@masterServiceId, @provisionVoucher, @bagId, 1
		,@provisionTotalVoucher, @provisionCashLocal, @provisionCashDolar, @exchangeRate, @country, @station
		,1, @preparationToken, GETDATE() )
	end
	

	---- buscar BOLSA O MARCHAMO DE DESCARGA, si no existe, crearla
	if(LOWER(@atmType) = 'normal') begin
		set @existsbag = 0
	
		select @existsbag =  1
		from DenariusDesktop_Dev.[dbo].[VRD_DescriptBagValue] b
		where b.DBV_IdBag = @returnBagId
	
		if(isnull(@existsbag,0) = 0) begin
			insert into DenariusDesktop_Dev.[dbo].[VRD_DescriptBagValue]
			([DBV_IdBag],[DBV_IdValueReg],[DBV_AmountNum],[DBV_AmountLetters],[DBA_AuxRouteServiceDefinition],[DBV_Type])
			values(@returnBagId,@returnVoucher,0,UPPER([DenariusBilling_Dev].dbo.[ConvertirNumero] (0)),@serviceDefinitionId,3)
	
			--crearla también en master service material
			insert into DenariusCorporate_Dev.dbo.LGT_Master_Service_Material(
			[MSM_FK_MasterService_Id], [MSM_ValueRegistrationForm], [MSM_MaterialCode], [MSM_FK_TypeOfMaterial_Id]
			,[MSM_GrandTotalAmount],[MSM_LocalAmount],[MSM_USDAmount],[MSM_USDExchangeRate],[MSM_Country],[MSM_Station]
			,[MSM_Status], [MSM_TokeInsertId], [MSM_TokenInsertDatetime])
			values(@masterServiceId, @returnVoucher, @returnBagId, 3
			,0, 0, 0, @exchangeRate, @country, @station
			,1, @preparationToken, GETDATE() )
		end
	end


	---- si tiene id de precarga de bin, actualizar el estado del registro
	if(ISNULL(@preloadId, 0) <> 0) begin
		update DenariusDesktop_Dev.dbo.ATM_BinPreload
		set Pre_Used = 1, Pre_TokenUpdate = @preparationToken, Pre_DateUpdate = GETDATE(), [Pre_MasterServiceId] = @masterServiceId
		where Pre_id = @preloadId
	end

	---- insertar el detalle de cada bin preparado.
    insert into [DenariusDesktop_Dev].[dbo].ATM_Provision_Detail	
   (PRO_IdBag,PRO_RouteVisitPointId,[PRO_BINNumber],[PRO_BINbarCode],[PRO_RouteServiceDefinitionId],[PRO_Country]
   ,[PRO_Station],[PRO_IdMoney],[PRO_Pieces],[PRO_Amount],[PRO_ProvisionMark],[PRO_ProvisionVoucher],[PRO_PreparationDate]
   ,[PRO_TokenIdPreparation],[PRO_State],PRO_ReturnVoucher,PRO_ReturnMark,[PRO_PurgeMark],[PRO_TableNumber])
   values(@bagId,@visitpointId,@binNumber,@binBarCode,@serviceDefinitionId,@country
   ,@station,@moneyId,@pieces,@binAmount,@binMark,@provisionVoucher,GETDATE()
   ,@preparationToken,1,@returnVoucher,@returnBagId,@purgeBagId,@tableNumber)

   --set @outProvisionDetailId = @@IDENTITY
   SELECT @outProvisionDetailId = IDENT_CURRENT('[DenariusDesktop_Dev].[dbo].ATM_Provision_Detail')

   select @outProvisionDetailId as 'ProvisionDetailId', @serviceDefinitionId 'ServiceDefinitionId', 1 as 'Success', 'REGISTRO PROCESADO CORRECTAMENTE' AS 'Message'
  
END;