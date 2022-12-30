-- UPDATE MEMBERSHIP AND SUBSCRIPTIONS ATTRIBUTES

-- CatMembershipAttribute

INSERT INTO CatMembershipAttribute
			(CatMembershipId,
			CatAttributeId,
			MembershipAttributeValue,
			MembershipAttributeDescription,
			MembershipAttributePosition,
			RowStatus,
			TokenCreated,
			DateCreated)
VALUES		((SELECT [CM].[IdCatMembership] FROM [dbo].[CatMembership] CM WHERE [CM].[MembershipName] = 'Club Forza'),		-- CatMembershipId
			1,																												-- CatAttributeId
			1,																												-- MembershipAttributeValue
			'hwa-membershipIcon',																							-- MembershipAttributeDescription
			2,																												-- MembershipAttributePosition
			1,																												-- RowStatus
			'SYS-JOCHOA',																									-- TokenCreated
			SYSDATETIME());																									-- DateCreated

INSERT INTO CatMembershipAttribute
			(CatMembershipId,
			CatAttributeId,
			MembershipAttributeValue,
			MembershipAttributeDescription,
			MembershipAttributePosition,
			RowStatus,
			TokenCreated,
			DateCreated)
VALUES		((SELECT [CM].[IdCatMembership] FROM [dbo].[CatMembership] CM WHERE [CM].[MembershipName] = 'Básica'),			-- CatMembershipId
			1,																												-- CatAttributeId
			1,																												-- MembershipAttributeValue
			'hwa-membershipIcon',																							-- MembershipAttributeDescription
			2,																												-- MembershipAttributePosition
			1,																												-- RowStatus
			'SYS-JOCHOA',																									-- TokenCreated
			SYSDATETIME());																									-- DateCreated

INSERT INTO CatMembershipAttribute
			(CatMembershipId,
			CatAttributeId,
			MembershipAttributeValue,
			MembershipAttributeDescription,
			MembershipAttributePosition,
			RowStatus,
			TokenCreated,
			DateCreated)
VALUES		((SELECT [CM].[IdCatMembership] FROM [dbo].[CatMembership] CM WHERE [CM].[MembershipName] = 'Plus'),			-- CatMembershipId
			1,																												-- CatAttributeId
			1,																												-- MembershipAttributeValue
			'hwa-membershipIcon',																							-- MembershipAttributeDescription
			2,																												-- MembershipAttributePosition
			1,																												-- RowStatus
			'SYS-JOCHOA',																									-- TokenCreated
			SYSDATETIME());																									-- DateCreated

-- CatSubscriptionAtribute

INSERT INTO CatSubscriptionAtribute
			(CatSubscriptionId, 
			CatAttributeId,
			SubscriptionAttributeValue,
			SubscriptionAttributeDescription,
			SubscriptionAttributePosition,
			RowStatus,
			TokenCreated,
			DateCreated)
VALUES		((SELECT [CS].[IdCatSubscription] FROM [dbo].[CatSubscription] CS WHERE [CS].[SubscriptionName] = 'Plan Básico'),	-- CatSubscriptionId
			1,																													-- CatAttributeId
			0,																													-- SubscriptionAttributeValue
			'hwa-planBasicoIcon',																								-- SubscriptionAttributeDescription
			2,																													-- SubscriptionAttributePosition
			1,																													-- RowStatus
			'SYS-JOCHOA',																										-- TokenCreated
			SYSDATETIME());																										-- DateCreated

INSERT INTO CatSubscriptionAtribute
			(CatSubscriptionId, 
			CatAttributeId,
			SubscriptionAttributeValue,
			SubscriptionAttributeDescription,
			SubscriptionAttributePosition,
			RowStatus,
			TokenCreated,
			DateCreated)
VALUES		((SELECT [CS].[IdCatSubscription] FROM [dbo].[CatSubscription] CS WHERE [CS].[SubscriptionName] = 'Plan Básico +'),	-- CatSubscriptionId
			1,																													-- CatAttributeId
			0,																													-- SubscriptionAttributeValue
			'hwa-planBasicoPlusIcon',																							-- SubscriptionAttributeDescription
			2,																													-- SubscriptionAttributePosition
			1,																													-- RowStatus
			'SYS-JOCHOA',																										-- TokenCreated
			SYSDATETIME());																										-- DateCreated

INSERT INTO CatSubscriptionAtribute
			(CatSubscriptionId, 
			CatAttributeId,
			SubscriptionAttributeValue,
			SubscriptionAttributeDescription,
			SubscriptionAttributePosition,
			RowStatus,
			TokenCreated,
			DateCreated)
VALUES		((SELECT [CS].[IdCatSubscription] FROM [dbo].[CatSubscription] CS WHERE [CS].[SubscriptionName] = 'Plan Gold'),		-- CatSubscriptionId
			1,																													-- CatAttributeId
			0,																													-- SubscriptionAttributeValue
			'hwa-planGoldIcon',																									-- SubscriptionAttributeDescription
			2,																													-- SubscriptionAttributePosition
			1,																													-- RowStatus
			'SYS-JOCHOA',																										-- TokenCreated
			SYSDATETIME());																										-- DateCreated

INSERT INTO CatSubscriptionAtribute
			(CatSubscriptionId, 
			CatAttributeId,
			SubscriptionAttributeValue,
			SubscriptionAttributeDescription,
			SubscriptionAttributePosition,
			RowStatus,
			TokenCreated,
			DateCreated)
VALUES		((SELECT [CS].[IdCatSubscription] FROM [dbo].[CatSubscription] CS WHERE [CS].[SubscriptionName] = 'Plan Corporativo'),-- CatSubscriptionId
			1,																													-- CatAttributeId
			0,																													-- SubscriptionAttributeValue
			'hwa-planCorporateIcon',																							-- SubscriptionAttributeDescription
			2,																													-- SubscriptionAttributePosition
			1,																													-- RowStatus
			'SYS-JOCHOA',																										-- TokenCreated
			SYSDATETIME());																										-- DateCreated