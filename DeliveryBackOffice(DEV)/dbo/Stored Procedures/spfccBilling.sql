-- =============================================
-- Author:		<Author,Edelman Vásquez>
-- Create date: <Create Date,2022-04-04>
-- Description:	<Description,SP devuelve los datos de facturación>
-- =============================================
CREATE PROCEDURE [dbo].[spfccBilling] 
	-- Add the parameters for the stored procedure here
	@GuideNumber as INT 

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
Select Top 1  a.inv_numberFEL, 
              a.inv_certificationFEL,
              a.inv_cli_name, 
			  a.inv_cli_nit, 
			  a.inv_amount, 
			  a.inv_date
       From dbo.invoiceheader  a         WITH (NOLOCK)
       Inner Join    dbo.invoicedetail b WITH (NOLOCK)
	   On a.inv_pk_id=b.dti_fk_header
Where b.dti_fk_orderNumber = @GuideNumber And a.inv_certificationFEL IS NOT NULL

END
