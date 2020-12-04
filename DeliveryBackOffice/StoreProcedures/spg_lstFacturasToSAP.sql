USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[spg_lstFacturasToSAP]    Script Date: 4/12/2020 12:28:03 p. m. ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 17 Nov 2020
-- Description:	Retorna listado de facturas listas para enviar a SAP
-- =============================================
CREATE PROCEDURE [dbo].[spg_lstFacturasToSAP]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	select inv_pk_id,inv_vpCodeOfReferences,inv_type,ihd.inv_status,ihd.inv_invoiceOfCreditNote
	from DeliveryBackOffice.dbo.invoiceHeader ihd with(nolock)
	--join DeliveryBackOffice.dbo.VisitPointClient vpc with(nolock) on vpc.CodeOfReference = ihd.inv_vpCodeOfReferences
	where ihd.inv_status in(-1,2)
	and inv_type in (1,2)
	and cast(ihd.inv_dateRegister as date) > '2020-12-01'
	and ihd.inv_SAPDocEntry is null
	and isnull(ihd.inv_certificationFEL,'') != ''
	order by inv_pk_id
END
GO


