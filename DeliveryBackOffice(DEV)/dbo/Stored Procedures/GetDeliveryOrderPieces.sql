/* =================================================
   SP:        GetDeliveryOrderPieces
   Propósito: Obtener el detalle de piezas para mostrar en comprobante de entrega
   Autor:     Brandon Pedroza
   Historia:  FDAPI-5314
   Fecha:     2022-09-13

=== CHANGELOG ============================

=========================================== */
CREATE PROCEDURE [dbo].[GetDeliveryOrderPieces]
    @GuideSerie   NVARCHAR(2),
    @GuideNumber  INT
AS
BEGIN

    SELECT 
        CONCAT(dop.GuideSerie, dop.GuideNumber, '-', dop.NoPiece)     AS [Piece],
        ca.ArtName                                                    AS [Article],
        do.IndicationsToSendDestination                               AS [AdditionalIndications]
    FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH (NOLOCK)
        INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do WITH (NOLOCK)
            ON do.Guide_Serie  = dop.GuideSerie
           AND do.Guide_Number = dop.GuideNumber
        LEFT JOIN DeliveryBackOffice.dbo.ArticleByCustomer abc WITH (NOLOCK)
            ON dop.ParcelCode = abc.Code
        LEFT JOIN DeliveryBackOffice.dbo.CatArticle ca WITH (NOLOCK)
            ON ca.ArtId = abc.AbcIdArticle
    WHERE do.Guide_Serie  = @GuideSerie
      AND do.Guide_Number = @GuideNumber
    ORDER BY dop.NoPiece ASC;
END