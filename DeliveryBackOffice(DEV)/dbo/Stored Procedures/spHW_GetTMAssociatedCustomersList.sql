-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <24-01-2023>
-- Description:	<Get list of associated customers for Telemarketing dashboard>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Modified:	<14-08-2024>
-- Description:	<Concat nirphone in Phone number>
-- =============================================
-- Author:		<Brandon Pedroza>
-- Modified:	<16-08-2024>
-- Description:	<Added idcontry parameter>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetTMAssociatedCustomersList]
	@RegisterUserId INT,
	@IdCountry AS NVARCHAR(2) = 'GT'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @CatTMSalesPersonId INT = 0;
	DECLARE @VoidStatus INT = (SELECT TOP 1 SO.StatusOrderId FROM [DeliveryBackOffice].[dbo].[StatusOrder] SO WITH(NOLOCK) WHERE SO.OrderDescription = 'Anulado' COLLATE Latin1_General_CI_AI);

	SET @CatTMSalesPersonId = (	SELECT  [CTSP].[IdCatTMSalesPerson]
								FROM	[dbo].[CatTMSalesPerson] CTSP 
								WHERE	[CTSP].[RegisterUserId] = @RegisterUserId);

    SELECT		[P].[PerFirstName] [FirstName],
				[P].[PerLastName] [LastName],
				[RU].[UsrEmail] [Email],
				ISNULL([RU].[PrefixCallingCode],'+502') [NirPhone],
				[RU].[Phone] [Phone],				
				[RU].[UsrDateCreated] [DateCreated],
				[C].[CutOffDate] [CutOffDate],
				[C].[CustomerGoalQuantity] [CustomerGoalQuantity],
				ISNULL([GuideAmountBeforeCut].[TotalGuides], 0) [ActualServiceCount],
				ISNULL([M].[IdMembership], 0) [MembershipId],
				ISNULL([CM].[MembershipName], '') [MembershipName], 
				ISNULL([CM].[MembershipCost], 0) [MembershipCost]
	FROM		[dbo].[Customer] C  WITH(NOLOCK) 
	INNER JOIN	[dbo].[Account] A  WITH(NOLOCK) 
		ON		[C].[IdCustomer] = [A].[IdCustomer]
	INNER JOIN	[dbo].[RolByUserByAccount] RUA  WITH(NOLOCK) 
		ON		[A].[AccIdAccount] = [RUA].[RuaIdAccount]
	INNER JOIN	[dbo].[RegisterUser] RU  WITH(NOLOCK) 
		ON		[RUA].[RuaIdUser] = [RU].[UsrIdUser]
	INNER JOIN	[dbo].[Person] P  WITH(NOLOCK) 
		ON		[RU].[UsrIdPerson] = [P].[PerIdPerson]
	LEFT JOIN	[dbo].[Membership] M  WITH(NOLOCK) 
		ON		[C].[IdCustomer] = [M].[CustomerId]
		AND		[M].[ExpirationDate] >= SYSDATETIME()
	LEFT JOIN	[dbo].[CatMembership] CM  WITH(NOLOCK) 
		ON		[M].[CatMembershipId] = [CM].[IdCatMembership]
	OUTER APPLY (
		SELECT
			TOP 1
				COUNT(DISTINCT DO.Guide_Number) 'TotalGuides'
		FROM
			[DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)
		WHERE
			DO.IdCustomer = [C].[IdCustomer]
			AND
			DO.StatusOrderId NOT IN (@VoidStatus)
			AND
			DO.DateCreated <= [C].[CutOffDate]
		GROUP BY
			DO.IdCustomer
	) GuideAmountBeforeCut
	WHERE	[C].[CatTMSalesPersonId] = @CatTMSalesPersonId
	AND ISNULL([P].[PerCountryOrigin], 'GT') = @IdCountry
    AND [C].[CutOffDate] >= SYSDATETIME()
	UNION
	SELECT		[P].[PerFirstName] [FirstName],
				[P].[PerLastName] [LastName],
				[RU].[UsrEmail] [Email],
				ISNULL([RU].[PrefixCallingCode], '+502') [NirPhone],
				[RU].[Phone] [Phone],
				[RU].[UsrDateCreated] [DateCreated],
				[RU].[UsrDateCreated] [CutOffDate],
				0 [CustomerGoalQuantity],
				0 [ActualServiceCount],
				ISNULL([M].[IdMembership], 0) [MembershipId],
				ISNULL([CM].[MembershipName], '') [MembershipName], 
				ISNULL([CM].[MembershipCost], 0) [MembershipCost]
	FROM		[dbo].[Customer] C  WITH(NOLOCK) 
	INNER JOIN	[dbo].[Account] A  WITH(NOLOCK) 
		ON		[C].[IdCustomer] = [A].[IdCustomer]
	INNER JOIN	[dbo].[RolByUserByAccount] RUA  WITH(NOLOCK) 
		ON		[A].[AccIdAccount] = [RUA].[RuaIdAccount]
	INNER JOIN	[dbo].[RegisterUser] RU  WITH(NOLOCK) 
		ON		[RUA].[RuaIdUser] = [RU].[UsrIdUser]
	INNER JOIN	[dbo].[Person] P  WITH(NOLOCK) 
		ON		[RU].[UsrIdPerson] = [P].[PerIdPerson]
	LEFT JOIN	[dbo].[Membership] M  WITH(NOLOCK) 
		ON		[C].[IdCustomer] = [M].[CustomerId]
		AND		[M].[ExpirationDate] >= SYSDATETIME()
	LEFT JOIN	[dbo].[CatMembership] CM  WITH(NOLOCK) 
		ON		[M].[CatMembershipId] = [CM].[IdCatMembership]
	WHERE	[M].[CatTMSalesPersonId] = @CatTMSalesPersonId
	AND ISNULL([P].[PerCountryOrigin], 'GT') = @IdCountry
    AND [C].[CutOffDate] >= SYSDATETIME();

END