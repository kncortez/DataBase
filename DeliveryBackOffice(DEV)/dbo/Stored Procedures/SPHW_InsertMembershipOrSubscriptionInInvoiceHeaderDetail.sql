-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-12-29>
-- Description:	<SP para insertar datos de cabecera de facturación de membresías o suscripciones>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_InsertMembershipOrSubscriptionInInvoiceHeaderDetail]
@TypeSalePackage AS nvarchar(50),
@IdSalePackage int,
@IdAccount   int,
@Token AS VARCHAR(200)

	
AS
BEGIN
 
 -- Datos cliente Cabecera de factura 
   
   DECLARE @inv_vpCodeOfReferences AS int = 999
   DECLARE @inv_cmp_nit  as varchar(100)=(SELECT dpf_FELEntity FROM [dbo].[del_ParametrosFactura] WITH (NOLOCK) WHERE dpf_VpCodeOfReference = @inv_vpCodeOfReferences)
   DECLARE @inv_cli_name as varchar(200)
   DECLARE @inv_cli_adress as varchar (200)
   DECLARE @inv_cli_nit as varchar (200)
   DECLARE @inv_cli_email as varchar (200)
   DECLARE @inv_date as datetime=GETDATE()
   DECLARE @inv_IVA as money 
   DECLARE @inv_amount as money
   DECLARE @inv_status AS INT = 1
   DECLARE @inv_dateRegister datetime=GETDATE()
   DECLARE @inv_tokenRegister varchar(200)=@Token
   ------------------------------------------------------------------------------------
   ------------------------------------------------------------------------------------

  
   ------------------------------------------------------------------------------------
   --Datos detalle de factura
    DECLARE @dti_fk_header bigint

    DECLARE     @dti_identification	varchar(200)='SERVICIO'
	DECLARE		@dti_category varchar(50)='SERVICIO'
	DECLARE		@dti_quantity decimal(10, 5)=1
	DECLARE		@dti_measurement varchar(20)='UND'
	DECLARE		@dti_priceUnit money
	DECLARE		@dti_description varchar(MAX)=(Select [Description] From [dbo].[CatArticleSAP] WITH (NOLOCK) Where Name='MEMBRESIA ANUAL CLUB FORZA' COLLATE Latin1_General_CI_AI) 
	DECLARE		@dti_IVA money
	DECLARE		@dti_amount money
	DECLARE		@dti_dateRegister datetime=GETDATE()
	DECLARE		@dti_tokenRegister varchar(200)= @Token
	DECLARE		@SAPCode nvarchar(50)=(Select TOP 1 SAPCode From [dbo].[CatArticleSAP] WITH (NOLOCK) Where Name='MEMBRESIA ANUAL CLUB FORZA' COLLATE Latin1_General_CI_AI)
	DECLARE		@SendToInvoice bit=1
	DECLARE     @Descriptionp AS NVARCHAR(500)


	IF(@TypeSalePackage ='Plan Básico')
		 SET @dti_description = (Select TOP 1[Description] From [dbo].[CatArticleSAP] WITH (NOLOCK) Where [Name]='SUSCRIPCION MENSUAL A' COLLATE Latin1_General_CI_AI)
	ELSE IF(@TypeSalePackage ='Plan Básico +')
		SET  @IdSalePackage = (Select TOP 1[Description] From [dbo].[CatArticleSAP]   WITH (NOLOCK) Where [Name]='SUSCRIPCION MENSUAL B' COLLATE Latin1_General_CI_AI)
    ELSE IF(@TypeSalePackage = 'Plan Gold')
	    SET  @dti_description =(Select TOP 1 [Description] From [dbo].[CatArticleSAP]  WITH (NOLOCK) Where [Name]='SUSCRIPCION MENSUAL C' COLLATE Latin1_General_CI_AI)
	ELSE IF(@TypeSalePackage = 'Plan Corporativo')
	    SET @dti_description =(Select TOP 1 [Description] From [dbo].[CatArticleSAP]   WITH (NOLOCK) Where [Name]='SUSCRIPCION MENSUAL D' COLLATE Latin1_General_CI_AI)
	


