create procedure Reporte_de_membresías_y_suscripciones
as 
begin
DECLARE @StartDate AS DATETIME= CONVERT(VARCHAR, DATEPART(YY, DATEADD(MONTH,-1,GETDATE()))) + '-' + CONVERT(VARCHAR,DATEPART(MM, DATEADD(MONTH,-1,GETDATE()))) + '-' + '01 00:00:00'
PRINT @StartDate 
DECLARE @EndDate AS DATETIME= DATEADD(DAY,-1, CONVERT(VARCHAR, DATEPART(YY, DATEADD(MONTH,0,GETDATE()))) + '-' + CONVERT(VARCHAR,DATEPART(MM, DATEADD(MONTH,0,GETDATE()))) + '-' + '01 23:59:59')
PRINT @EndDate 

SELECT 'Anual' 'Tipo de Membresía/Suscripción',CTM.Description 'Nombre del cliente'
,MEM.InvoiceName 'Nombre en Factura',MEM.TaxIdNumber 'Nit'
,INH.inv_certificationFEL 'Certificación FEL'
,MEM.MembershipCost 'Monto Facturado con IVA'
,FORMAT (INH.inv_date, 'dd/MM/yyyy') 'Fecha de Factura'
,CAT.Name 'Descripción de Artículo'
,IND.SAPCode 'Número de Artículo'
,FORMAT (MEM.DateCreated, 'dd/MM/yyyy') 'Fecha de Compra'
,CTS.FirstName + ' ' + CTS.LastName 'Vendedor'
,IIF(MEM.CatTMSalesPersonId IS NULL,'Portal Web','Telemercadeo') 'Canal'
FROM DeliveryBackOffice.dbo.Membership MEM WITH(NOLOCK)
INNER JOIN DeliveryBackOffice.dbo.Customer CTM WITH(NOLOCK) 
	ON MEM.CustomerId = ctm.IdCustomer
LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH(NOLOCK)
	ON IND.MembershipId = MEM.IdMembership
LEFT JOIN DeliveryBackOffice.DBO.invoiceHeader INH WITH(NOLOCK)
	ON INH.inv_pk_id = IND.dti_fk_header
LEFT JOIN DeliveryBackOffice.dbo.CatArticleSAP CAT WITH(NOLOCK)
	ON CAT.SAPCode = IND.SAPCode AND CAT.RowSatus = 1
LEFT JOIN DeliveryBackOffice.dbo.CatTMSalesPerson CTS 
	ON CTS.IdCatTMSalesPerson = MEM.CatTMSalesPersonId
WHERE MEM.DateCreated BETWEEN @StartDate AND @EndDate
UNION
SELECT 'Mensual' 'Tipo de Membresía/Suscripción',CTM.Description 'Nombre del cliente'
,INH.inv_cli_name 'Nombre en Factura',INH.inv_cli_nit 'Nit'
,INH.inv_certificationFEL 'Certificación FEL'
,SUS.SubscriptionCost 'Monto Facturado con IVA'
,FORMAT (INH.inv_date, 'dd/MM/yyyy') 'Fecha de Factura'
,CAT.Name 'Descripción de Artículo'
,IND.SAPCode 'Número de Artículo'
,FORMAT (SUS.DateCreated, 'dd/MM/yyyy') 'Fecha de Compra'
,NULL 'Vendedor'
,'Portal Web' 'Canal'
FROM DeliveryBackOffice.dbo.Subscription SUS WITH(NOLOCK)
INNER JOIN DeliveryBackOffice.dbo.Membership MEM WITH(NOLOCK)
	ON SUS.MembershipId = MEM.IdMembership
INNER JOIN DeliveryBackOffice.dbo.Customer CTM WITH(NOLOCK) 
	ON SUS.CustomerId = CTM.IdCustomer
LEFT JOIN DeliveryBackOffice.dbo.invoiceDetail IND WITH(NOLOCK)
	ON IND.SubscriptionId = SUS.IdSubscription
LEFT JOIN DeliveryBackOffice.DBO.invoiceHeader INH WITH(NOLOCK)
	ON INH.inv_pk_id = IND.dti_fk_header
LEFT JOIN DeliveryBackOffice.dbo.CatArticleSAP CAT WITH(NOLOCK)
	ON CAT.SAPCode = IND.SAPCode AND CAT.RowSatus = 1
LEFT JOIN DeliveryBackOffice.dbo.CatTMSalesPerson CTS 
	ON CTS.IdCatTMSalesPerson = MEM.CatTMSalesPersonId
WHERE MEM.DateCreated BETWEEN @StartDate AND @EndDate
end