-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <26-12-2022>
-- Description:	<Get membership transaction history>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetMembershipTransactionHistory]
	@AccountId AS INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MEMBERSHIP_ID AS INT;					-- Membership
	DECLARE @CUSTOMER_ID AS INT;					-- Customer
	DECLARE @MEMBERSHIP_STATUS_ACTIVE_ID AS INT;	-- CatSalesPackageStatus
	DECLARE @MEMBERSHIP_STATUS_INACTIVE_ID AS INT;	-- CatSalesPackageStatus

	SET @CUSTOMER_ID = (SELECT	[A].[IdCustomer]
						FROM	[dbo].[Account] A
						WHERE	[A].[AccIdAccount] = @AccountId);
    
	SET @MEMBERSHIP_STATUS_ACTIVE_ID = (SELECT	[CSPS].[IdCatSalesPackageStatus]
										FROM	[dbo].[CatSalesPackageStatus] CSPS
										WHERE	[CSPS].[SalesPackageStatusName] = 'Activa');

	SET @MEMBERSHIP_STATUS_INACTIVE_ID = (SELECT	[CSPS].[IdCatSalesPackageStatus]
										FROM	[dbo].[CatSalesPackageStatus] CSPS
										WHERE	[CSPS].[SalesPackageStatusName] = 'Inactiva');

	SET @MEMBERSHIP_ID =	(SELECT TOP 1 [M].[IdMembership]
							FROM	[dbo].[Membership] M
							WHERE	[M].[AccountId] = @AccountId
								AND [M].[RowStatus] = 1
								AND [M].[CatMembershipStatusId] IN (@MEMBERSHIP_STATUS_ACTIVE_ID, @MEMBERSHIP_STATUS_INACTIVE_ID));

	-- Membership data
	SELECT		[M].[IdMembership],
				[M].[CustomerId],
				([M].[MembershipMaxServiceFixedValue] - [M].[ActualServiceCount]) [MembershipRemainingUses],
				(([M].[ActualServiceCount] * 100) / [M].[MembershipMaxServiceFixedValue]) [MembershipUsagePercentage]
	FROM		[dbo].[Membership] M
	INNER JOIN	[dbo].[CatMembership] CM
		ON		[M].[CatMembershipId] = [CM].[IdCatMembership]
	INNER JOIN	[dbo].[CatSalesPackageStatus] CSPS
		ON		[M].[CatMembershipStatusId] = [CSPS].[IdCatSalesPackageStatus]
	WHERE		[M].[AccountId] = @AccountId
		AND		[M].[RowStatus] = 1
		AND		[M].[CatMembershipStatusId] IN (@MEMBERSHIP_STATUS_ACTIVE_ID, @MEMBERSHIP_STATUS_INACTIVE_ID);

	-- Membership history
	SELECT	[MSL].[IdMembershipSubscriptionLog],
			CONCAT([MSL].[LogGuideSerie], [MSL].[LogGuideNumber]) [Guide],
			[MSL].[DateCreated] [Date],
			[MSL].[LogGuideOriginalValue] [OriginalAmount],
			[MSL].[LogGuideNewValue] [NewAmount],
			([MSL].[LogGuideOriginalValue] - [MSL].[LogGuideNewValue]) [DiscountApplied]
	FROM	[dbo].[MembershipSubscriptionLog] MSL
	WHERE	[MSL].[CustomerId] = @CUSTOMER_ID
		AND [MSL].[MembershipId] = @MEMBERSHIP_ID
		AND [MSL].[SubscriptionId] IS NULL
		AND [MSL].[RowStatus] = 1
		AND [MSL].[SalesPackageStatusId] = @MEMBERSHIP_STATUS_ACTIVE_ID;

END