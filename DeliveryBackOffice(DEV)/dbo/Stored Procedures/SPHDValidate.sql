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


		       SET @Envio =(Select IdCatInvoiceType From [dbo].[CatInvoiceType] CIT  WHERE [Name]='Envío')
			   SET @ComisionCOD =(Select IdCatInvoiceType From [dbo].[CatInvoiceType] CIT  WHERE [Name]='Comisión COD')

		
			



		IF CHARINDEX('-', @Guide) > 0
		BEGIN
		   SET  @Guide=  SUBSTRING(@Guide, 0, IIF(CHARINDEX('-', @Guide) = 0, (LEN(@Guide)), (CHARINDEX('-', @Guide) - 0)))
		END
If (@Guide IS NOT NULL) 
Begin


 DECLARE @OptionGuide AS INT = (Select 
								COUNT(IH.inv_creditNote)
								FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
											INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
											ON IH.inv_pk_id = ID.dti_fk_header
								WHERE ID.dti_fk_orderSerie + Cast(ID.dti_fk_orderNumber as varchar) = @Guide

								        
								)



   IF (@OptionGuide =0)
   BEGIN



    IF (@TipoEnvio > 0  OR @TipoComisionCOD >0)
	 BEGIN

			Select 0 'HaveaCreditNote',
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
							 AND (IH.CatInvoiceTypeId IS NULL OR IH.CatInvoiceTypeId IN (@Envio,@ComisionCOD))
         END
		 ELSE
		 BEGIN

		 	Select 0 'HaveaCreditNote',
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

		 END
   



   END
	   ELSE IF (@OptionGuide>=1)
		   BEGIN
					Select 1 'HaveaCreditNote'
		   END
			   ELSE
				   Select 2 'HaveaCreditNote'

END
ELSE IF (@NumberFel IS NOT NULL)
BEGIN


	Declare @OrderNumber INT =	(Select TOP 1
										ID.dti_fk_orderNumber
								 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
									 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
									 ON IH.inv_pk_id = ID.dti_fk_header
								 WHERE IH.inv_certificationFEL IS NOT NULL   
								 AND inv_certificationFEL =  @NumberFel
								 )

	Declare @OptionFel INT =(  Select Top 1
										COUNT(IH.inv_creditNote)
								 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
									 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
									 ON IH.inv_pk_id = ID.dti_fk_header
								 WHERE IH.inv_certificationFEL IS NOT NULL 
								 AND ID.dti_fk_orderNumber = @OrderNumber
								 )

IF (@OptionFel IS NOT NULL OR @OptionFel>0)
BEGIN
Select TOP 1 0 'HaveaCreditNote',
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
					 ORDER BY IH.inv_pk_id DESC
END
	ELSE IF (@OptionFel>=1)
		BEGIN
			Select 1 'HaveaCreditNote'
		END
			ELSE
				BEGIN
					Select 2 'HaveaCreditNote'
				END
   


END
ELSE IF (@Membership IS NOT NULL)
BEGIN
	Declare @OptionMembership INT =( Select COUNT(IH.inv_creditNote)
										 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
											 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
											 ON IH.inv_pk_id = ID.dti_fk_header
										 WHERE inv_status  in(-1,1,2)
											  AND (IH.inv_certificationFEL IS NOT NULL 
											  AND IH.inv_certificationFEL<>'')
											  AND ID.MembershipId= @Membership )
IF (@OptionMembership=0)
BEGIN

	Select 0 'HaveaCreditNote',
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

	END
	ELSE IF(@OptionMembership>=1)
	BEGIN
		Select 1 'HaveaCreditNote'
		END
			ELSE
				BEGIN
					Select 2 'HaveaCreditNote'
					END	
END
ELSE IF (@Subscription IS NOT NULL)
BEGIN

Declare @OptionSubscription INT =(  Select COUNT(IH.inv_numberFEL)
										 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
											 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
											 ON IH.inv_pk_id = ID.dti_fk_header
										 WHERE 
											 inv_status  in(-1,1,2)
											  AND
											 (IH.inv_certificationFEL IS NOT NULL 
											  AND IH.inv_certificationFEL<>'')
											  AND ID.SubscriptionId =@Subscription )
IF (@OptionSubscription=0)
BEGIN

Select 0 'HaveaCreditNote',
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
END
ELSE IF(@OptionSubscription>=1)
	BEGIN
		Select 1 'HaveaCreditNote'
		END
			ELSE
				BEGIN
					Select 2 'HaveaCreditNote'
					END	

END

   END