BEGIN TRANSACTION
BEGIN TRY

       IF(@TypeSalePackage = 'Membership' COLLATE Latin1_General_CI_AI)
		BEGIN
  
		  SELECT 
		        @inv_amount     = M.MembershipCost,
		        @inv_cli_email  = M.InvoiceEmail,
				@inv_cli_adress = M.FiscalAddress ,
				@inv_cli_nit    = M.TaxIdNumber,
				@inv_cli_name   = M.InvoiceName,
				@inv_IVA  =   M.MembershipCost - (M.MembershipCost / 1.12),
				@Descriptionp = CM.MembershipName
		    FROM [DeliveryBackOffice].[dbo].[Membership] M WITH (NOLOCK)
			     INNER JOIN [dbo].[CatMembership] CM WITH (NOLOCK)
				 ON M.CatMembershipId = CM.IdCatMembership
			WHERE AccountId =   @IdAccount AND 
				 M.RowStatus = 1 AND 
				 CM.IdCatMembership = @IdSalePackage

				SET @dti_description = @dti_description 
		 

		END
		ELSE
		BEGIN
		
		

			Select  
			    @inv_amount     = S.SubscriptionCost,
		        @inv_cli_email  = M.InvoiceEmail,
				@inv_cli_adress = M.FiscalAddress ,
				@inv_cli_nit    = M.TaxIdNumber,
				@inv_cli_name   = M.InvoiceName,
				@inv_IVA  =   S.SubscriptionCost - (S.SubscriptionCost / 1.12),
				@Descriptionp = CS.SubscriptionName
				From dbo.Membership M WITH (NOLOCK)
					Inner Join [dbo].[Subscription] S WITH (NOLOCK)
				ON M.IdMembership = s.MembershipId
					Inner Join dbo.CatSubscription CS
				ON s.CatSubscriptionId= cs.IdCatSubscription
				WHERE M.AccountId =   @IdAccount AND 
					  M.RowStatus = 1 AND 
				      CS.IdCatSubscription = @IdSalePackage

				SET @dti_description = @dti_description +' '+   @Descriptionp
		 
		
		END


		INSERT INTO [dbo].[invoiceHeader]
		(
			inv_vpCodeOfReferences,
			inv_cmp_nit,
			inv_cli_name,
			inv_cli_adress,
			inv_cli_nit,
			inv_cli_email,
			inv_date,
			inv_IVA,
			inv_amount,
			inv_status,
			inv_dateRegister,
			inv_tokenRegister,
			inv_type

		) VALUES
		(
		    
			@inv_vpCodeOfReferences,
			@inv_cmp_nit,
			@inv_cli_name,
			@inv_cli_adress,
			@inv_cli_nit,
			@inv_cli_email,
			@inv_date,
			@inv_IVA,
			@inv_amount,
			@inv_status,
			@inv_dateRegister,
			@inv_tokenRegister,
			1
		
		)



		SET @dti_fk_header = SCOPE_IDENTITY()

		INSERT INTO [dbo].[invoiceDetail]
		(
		dti_fk_header,
		dti_identification,
		dti_category,
		dti_quantity,
		dti_measurement,
		dti_priceUnit,
		dti_description,
		dti_IVA,
		dti_amount,
		dti_dateRegister,
		dti_tokenRegister,
		SAPCode,
		SendToInvoice
		) VALUES
		(
			@dti_fk_header,
			@dti_identification,	
			@dti_category,
			@dti_quantity,
			@dti_measurement,
			@inv_amount,
			@dti_description,
			@inv_IVA,
			@inv_amount,
			@dti_dateRegister,
			@dti_tokenRegister,
			@SAPCode,
			@SendToInvoice
			
		
		)



		COMMIT TRANSACTION

		SELECT Result=1,'Transacción exitosa' AS 'Description' ,@dti_fk_header IdInvoice
END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION
		SELECT Result=0,	
		       ERROR_MESSAGE() AS 'Description', IdInvoice=0
	END CATCH
END