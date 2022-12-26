-- =============================================
-- Author:		<Edelman, Vásquez>
-- Create date: <2022-10-7>
-- Description:	<SP lista guías pagadas que no tengan Factura>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_ListofPaidGuidesthatdonotHaveanInvoice] 
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

		  SELECT CONVERT( DATE, ord.DateCreated),
			   ord.Guide_Serie,
			   ord.Guide_Number,
			   ord.PriceShippment,
			   st.OrderDescription
		FROM dbo.DeliveryOrder ord WITH (NOLOCK)
			 INNER JOIN dbo.Cost cst WITH(NOLOCK) ON cst.ProductNumber = CONCAT(ord.Guide_Serie,ord.Guide_Number)
						AND ISNULL(cst.TotalAmountPaid,0)>0
			 LEFT JOIN dbo.invoiceDetail id WITH(NOLOCK) ON id.dti_fk_orderSerie= ord.Guide_Serie 
						AND id.dti_fk_orderNumber = ord.Guide_Number
			 INNER JOIN dbo.StatusOrder st ON st.StatusOrderId = ord.StatusOrderId
		WHERE ord.Guide_Serie = 'FD'
			  AND ord.IdCustomer = @IdCustomer
			  AND id.dti_fk_header IS NULL
			  AND CONVERT( DATE, ord.DateCreated) BETWEEN @DateOf AND @DateTo
	  
   END
   ELSE
	BEGIN 

	SELECT CONVERT( DATE, ord.DateCreated),
			   ord.Guide_Serie,
			   ord.Guide_Number,
			   ord.PriceShippment,
			   st.OrderDescription
		FROM dbo.DeliveryOrder ord WITH (NOLOCK)
			 INNER JOIN dbo.Cost cst WITH(NOLOCK) ON cst.ProductNumber = CONCAT(ord.Guide_Serie,ord.Guide_Number)
						AND ISNULL(cst.TotalAmountPaid,0)>0
			 LEFT JOIN dbo.invoiceDetail id WITH(NOLOCK) ON id.dti_fk_orderSerie= ord.Guide_Serie 
						AND id.dti_fk_orderNumber = ord.Guide_Number
			 INNER JOIN dbo.StatusOrder st ON st.StatusOrderId = ord.StatusOrderId
		WHERE ord.Guide_Serie = 'FD'
			  AND ord.IdCustomer = @IdCustomer
			  AND id.dti_fk_header IS NULL
			  AND CONVERT( DATE, ord.DateCreated) BETWEEN @DateOf AND @DateTo
	END
END