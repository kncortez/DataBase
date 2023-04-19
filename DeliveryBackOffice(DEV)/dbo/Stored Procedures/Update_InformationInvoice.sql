-- =============================================
-- Author:		<Eduardo, López>
-- Create date: <2023-02-28>
-- Description:	<Completar data incompleta de facturas>
-- =============================================
CREATE PROCEDURE [dbo].[Update_InformationInvoice]
	@CertificationFEL VARCHAR(100),
	@SerieFEL VARCHAR(50),
	@AddressEXC VARCHAR(200),
	@ClientNit VARCHAR(25),
	@ClientName VARCHAR(100),
	@NumberFEL VARCHAR(25),
	@Inv_pk_id INT
AS
BEGIN
	
	DECLARE @DateFac DATETIME;
	DECLARE @DateNow VARCHAR (10)

	SET @DateFac = (SELECT TOP 1 inv_dateRegister FROM invoiceHeader WITH (NOLOCK) WHERE inv_pk_id = @Inv_pk_id)
	SET @DateNow = (SELECT CONVERT(VARCHAR, GETDATE(),101))

	UPDATE 
		DeliveryBackOffice.dbo.invoiceHeader 
	SET 
		inv_certificationFEL= @CertificationFEL
		,inv_serieFEL= @SerieFEL
		,inv_cmp_adress= @AddressEXC
		,inv_cli_nit= @ClientNit
		,inv_cli_name= @ClientName
		,inv_cmp_nameFEL= @ClientName
		,inv_numberFEL= @NumberFEL
		,inv_FechaHoraFEL= @DateFac
		,inv_dateFEL= @DateFac
		,inv_cmp_nit='86534599'
		,inv_status = -1
		,inv_cmp_name='DELIVERY EXPRESS, SOCIEDAD ANONIMA'
		,inv_cmp_nameComercial='DELIVERY EXPRESS'
		,inv_descriptionFEL='PROCESO REALIZADO'
		,inv_RequestorFEL='301767F2-BA4D-43A2-9131-E13C95857549'
		,inv_TransactionFEL='SYSTEM_REQUEST'
		,inv_CountryFEL='GT'
		,inv_EntityFEL='GT'
		,inv_UserFEL='301767F2-BA4D-43A2-9131-E13C95857549'
		,inv_UserName='ADMINISTRADOR'
		,inv_Data1FEL='POST_DOCUMENTGT'
		,inv_Data3FEL='XML'
		,inv_subjectFEL='Forza Delivery - Factura Electrónica'
		,inv_tokenUpdate = 'UPDATE MANUAL '+@DateNow
		,inv_establecimientoFEL=1 
	WHERE 
		inv_pk_id = @Inv_pk_id
			

END