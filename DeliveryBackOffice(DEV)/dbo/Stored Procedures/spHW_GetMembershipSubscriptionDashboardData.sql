-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <26-12-2022>
-- Description:	<Get Membership and subscription data for Club Forza dashboard>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetMembershipSubscriptionDashboardData]
	@AccountId AS INT,
	@DateStart AS DATETIME,
	@DateEnd AS DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @MEMBERSHIP_ID AS INT;					-- Membership
	DECLARE @MEMBERSHIP_STATUS_ACTIVE_ID AS INT;	-- CatSalesPackageStatus
	DECLARE @MEMBERSHIP_STATUS_INACTIVE_ID AS INT;	-- CatSalesPackageStatus

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
				[M].[CatMembershipId],
				[CM].[MembershipName],
				[M].[CatMembershipStatusId],
				[CSPS].[SalesPackageStatusName],
				[M].[MembershipCost],
				[M].[IsAutoRenewable],
				[M].[MembershipMaxServiceFixedValue],
				[M].[ActualServiceCount],
				[M].[ExpirationDate] [MembershipExpirationDate],
				(([M].[ActualServiceCount] * 100) / [M].[MembershipMaxServiceFixedValue]) [MembershipUsagePercentage],
				(SELECT COUNT([MSL].[IdMembershipSubscriptionLog])
				FROM	[dbo].[MembershipSubscriptionLog] MSL
				WHERE	[MSL].[CustomerId] = [M].[CustomerId]
					AND [MSL].[RowStatus] = 1
					AND [MSL].[SubscriptionId] IS NULL
					AND [MSL].[DateCreated] BETWEEN @DateStart AND @DateEnd ) [MembershipDeliveriesCount]
	FROM		[dbo].[Membership] M
	INNER JOIN	[dbo].[CatMembership] CM
		ON		[M].[CatMembershipId] = [CM].[IdCatMembership]
	INNER JOIN	[dbo].[CatSalesPackageStatus] CSPS
		ON		[M].[CatMembershipStatusId] = [CSPS].[IdCatSalesPackageStatus]
	WHERE		[M].[AccountId] = @AccountId
		AND		[M].[RowStatus] = 1
		AND		[M].[CatMembershipStatusId] IN (@MEMBERSHIP_STATUS_ACTIVE_ID, @MEMBERSHIP_STATUS_INACTIVE_ID);

	-- Subscription Data

	SELECT		[S].[IdSubscription],
				[S].[CatSubscriptionId],
				[CS].[SubscriptionName],
				[S].[CatSubscriptionStatusId],
				[S].[SubscriptionCost],
				[S].[SubscriptionMaxServiceFixedValue],
				[S].[ActualServiceCount],
				[S].[ExpirationDate] [SubscriptionExpirationDate]
	FROM		[dbo].[Subscription] S
	INNER JOIN	[dbo].[CatSubscription] CS
		ON		[S].[CatSubscriptionId] = [CS].[IdCatSubscription]
	WHERE		[S].[MembershipId] = @MEMBERSHIP_ID
		AND		[S].[ExpirationDate] >= GETDATE()
		AND		[S].[RowStatus] = 1;
END