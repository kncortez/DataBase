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
@Subscription int=null,
@TipoEnvio AS INT =0,
@TipoComisionCOD AS INT=0
AS
BEGIN

	SET NOCOUNT ON;

	 SET @Guide =  SUBSTRING(@Guide, 0, IIF(CHARINDEX('-', @Guide) = 0, (LEN(@Guide)), (CHARINDEX('-', @Guide) - 0)))

	

If (@Guide IS NOT NULL) 
Begin


 DECLARE @OptionGuide AS INT = (Select 
								Count(IH.inv_numberFEL)
								FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
											INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
											ON IH.inv_pk_id = ID.dti_fk_header
								WHERE ID.dti_fk_orderSerie + Cast(ID.dti_fk_orderNumber as varchar) = @Guide)



   IF (@OptionGuide =1)
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
					 WHERE ID.dti_fk_orderSerie + Cast(ID.dti_fk_orderNumber as varchar) = @Guide AND 
					 IH.inv_invoiceOfCreditNote IS NULL AND inv_certificationFEL IS NOT NULL
   



   END
	   ELSE IF (@OptionGuide>=2)
		   BEGIN
					Select 1 'HaveaCreditNote'
		   END
			   ELSE
				   Select 2 'HaveaCreditNote'

END
ELSE IF (@NumberFel IS NOT NULL)
BEGIN

	Declare @OptionFel INT =( Select
									Count(IH.inv_serieFEL)
								 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
									 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
									 ON IH.inv_pk_id = ID.dti_fk_header
								 WHERE IH.inv_certificationFEL IS NOT NULL   AND inv_certificationFEL = @NumberFel)

IF (@OptionFel=1)
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
					 IH.inv_invoiceOfCreditNote IS NULL AND inv_certificationFEL = @NumberFel
END
	ELSE IF (@OptionFel=2)
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
	Declare @OptionMembership INT =( Select COUNT(IH.inv_numberFEL)
										 FROM [dbo].[invoiceHeader] IH WITH (NOLOCK)
											 INNER JOIN [dbo].[invoiceDetail] ID WITH (NOLOCK)
											 ON IH.inv_pk_id = ID.dti_fk_header
										 WHERE inv_status  in(-1,1,2)
											  AND (IH.inv_certificationFEL IS NOT NULL 
											  AND IH.inv_certificationFEL<>'')
											  AND ID.MembershipId= @Membership )
IF (@OptionMembership=1)
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
	ELSE IF(@OptionMembership=2)
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
IF (@OptionSubscription=1)
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
ELSE IF(@OptionSubscription=2)
	BEGIN
		Select 1 'HaveaCreditNote'
		END
			ELSE
				BEGIN
					Select 2 'HaveaCreditNote'
					END	

END

   END