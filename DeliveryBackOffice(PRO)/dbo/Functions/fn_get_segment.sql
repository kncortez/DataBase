
-- =============================================
-- Description:	<Función utilizada para obtener el segmento al que pertenece una guía>
-- =============================================


CREATE FUNCTION [dbo].[fn_get_segment]
(
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

    DECLARE @Segment NVARCHAR(10) =
            (
                SELECT TOP 1
                       csg.CrsShortName
                FROM dbo.DeliveryOrder dsg WITH (NOLOCK)
                    LEFT JOIN dbo.Township twn WITH (NOLOCK)
                        ON twn.IdTownship = dsg.ReceiverIdTownship
                    LEFT JOIN dbo.Township twc WITH (NOLOCK)
                        ON twc.TownshipName = dsg.Receiver_Town
                    LEFT JOIN
                    (
                        SELECT CV.HeaderCode,
                               MAX(CV.Hub) HUB
                        FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
                        GROUP BY CV.HeaderCode
                    ) HB
                        ON HB.HeaderCode = ISNULL(twn.HeaderCode, twc.HeaderCode)
                    LEFT JOIN dbo.HubLogistics hub WITH (NOLOCK)
                        ON hub.HubAbbreviation = HB.HUB
                    LEFT JOIN dbo.VisitPointCoverage vpc WITH (NOLOCK)
                        ON vpc.HubLogisticId = hub.IdHubLogistic
                           AND vpc.VisitPointId = dsg.Sender_ID
                           AND vpc.RowStatus = 1
                    LEFT JOIN dbo.CatRateSegment csg WITH (NOLOCK)
                        ON csg.CrsId = vpc.SegmentId
                WHERE dsg.Guide_Serie = @GuideSerie
                      AND dsg.Guide_Number = @GuideNumber
            );

    IF @Segment IS NULL
    BEGIN

        SELECT @Segment = IIF(HBO.HUB = HBD.HUB, 'LOC', IIF( ISNULL(twn.IdProvince,twc.IdProvince) = ISNULL(twr.IdProvince,trc.IdProvince) and (HBD.HUB = 'GTM' OR HBO.HUB ='GTM') , 'MET', 'FOR'))
        FROM dbo.DeliveryOrder dsg WITH (NOLOCK)
            LEFT JOIN dbo.Township twn WITH (NOLOCK)
                ON twn.IdTownship = dsg.SenderIdTownship
            LEFT JOIN dbo.Township twc WITH (NOLOCK)
                ON twc.TownshipName = dsg.Sender_Town
            LEFT JOIN
            (
                SELECT CV.HeaderCode,
                       MAX(CV.Hub) HUB
                FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
                GROUP BY CV.HeaderCode
            ) HBO
                ON HBO.HeaderCode = ISNULL(twn.HeaderCode, twc.HeaderCode)
            LEFT JOIN dbo.Township twr WITH (NOLOCK)
                ON twr.IdTownship = dsg.ReceiverIdTownship
            LEFT JOIN dbo.Township trc WITH (NOLOCK)
                ON trc.TownshipName = dsg.Receiver_Town
            LEFT JOIN
            (
                SELECT CV.HeaderCode,
                       MAX(CV.Hub) HUB
                FROM dbo.DumpServiceCoverage CV WITH (NOLOCK)
                GROUP BY CV.HeaderCode
            ) HBD
                ON HBD.HeaderCode = ISNULL(twr.HeaderCode, trc.HeaderCode)
        WHERE dsg.Guide_Serie = @GuideSerie
              AND dsg.Guide_Number = @GuideNumber;

    END;

    RETURN ISNULL(@Segment, 'FOR');
END;



