-- =============================================
-- Author:		<Eduardo L�pez>
-- Create date: <Create Date,07/12/2023>
-- Description:	<Activaci�n de productos de marketplace>
-- =============================================
CREATE PROCEDURE ActiveProductMarketplace
@Email VARCHAR (100),
@Code VARCHAR(25)

AS

BEGIN
	BEGIN
	DECLARE @EXISTPRODUCT INT;

	SET @EXISTPRODUCT = (SELECT TOP 1 COUNT(ActivationCode) 
								FROM Product WITH(NOLOCK)
								WHERE ActivationCode = @Code)

	IF(@EXISTPRODUCT > 0)

		BEGIN
		 UPDATE Product
			SET RowStatus = 1
			WHERE ActivationCode = @Code
		SELECT cp.CatProductName,
		IIF(cp.CatProductName = 'Gift Card',('Felicidades..! has activado la '+' '+cp.CatProductName), 
		(IIF(cp.CatProductName = 'Club Forza',('Felicidades..! has activado la membresía'+' '+cp.CatProductName),('Felicidades..! has activado el'+' '+cp.CatProductName)))) AS Message,
		REPLACE(CONVERT(VARCHAR(10),pt.ProductExpirationDate,105),'-','/') AS DateExpiration
		from CatProduct cp WITH(NOLOCK)
		  INNER JOIN Product pt WITH(NOLOCK)
		  ON cp.IdCatProduct = pt.CatProductId
		  WHERE pt.ActivationCode = @Code

		SELECT DISTINCT CatProductAttributeDescription FROM CatProductAttribute cpa WITH(NOLOCK)
			INNER JOIN CatProduct ctp WITH(NOLOCK)
			ON cpa.CatProductId = ctp.IdCatProduct
			INNER JOIN Product pdt WITH(NOLOCK)
			ON ctp.IdCatProduct = pdt.CatProductId
			 WHERE pdt.ActivationCode = @Code

	    END
	ELSE

		BEGIN
			SELECT 
			0 AS CatProductName,
			'El código del producto ingresado no existe' AS Message,
			'' AS DateExpiration


		END
END