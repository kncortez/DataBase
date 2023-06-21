-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2023-03-31>
-- Description:	<VALIDAR SI FACTURA TIENE NOTA DE CREDITO>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDValidate]
@Guide     Nvarchar(25)=null,
@DateOf    Datetime=null,
@DateTo    DateTime=null,
@NumberFel Nvarchar(40)=null,
@Membership int=null,
@Subscription INT=null,
@TipoEnvio AS INT =0,
@TipoComisionCOD AS INT=0
AS
BEGIN

	SET NOCOUNT ON;

	

	 DECLARE @Envio INT =0
	 DECLARE @ComisionCOD INT=0

	       -- IF(@TipoEnvio > 0)
		       SET @Envio =(Select IdCatInvoiceType From [dbo].[CatInvoiceType] CIT  WHERE [Name]='Envío')

		    
			--IF(@TipoComisionCOD>0)
			SET @ComisionCOD =(Select IdCatInvoiceType From [dbo].[CatInvoiceType] CIT  WHERE [Name]='Comisión COD')

		
			



		IF CHARINDEX('-', @Guide) > 0
		BEGIN
		   SET  @Guide=  SUBSTRING(@Guide, 0, IIF(CHARINDEX('-', @Guide) = 0, (LEN(@Guide)), (CHARINDEX('-', @Guide) - 0)))
		END
If (@Guide IS NOT NULL) 
Begin



    IF (@TipoEnvio = 1 And @TipoComisionCOD = 0)
	 BEGIN

			Select 
			    Top 1
				ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote',
				ID.dti_description,
				IH.inv_pk_id,
				IH.inv_serieFEL,
				IH.inv_numberFEL,
				IH.inv_certificationFEL,
				IH.inv_cli_name
						 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
							 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
							 ON IH.inv_pk_id = ID.dti_fk_header
							 WHERE ID.dti_fk_orderSerie + Cast(ID.dti_fk_orderNumber as varchar) = @Guide 
							 AND   IH.inv_invoiceOfCreditNote IS NULL
							 AND   inv_certificationFEL IS NOT NULL
							 AND (IH.CatInvoiceTypeId IS NULL OR IH.CatInvoiceTypeId IN (@Envio))
							 AND IH.inv_creditNote IS NULL
							 AND   IH.inv_invoiceOfCreditNote IS  NULL
							 ORDER BY IH.inv_pk_id DESC
         END
		ELSE IF (@TipoComisionCOD = 1 And @TipoEnvio=0)
		 BEGIN

			Select Top 1 
			    ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote',
				ID.dti_description,
				IH.inv_pk_id,
				IH.inv_serieFEL,
				IH.inv_numberFEL,
				IH.inv_certificationFEL,
				IH.inv_cli_name
						 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
							 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
							 ON IH.inv_pk_id = ID.dti_fk_header
							 WHERE ID.dti_fk_orderSerie + Cast(ID.dti_fk_orderNumber as varchar) = @Guide 
							 AND   IH.inv_invoiceOfCreditNote IS NULL
							 AND   inv_certificationFEL IS NOT NULL
							 AND (IH.CatInvoiceTypeId IS NULL OR IH.CatInvoiceTypeId IN (@ComisionCOD))
							 AND IH.inv_creditNote IS NULL
							 AND  IH.inv_invoiceOfCreditNote IS   NULL
							 ORDER BY IH.inv_pk_id DESC
         END
	ELSE IF (@TipoEnvio = 1  And @TipoComisionCOD =1)
	 BEGIN

			Select
				ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote',
				ID.dti_description,
				IH.inv_pk_id,
				IH.inv_serieFEL,
				IH.inv_numberFEL,
				IH.inv_certificationFEL,
				IH.inv_cli_name
						 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
							 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
							 ON IH.inv_pk_id = ID.dti_fk_header
							 WHERE ID.dti_fk_orderSerie + Cast(ID.dti_fk_orderNumber as varchar) = @Guide 
							 AND   inv_certificationFEL IS NOT NULL
							 AND IH.inv_creditNote IS NULL
							 AND  IH.inv_invoiceOfCreditNote IS  NULL

         END
	
		 ELSE
		 BEGIN

	
				Select
				ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote',
				ID.dti_description,
				IH.inv_pk_id,
				IH.inv_serieFEL,
				IH.inv_numberFEL,
				IH.inv_certificationFEL,
				IH.inv_cli_name
						 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
							 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
							 ON IH.inv_pk_id = ID.dti_fk_header
							 WHERE ID.dti_fk_orderSerie + Cast(ID.dti_fk_orderNumber as varchar) = @Guide 
							 AND   inv_certificationFEL IS NOT NULL
							 AND IH.inv_creditNote IS NULL
							 AND  IH.inv_invoiceOfCreditNote IS   NULL
							

		 END
   




END
ELSE IF (@NumberFel IS NOT NULL)
BEGIN


Select TOP 1 ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote',
	    ID.dti_description,
		IH.inv_pk_id,
        IH.inv_serieFEL,
		IH.inv_numberFEL,
		IH.inv_certificationFEL,
		IH.inv_cli_name
		         FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
                     INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
					 ON IH.inv_pk_id = ID.dti_fk_header
					 WHERE 
					 IH.inv_invoiceOfCreditNote IS NULL AND inv_certificationFEL = @NumberFel
					  AND IH.inv_creditNote IS NULL
					  AND  IH.inv_invoiceOfCreditNote IS  NULL
					 ORDER BY IH.inv_pk_id DESC
					 
						

   


END
ELSE IF (@Membership IS NOT NULL)
BEGIN
	
	Select ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote',
			ID.dti_description,
			IH.inv_pk_id,
			IH.inv_serieFEL,
			IH.inv_numberFEL,
			IH.inv_certificationFEL,
			IH.inv_cli_name
					 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
						 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
						 ON IH.inv_pk_id = ID.dti_fk_header
						 WHERE 
						 IH.inv_invoiceOfCreditNote IS NULL AND ID.MembershipId = @Membership
						 AND  IH.inv_dateFEL Between  @DateOf + ' 00:00:00'  AND @DateTo + ' 23:59:59'
						 AND   inv_certificationFEL IS NOT NULL
						 AND IH.inv_creditNote IS NULL
						 AND  IH.inv_invoiceOfCreditNote IS  NULL

	
END
ELSE IF (@Subscription IS NOT NULL)
BEGIN



Select ISNULL(IH.inv_creditNote,0) 'HaveaCreditNote',
	    ID.dti_description,
		IH.inv_pk_id,
        IH.inv_serieFEL,
		IH.inv_numberFEL,
		IH.inv_certificationFEL,
		IH.inv_cli_name
		         FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
                     INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
					 ON IH.inv_pk_id = ID.dti_fk_header
					 WHERE  
					 IH.inv_invoiceOfCreditNote IS NULL AND  ID.SubscriptionId = @Subscription
					 AND   IH.inv_dateFEL Between  @DateOf + ' 00:00:00'  AND @DateTo + ' 23:59:59'
					 AND   inv_certificationFEL IS NOT NULL
					 AND IH.inv_creditNote IS NULL
					 AND  IH.inv_invoiceOfCreditNote IS   NULL

END

   END