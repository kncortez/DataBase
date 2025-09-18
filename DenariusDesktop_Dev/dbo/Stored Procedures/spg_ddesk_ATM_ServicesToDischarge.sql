-- =============================================
-- Author:		Emilio Orozco
-- Create date: 26/02/2024
-- Description:	devuelve los ultimos 5 servicios de abastecimiento para un ATM específico o para 1 país en específico
-- =============================================
ALTER PROCEDURE [dbo].[spg_ddesk_ATM_ServicesToDischarge]
--declare
	-- Add the parameters for the stored procedure here
	@country varchar(2) = 'GT'
	,@visitpointId bigint = 146304
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select top 5 ms.LMS_ServiceId as ID_CORPORATE_LONG, p.SRV_IdPetition as ID_PETITION, vp.RVP_ClientCostingCode CAJERO
	, vp.RVP_AgCode NO_ATM, ms.LMS_BillingVPName NOMBRE_ATM, br.BRA_BrandName MARCA
	, mo.MOD_ModelName MODELO
	--,case mo.MOD_ModelName
	--	when 'GENERICO' then '0'
	--	else mo.MOD_ModelName end as MODELO
	,sw.SWT_Switch RED
	, (select sum(msp.mbs_amount) 
		from denariusdesktop_dev.DBO.MNG_MoneyByServicePetition msp with(nolock)
		inner join denariusweb_dev.[dbo].[Money] mon with(nolock) on msp.mbs_idmoney = mon.mon_idmoney
		inner join denariusweb_dev.[dbo].[CurrencyByCountry] cur with(nolock) on mon.mon_idcurrency = cur.cbc_idcurrency
		where mbs_servicepetition = cwp.CWP_PetitionId
		and cur.cbc_currencytype = 'Local'
		and cur.cbc_idcountry = @country) MONTO_LOCAL
	, (select sum(msp.mbs_amount) 
		from denariusdesktop_dev.DBO.MNG_MoneyByServicePetition msp with(nolock)
		inner join denariusweb_dev.[dbo].[Money] mon with(nolock) on msp.mbs_idmoney = mon.mon_idmoney
		inner join denariusweb_dev.[dbo].[CurrencyByCountry] cur with(nolock) on mon.mon_idcurrency = cur.cbc_idcurrency
		where mbs_servicepetition = cwp.CWP_PetitionId
		and cur.cbc_currencytype <> 'Local'
		and cur.cbc_idcountry = @country) MONTO_EXTRANJERO, ms.LMS_ServiceDate DATE_BEGIN, ms.LMS_ServiceDateMax DATE_END
	, vp.RVP_isATMRecycler IS_ATM_RECYCLER
	from DenariusCorporate_Dev.dbo.lgt_master_service ms WITH(NOLOCK)
	inner join DenariusCorporate_Dev.dbo.CorpByWebByPetition cwp WITH(NOLOCK) on ms.LMS_ServiceId = cwp.CWP_CorporateId
	inner join DenariusDesktop_Dev.dbo.SYS_MNG_ServicePetitions p WITH(NOLOCK) on cwp.CWP_PetitionId = p.SRV_IdPetition
	INNER JOIN DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints vp with(nolock) on ms.LMS_BillingVPCode = vp.RVP_VisitPointId
	LEFT JOIN DenariusDesktop_Dev.[dbo].[ATM_Switch] sw with(nolock) on sw.SWT_SwitchID = vp.RVP_ATM_SwitchId
	LEFT JOIN [DenariusDesktop_Dev].[dbo].[ATM_Model] mo with(nolock) on mo.MOD_ModelId = vp.RVP_ATM_ModelId
	LEFT JOIN [DenariusDesktop_Dev].[dbo].[ATM_Brand] br with(nolock) on mo.MOD_BrandId = br.BRA_BrandId
	where ms.LMS_ServiceType = 3101
	and isnull(p.SRV_ATMStatus,1000) <> 1004--DESCARGADO
	and ms.LMS_BillingVPCode = @visitpointId
	and DATEADD(hour,8, ms.LMS_ServiceDate)<=GETDATE()
	order by ms.LMS_ServiceDate desc
END