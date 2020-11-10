USE [DeliveryBackOffice]
GO
/****** Object:  StoredProcedure [dbo].[spws_get_vpclient_name]    Script Date: 30/10/2020 09:57:32 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2020-10-30>
-- Description:	<Devuelve el nombre de los Visit Point registrados
--				basado en coincidencia de  nombre>
-- =============================================
create PROCEDURE [dbo].[spws_get_vpclient_name]
	-- Add the parameters for the stored procedure here
	@ValName as nvarchar(100) = '',
	@IdCountry as nvarchar(2) = 'GT',
	@Exclusive as nvarchar(5) = 'false'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @Exclusive = 'false' begin
		if @ValName = '' begin

			select -1 AS CodeOfReference, 'TODOS' AS DescriptionOfClient, -1 AS IdKindOfVPClient, 'TODOS' AS KindOfVPName,-1  AS IdSettlement
			UNION
			select vp.CodeOfReference, vp.DescriptionOfClient, kvp.IdKindOfVPClient, kvp.KindOfVPName   , vp.IdSettlement
			from 
			DeliveryBackOffice.dbo.VisitPointClient vp
			inner join KindOfVPClient kvp on kvp.IdKindOfVPClient = vp.IdKindOfVPClient
			where vp.CountryId = @IdCountry

		end
		if @ValName != '' begin
		select -1 AS CodeOfReference, 'TODOS' AS DescriptionOfClient, -1 AS IdKindOfVPClient, 'TODOS' AS KindOfVPName,-1  AS IdSettlement
			UNION
			select vp.CodeOfReference, vp.DescriptionOfClient, kvp.IdKindOfVPClient, kvp.KindOfVPName   , vp.IdSettlement
			from 
			DeliveryBackOffice.dbo.VisitPointClient vp
			inner join KindOfVPClient kvp on kvp.IdKindOfVPClient = vp.IdKindOfVPClient
			where vp.CountryId = @IdCountry
		and vp.DescriptionOfClient like '%' + @ValName + '%'
		end
	end

	if @Exclusive = 'true' begin
		if @ValName = '' begin
			select vp.CodeOfReference, vp.DescriptionOfClient, kvp.IdKindOfVPClient, kvp.KindOfVPName   , vp.IdSettlement
			from 
			DeliveryBackOffice.dbo.VisitPointClient vp
			inner join KindOfVPClient kvp on kvp.IdKindOfVPClient = vp.IdKindOfVPClient
			where vp.CountryId = @IdCountry

		end
		if @ValName != '' begin
			select vp.CodeOfReference, vp.DescriptionOfClient, kvp.IdKindOfVPClient, kvp.KindOfVPName   , vp.IdSettlement
			from 
			DeliveryBackOffice.dbo.VisitPointClient vp
			inner join KindOfVPClient kvp on kvp.IdKindOfVPClient = vp.IdKindOfVPClient
			where vp.CountryId = @IdCountry
		and vp.DescriptionOfClient like '%' + @ValName + '%'
		end
		
	end
END
