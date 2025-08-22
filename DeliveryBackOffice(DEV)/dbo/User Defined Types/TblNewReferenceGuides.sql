CREATE TYPE [dbo].[TblNewReferenceGuides] AS TABLE (
    [GuideSerie]                            NVARCHAR (2)    NOT NULL,
    [GuideNumber]                           INT             NOT NULL,
    [TicketNumber]                          NVARCHAR (150)  NOT NULL
);