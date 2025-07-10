-- =============================================
-- Author:		<Tito Garcia>
-- Create date: <2025-06-30>
-- Description:	<Se obtiene la información para payload de API UE>
-- =============================================
CREATE PROCEDURE [dbo].[GetWebhookDataUEForJSON]
    @WebhookTrackingQueueId BIGINT,
    @WebhookTypeName NVARCHAR(50)
AS
BEGIN

	IF @WebhookTypeName = 'CreatedGuides'
	BEGIN

		SELECT
			DO.Guide_Number AS GuideNumber,
			CUS.CustomerUEId AS Sender,
			CONCAT(ISNULL(DO.Receiver_FirstName,''), ' ', ISNULL(DO.Receiver_LastName,'')) AS Recipient,
			GETDATE() AS Date,
			DO.Receiver_Address AS Address,
			CUS.CustomerUEId AS Charge_client,
			ISNULL(SM.SettlementUEId, '') AS City_origin,
			ISNULL(SM2.SettlementUEId, '') AS City_destination,
			DO.IndicationsToSendDestination AS Note
		FROM dbo.WebhookTrackingQueue WTQ WITH(NOLOCK)
		INNER JOIN dbo.DeliveryOrder DO WITH(NOLOCK)
			ON WTQ.GuideSerie = DO.Guide_Serie 
			AND WTQ.GuideNumber = DO.Guide_Number
		INNER JOIN dbo.Customer CUS WITH(NOLOCK)
			ON DO.IdCustomer = CUS.IdCustomer
		LEFT JOIN dbo.SettlementMapping SM WITH(NOLOCK)
			ON DO.SenderIdSettlement = SM.SettlementForzaId
		LEFT JOIN dbo.SettlementMapping SM2 WITH(NOLOCK)
			ON DO.ReceiverIdSettlement = SM2.SettlementForzaId
		WHERE WTQ.IdWebhookTrackingQueue = @WebhookTrackingQueueId;


		WITH TrackingInfo AS (
			SELECT GuideSerie, GuideNumber
			FROM WebhookTrackingQueue WITH(NOLOCK)
			WHERE IdWebhookTrackingQueue = @WebhookTrackingQueueId
		)
		SELECT DOP.ParcelCode,
			AM.ArticleUEId AS IdPacket,
			COUNT(*) AS Quantity,
			SUM(DOP.PieceWeight) AS Weight
		FROM DeliveryOrderPiece DOP WITH(NOLOCK)
		INNER JOIN TrackingInfo T
			ON DOP.GuideSerie = T.GuideSerie AND DOP.GuideNumber = T.GuideNumber
		LEFT JOIN ArticleByCustomer ABC
			ON DOP.ParcelCode = ABC.Code
		LEFT JOIN CatArticle CA
			ON ABC.AbcIdArticle = CA.ArtId
		LEFT JOIN ArticleMapping AM
			ON CA.ArtId = AM.ArticleForzaId
		GROUP BY DOP.ParcelCode, AM.ArticleUEId;

	END
	ELSE IF @WebhookTypeName = 'VoidedGuides'
	BEGIN
			SELECT
			DO.Guide_Number AS Id,
			2 AS Status
		FROM DeliveryOrder DO WITH(NOLOCK) 
			INNER JOIN WebhookTrackingQueue WTQ WITH(NOLOCK)
				ON DO.Guide_Serie = WTQ.GuideSerie AND do.Guide_Number = WTQ.GuideNumber
		WHERE WTQ.IdWebhookTrackingQueue = @WebhookTrackingQueueId;
	END
	ELSE IF @WebhookTypeName = 'DeliveredGuides'
	BEGIN
			SELECT
			DO.Guide_Number AS Id,
			9 AS Status
		FROM DeliveryOrder DO WITH(NOLOCK) 
			INNER JOIN WebhookTrackingQueue WTQ WITH(NOLOCK)
				ON DO.Guide_Serie = WTQ.GuideSerie AND do.Guide_Number = WTQ.GuideNumber
		WHERE WTQ.IdWebhookTrackingQueue = @WebhookTrackingQueueId;
	END
END