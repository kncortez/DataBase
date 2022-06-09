
-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2021-04-12>
-- Description:	<Devuelve un ID de la tabla settlement en función de la direccion o la zona>
-- =============================================

CREATE PROCEDURE [dbo].[spws_find_settlement]
	-- Add the parameters for the stored procedure here
	@AddressParse VARCHAR(600),
	@HeaderCode nvarchar(20),
	@Zone int = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
	IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

		-- Quitar Departamento y Municipio de la direccion para tener un mejor resultado en la coincidencia
	set @AddressParse = ( select REPLACE(REPLACE(@AddressParse, twn.TownshipName, ''), prv.ProvinceName,'') from  Township twn 
		left join Province prv on prv.IdProvince = twn.IdProvince
	where twn.HeaderCode = @HeaderCode)


	-- separar en un arrglo la direccion 
	 DECLARE @IdSettlement int;
		select Item
		into #ItemAddress
		from DenariusDesktop_Dev.dbo.SplitUnlimited(@AddressParse,' ')


	if @Zone =0 -- si no trae zona verificar por direccion
	begin
		select TOP 1 ST.IdSettlement  , COUNT(ST.IdSettlement) AS mas_popular, ST.Settlement
		into #SettlementList
		from #ItemAddress i
			left join dbo.Township tw on tw.HeaderCode = @HeaderCode
			left join dbo.Settlement st on st.IdTownship = tw.IdTownship and st.Settlement like concat('%', i.Item, '%')
		where len(i.Item)>3 and st.IdSettlement is not null
		GROUP BY ST.IdSettlement, ST.Settlement
		ORDER BY 2 DESC

		set @IdSettlement =(select top 1 IdSettlement from #SettlementList)


	end
	else
	begin
		set @IdSettlement = (select top 1 st.IdSettlement
		from dbo.Township tw
			left join dbo.Settlement st on st.IdTownship = tw.IdTownship
		where tw.HeaderCode = @HeaderCode 
		and st.Settlement like concat('%Zona ', @Zone ,'%')
		order by IdSettlement )

	end


	if @IdSettlement is null
	begin 
		set @IdSettlement =  (select top 1 st.IdSettlement
		from dbo.Township tw
		left join dbo.Settlement st on st.IdTownship = tw.IdTownship
		where tw.HeaderCode = @HeaderCode 
		order by IdSettlement)
	end
	


	select  isnull(@IdSettlement,0) as IdSettlement

	IF OBJECT_ID('tempdb.dbo.#ItemAddress', 'U') IS NOT NULL DROP TABLE #ItemAddress;
	IF OBJECT_ID('tempdb.dbo.#SettlementList', 'U') IS NOT NULL DROP TABLE #SettlementList;

END


