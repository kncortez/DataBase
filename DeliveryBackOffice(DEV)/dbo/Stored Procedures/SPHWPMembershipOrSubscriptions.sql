-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <Create Date,12/07/2022>
-- Description:	<Description,muestra las membresias y credenciales disponibles con su respectivo detalle>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <Create Date,18/07/2023>
-- Description:	<Description,Descripción corta y larga de los beneficios>
-- =============================================
/*
	Actualización: Ordenar atributos de acuerdo a campo AttributePosition - 30-12-2022
	Actualización: Agregar campo de ícono a estructura de membresías y suscripciones - 11-01-2023
	Actualización: Validar rowStatus para atributos - 11-01-2023
	Actualización: Agregar objeto de descripciones para membresías - 20-01-2023
	Autor: Jerson Ochoa
*/
CREATE PROCEDURE [dbo].[SPHWPMembershipOrSubscriptions]
    -- Add the parameters for the stored procedure here

    @Type AS NVARCHAR(50),
    --@Token AS NVARCHAR(50),
    @AccountId AS BIGINT = NULL,
	@IdCountry NVARCHAR(2)
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here 

    DECLARE @CustomerId INT;
    IF (@AccountId IS NOT NULL)
    BEGIN
        SET @CustomerId =
        (
            SELECT TOP 1
                   Acc.IdCustomer
            FROM [DeliveryBackOffice].[dbo].[Account] Acc WITH (NOLOCK)
            WHERE Acc.AccIdAccount = @AccountId
        );
    END;
	DECLARE @FirstMembership TABLE (CatMembershipId INT, IdMembership INT)

    IF (@Type = 'MEMBERSHIP')
    BEGIN
        

		INSERT INTO @FirstMembership (CatMembershipId, IdMembership)
		SELECT
			CatMembershipId,
			IdMembership
		FROM (
			SELECT *,
				   ROW_NUMBER() OVER (PARTITION BY CatMembershipId ORDER BY IdMembership) AS rn
			FROM [dbo].[Membership] M WITH (NOLOCK)
			WHERE M.RowStatus = 1
			  AND (
				   (M.AccountId = @AccountId AND M.CustomerId = @CustomerId)
				   OR M.CustomerId = @CustomerId
			  )
		) AS Ranked
		WHERE rn = 1;

		IF EXISTS (
		SELECT TOP 1 1
		FROM [dbo].[CatMembershipAttribute] CMA WITH (NOLOCK)
		INNER JOIN [dbo].[CatMembership] CM WITH (NOLOCK)
			ON CMA.CatMembershipId = CM.IdCatMembership
		LEFT JOIN @FirstMembership FM
			ON FM.CatMembershipId = CM.IdCatMembership
		WHERE CMA.RowStatus = 1
		  AND CM.RowStatus = 1
		  ) 
		BEGIN

			SELECT 201 AS IdResult,
				   'Registros encontrados con exito' AS [Message]

			SELECT DISTINCT CM.IdCatMembership AS Id,
				  CM.MembershipName AS Name,
				  CM.Icon AS Icon,
				   CM.MembershipCost AS Costo,
				   CASE
					WHEN ISNULL(CM.MembershipCost, 0) = 0 THEN
						0
					ELSE
						1
				END AS ActiveClienteHasSalesPackage
			FROM [dbo].[CatMembership] CM WITH (NOLOCK)
            INNER JOIN [dbo].[CatMembershipAttribute] CMA WITH (NOLOCK)
                ON CM.IdCatMembership = CMA.CatMembershipId
			OUTER APPLY
			(
				SELECT TOP 1
						MMBRSHP.IdMembership
				FROM [dbo].[Membership] MMBRSHP WITH (NOLOCK)
				WHERE MMBRSHP.CatMembershipId = CM.IdCatMembership
						AND
						(
							(
								MMBRSHP.AccountId = @AccountId
								AND MMBRSHP.CustomerId = @CustomerId
							)
							-- En caso no se encuentre el AccoundId registrado en la membresía
							OR MMBRSHP.CustomerId = @CustomerId
						)
						AND MMBRSHP.RowStatus = 1
			) MMBRSHP
			WHERE CM.RowStatus = 1

			SELECT DISTINCT 
				   CM.IdCatMembership,
				   CMA.IdCatMembershipAttribute AS Id,
				   CMA.MembershipAttributeDescription AS Descripcion, 
				   ISNULL(CMA.MembershipAttributeDescriptionLong, CMA.MembershipAttributeDescription) AS DescripcionLong,
				   CMA.MembershipAttributeValue AS Valor,
				   CMA.MembershipAttributePosition AS Posicion
			FROM [dbo].[CatMembershipAttribute] CMA WITH (NOLOCK)
			INNER JOIN [dbo].[CatMembership] CM WITH (NOLOCK)
				ON CMA.CatMembershipId = CM.IdCatMembership
			LEFT JOIN @FirstMembership FM
				ON FM.CatMembershipId = CM.IdCatMembership
			WHERE CMA.RowStatus = 1
			  AND CM.RowStatus = 1
			ORDER BY CMA.MembershipAttributePosition;


			SELECT CMD.CatMembershipId,
				   CMD.IdCatMembershipDescription AS Id,
				   CMD.Title AS Titulo,
				   CMD.Description AS Descripcion,
				   CMD.Type AS Tipo,
				   CMD.Position AS Posicion
			FROM [dbo].[CatMembershipDescription] CMD WITH (NOLOCK)
			INNER JOIN CatMembership CM WITH (NOLOCK)
				ON CMD.CatMembershipId = CM.IdCatMembership
			LEFT JOIN @FirstMembership FM
				ON FM.CatMembershipId = CMD.CatMembershipId
			WHERE  [CMD].[RowStatus] = 1
			AND CM.RowStatus = 1
			ORDER BY [CMD].[Position],
					[CMD].[Type]

		END
		ELSE
		BEGIN
			SELECT 0 AS IdResult,
				  'No se encontraron registros' AS [Message]
		END

    END;

    IF (@Type = 'Subscription')
    BEGIN
        	
		  SELECT 200 AS IdResult,
				 'Registros encontrados con exito' AS [Message]

		  SELECT DISTINCT
					CS.IdCatSubscription AS Id,
					CS.SubscriptionName AS Name,
					CS.Icon AS Icon,
					COALESCE(CS.SubscriptionWeight,0) AS [Order],
					CS.SubscriptionCost AS Costo,
					CS.SubscriptionValidity AS 'Tiempo de validez',
					CASE
								WHEN ISNULL(SBSCRPTN.IdSubscription, 0) = 0 THEN
									0
								ELSE
									1
							END AS ActiveClienteHasSalesPackage
		FROM [dbo].[CatSubscription] CS WITH (NOLOCK)
		INNER JOIN [dbo].[CatSubscriptionAtribute] CSA WITH (NOLOCK)
			ON CS.IdCatSubscription = CSA.CatSubscriptionId
		OUTER APPLY
		(
		SELECT TOP 1
				SBSCRPTN.IdSubscription
		FROM [dbo].[Subscription] SBSCRPTN WITH (NOLOCK)
		WHERE SBSCRPTN.CatSubscriptionId = CS.IdCatSubscription
				AND
				(
					(
						SBSCRPTN.AccountId = @AccountId
						AND SBSCRPTN.CustomerId = @CustomerId
					)
					-- En caso no se encuentre el AccoundId registrado en la membresía
					OR SBSCRPTN.CustomerId = @CustomerId
				)
				AND SBSCRPTN.RowStatus = 1
		) SBSCRPTN
		WHERE CS.RowStatus = 1
			AND
			(
				(ISNULL(@AccountId, 0) > 0) -- usuario individual
				OR (
				-- CS.IncludedMembershipId IS NOT NULL
				--AND 
				ISNULL(@AccountId, 0) = 0
					) -- otros usuarios
			) AND CS.IdCountry = @IdCountry

		--SELECT* FROM [CatSubscription]



		SELECT DISTINCT
			CS.IdCatSubscription,
			CSA.IdCatSubscriptionAttribute AS Id,
			CSA.SubscriptionAttributeDescription AS Descripcion,
			ISNULL(CSA.SubscriptionAttributeDescriptionLong, CSA.SubscriptionAttributeDescription) AS DescripcionLong,
			CSA.SubscriptionAttributeValue AS Valor,
			CSA.SubscriptionAttributePosition AS Posicion,
			CS.IdCatSubscription,
			CS.SubscriptionName,
			CS.Icon,
			COALESCE(CS.SubscriptionWeight, 0) AS SubscriptionWeight,
			CS.SubscriptionCost,
			CS.SubscriptionValidity,
			-- Indica si el cliente tiene suscripción activa
			CASE WHEN ISNULL(SBSCRPTN.IdSubscription, 0) = 0 THEN 0 ELSE 1 END AS ActiveClienteHasSalesPackage
		FROM [dbo].[CatSubscription] CS WITH (NOLOCK)
		INNER JOIN [dbo].[CatSubscriptionAtribute] CSA WITH (NOLOCK)
			ON CS.IdCatSubscription = CSA.CatSubscriptionId
		OUTER APPLY
		(
			SELECT TOP 1 SBSCRPTN.IdSubscription
			FROM [dbo].[Subscription] SBSCRPTN WITH (NOLOCK)
			WHERE SBSCRPTN.CatSubscriptionId = CS.IdCatSubscription
			  AND (
				  (SBSCRPTN.AccountId = @AccountId AND SBSCRPTN.CustomerId = @CustomerId)
				  OR SBSCRPTN.CustomerId = @CustomerId
			  )
			  AND SBSCRPTN.RowStatus = 1
		) SBSCRPTN
		WHERE CS.RowStatus = 1
		  AND CSA.RowStatus = 1
		  AND CS.IdCountry = @IdCountry
		ORDER BY CS.IdCatSubscription, CSA.SubscriptionAttributePosition;



		 SELECT CS.IdCatSubscription, 
				CSD.IdCatSubscriptionDescription AS Id,
				 CSD.Title AS Titulo,
				 CSD.Description AS Descripcion,
				 CSD.Type AS Tipo,
				 CSD.Position AS Posicion
		FROM [dbo].[CatSubscriptionDescription] CSD
		INNER JOIN [dbo].[CatSubscription] CS WITH (NOLOCK)
		ON	[CSD].[CatSubscriptionId] = [CS].[IdCatSubscription]    
		WHERE [CSD].[RowStatus] = 1  AND CS.IdCountry = @IdCountry
		ORDER BY CS.IdCatSubscription,
				[CSD].[Position],
				[CSD].[Type]

    END;

END;