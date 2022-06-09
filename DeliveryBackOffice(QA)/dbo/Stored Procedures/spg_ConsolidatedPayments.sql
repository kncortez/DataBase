-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 14 Octubre 2020
-- Description:	Retorna Consolidado de pagos
-- =============================================
CREATE PROCEDURE [dbo].[spg_ConsolidatedPayments]
	-- Add the parameters for the stored procedure here
	@vpCodeOfReferences as int,
	@fechaInicio as datetime,
	@fechaFin as datetime,
	@IdKindOfVPClient as int = null,
	@opcion as varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	if @opcion = 'encabezado' begin
		select vpc.CodeOfReference 'Código Express Center',
			vpc.DescriptionOfClient 'Nombre Establecimiento',
			parsename(convert(varchar,cast(COUNT(distinct ord.Guide_Serie  + cast(ord.Guide_Number as varchar)) as money),1),2) 'Ordenes',
			parsename(CONVERT(varchar,CAST(COUNT(distinct inv_pk_id) as money),1),2) 'Cantidad de Facturas',
			convert(varchar,isnull(SUM(ihd.inv_amount),0),1) 'Total Facturado'
		from DeliveryBackOffice.dbo.DeliveryOrder ord with(nolock)
		join DeliveryBackOffice.dbo.VisitPointClient vpc with(nolock) on ord.Sender_ID = vpc.CodeOfReference
		left join DeliveryBackOffice.dbo.invoiceDetail ide with(nolock) on ide.dti_fk_orderSerie = ord.Guide_Serie
																	and ide.dti_fk_orderNumber = ord.Guide_Number
		left join DeliveryBackOffice.dbo.invoiceHeader ihd with(nolock) on ihd.inv_pk_id = ide.dti_fk_header
		and ihd.inv_type = 1
		where ord.DateCreated between @fechaInicio and @fechaFin
		and vpc.CodeOfReference = ISNULL(@vpCodeOfReferences,vpc.CodeOfReference)
		and vpc.IdKindOfVPClient = ISNULL(@IdKindOfVPClient,vpc.IdKindOfVPClient)
		group by vpc.CodeOfReference,vpc.DescriptionOfClient
		order by 2
	end
	if @opcion = 'detalle' begin
		select
			isnull(PARSENAME(convert(varchar,cast(ihd.inv_pk_id as money),1),2),'') 'Código',
			ord.Sender_FirstName + ' ' + ord.Sender_LastName 'Remitente',
			ord.Guide_Serie + cast(ord.Guide_Number as varchar) 'Guia de Transporte',
			isnull(ihd.inv_serieFEL + ' - ' + cast(ihd.inv_numberFEL as varchar),'') 'Factura',
			convert(varchar(10),ord.DateCreated,20) 'Fecha',
			isnull(tio_pk_name,'') 'Tipo de Pago',
			isnull(convert(varchar,io.io_amount,1),'') 'Monto',
			ihd.inv_status 'invoiceStatus',
			isnull(csi.ist_nombre,'') 'Estado Factura',
			isnull(csi.ist_descripcion,'') 'dscEstdFac'
		from DeliveryBackOffice.dbo.DeliveryOrder ord with(nolock)
		join DeliveryBackOffice.dbo.VisitPointClient vpc with(nolock) on ord.Sender_ID = vpc.CodeOfReference
		left join DeliveryBackOffice.dbo.invoiceDetail ide with(nolock) on ide.dti_fk_orderSerie = ord.Guide_Serie
																	and ide.dti_fk_orderNumber = ord.Guide_Number
		left join DeliveryBackOffice.dbo.invoiceHeader ihd with(nolock) on ihd.inv_pk_id = ide.dti_fk_header
		and ihd.inv_type = 1
		left join InOutOfMoneyDetail io with(nolock) ON io.io_invoice = ihd.inv_pk_id
		left join ctgTypeOfInOutOfMoney cio with(nolock) ON cio.tio_pk_id = io.io_type
		left join ctg_statusInvoice csi with(nolock) ON  csi.ist_pk_id = ihd.inv_status
		where ord.DateCreated between @fechaInicio and @fechaFin
		and vpc.CodeOfReference = ISNULL(@vpCodeOfReferences,vpc.CodeOfReference)
		and vpc.IdKindOfVPClient = ISNULL(@IdKindOfVPClient,vpc.IdKindOfVPClient)
	end
	if @opcion = 'resumen' begin
		select
			cast(COUNT(distinct ih.inv_pk_id) as varchar) + ' Facturas' 'Descripción',
			tio_pk_name 'Tipo de Pago',
			convert(varchar,sum(io.io_amount),1) 'Monto'
		from
			invoiceHeader ih with(nolock)
			join invoiceDetail id with(nolock) ON id.dti_fk_header = inv_pk_id
			join DeliveryOrder do with(nolock) ON do.Guide_Serie = id.dti_fk_orderSerie
						and do.Guide_Number = id.dti_fk_orderNumber
			left join InOutOfMoneyDetail io with(nolock) ON io.io_invoice = ih.inv_pk_id
			left join ctgTypeOfInOutOfMoney cio with(nolock) ON cio.tio_pk_id = io.io_type
			join VisitPointClient vp with(nolock) ON vp.CodeOfReference = ih.inv_vpCodeOfReferences
		where inv_vpCodeOfReferences = ISNULL(@vpCodeOfReferences,inv_vpCodeOfReferences)
		and inv_date between @fechaInicio and @fechaFin
		and vp.IdKindOfVPClient = ISNULL(@IdKindOfVPClient,vp.IdKindOfVPClient)
		and ih.inv_creditNote is null
		and inv_type in (1)--1: Factura 2: Nota de credito 3: Registro 4: Proforma
		and io.io_type in (1,2)--1: Efectivo 2: Tarjeta
		group by tio_pk_name
	end
END
