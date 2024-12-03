-- =============================================
-- Author:      <Daniel Ramirez>
-- Create date: <2024-11-25>
-- Description: <Crear tipo TblBillingGuideDetail>
-- =============================================
CREATE TYPE TblBillingGuideDetail AS TABLE (
    IdVisitPointClient INT,
    GuideSerie         NVARCHAR(2),
    GuideNumber        INT
);