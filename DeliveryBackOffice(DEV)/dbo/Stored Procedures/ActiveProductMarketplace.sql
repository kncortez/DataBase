-- =============================================
-- Author:		<Eduardo L�pez>
-- Create date: <Create Date,07/12/2023>
-- Description:	<Activaci�n de productos de marketplace>
-- =============================================
CREATE PROCEDURE ActiveProductMarketplace
@Email NVARCHAR (100),
@Code NVARCHAR(25),
@Token NVARCHAR(50)= ''
AS

BEGIN
	DECLARE @ActivationCode NVARCHAR(50) = '';
	DECLARE @RowStatus bit=0;
	DECLARE @IdAccount bigint = null
	DECLARE @IdCustomer int = null

	SELECT TOP 1 @ActivationCode = ActivationCode, @RowStatus = RowStatus 
								FROM Subscription WITH(NOLOCK)
								WHERE ActivationCode = @Code

	select @IdAccount=A2.RuaIdAccount,@IdCustomer=A3.IdCustomer from RegisterUser A1			
			INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount A2
			ON A1.UsrIdUser = A2.RuaIdUser AND A2.RuaRowStatus = 1
			INNER JOIN DeliveryBackOffice.dbo.Account A3
			ON A3.AccIdAccount = A2.RuaIdAccount AND A3.AccRowStatus = 1
			where UsrEmail = @Email and UsrRowStatus = 1			

	IF (@IdAccount is null)
	BEGIN
		SELECT 
			0 AS CatProductName,
			'No se encontró cuenta relacionado con el correo' + @Email  AS Message,
			'' AS DateExpiration
	END
	ELSE
	--Si es una suscripción y no se ha usado
	IF(LEN(@ActivationCode) > 0 and @RowStatus = 0)	
		BEGIN
		 UPDATE Subscription
			SET RowStatus = 1
			,AccountId = @IdAccount
			,CustomerId = @IdCustomer
			,TokenUpdated = @Token
			,DateUpdated = GETDATE()	
			,ActivationDAte = GETDATE()
			WHERE ActivationCode = @Code
			
		  SELECT cp.SubscriptionName AS CatProductName,
		IIF(cp.SubscriptionName = 'Gift Card',('Felicidades..! has activado la '+' '+cp.SubscriptionName), 
		(IIF(cp.SubscriptionName = 'Club Forza',('Felicidades..! has activado la membresía'+' '+cp.SubscriptionName),('Felicidades..! has activado el'+' '+cp.SubscriptionName)))) AS Message,
		REPLACE(CONVERT(VARCHAR(10),pt.ExpirationDate,105),'-','/') AS DateExpiration
		from CatSubscription cp WITH(NOLOCK)
		  INNER JOIN Subscription pt WITH(NOLOCK)
		  ON cp.IdCatSubscription = pt.CatSubscriptionId and pt.RowStatus = 1
		  WHERE pt.ActivationCode = @Code		 

		SELECT DISTINCT SubscriptionAttributeDescription AS CatProductAttributeDescription FROM CatSubscriptionAtribute cpa WITH(NOLOCK)
			INNER JOIN CatSubscription ctp WITH(NOLOCK)
			ON cpa.CatSubscriptionId = ctp.IdCatSubscription
			INNER JOIN Subscription pdt WITH(NOLOCK)
			ON ctp.IdCatSubscription = pdt.CatSubscriptionId and pdt.RowStatus = 1
			 WHERE pdt.ActivationCode = @Code
			 and cpa.RowStatus = 1

	    END
	ELSE IF (@ActivationCode > 0 and @RowStatus = 1)
		BEGIN
			SELECT 
			0 AS CatProductName,
			'El producto ya ha sido activado con anterioridad' AS Message,
			'' AS DateExpiration
		END
	ELSE
	BEGIN
		SET @ActivationCode = ''
		SET @RowStatus = 0
		SELECT TOP 1 @ActivationCode = ActivationCode, @RowStatus = RowStatus 
								FROM Membership WITH(NOLOCK)
								WHERE ActivationCode = @Code
PRINT @ActivationCode
PRINT @RowStatus
print LEN(@ActivationCode)
		--Si es una membresía y no se ha usado
	  IF(LEN(@ActivationCode) > 0 and @RowStatus = 0)	
	   BEGIN

		    UPDATE Membership
		   	SET RowStatus = 1
			,AccountId = @IdAccount
			,CustomerId = @IdCustomer
			,TokenUpdated = @Token
			,DateUpdated = GETDATE()	
			,ActivationDAte = GETDATE()
		   	WHERE ActivationCode = @Code
		   
		     SELECT cp.MembershipName AS CatProductName,
		   IIF(cp.MembershipName = 'Gift Card',('Felicidades..! has activado la '+' '+cp.MembershipName), 
		   (IIF(cp.MembershipName = 'Club Forza',('Felicidades..! has activado la membresía'+' '+cp.MembershipName),('Felicidades..! has activado el'+' '+cp.MembershipName)))) AS Message,
		   REPLACE(CONVERT(VARCHAR(10),pt.ExpirationDate,105),'-','/') AS DateExpiration
		   from CatMembership cp WITH(NOLOCK)
		     INNER JOIN Membership pt WITH(NOLOCK)
		     ON cp.IdCatMembership = pt.CatMembershipId
			 and pt.RowStatus = 1
		     WHERE pt.ActivationCode = @Code
		   
		   SELECT DISTINCT MembershipAttributeDescription AS CatProductAttributeDescription FROM CatMembershipAttribute cpa WITH(NOLOCK)
		   	INNER JOIN CatMembership ctp WITH(NOLOCK)
		   	ON cpa.CatMembershipId = ctp.IdCatMembership
		   	INNER JOIN Membership pdt WITH(NOLOCK)
		   	ON ctp.IdCatMembership = pdt.CatMembershipId
			and pdt.RowStatus = 1
		   	 WHERE pdt.ActivationCode = @Code
			 and cpa.RowStatus = 1

	    END
		ELSE IF (LEN(@ActivationCode) > 0 and @RowStatus = 1)
		BEGIN
			SELECT 
			0 AS CatProductName,
			'El producto ya ha sido activado con anterioridad' AS Message,
			'' AS DateExpiration
		END
		ELSE
		BEGIN
				SELECT 
			0 AS CatProductName,
			'El código del producto ingresado no existe' AS Message,
			'' AS DateExpiration
		END

	END

E