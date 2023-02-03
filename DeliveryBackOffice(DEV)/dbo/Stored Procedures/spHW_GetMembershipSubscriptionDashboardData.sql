-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <26-12-2022>
-- Description:	<Get Membership and subscription data for Club Forza dashboard>
-- =============================================
-- =============================================
-- Author:		<Andrés Ruíz>
-- Create date: <31-01-2023>
-- Description:	<Added membership and subscription fields for more information in dashboard>
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

	SET @DateStart = DATEADD(SECOND,-1,CAST(DATEADD(DAY,1,CAST(@DateStart AS DATE)) AS DATETIME));
	SET @DateEnd = DATEADD(SECOND,-1,CAST(DATEADD(DAY,1,CAST(@DateEnd AS DATE)) AS DATETIME));

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
				IIF(([M].[MembershipMaxServiceFixedValue] - [M].[ActualServiceCount]) <= 0, 0, ([M].[MembershipMaxServiceFixedValue] - [M].[ActualServiceCount])) [MembershipAvailableFixedService],
				[M].[ExpirationDate] [MembershipExpirationDate],
				IIF((([M].[ActualServiceCount] * 100) / [M].[MembershipMaxServiceFixedValue]) > 100, 100, (([M].[ActualServiceCount] * 100) / [M].[MembershipMaxServiceFixedValue])) [MembershipUsagePercentage],
				(SELECT COUNT([MSL].[IdMembershipSubscriptionLog])
				FROM	[dbo].[MembershipSubscriptionLog] MSL
				WHERE	[MSL].[CustomerId] = [M].[CustomerId]
					AND [MSL].[MembershipId] = [M].[IdMembership]
					AND [MSL].[RowStatus] = 1
					AND [MSL].[DateCreated] BETWEEN @DateStart AND @DateEnd ) [MembershipDeliveriesCount],
				CAST(IIF((([M].[ActualServiceCount] * 100) / [M].[MembershipMaxServiceFixedValue]) > 100, 0, 1) AS BIT) [IsMembershipFixedActive],
				ISNULL((SELECT SUM(ISNULL([MSL].[LogGuideOriginalValue], 0) - ISNULL([MSL].[LogGuideNewValue], 0))
				FROM	[dbo].[MembershipSubscriptionLog] MSL
				WHERE	[MSL].[CustomerId] = [M].[CustomerId]
					AND [MSL].[MembershipId] = [M].[IdMembership]
					AND [MSL].[RowStatus] = 1
					/* AND [MSL].[DateCreated] BETWEEN @DateStart AND @DateEnd */ ), 0) [MembershipDeliveriesTotalDiscountGiven]
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
				[S].[IsAutoRenewable],
				[S].[SubscriptionMaxServiceFixedValue],
				[S].[ActualServiceCount],
				IIF(([S].[SubscriptionMaxServiceFixedValue] - [S].[ActualServiceCount]) <= 0, 0, ([S].[SubscriptionMaxServiceFixedValue] - [S].[ActualServiceCount])) [SubscriptionAvailableFixedService],
				IIF((([S].[ActualServiceCount] * 100) / [S].[SubscriptionMaxServiceFixedValue]) > 100, 100, (([S].[ActualServiceCount] * 100) / [S].[SubscriptionMaxServiceFixedValue])) [SubscriptionUsagePercentage],
				[S].[ExpirationDate] [SubscriptionExpirationDate],
				(SELECT COUNT([MSL].[IdMembershipSubscriptionLog])
				FROM	[dbo].[MembershipSubscriptionLog] MSL
				WHERE	[MSL].[CustomerId] = [S].[CustomerId]
					AND [MSL].[SubscriptionId] = [S].[IdSubscription]
					AND [MSL].[RowStatus] = 1
					AND [MSL].[DateCreated] BETWEEN @DateStart AND @DateEnd ) [SubscriptionDeliveriesCount],
				CAST(IIF((([S].[ActualServiceCount] * 100) / [S].[SubscriptionMaxServiceFixedValue]) > 100, 0, 1) AS BIT) [IsSubscriptionFixedActive],
				ISNULL((SELECT SUM(ISNULL([MSL].[LogGuideOriginalValue], 0) - ISNULL([MSL].[LogGuideNewValue], 0))
				FROM	[dbo].[MembershipSubscriptionLog] MSL
				WHERE	[MSL].[CustomerId] = [S].[CustomerId]
					AND [MSL].[MembershipId] = [S].[IdSubscription]
					AND [MSL].[RowStatus] = 1
					/* AND [MSL].[DateCreated] BETWEEN @DateStart AND @DateEnd */ ), 0) [SubscriptionDeliveriesTotalDiscountGiven]
	FROM		[dbo].[Subscription] S
	INNER JOIN	[dbo].[CatSubscription] CS
		ON		[S].[CatSubscriptionId] = [CS].[IdCatSubscription]
	WHERE		[S].[MembershipId] = @MEMBERSHIP_ID
		AND		[S].[ExpirationDate] >= GETDATE()
		AND		[S].[RowStatus] = 1
	ORDER BY
		[S].[ExpirationDate] ASC;
END