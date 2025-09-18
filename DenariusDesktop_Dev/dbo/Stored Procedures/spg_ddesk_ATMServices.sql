ALTER PROCEDURE [dbo].[spg_ddesk_ATMServices]
	--declare 
	@pCountry varchar(2) = 'GT'
	,@pCardCode nvarchar(15)=''
	,@pUserID int = 100323
	,@pUserName varchar(50)='cesar.borja'
	,@pIsAtmSupervisor bit = 1
	,@pServiceDateBegin datetime = '2024-04-17 00:00:00.000'
	,@pServiceDateEnd datetime =   '2024-04-17 23:59:59.999'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET ARITHABORT  OFF;

    select ms.LMS_ServiceId as ID_SERVICIO_CORPORATIVO, pet.SRV_IdPetition as ID_SERVICIO_PETITION, vp.RVP_ClientCostingCode CAJERO
	, vp.RVP_AgCode NO_ATM, ms.LMS_BillingVPName NOMBRE_ATM, br.BRA_BrandName MARCA, mo.MOD_ModelName MODELO,sw.SWT_Switch RED
	, (select sum(msp.mbs_amount) 
		from denariusdesktop_dev.DBO.MNG_MoneyByServicePetition msp with(nolock)
		inner join denariusweb_dev.[dbo].[Money] mon with(nolock) on msp.mbs_idmoney = mon.mon_idmoney
		inner join denariusweb_dev.[dbo].[CurrencyByCountry] cur with(nolock) on mon.mon_idcurrency = cur.cbc_idcurrency
		where mbs_servicepetition = cwp.CWP_PetitionId
		and cur.cbc_currencytype = 'Local'
		and cur.cbc_idcountry = @pCountry) MONTO_LOCAL
	, (select sum(msp.mbs_amount) 
		from denariusdesktop_dev.DBO.MNG_MoneyByServicePetition msp with(nolock)
		inner join denariusweb_dev.[dbo].[Money] mon with(nolock) on msp.mbs_idmoney = mon.mon_idmoney
		inner join denariusweb_dev.[dbo].[CurrencyByCountry] cur with(nolock) on mon.mon_idcurrency = cur.cbc_idcurrency
		where mbs_servicepetition = cwp.CWP_PetitionId
		and cur.cbc_currencytype <> 'Local'
		and cur.cbc_idcountry = @pCountry) MONTO_EXTRANJERO, ms.LMS_ServiceDate DATE_BEGIN, ms.LMS_ServiceDateMax DATE_END
	--,case st.StatusName
	--	when 'DESCARGADO' then dh.DischargeDate
	--	else ms.LMS_ServiceDate end as DATE_BEGIN
	--,case st.StatusName
	--	when 'DESCARGADO' then dh.DischargeDate
	--	else ms.LMS_ServiceDateMax end as DATE_END
	, st.StatusName ESTADO
	, 'PENDIENTE' EN_PROCESO, ms.LMS_RouteDelivery RUTA, pet.SRV_ATMReceptor RECEPTOR_ID, pet.SRV_ATMIdUserReceptor RECEPTOR_NOMBRE--, ms.LMS_SameDayDelivery TIPO_ENTREGA
	, (case ms.LMS_SameDayDelivery when 0 then 'PROGRAMADO' when 1 then 'ESPECIAL' end) TIPO_ENTREGA
	, ms.LMS_Country PAIS, vp.RVP_VisitPointId ID_PUNTO_VISITA,	def.DEF_ServiceDefIdCode ID_SERVICIO_DEFINITION
	, pet.SRV_Station ID_ESTACION, UPPER(stat.STN_Name) NOMBRE_ESTACION, ms.LMS_BillingCardCode CARDCODE, ms.LMS_BillingCardCodeName CARDCODE_NAME
	, vp.RVP_isATMRecycler IS_ATM_RECYCLER
	from DenariusCorporate_Dev.[dbo].[LGT_Master_Service]  ms with(nolock)
	INNER JOIN DenariusCorporate_Dev.dbo.CorpByWebByPetition cwp WITH(NOLOCK) on ms.LMS_ServiceId = cwp.CWP_CorporateId
	INNER JOIN DenariusDesktop_Dev.dbo.SYS_MNG_ServicePetitions pet with(nolock) on cwp.CWP_PetitionId = pet.SRV_IdPetition
	LEFT JOIN DenariusDesktop_Dev.dbo.ADM_Status st with(nolock) on st.TableName = 'SYS_MNG_ServicePetitions' and st.ColumnName = 'SRV_ATMStatus' and st.StatusValue = isnull(pet.SRV_ATMStatus,1000)
	LEFT JOIN DenariusDesktop_Dev.dbo.ADM_MNG_RouteServiceDefinition def with(nolock) on pet.SRV_IdPetition = def.DEF_ServicePetition
	INNER JOIN DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints vp with(nolock) on ms.LMS_BillingVPCode = vp.RVP_VisitPointId
	LEFT JOIN DenariusDesktop_Dev.[dbo].[ATM_Switch] sw with(nolock) on sw.SWT_SwitchID = vp.RVP_ATM_SwitchId
	LEFT JOIN [DenariusDesktop_Dev].[dbo].[ATM_Model] mo with(nolock) on mo.MOD_ModelId = vp.RVP_ATM_ModelId
	LEFT JOIN [DenariusDesktop_Dev].[dbo].[ATM_Brand] br with(nolock) on mo.MOD_BrandId = br.BRA_BrandId
	LEFT JOIN [DenariusDesktop_Dev].[dbo].[PRM_Station] stat with(nolock) on pet.SRV_Station = stat.STN_IdStation 
	where ms.LMS_ServiceType = 3101
	and ISNULL(pet.SRV_ATMStatus,1000) <> 1004--descargado
	and (@pIsAtmSupervisor = 1 or (pet.SRV_ATMIdUserReceptor = @pUserName and pet.SRV_ATMReceptor = @pUserID))
	and LMS_ServiceDate between @pServiceDateBegin and @pServiceDateEnd
	and ms.LMS_Country = @pCountry
	and (@pCardCode = '' or ms.LMS_BillingCardCode = @pCardCode)
	AND isnull(def.DEF_Scan,0)>=0--PARA QUE NO TOME LOS MULTIAGENCIAS QUE SE CREO NUEVO DEFINITION
	--order by LMS_ServiceDate, LMS_ServiceId asc
	union
	select ms.LMS_ServiceId as ID_SERVICIO_CORPORATIVO, pet.SRV_IdPetition as ID_SERVICIO_PETITION, vp.RVP_ClientCostingCode CAJERO
	, vp.RVP_AgCode NO_ATM, ms.LMS_BillingVPName NOMBRE_ATM, br.BRA_BrandName MARCA, mo.MOD_ModelName MODELO,sw.SWT_Switch RED
	, isnull((select sum(msp.mbs_amount) 
		from denariusdesktop_dev.DBO.MNG_MoneyByServicePetition msp with(nolock)
		inner join denariusweb_dev.[dbo].[Money] mon with(nolock) on msp.mbs_idmoney = mon.mon_idmoney
		inner join denariusweb_dev.[dbo].[CurrencyByCountry] cur with(nolock) on mon.mon_idcurrency = cur.cbc_idcurrency
		where mbs_servicepetition = dh.PetitionId
		and cur.cbc_currencytype = 'Local'
		and cur.cbc_idcountry = @pCountry),0) MONTO_LOCAL
	, isnull( (select sum(msp.mbs_amount) 
		from denariusdesktop_dev.DBO.MNG_MoneyByServicePetition msp with(nolock)
		inner join denariusweb_dev.[dbo].[Money] mon with(nolock) on msp.mbs_idmoney = mon.mon_idmoney
		inner join denariusweb_dev.[dbo].[CurrencyByCountry] cur with(nolock) on mon.mon_idcurrency = cur.cbc_idcurrency
		where mbs_servicepetition = dh.PetitionId
		and cur.cbc_currencytype <> 'Local'
		and cur.cbc_idcountry = @pCountry),0) MONTO_EXTRANJERO, dh.DischargeDate DATE_BEGIN, dh.DischargeDate DATE_END
	, st.StatusName ESTADO
	, 'PENDIENTE' EN_PROCESO, ms.LMS_RouteDelivery RUTA, pet.SRV_ATMReceptor RECEPTOR_ID, pet.SRV_ATMIdUserReceptor RECEPTOR_NOMBRE--, ms.LMS_SameDayDelivery TIPO_ENTREGA
	, (case ms.LMS_SameDayDelivery when 0 then 'PROGRAMADO' when 1 then 'ESPECIAL' end) TIPO_ENTREGA
	, ms.LMS_Country PAIS, vp.RVP_VisitPointId ID_PUNTO_VISITA,	def.DEF_ServiceDefIdCode ID_SERVICIO_DEFINITION
	, pet.SRV_Station ID_ESTACION, UPPER(stat.STN_Name) NOMBRE_ESTACION, ms.LMS_BillingCardCode CARDCODE, ms.LMS_BillingCardCodeName CARDCODE_NAME
	--,pet.*
	, vp.RVP_isATMRecycler IS_ATM_RECYCLER
	from DenariusDesktop_Dev.dbo.ATM_DischargeHeader dh with(nolock)
	inner join DenariusCorporate_Dev.[dbo].[LGT_Master_Service]  ms with(nolock) on ms.LMS_ServiceId = dh.MasterServiceId
	INNER JOIN DenariusDesktop_Dev.dbo.SYS_MNG_ServicePetitions pet with(nolock) on dh.PetitionId = pet.SRV_IdPetition
	LEFT JOIN DenariusDesktop_Dev.dbo.ADM_Status st with(nolock) on st.TableName = 'SYS_MNG_ServicePetitions' and st.ColumnName = 'SRV_ATMStatus' and st.StatusValue = isnull(pet.SRV_ATMStatus,1000)
	LEFT JOIN DenariusDesktop_Dev.dbo.ADM_MNG_RouteServiceDefinition def with(nolock) on pet.SRV_IdPetition = def.DEF_ServicePetition
	INNER JOIN DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints vp with(nolock) on ms.LMS_BillingVPCode = vp.RVP_VisitPointId
	LEFT JOIN DenariusDesktop_Dev.[dbo].[ATM_Switch] sw with(nolock) on sw.SWT_SwitchID = vp.RVP_ATM_SwitchId
	LEFT JOIN [DenariusDesktop_Dev].[dbo].[ATM_Model] mo with(nolock) on mo.MOD_ModelId = vp.RVP_ATM_ModelId
	LEFT JOIN [DenariusDesktop_Dev].[dbo].[ATM_Brand] br with(nolock) on mo.MOD_BrandId = br.BRA_BrandId
	LEFT JOIN [DenariusDesktop_Dev].[dbo].[PRM_Station] stat with(nolock) on pet.SRV_Station = stat.STN_IdStation 
	where ms.LMS_ServiceType in (3101,3103)
	and isnull(pet.SRV_ATMStatus,1000) = 1004
	and (@pIsAtmSupervisor = 1 or (pet.SRV_ATMIdUserReceptor = @pUserName and pet.SRV_ATMReceptor = @pUserID))
	and dh.DischargeDate between @pServiceDateBegin and @pServiceDateEnd
	and ms.LMS_Country = @pCountry
	and (@pCardCode = '' or ms.LMS_BillingCardCode = @pCardCode)
	AND isnull(def.DEF_Scan,0)>=0--PARA QUE NO TOME LOS MULTIAGENCIAS QUE SE CREO NUEVO DEFINITION
	order by LMS_ServiceDate, LMS_ServiceId asc


END;