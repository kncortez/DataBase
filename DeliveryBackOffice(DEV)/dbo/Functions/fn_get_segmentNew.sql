
-- =============================================
-- Author:		<Eduardo López>
-- Create date: <2023-03-08>
-- Description:	<Calcula segmento a la cual pertenece guía>
-- =============================================


CREATE FUNCTION [dbo].[fn_get_segmentNew]
(
    @GuideSerie NVARCHAR(2),
    @GuideNumber INT,
	@SenderID INT,
	@ReceiverTown NVARCHAR(100)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @TownSenderID INT;
		DECLARE @TownDestinyID INT;
		DECLARE @SegmentGuide Varchar(5);

			SET @TownSenderID = (SELECT top 1 IdTownship FROM VisitPointClient WITH (NOLOCK) WHERE CodeOfReference = @SenderID)

				IF(@TownSenderID IS NULL)
					BEGIN
						SET @TownSenderID = 73
					END


				SET @TownDestinyID = (SELECT top 1 IdTownship  FROM Township WITH (NOLOCK) WHERE TownshipName = @ReceiverTown)


				SET @SegmentGuide =  (SELECT TOP 1 Crs.CrsShortName FROM CorporateTownshipCoverage ctc WITH (NOLOCK)
				INNER JOIN CatRateSegment crs WITH (NOLOCK)
				ON ctc.SegmentTypeId = crs.CrsId
				WHERE  ctc.TownshipSourceId = @TownSenderID
				AND ctc.TownshipDestinyId = @TownDestinyID)



    

	  --RETURN @SegmentGuide
    RETURN ISNULL(@SegmentGuide, 'FOR');
END;