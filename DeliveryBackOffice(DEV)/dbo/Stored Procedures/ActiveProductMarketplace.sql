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
	DECLARE @EXISTPRODUCT INT;

	SET @EXISTPRODUCT = (SELECT TOP 1 COUNT(ActivationCode) 
								FROM Subscription WITH(NOLOCK)
								WHERE ActivationCode = @Code)

	IF(@EXISTPRODUCT > 0)

		BEGIN
		 UPDATE Subscription
			SET RowStatus = 1
			WHERE ActivationCode = @Code

		  SELECT cp.SubscriptionName AS CatProductName,
		IIF(cp.SubscriptionName = 'Gift Card',('Felicidades..! has activado la '+' '+cp.SubscriptionName), 
		(IIF(cp.SubscriptionName = 'Club Forza',('Felicidades..! has activado la membresía'+' '+cp.SubscriptionName),('Felicidades..! has activado el'+' '+cp.SubscriptionName)))) AS Message,
		REPLACE(CONVERT(VARCHAR(10),pt.ExpirationDate,105),'-','/') AS DateExpiration
		from CatSubscription cp WITH(NOLOCK)
		  INNER JOIN Subscription pt WITH(NOLOCK)
		  ON cp.IdCatSubscription = pt.CatSubscriptionId
		  WHERE pt.ActivationCode = @Code

		SELECT DISTINCT SubscriptionAttributeDescription AS CatProductAttributeDescription FROM CatSubscriptionAtribute cpa WITH(NOLOCK)
			INNER JOIN CatSubscription ctp WITH(NOLOCK)
			ON cpa.CatSubscriptionId = ctp.IdCatSubscription
			INNER JOIN Subscription pdt WITH(NOLOCK)
			ON ctp.IdCatSubscription = pdt.CatSubscriptionId
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