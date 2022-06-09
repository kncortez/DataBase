


CREATE FUNCTION [dbo].[fn_get_hub_destiny]
(
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT
)
RETURNS VARCHAR(MAX)
AS
BEGIN

    DECLARE @Hub NVARCHAR(10) =
            (
                SELECT TOP 1
                  hub.HubAbbreviation
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
                   
                WHERE dsg.Guide_Serie = @GuideSerie
                      AND dsg.Guide_Number = @GuideNumber
            );

    RETURN ISNULL(@Hub, '');
END;



