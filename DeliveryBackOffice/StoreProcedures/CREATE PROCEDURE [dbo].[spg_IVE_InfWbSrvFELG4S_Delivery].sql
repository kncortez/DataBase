USE DeliveryBackOffice
GO
/****** Object:  StoredProcedure [dbo].[spg_IVE_InfWbSrvFELG4S_Delivery]    Script Date: 11/10/2020 21:43:23 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 6 octubre 2020
-- Description:	Retorna credenciales de consumo web service FEL G4S
-- =============================================
create PROCEDURE [dbo].[spg_IVE_InfWbSrvFELG4S_Delivery]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF DenariusDesktop_Dev.dbo.bll_fnc_esProduccion() = 1
		select '' as 'Requestor',
		'' as 'Transaction',
		'' as 'Country',
		'' 'Entity',--NIT
		'' 'User',
		'Este UserName será proporcionado por G4S Documenta' 'UserName',
		'POST_DOCUMENT_SAT o POST_DOCUMENT_EMISOR' 'Data1'
	ELSE
		--select
		--'Forza Delivery Expres' 'Nombre',
		--'Ave Petapa 42.51 zona 12, Guatemala, Guatemala' 'Direccion',
		--'EEEB604D-D98B-4DF8-9683-8B01592550BE' as 'Requestor',
		--'SYSTEM_REQUEST' as 'Transaction',
		--'GT' as 'Country',
		--'82415218' 'Entity',--NIT
		--'EEEB604D-D98B-4DF8-9683-8B01592550BE' 'User',
		--'ADMINISTRADOR' 'UserName',
		--'POST_DOCUMENTGT' 'Data1',
		--'XML' 'Data3'
		select
			'DELIVERY EXPRESS, SOCIEDAD ANONIMA' 'Nombre',
			'Ave Petapa 42.51 zona 12, Guatemala, Guatemala' 'Direccion',
			'0D9502F3-144F-4B41-AF42-D6118F3B49FE' as 'Requestor',
			'SYSTEM_REQUEST' as 'Transaction',
			'GT' as 'Country',
			'86534599' 'Entity',--NIT
			'0D9502F3-144F-4B41-AF42-D6118F3B49FE' 'User',
			'ADMINISTRADOR' 'UserName',
			'POST_DOCUMENTGT' 'Data1',
			'XML' 'Data3',
			'no-reply@forzalatam.com' 'Correo',
			'Forza Delivery - Factura Electrónica' 'AsuntoCorreo'
END
