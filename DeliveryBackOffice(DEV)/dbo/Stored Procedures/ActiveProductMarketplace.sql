-- =============================================
-- Author:		<Eduardo L�pez>
-- Create date: <Create Date,07/12/2023>
-- Description:	<Activaci�n de productos de marketplace>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <Update Date,14/02/2024>
-- Description:	<Recalcular fecha de vigencia al Activar productos de marketplace>
-- =============================================
CREATE PROCEDURE [dbo].[ActiveProductMarketplace]
@Email NVARCHAR (100),
@Code NVARCHAR(25),
@Token NVARCHAR(50)= ''
AS

BEGIN
	DECLARE @ActivationCode NVARCHAR(50) = '';
	DECLARE @RowStatus bit=0;
	DECLARE @IdAccount bigint = null
	DECLARE @IdCustomer int = null
	DECLARE @IdCountryEmail NVARCHAR(3)= 'GT';
	DECLARE @IdCountry NVARCHAR(3)= 'GT';

	SELECT TOP 1 @ActivationCode = S.ActivationCode, @RowStatus = S.RowStatus, @IdCountry = ISNULL(CS.IdCountry,'GT') 
	FROM Subscription S WITH(NOLOCK)
	INNER JOIN CatSubscription CS ON S.CatSubscriptionId = CS.IdCatSubscription
	WHERE ActivationCode = @Code

	select @IdAccount=A2.RuaIdAccount,@IdCustomer=A3.IdCustomer, @IdCountryEmail = ISNULL(A4.CountryID,'GT') from RegisterUser A1			
			INNER JOIN DeliveryBackOffice.dbo.RolByUserByAccount A2
			ON A1.UsrIdUser = A2.RuaIdUser 
			INNER JOIN DeliveryBackOffice.dbo.Account A3
			ON A3.AccIdAccount = A2.RuaIdAccount 
			LEFT JOIN DeliveryBackOffice.dbo.Customer A4
			ON A3.IdCustomer = A4.IdCustomer
			where UsrEmail = @Email and UsrRowStatus = 1
			AND A2.RuaRowStatus = 1 AND A3.AccRowStatus = 1

	IF (@IdCountry = @IdCountryEmail)
	BEGIN 
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
			 UPDATE S
				SET S.RowStatus = 1
				,S.AccountId = @IdAccount
				,S.CustomerId = @IdCustomer
				,S.TokenUpdated = @Token
				,S.DateUpdated = GETDATE()	
				,S.ActivationDAte = GETDATE()
				,S.ExpirationDate = DATEADD(MONTH, cp.SubscriptionValidity, GETDATE())
			FROM [Subscription] S
				INNER JOIN 
				[CatSubscription] cp
				ON S.CatSubscriptionId = cp.IdCatSubscription
				WHERE ActivationCode = @Code
			
			  SELECT cp.SubscriptionName AS CatProductName,
			IIF(cp.SubscriptionName = 'Gift Card',('Felicidades..! has activado la '+' '+cp.SubscriptionName), 
			(IIF(cp.SubscriptionName = 'Club Forza',('Felicidades..! has activado la membresía'+' '+cp.SubscriptionName),('Felicidades..! has activado el'+' '+cp.SubscriptionName)))) AS Message,
			REPLACE(CONVERT(VARCHAR(10),pt.ExpirationDate,105),'-','/') AS DateExpiration
			from CatSubscription cp WITH(NOLOCK)
			  INNER JOIN Subscription pt WITH(NOLOCK)
			  ON cp.IdCatSubscription = pt.CatSubscriptionId 
			  WHERE pt.ActivationCode = @Code and pt.RowStatus = 1		 

			SELECT  SubscriptionAttributeDescription AS CatProductAttributeDescription FROM CatSubscriptionAtribute cpa WITH(NOLOCK)
				INNER JOIN CatSubscription ctp WITH(NOLOCK)
				ON cpa.CatSubscriptionId = ctp.IdCatSubscription
				INNER JOIN Subscription pdt WITH(NOLOCK)
				ON ctp.IdCatSubscription = pdt.CatSubscriptionId 
				 WHERE pdt.ActivationCode = @Code
				 and cpa.RowStatus = 1 and pdt.RowStatus = 1

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

				UPDATE M
		   		SET M.RowStatus = 1
				,M.AccountId = @IdAccount
				,M.CustomerId = @IdCustomer
				,M.TokenUpdated = @Token
				,M.DateUpdated = GETDATE()	
				,M.ActivationDAte = GETDATE()
				,ExpirationDate = DATEADD(MONTH, CM.MembershipValidity, GETDATE())
				FROM Membership M
				INNER JOIN
				CatMembership CM
				ON M.CatMembershipId = CM.IdCatMembership
		   		WHERE M.ActivationCode = @Code
		   
				 SELECT cp.MembershipName AS CatProductName,
			   IIF(cp.MembershipName = 'Gift Card',('Felicidades..! has activado la '+' '+cp.MembershipName), 
			   (IIF(cp.MembershipName = 'Club Forza',('Felicidades..! has activado la membresía'+' '+cp.MembershipName),('Felicidades..! has activado el'+' '+cp.MembershipName)))) AS Message,
			   REPLACE(CONVERT(VARCHAR(10),pt.ExpirationDate,105),'-','/') AS DateExpiration
			   from CatMembership cp WITH(NOLOCK)
				 INNER JOIN Membership pt WITH(NOLOCK)
				 ON cp.IdCatMembership = pt.CatMembershipId
				 WHERE pt.ActivationCode = @Code and pt.RowStatus = 1
		   
			   SELECT DISTINCT MembershipAttributeDescription AS CatProductAttributeDescription FROM CatMembershipAttribute cpa WITH(NOLOCK)
		   		INNER JOIN CatMembership ctp WITH(NOLOCK)
		   		ON cpa.CatMembershipId = ctp.IdCatMembership
		   		INNER JOIN Membership pdt WITH(NOLOCK)
		   		ON ctp.IdCatMembership = pdt.CatMembershipId
		   		 WHERE pdt.ActivationCode = @Code
				 and cpa.RowStatus = 1 and pdt.RowStatus = 1

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
	END;
	ELSE
	BEGIN
		SELECT 
		0 AS CatProductName,
		'El código no es compatible con la cuenta.'  AS Message,
		'' AS DateExpiration
	END;

END