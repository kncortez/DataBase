-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <05-05-2023>
-- Description:	<Get Notification Queue Detail>
-- =============================================
CREATE PROCEDURE [spNS_GetNotificationsQueueDetail]
	@NotificationQueueId AS INT
AS
BEGIN
	
	SET NOCOUNT ON;

    SELECT		ISNULL(CONCAT([NQD].[GuideSerie], [NQD].[GuideNumber]), '') [Guide],
				ISNULL([NQD].[MembershipId], '') [MembershipId],
				ISNULL([CM].[MembershipName], '') [MembershipName],
				ISNULL([NQD].[SubscriptionId], '') [SubscriptionId],
				ISNULL([CS].[SubscriptionName], '') [SubscriptionName]
	FROM		[dbo].[NotificationQueueDetail] NQD
	LEFT JOIN	[dbo].[CatMembership] CM
		ON		[NQD].[MembershipId] = [CM].[IdCatMembership]
	LEFT JOIN	[dbo].[CatSubscription] CS
		ON		[NQD].[MembershipId] = [CS].[IdCatSubscription]
	WHERE	[NQD].[NotificationQueueId] = @NotificationQueueId
		AND [NQD].[RowStatus] = 1 ;
END