-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2020-07-23>
-- Description:	<Devuelve el nombre de un poblado
--				basado en coincidencia de  nombre>
-- =============================================
CREATE PROCEDURE spwb_get_settlement_name
	-- Add the parameters for the stored procedure here
	@ValName as nvarchar(100),
	@IdCountry as nvarchar(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    select pob.IdSettlement [IdSettlement],
	pob.Settlement          [SettlementName]
	from DeliveryBackOffice.dbo.Settlement pob with (nolock)
	where pob.SettlementSatus = 'TRUE'
	and pob.Settlement like '%' + @ValName + '%'
	and pob.IdCountry = @IdCountry

END
GO
