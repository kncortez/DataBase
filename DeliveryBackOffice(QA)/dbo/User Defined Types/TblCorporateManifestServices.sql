CREATE TYPE [dbo].[TblCorporateManifestServices] AS TABLE (
    [GuideSerie]     NVARCHAR (10) NOT NULL,
    [GuideNumber]    INT           NOT NULL,
    [ManifestSerie]  NVARCHAR (10) NOT NULL,
    [ManifestNumber] INT           NOT NULL);

