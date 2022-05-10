USE [DeliveryBackOffice]
GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_segment]    Script Date: 31/01/2022 15:48:25 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



ALTER FUNCTION [dbo].[fn_get_segment]
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
                FROM dbo.DeliveryOrder dsg
                    LEFT JOIN dbo.Township twn
                        ON twn.IdTownship = dsg.ReceiverIdTownship
                    LEFT JOIN dbo.Township twc
                        ON twc.TownshipName = dsg.Receiver_Town
                    LEFT JOIN
                    (
                        SELECT CV.HeaderCode,
                               MAX(CV.Hub) HUB
                        FROM dbo.DumpServiceCoverage CV
                        GROUP BY CV.HeaderCode
                    ) HB
                        ON HB.HeaderCode = ISNULL(twn.HeaderCode, twc.HeaderCode)
                    LEFT JOIN dbo.HubLogistics hub
                        ON hub.HubAbbreviation = HB.HUB
                    LEFT JOIN dbo.VisitPointCoverage vpc
                        ON vpc.HubLogisticId = hub.IdHubLogistic
                           AND vpc.VisitPointId = dsg.Sender_ID
                           AND vpc.RowStatus = 1
                    LEFT JOIN dbo.CatRateSegment csg
                        ON csg.CrsId = vpc.SegmentId
                WHERE dsg.Guide_Serie = @GuideSerie
                      AND dsg.Guide_Number = @GuideNumber
            );

    IF @Segment IS NULL
    BEGIN

        SELECT @Segment = IIF(HBO.HUB = HBD.HUB, 'LOC', IIF( ISNULL(twn.IdProvince,twc.IdProvince) = ISNULL(twr.IdProvince,trc.IdProvince) and (HBD.HUB = 'GTM' OR HBO.HUB ='GTM') , 'MET', 'FOR'))
        FROM dbo.DeliveryOrder dsg
            LEFT JOIN dbo.Township twn
                ON twn.IdTownship = dsg.SenderIdTownship
            LEFT JOIN dbo.Township twc
                ON twc.TownshipName = dsg.Sender_Town
            LEFT JOIN
            (
                SELECT CV.HeaderCode,
                       MAX(CV.Hub) HUB
                FROM dbo.DumpServiceCoverage CV
                GROUP BY CV.HeaderCode
            ) HBO
                ON HBO.HeaderCode = ISNULL(twn.HeaderCode, twc.HeaderCode)
            LEFT JOIN dbo.Township twr
                ON twr.IdTownship = dsg.ReceiverIdTownship
            LEFT JOIN dbo.Township trc
                ON trc.TownshipName = dsg.Receiver_Town
            LEFT JOIN
            (
                SELECT CV.HeaderCode,
                       MAX(CV.Hub) HUB
                FROM dbo.DumpServiceCoverage CV
                GROUP BY CV.HeaderCode
            ) HBD
                ON HBD.HeaderCode = ISNULL(twr.HeaderCode, trc.HeaderCode)
        WHERE dsg.Guide_Serie = @GuideSerie
              AND dsg.Guide_Number = @GuideNumber;

    END;

    RETURN ISNULL(@Segment, 'FOR');
END;