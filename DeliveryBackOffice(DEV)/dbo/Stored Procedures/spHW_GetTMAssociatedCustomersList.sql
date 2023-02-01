-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <24-01-2023>
-- Description:	<Get list of associated customers for Telemarketing dashboard>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetTMAssociatedCustomersList]
	@RegisterUserId INT
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
				[RU].[Phone] [Phone],
				[RU].[UsrDateCreated] [DateCreated],
				[C].[CutOffDate] [CutOffDate],
				[C].[CustomerGoalQuantity] [CustomerGoalQuantity],
				ISNULL([GuideAmountBeforeCut].[TotalGuides], 0) [ActualServiceCount],
				ISNULL([M].[IdMembership], 0) [MembershipId],
				ISNULL([CM].[MembershipName], '') [MembershipName], 
				ISNULL([CM].[MembershipCost], 0) [MembershipCost]
	FROM		[dbo].[Customer] C
	INNER JOIN	[dbo].[Account] A
		ON		[C].[IdCustomer] = [A].[IdCustomer]
		AND		[C].[CutOffDate] >= SYSDATETIME()
	INNER JOIN	[dbo].[RolByUserByAccount] RUA
		ON		[A].[AccIdAccount] = [RUA].[RuaIdAccount]
	INNER JOIN	[dbo].[RegisterUser] RU
		ON		[RUA].[RuaIdUser] = [RU].[UsrIdUser]
	INNER JOIN	[dbo].[Person] P
		ON		[RU].[UsrIdPerson] = [P].[PerIdPerson]
	LEFT JOIN	[dbo].[Membership] M
		ON		[C].[IdCustomer] = [M].[CustomerId]
		AND		[M].[ExpirationDate] >= SYSDATETIME()
	LEFT JOIN	[dbo].[CatMembership] CM
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
	WHERE	[C].[CatTMSalesPersonId] = @CatTMSalesPersonId;

END