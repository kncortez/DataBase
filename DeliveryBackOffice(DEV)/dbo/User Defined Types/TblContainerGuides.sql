CREATE TYPE [dbo].[TblContainerGuides] AS TABLE (
    [GuideSerie]                            NVARCHAR (2)    NULL,
    [GuideNumber]                           INT             NULL,
    [TicketNumber]                          NVARCHAR (150)  NULL,
    [IdCustomer]                            INT
);