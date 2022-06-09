CREATE TABLE [dbo].[CatCommercialSegment] (
    [IdCommercialSegment]          INT            IDENTITY (1, 1) NOT NULL,
    [CommercialSegmentName]        NVARCHAR (75)  NOT NULL,
    [CommercialSegmentDescription] NVARCHAR (200) NULL,
    [RowStatus]                    BIT            CONSTRAINT [DF_CatCommercialSegment_RowStatus] DEFAULT ('TRUE') NOT NULL,
    [TokenCreated]                 NVARCHAR (50)  NOT NULL,
    [DateCreated]                  DATETIME       NOT NULL,
    [TokenUpdated]                 NVARCHAR (50)  NULL,
    [DateUpdated]                  DATETIME       NULL,
    CONSTRAINT [PK_CatCommercialSegment] PRIMARY KEY CLUSTERED ([IdCommercialSegment] ASC)
);

