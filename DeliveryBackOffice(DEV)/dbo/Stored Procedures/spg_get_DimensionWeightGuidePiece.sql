-- =============================================
-- Author:		<Marco, Jiménez>
-- Create date: <2021-06-22>
-- Description:	<Retorna las dimesiones y pesos de una pieza>
-- =============================================
-- Modified:	<Brandon, Pedroza>
-- Create date: <2024-06-04>
-- Description:	<Se agrega parametro para filtrar por pais>
-- =============================================
CREATE PROCEDURE [dbo].[spg_get_DimensionWeightGuidePiece]
    @numberPiece as int,
    @serieGuide as nvarchar(2),
    @numberGuide as int,
	@IdCountry AS NVARCHAR(2)= 'GT'
AS
BEGIN
    IF EXISTS
    (
        SELECT *
        FROM DeliveryBackOffice.dbo.DeliveryOrderPiece dop WITH(NOLOCK)
		INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro WITH(NOLOCK)
          ON dro.Guide_Serie = dop.GuideSerie AND dro.Guide_Number = dop.GuideNumber
        WHERE dop.GuideSerie = @serieGuide
              AND dop.GuideNumber = @numberGuide
			  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry
    )
    BEGIN
        IF @numberPiece = 0
        BEGIN
            IF
            (
                SELECT IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder
                WHERE Guide_Number = @numberGuide
                      AND Guide_Serie = @serieGuide
					  AND IIF(SenderCountryId IS NULL, 'GT',SenderCountryId)=@IdCountry
            ) is NULL
            BEGIN
                SELECT dop.GuideSerie,
                       dop.GuideNumber,
                       dop.NoPiece,
                       dop.Detail,
                       dop.PiecePhysicalWeight,
                       dop.PieceWeight,
                       'Punto Vacio' as Name,
                       vpc.DescriptionOfClient,
                       ISNULL(dop.CategoryCheck,0) AS CategoryCheck,
                       dop.PieceHeight,
                       dop.PieceWidth,
                       dop.PieceLength
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro
                        ON dro.Guide_Serie = dop.GuideSerie
                           AND dro.Guide_Number = dop.GuideNumber
                    INNER JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc
                        ON vpc.CodeOfReference = dro.Sender_ID
                WHERE dop.GuideSerie = @serieGuide
                      AND dop.GuideNumber = @numberGuide
					  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry
            END
            ELSE
            BEGIN
                SELECT dop.GuideSerie,
                       dop.GuideNumber,
                       dop.NoPiece,
                       dop.Detail,
                       dop.PiecePhysicalWeight,
                       dop.PieceWeight,
                       cli.Name,
                       vpc.DescriptionOfClient,
                       ISNULL(dop.CategoryCheck,0) AS CategoryCheck,
                       dop.PieceHeight,
                       dop.PieceWidth,
                       dop.PieceLength
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro
                        ON dro.Guide_Serie = dop.GuideSerie
                           AND dro.Guide_Number = dop.GuideNumber
                    INNER JOIN DeliveryBackOffice.[dbo].[Customer] cli
                        ON cli.IdCustomer = dro.IdCustomer
                    INNER JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc
                        ON vpc.CodeOfReference = dro.Sender_ID
                WHERE dop.GuideSerie = @serieGuide
                      AND dop.GuideNumber = @numberGuide
					  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry
            END
        END
        ELSE
        BEGIN
            IF
            (
                SELECT IdCustomer
                FROM DeliveryBackOffice.dbo.DeliveryOrder
                WHERE Guide_Number = @numberGuide
                      AND Guide_Serie = @serieGuide
					  AND IIF(SenderCountryId IS NULL, 'GT',SenderCountryId)=@IdCountry
            ) is NULL
            BEGIN
                SELECT dop.GuideSerie,
                       dop.GuideNumber,
                       dop.NoPiece,
                       dop.Detail,
                       dop.PiecePhysicalWeight,
                       dop.PieceWeight,
                       'Punto Vacio' as Name,
                       vpc.DescriptionOfClient,
                       ISNULL(dop.CategoryCheck,0) AS CategoryCheck,
                       dop.PieceHeight,
                       dop.PieceWidth,
                       dop.PieceLength
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro
                        ON dro.Guide_Serie = dop.GuideSerie
                           AND dro.Guide_Number = dop.GuideNumber
                    JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc
                        ON vpc.CodeOfReference = dro.Sender_ID
                WHERE dop.GuideSerie = @serieGuide
                      AND dop.GuideNumber = @numberGuide
                      AND dop.NoPiece = @numberPiece
					  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry
            END
            ELSE
            BEGIN
                SELECT dop.GuideSerie,
                       dop.GuideNumber,
                       dop.NoPiece,
                       dop.Detail,
                       dop.PiecePhysicalWeight,
                       dop.PieceWeight,
                       cli.Name,
                       cli.IdCustomer,
                       vpc.DescriptionOfClient,
                       ISNULL(dop.CategoryCheck,0) AS CategoryCheck,
                       dop.PieceHeight,
                       dop.PieceWidth,
                       dop.PieceLength
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro
                        ON dro.Guide_Serie = dop.GuideSerie
                           AND dro.Guide_Number = dop.GuideNumber
                    INNER JOIN DeliveryBackOffice.[dbo].[Customer] cli
                        ON cli.IdCustomer = dro.IdCustomer
                    INNER JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc
                        ON vpc.CodeOfReference = dro.Sender_ID
                WHERE dop.GuideSerie = @serieGuide
                      AND dop.GuideNumber = @numberGuide
                      AND dop.NoPiece = @numberPiece
					  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry
            END
        END
    END
    ELSE
    BEGIN
        DECLARE @count int
        SET @count = 0

        DECLARE @statusOrderId int
        SELECT @statusOrderId = StatusOrderId
        FROM DeliveryBackOffice.dbo.DeliveryOrder
        WHERE Guide_Serie = @serieGuide
              AND Guide_Number = @numberGuide
			  AND IIF(SenderCountryId IS NULL, 'GT',SenderCountryId)=@IdCountry

        WHILE @count <
        (
            SELECT SUM(Pieces_Dry + Pieces_Cold)
            FROM DeliveryBackOffice.dbo.DeliveryOrder
            WHERE Guide_Serie = @serieGuide
                  AND Guide_Number = @numberGuide
				  AND IIF(SenderCountryId IS NULL, 'GT',SenderCountryId)=@IdCountry
        )
        BEGIN select * from CatCountry where IdCountry in('GT','HN')
            INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderPiece
            (
                GuideSerie,
                GuideNumber,
                Currency,
                DateCreated,
                NoPiece,
                StatusOrderId
            )
            VALUES
            (@serieGuide,
				@numberGuide, 
				CASE 
                    WHEN @IdCountry = 'GT' THEN 'GTQ' 
                    WHEN @IdCountry = 'HN' THEN 'HND' END,
					GETDATE(),
					@count + 1, 
					@statusOrderId)
            SET @count = @count + 1
        END

        IF
        (
            SELECT IdCustomer
            FROM DeliveryBackOffice.dbo.DeliveryOrder
            WHERE Guide_Number = @numberGuide
                  AND Guide_Serie = @serieGuide
				  AND IIF(SenderCountryId IS NULL, 'GT',SenderCountryId)=@IdCountry
        ) is NULL
        BEGIN
            IF @numberPiece = 0
            BEGIN
                SELECT dop.GuideSerie,
                       dop.GuideNumber,
                       dop.NoPiece,
                       dop.Detail,
                       dop.PiecePhysicalWeight,
                       dop.PieceWeight,
                       'Punto Vacio' as Name,
                       vpc.DescriptionOfClient,
                       ISNULL(dop.CategoryCheck,0) AS CategoryCheck,
                       dop.PieceHeight,
                       dop.PieceWidth,
                       dop.PieceLength
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro
                        ON dro.Guide_Serie = dop.GuideSerie
                           AND dro.Guide_Number = dop.GuideNumber
                    INNER JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc
                        ON vpc.CodeOfReference = dro.Sender_ID
                WHERE dop.GuideSerie = @serieGuide
                      AND dop.GuideNumber = @numberGuide
					  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry

            END
            ELSE
            BEGIN
                SELECT dop.GuideSerie,
                       dop.GuideNumber,
                       dop.NoPiece,
                       dop.Detail,
                       dop.PiecePhysicalWeight,
                       dop.PieceWeight,
                       'Punto Vacio' as Name,
                       vpc.DescriptionOfClient,
                       ISNULL(dop.CategoryCheck,0) AS CategoryCheck,
                       dop.PieceHeight,
                       dop.PieceWidth,
                       dop.PieceLength
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro
                        ON dro.Guide_Serie = dop.GuideSerie
                           AND dro.Guide_Number = dop.GuideNumber
                    INNER JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc
                        ON vpc.CodeOfReference = dro.Sender_ID
                WHERE dop.GuideSerie = @serieGuide
                      AND dop.GuideNumber = @numberGuide
                      AND dop.NoPiece = @numberPiece
					  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry
            END

        END
        ELSE
        BEGIN
            IF @numberPiece = 0
            BEGIN
                SELECT dop.GuideSerie,
                       dop.GuideNumber,
                       dop.NoPiece,
                       dop.Detail,
                       dop.PiecePhysicalWeight,
                       dop.PieceWeight,
                       cli.Name,
                       cli.IdCustomer,
                       vpc.DescriptionOfClient,
                       ISNULL(dop.CategoryCheck,0) AS CategoryCheck,
                       dop.PieceHeight,
                       dop.PieceWidth,
                       dop.PieceLength
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro
                        ON dro.Guide_Serie = dop.GuideSerie
                           AND dro.Guide_Number = dop.GuideNumber
                    INNER JOIN DeliveryBackOffice.[dbo].[Customer] cli
                        ON cli.IdCustomer = dro.IdCustomer
                    INNER JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc
                        ON vpc.CodeOfReference = dro.Sender_ID
                WHERE dop.GuideSerie = @serieGuide
                      AND dop.GuideNumber = @numberGuide
					  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry
            END
            ELSE
            BEGIN
                SELECT dop.GuideSerie,
                       dop.GuideNumber,
                       dop.NoPiece,
                       dop.Detail,
                       dop.PiecePhysicalWeight,
                       dop.PieceWeight,
                       cli.Name,
                       cli.IdCustomer,
                       vpc.DescriptionOfClient,
                       ISNULL(dop.CategoryCheck,0) AS CategoryCheck,
                       dop.PieceHeight,
                       dop.PieceWidth,
                       dop.PieceLength
                FROM [DeliveryBackOffice].[dbo].[DeliveryOrderPiece] dop
                    INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryOrder] dro
                        ON dro.Guide_Serie = dop.GuideSerie
                           AND dro.Guide_Number = dop.GuideNumber
                    INNER JOIN DeliveryBackOffice.[dbo].[Customer] cli
                        ON cli.IdCustomer = dro.IdCustomer
                    INNER JOIN DeliveryBackOffice.[dbo].[VisitPointClient] vpc
                        ON vpc.CodeOfReference = dro.Sender_ID
                WHERE dop.GuideSerie = @serieGuide
                      AND dop.GuideNumber = @numberGuide
                      AND dop.NoPiece = @numberPiece
					  AND IIF(dro.SenderCountryId IS NULL, 'GT',dro.SenderCountryId)=@IdCountry
            END
        END
    END
END
