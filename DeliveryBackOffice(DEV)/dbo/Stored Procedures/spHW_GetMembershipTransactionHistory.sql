-- =============================================
-- Author:		<Jerson Ochoa>
-- Create date: <26-12-2022>
-- Description:	<Get membership transaction history>
-- =============================================
-- Actualizaciones
-- Author: Jerson Ochoa
-- Agregar manejo de estados de servicio agrupados de acuerdo a catálogo definido - 12-01-2023
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetMembershipTransactionHistory] @AccountId AS INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @MEMBERSHIP_ID AS INT; -- Membership
    DECLARE @CUSTOMER_ID AS INT; -- Customer
    DECLARE @MEMBERSHIP_STATUS_ACTIVE_ID AS INT; -- CatSalesPackageStatus
    DECLARE @MEMBERSHIP_STATUS_INACTIVE_ID AS INT; -- CatSalesPackageStatus
    DECLARE @NULL_STATUS_ORDER AS INT; -- StatusOrder
    DECLARE @DESTROYED_STATUS_ORDER AS INT; -- StatusOrder

    DECLARE @SPECIALSUSCRIPTION AS INT;
    SET @SPECIALSUSCRIPTION =
    (
        SELECT TOP 1
               CS.IdCatSubscription
        FROM [DeliveryBackOffice].[dbo].[CatSubscription] CS WITH (NOLOCK)
        WHERE CS.SubscriptionName = 'Plan Diamante' COLLATE Latin1_General_CI_AI
    );

    SET @CUSTOMER_ID =
    (
        SELECT [A].[IdCustomer]
        FROM [dbo].[Account] A
        WHERE [A].[AccIdAccount] = @AccountId
    );

    SET @MEMBERSHIP_STATUS_ACTIVE_ID =
    (
        SELECT [CSPS].[IdCatSalesPackageStatus]
        FROM [dbo].[CatSalesPackageStatus] CSPS
        WHERE [CSPS].[SalesPackageStatusName] = 'Activa'
    );

    SET @MEMBERSHIP_STATUS_INACTIVE_ID =
    (
        SELECT [CSPS].[IdCatSalesPackageStatus]
        FROM [dbo].[CatSalesPackageStatus] CSPS
        WHERE [CSPS].[SalesPackageStatusName] = 'Inactiva'
    );

    SET @MEMBERSHIP_ID =
    (
        SELECT TOP 1
               [M].[IdMembership]
        FROM [dbo].[Membership] M
        WHERE [M].[AccountId] = @AccountId
              AND [M].[RowStatus] = 1
              AND [M].[CatMembershipStatusId] IN ( @MEMBERSHIP_STATUS_ACTIVE_ID, @MEMBERSHIP_STATUS_INACTIVE_ID )
    );

    SET @NULL_STATUS_ORDER =
    (
        SELECT [SO].[StatusOrderId]
        FROM [dbo].[StatusOrder] SO
        WHERE [SO].[OrderDescription] = 'Anulado'
    );

    SET @DESTROYED_STATUS_ORDER =
    (
        SELECT [SO].[StatusOrderId]
        FROM [dbo].[StatusOrder] SO
        WHERE [SO].[OrderDescription] = 'Paquete destruido'
    );

    -- Membership data
    SELECT [M].[IdMembership]
         , [M].[CustomerId]
         , [CM].[MembershipName]
         , IIF(([M].[MembershipMaxServiceFixedValue] - [M].[ActualServiceCount]) < 0
             , 0
             , ([M].[MembershipMaxServiceFixedValue] - [M].[ActualServiceCount])) [MembershipRemainingUses]
         , IIF((([M].[ActualServiceCount] * 100) / IIF([M].[MembershipMaxServiceFixedValue] = 0, 1, [M].[MembershipMaxServiceFixedValue])) > 100, 100, (([M].[ActualServiceCount] * 100) / IIF([M].[MembershipMaxServiceFixedValue] = 0, 1, [M].[MembershipMaxServiceFixedValue]))) [MembershipUsagePercentage]
         , [M].[IsAutoRenewable]
         , ISNULL([CM].[Icon], '')                                                [Icon]
         , [M].[DateCreated]
         , [M].[ExpirationDate]
         , ISNULL([M].[AccumulatedPoints], 0)                                     [AccumulatedPoints]
         , ISNULL([M].[AvailablePoints], 0)                                       [AvailablePoints]
    FROM [dbo].[Membership]                      M
        INNER JOIN [dbo].[CatMembership]         CM
            ON [M].[CatMembershipId] = [CM].[IdCatMembership]
        INNER JOIN [dbo].[CatSalesPackageStatus] CSPS
            ON [M].[CatMembershipStatusId] = [CSPS].[IdCatSalesPackageStatus]
    WHERE [M].[AccountId] = @AccountId
          AND [M].[RowStatus] = 1
          AND [M].[CatMembershipStatusId] IN ( @MEMBERSHIP_STATUS_ACTIVE_ID, @MEMBERSHIP_STATUS_INACTIVE_ID );

    -- Membership attributes
    SELECT [CMA].[IdCatMembershipAttribute]
         , [CMA].[MembershipAttributeDescription]
         , [CMA].[MembershipAttributePosition]
    FROM [dbo].[CatMembershipAttribute]  CMA
        INNER JOIN [dbo].[CatMembership] CM
            ON [CMA].[CatMembershipId] = [CM].[IdCatMembership]
        INNER JOIN [dbo].[Membership]    M
            ON [CM].[IdCatMembership] = [M].[CatMembershipId]
               AND [M].[IdMembership] = @MEMBERSHIP_ID
    WHERE [CMA].[RowStatus] = 1
    ORDER BY [CMA].[MembershipAttributePosition] ASC;

    -- Membership history
    SELECT [MSL].[IdMembershipSubscriptionLog]
         , CONCAT([MSL].[LogGuideSerie], [MSL].[LogGuideNumber])      [Guide]
         , [MSL].[DateCreated]                                        [Date]
         , [MSL].[LogGuideOriginalValue]                              [OriginalAmount]
         , [MSL].[LogGuideNewValue]                                   [NewAmount]
         , ([MSL].[LogGuideOriginalValue] - [MSL].[LogGuideNewValue]) [DiscountApplied]
         , [SO].[StatusOrderId]
         , [SO].[OrderDescription]
         , CASE
               WHEN [SO].[OrderDescription] = 'Generado' THEN
                   'Generado'
               WHEN [SO].[OrderDescription] = 'Entregado'
                    OR [SO].[OrderDescription] = 'Entregado En Express Center'
                    OR [SO].[OrderDescription] = 'COD liquidado'
                    OR [SO].[OrderDescription] = 'COD pagado' THEN
                   'Entregado'
               WHEN [SO].[OrderDescription] = 'Devuelto'
                    OR [SO].[OrderDescription] = 'Devuelto en Express Center' THEN
                   'Devuelto'
               WHEN [SO].[OrderDescription] = 'Anulado' THEN
                   'Cancelado'
               ELSE
                   'En proceso'
           END                                                        [OrderStatus]
    FROM [dbo].[MembershipSubscriptionLog] MSL
        INNER JOIN [dbo].[DeliveryOrder]   DO WITH (NOLOCK)
            ON [MSL].[LogGuideSerie] = [DO].[Guide_Serie]
               AND [MSL].[LogGuideNumber] = [DO].[Guide_Number]
               AND [DO].[StatusOrderId] NOT IN ( @NULL_STATUS_ORDER, @DESTROYED_STATUS_ORDER )
        INNER JOIN [dbo].[StatusOrder]     SO
            ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
    WHERE [MSL].[CustomerId] = @CUSTOMER_ID
          AND [MSL].[MembershipId] = @MEMBERSHIP_ID
          AND [MSL].[SubscriptionId] IS NULL
          AND [MSL].[RowStatus] = 1
          AND [MSL].[SalesPackageStatusId] = @MEMBERSHIP_STATUS_ACTIVE_ID;

    -- Subscription Data
    SELECT [S].[IdSubscription]
         , [S].[CatSubscriptionId]
         , [CS].[SubscriptionName]
         , [S].[CatSubscriptionStatusId]
         , [CSPS].[SalesPackageStatusName]
         , [S].[SubscriptionCost]
         , [S].[CustomerId]
         , [S].[AccountId]
         , [S].[IsAutoRenewable]
         , CAST((CASE
                     WHEN [S].[CatSubscriptionId] IN ( @SPECIALSUSCRIPTION ) THEN
                         0
                     ELSE
                         1
                 END
                ) AS BIT)                                                                   [CanAutorenew]
         , [S].[SubscriptionMaxServiceFixedValue]
         , [S].[ActualServiceCount]
         , IIF(([S].[SubscriptionMaxServiceFixedValue] - [S].[ActualServiceCount]) < 0
             , 0
             , ([S].[SubscriptionMaxServiceFixedValue] - [S].[ActualServiceCount]))         [SubscriptionRemainingUses]
         , IIF((([S].[ActualServiceCount] * 100) / [S].[SubscriptionMaxServiceFixedValue]) > 100
             , 100
             , (([S].[ActualServiceCount] * 100) / [S].[SubscriptionMaxServiceFixedValue])) [SubscriptionUsagePercentage]
         , [S].[DateCreated]
         , [S].[ExpirationDate]
         , ISNULL([CS].[Icon], '')                                                          [Icon]
    FROM [dbo].[Subscription]                    S
        INNER JOIN [dbo].[CatSubscription]       CS
            ON [S].[CatSubscriptionId] = [CS].[IdCatSubscription]
        INNER JOIN [dbo].[CatSalesPackageStatus] CSPS
            ON [S].[CatSubscriptionStatusId] = [CSPS].[IdCatSalesPackageStatus]
    WHERE [S].[MembershipId] = @MEMBERSHIP_ID
          AND [S].[RowStatus] = 1
          AND [S].[CatSubscriptionStatusId] IN ( @MEMBERSHIP_STATUS_ACTIVE_ID, @MEMBERSHIP_STATUS_INACTIVE_ID );

    -- Subscription Attributes
    SELECT [CSA].[IdCatSubscriptionAttribute]
         , [CSA].[CatSubscriptionId]
         , [CSA].[CatAttributeId]
         , [CA].[AttributeName]
         , [CSA].[SubscriptionAttributeValue]
         , [CSA].[SubscriptionAttributeDescription]
    FROM [dbo].[CatSubscriptionAtribute] CSA
        INNER JOIN [dbo].[CatAttribute]  CA
            ON [CSA].[CatAttributeId] = [CA].[IdCatAttribute]
    WHERE [CSA].[CatSubscriptionId] IN
          (
              SELECT [S].[CatSubscriptionId]
              FROM [dbo].[Subscription] S
              WHERE [S].[MembershipId] = @MEMBERSHIP_ID
          )
          AND [CSA].[RowStatus] = 1
    ORDER BY [CSA].[CatSubscriptionId]
           , [CSA].[SubscriptionAttributePosition];

    -- Subscription History
    SELECT [MSL].[IdMembershipSubscriptionLog]
         , [MSL].[MembershipId]
         , [MSL].[SubscriptionId]
         , [MSL].[LogActionDescription]
         , CONCAT([MSL].[LogGuideSerie], [MSL].[LogGuideNumber])      [Guide]
         , [MSL].[LogGuideOriginalValue]                              [OriginalAmount]
         , [MSL].[LogGuideNewValue]                                   [NewAmount]
         , ([MSL].[LogGuideOriginalValue] - [MSL].[LogGuideNewValue]) [DiscountApplied]
         , [MSL].[DateCreated]                                        [Date]
         , CASE
               WHEN [SO].[OrderDescription] = 'Generado' THEN
                   'Generado'
               WHEN [SO].[OrderDescription] = 'Entregado'
                    OR [SO].[OrderDescription] = 'Entregado En Express Center'
                    OR [SO].[OrderDescription] = 'COD liquidado'
                    OR [SO].[OrderDescription] = 'COD pagado' THEN
                   'Entregado'
               WHEN [SO].[OrderDescription] = 'Devuelto'
                    OR [SO].[OrderDescription] = 'Devuelto en Express Center' THEN
                   'Devuelto'
               WHEN [SO].[OrderDescription] = 'Anulado' THEN
                   'Cancelado'
               ELSE
                   'En proceso'
           END                                                        [OrderStatus]
    FROM [dbo].[MembershipSubscriptionLog] MSL
        INNER JOIN [dbo].[DeliveryOrder]   DO WITH (NOLOCK)
            ON [MSL].[LogGuideSerie] = [DO].[Guide_Serie]
               AND [MSL].[LogGuideNumber] = [DO].[Guide_Number]
               AND [DO].[StatusOrderId] NOT IN ( @NULL_STATUS_ORDER, @DESTROYED_STATUS_ORDER )
        INNER JOIN [dbo].[StatusOrder]     SO
            ON [DO].[StatusOrderId] = [SO].[StatusOrderId]
    WHERE [MSL].[MembershipId] = @MEMBERSHIP_ID
          AND [MSL].[SubscriptionId] IS NOT NULL
          AND [MSL].[RowStatus] = 1
    ORDER BY [MSL].[SubscriptionId]
           , [MSL].[LogServiceNumber];
END;