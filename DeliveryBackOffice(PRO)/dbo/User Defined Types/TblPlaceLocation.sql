CREATE TYPE [dbo].[TblPlaceLocation] AS TABLE (
    [PlaceName]               NVARCHAR (50)  NULL,
    [PlaceNameExtended]       NVARCHAR (100) NULL,
    [PlaceIdentifier]         INT            NULL,
    [PlaceIdentifierExtended] BIGINT         NULL,
    [PlaceLatitude]           NVARCHAR (20)  NOT NULL,
    [PlaceLongitude]          NVARCHAR (20)  NOT NULL);

