/* =================================================
   SP:        [dbo].[spHW_GetTMAssociatedCustomersList]
   Propósito: Get list of associated customers for Telemarketing dashboard
   Autor:     Jerson Ochoa
   Historia:  
   Fecha:     2023-01-24
============================================
=== CHANGELOG ================================
2024-08-14	|	Épica: 	|	Autor: Brandon Pedroza    |   Concat nirphone in Phone number
=========================================== 
2024-08-16	|	Épica: 	|	Autor: Brandon Pedroza    |   Added idcontry parameter
=========================================== 
2026-03-30	|	Épica: FDAPI-5985	|	Autor: Erick Guerra    |   Optimización de consultas
=========================================== */

CREATE PROCEDURE [dbo].[spHW_GetTMAssociatedCustomersList]
	@RegisterUserId INT,
	@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @CatTMSalesPersonId INT;
	DECLARE @VoidStatus         INT;
	DECLARE @Today DATETIME = SYSDATETIME();
	DECLARE @UserId INT = @RegisterUserId;
	DECLARE @Country AS NVARCHAR(2) = @IdCountry;

	SET @CatTMSalesPersonId = (
		SELECT [CTSP].[IdCatTMSalesPerson]
			FROM	[dbo].[CatTMSalesPerson] CTSP WITH(NOLOCK)
			WHERE	[CTSP].[RegisterUserId] = @UserId
	);

	IF @CatTMSalesPersonId IS NULL RETURN;

	SET @VoidStatus = (
		SELECT TOP 1 SO.StatusOrderId 
			FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) 
			WHERE SO.OrderDescription = 'Anulado'
	);

	-- CTE utilizado para evitar ejecución repetitiva por fila hacia DeliveryOrder
	;WITH GuideAmountBeforeCut AS (
        SELECT
			C.IdCustomer,
			COUNT(DISTINCT DO.Guide_Number) AS TotalGuides
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
			INNER JOIN [dbo].[Customer] C WITH(NOLOCK)
				ON DO.IdCustomer = C.IdCustomer
		WHERE C.CatTMSalesPersonId = @CatTMSalesPersonId
			AND C.CutOffDate >= @Today
			AND DO.StatusOrderId  <> @VoidStatus
			AND DO.DateCreated <= C.CutOffDate
		GROUP BY C.IdCustomer
    )
	SELECT
		[P].[PerFirstName] [FirstName],
		[P].[PerLastName] [LastName],
		[RU].[UsrEmail] [Email],
		ISNULL([RU].[PrefixCallingCode],'+502') [NirPhone],
		[RU].[Phone] [Phone],				
		[RU].[UsrDateCreated] [DateCreated],
		[C].[CutOffDate] [CutOffDate],
		[C].[CustomerGoalQuantity] [CustomerGoalQuantity],
		ISNULL([GA].[TotalGuides], 0) [ActualServiceCount],
		ISNULL([M].[IdMembership], 0) [MembershipId],
		ISNULL([CM].[MembershipName], '') [MembershipName], 
		ISNULL([CM].[MembershipCost], 0) [MembershipCost]
    FROM [dbo].[Customer] C WITH(NOLOCK)
        INNER JOIN [dbo].[Account] A WITH(NOLOCK)
            ON [C].[IdCustomer] = [A].[IdCustomer]
        INNER JOIN [dbo].[RolByUserByAccount] RUA WITH(NOLOCK)
            ON [A].[AccIdAccount] = [RUA].[RuaIdAccount]
        INNER JOIN [dbo].[RegisterUser] RU WITH(NOLOCK)
            ON [RUA].[RuaIdUser] = [RU].[UsrIdUser]
        INNER JOIN [dbo].[Person] P WITH(NOLOCK)
            ON [RU].[UsrIdPerson] = [P].[PerIdPerson]
        LEFT JOIN [dbo].[Membership] M WITH(NOLOCK)
            ON  [C].[IdCustomer] = [M].[CustomerId]
            AND [M].[ExpirationDate] >= @Today
        LEFT JOIN [dbo].[CatMembership] CM WITH(NOLOCK)
            ON [M].[CatMembershipId] = [CM].[IdCatMembership]
		LEFT JOIN GuideAmountBeforeCut GA
			ON GA.IdCustomer = C.IdCustomer
    WHERE
        [C].[CatTMSalesPersonId] = @CatTMSalesPersonId
        AND [C].[CutOffDate] >= @Today
		AND [P].[PerCountryOrigin] = @Country
	UNION
	SELECT
		[P].[PerFirstName] [FirstName],
		[P].[PerLastName] [LastName],
		[RU].[UsrEmail] [Email],
		ISNULL([RU].[PrefixCallingCode],'+502') [NirPhone],
		[RU].[Phone] [Phone],				
		[RU].[UsrDateCreated] [DateCreated],
		[RU].[UsrDateCreated] [CutOffDate],
		0 [CustomerGoalQuantity],
		0 [ActualServiceCount],
		ISNULL([IdMembership], 0) [MembershipId],
		ISNULL([CM].[MembershipName], '') [MembershipName], 
		ISNULL([CM].[MembershipCost], 0) [MembershipCost]
    FROM [dbo].[Customer] C  WITH(NOLOCK) 
		INNER JOIN [dbo].[Account] A  WITH(NOLOCK) 
			ON [C].[IdCustomer] = [A].[IdCustomer]
		INNER JOIN [dbo].[RolByUserByAccount] RUA  WITH(NOLOCK) 
			ON [A].[AccIdAccount] = [RUA].[RuaIdAccount]
		INNER JOIN [dbo].[RegisterUser] RU  WITH(NOLOCK) 
			ON [RUA].[RuaIdUser] = [RU].[UsrIdUser]
		INNER JOIN [dbo].[Person] P  WITH(NOLOCK) 
			ON [RU].[UsrIdPerson] = [P].[PerIdPerson]
		LEFT JOIN [dbo].[Membership] M  WITH(NOLOCK) 
			ON [C].[IdCustomer] = [M].[CustomerId]
			AND [M].[ExpirationDate] >= @Today
		LEFT JOIN [dbo].[CatMembership] CM  WITH(NOLOCK) 
			ON [M].[CatMembershipId] = [CM].[IdCatMembership]
	WHERE [M].[CatTMSalesPersonId] = @CatTMSalesPersonId
		AND [C].[CutOffDate] >= @Today
		AND [P].[PerCountryOrigin] = @Country
	OPTION (OPTIMIZE FOR UNKNOWN)
END