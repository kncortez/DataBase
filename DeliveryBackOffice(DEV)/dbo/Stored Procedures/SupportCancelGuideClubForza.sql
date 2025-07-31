-- =============================================
-- Author:		<César Aquino>
-- Create date: <2022-08-28>
-- Description:	<Sp para anular una guia de Club Forza cuando el carrito ya esta cerrado>
-- =============================================

CREATE PROCEDURE [dbo].[SupportCancelGuideClubForza]
    -- Add the parameters for the stored procedure here

    @GuideSerie NVARCHAR(2)
  , @GuideNumber INT
  , @Token NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY



        DECLARE @GEN_STATUS_ORDER_ID AS INT; -- StatusOrder
        DECLARE @SOL_STATUS_ORDER_ID AS INT; -- StatusOrder
        DECLARE @NULL_STATUS_ORDER_ID AS INT; -- StatusOrder
        DECLARE @ActualGuideStatus AS INT;


        DECLARE @TR_ID AS INT;


        SET @GEN_STATUS_ORDER_ID =
        (
            SELECT [SO].[StatusOrderId]
            FROM [dbo].[StatusOrder] SO
            WHERE [SO].[OrderDescription] = 'Generado'
        );

        SET @SOL_STATUS_ORDER_ID =
        (
            SELECT [SO].[StatusOrderId]
            FROM [dbo].[StatusOrder] SO
            WHERE [SO].[OrderDescription] = 'Solicitado'
        );

        SET @NULL_STATUS_ORDER_ID =
        (
            SELECT [SO].[StatusOrderId]
            FROM [dbo].[StatusOrder] SO
            WHERE [SO].[OrderDescription] = 'Anulado'
        );

        SELECT @ActualGuideStatus = DO.StatusOrderId
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH (NOLOCK)
        WHERE DO.Guide_Serie = @GuideSerie
              AND DO.Guide_Number = @GuideNumber;

        BEGIN TRANSACTION;

        IF (@ActualGuideStatus IN ( @GEN_STATUS_ORDER_ID, @SOL_STATUS_ORDER_ID ))
        BEGIN

            UPDATE [dbo].[DeliveryOrder]
            SET [StatusOrderId] = @NULL_STATUS_ORDER_ID
              , [TokenUpdated] = @Token
              , [DateUpdated] = GETDATE()
            WHERE [Guide_Serie] = @GuideSerie
                  AND [Guide_Number] = @GuideNumber;

            INSERT INTO [dbo].[DeliveryOrderDetail]
            (
                [Guide_Serie]
              , [Guide_Number]
              , [StatusOrderId]
              , [UserCreated]
              , [DateCreated]
              , [DateCreatedInSystem]
              , [RowStatus]
            )
            VALUES
            (@GuideSerie, @GuideNumber, @NULL_STATUS_ORDER_ID, @Token, GETDATE(), GETDATE(), 1);

            SET @TR_ID =
            (
                SELECT [MSL].[SubscriptionId]
                FROM [dbo].[MembershipSubscriptionLog] MSL
                WHERE [MSL].[LogGuideSerie] = @GuideSerie
                      AND [MSL].[LogGuideNumber] = @GuideNumber
                      AND [MSL].[RowStatus] = 1
                      AND [MSL].[SubscriptionId] IS NOT NULL
            );

            IF (@TR_ID > 0)
            BEGIN
                -- Descontar transacción de suscripción
                UPDATE [dbo].[Subscription]
                SET [ActualServiceCount] = [ActualServiceCount] - 1
                  , [TokenUpdated] = @Token
                  , [DateUpdated] = SYSDATETIME()
                WHERE [IdSubscription] = @TR_ID;

                -- Anular transacción de suscripción o membresía asociada
                UPDATE [dbo].[MembershipSubscriptionLog]
                SET [RowStatus] = 0
                  , [TokenUpdated] = @Token
                  , [DateUpdated] = SYSDATETIME()
                WHERE [LogGuideSerie] = @GuideSerie
                      AND [LogGuideNumber] = @GuideNumber
                      AND [RowStatus] = 1;
            END;
            -- Obtener ID de membresía con transacción asociada
            SET @TR_ID =
            (
                SELECT [MSL].[MembershipId]
                FROM [dbo].[MembershipSubscriptionLog] MSL
                WHERE [MSL].[LogGuideSerie] = @GuideSerie
                      AND [MSL].[LogGuideNumber] = @GuideNumber
                      AND [MSL].[RowStatus] = 1
                      AND [MSL].[SubscriptionId] IS NULL
            );

            IF (@TR_ID > 0)
            BEGIN
                -- Descontar transacción de memebresía
                UPDATE [dbo].[Membership]
                SET [ActualServiceCount] = [ActualServiceCount] - 1
                  , [TokenUpdated] = @Token
                  , [DateUpdated] = SYSDATETIME()
                WHERE [IdMembership] = @TR_ID;

                -- Anular transacción de suscripción o membresía asociada
                UPDATE [dbo].[MembershipSubscriptionLog]
                SET [RowStatus] = 0
                  , [TokenUpdated] = @Token
                  , [DateUpdated] = SYSDATETIME()
                WHERE [LogGuideSerie] = @GuideSerie
                      AND [LogGuideNumber] = @GuideNumber
                      AND [RowStatus] = 1;
            END;
        END;
        ELSE
        BEGIN
            SELECT 'guía en estado inválido';
        END;

        COMMIT TRANSACTION;

		SELECT 'cambiar realizados correctamente'
    END TRY
    BEGIN CATCH
        ROLLBACK;


        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER();
    END CATCH;
END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportCancelGuideClubForza] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportCancelGuideClubForza] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportCancelGuideClubForza] TO [cvaldes]
    AS [dbo];

