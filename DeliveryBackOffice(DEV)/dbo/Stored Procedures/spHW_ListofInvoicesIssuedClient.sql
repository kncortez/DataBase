-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-10-7>
-- Description:	<sP Nuevo método que lista las facturas emitidas de un cliente>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_ListofInvoicesIssuedClient]
@IdCustomer AS INT,
@DateOf AS DATETIME=NULL,
@DateTo AS DATETIME=NULL

AS
BEGIN

	

	SET @DateTo  = Format(GETDATE(),'yyyy-MM-dd');
	
	
	SET NOCOUNT ON;
	 
   IF (@DateOf IS NULL)
	BEGIN
		SET @DateOf  = Format(GETDATE()-7,'yyyy-MM-dd');
		SET @DateTo  = Format(GETDATE(),'yyyy-MM-dd');
	END


	IF((SELECT DATEDIFF(DAY,@DateOf,@DateTo))>30) /* Validar que el rango no sea mayor a 30 días  */
	BEGIN

	    SET @DateOf   = Format(GETDATE()-30,'yyyy-MM-dd');
		SET @DateTo = Format(GETDATE(),'yyyy-MM-dd');

	SELECT DISTINCT CONVERT(DATE,ih.inv_date) inv_date,
						ih.inv_pk_id,
					   ih.inv_certificationFEL,
					   ih.inv_amount,
					   SO.OrderDescription estado
				FROM DeliveryBackOffice.dbo.invoiceHeader ih WITH (NOLOCK)
					INNER JOIN dbo.invoiceDetail id WITH (NOLOCK)
						ON id.dti_fk_header = ih.inv_pk_id
					INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
						ON ord.Guide_Serie = id.dti_fk_orderSerie
						   AND ord.Guide_Number = id.dti_fk_orderNumber
						   AND ord.IdCustomer = @IdCustomer
					INNER JOIN dbo.DeliveryOrder DO WITH (NOLOCK)
					    ON id.dti_fk_orderSerie = DO.Guide_Serie 
						   AND id.dti_fk_orderNumber = DO.Guide_Number
					INNER JOIN dbo.StatusOrder SO WITH (NOLOCK)
					    ON  DO.StatusOrderId = SO.StatusOrderId 
				WHERE CONVERT(DATE, ih.inv_date)
				BETWEEN  CONVERT(DATE ,@DateOf)  AND CONVERT(DATE, @DateTo) 
				
	END
	ELSE
	BEGIN 
			SELECT DISTINCT CONVERT(DATE,ih.inv_date) inv_date,
						ih.inv_pk_id,
					   ih.inv_certificationFEL,
					   ih.inv_amount,
					   SO.OrderDescription estado
				FROM DeliveryBackOffice.dbo.invoiceHeader ih WITH (NOLOCK)
					INNER JOIN dbo.invoiceDetail id WITH (NOLOCK)
						ON id.dti_fk_header = ih.inv_pk_id
					INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
						ON ord.Guide_Serie = id.dti_fk_orderSerie
						   AND ord.Guide_Number = id.dti_fk_orderNumber
						   AND ord.IdCustomer = @IdCustomer
					INNER JOIN dbo.DeliveryOrder DO WITH (NOLOCK)
					    ON id.dti_fk_orderSerie = DO.Guide_Serie 
						   AND id.dti_fk_orderNumber = DO.Guide_Number
					INNER JOIN dbo.StatusOrder SO WITH (NOLOCK)
					    ON  DO.StatusOrderId = SO.StatusOrderId 
				WHERE CONVERT(DATE, ih.inv_date)
					BETWEEN  CONVERT(DATE ,@DateOf)  AND CONVERT(DATE, @DateTo) 
	
	
	END

END