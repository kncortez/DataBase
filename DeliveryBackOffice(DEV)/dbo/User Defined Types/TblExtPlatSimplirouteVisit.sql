CREATE TYPE [dbo].[TblExtPlatSimplirouteVisit] AS TABLE (
    [IdService]            INT              NOT NULL,
    [GuideSerie]           NVARCHAR (2)     NULL,
    [GuideNumber]          INT              NULL,
    [TrackingData]         NVARCHAR (150)   NULL,
    [Plan]                 NVARCHAR (50)    NULL,
    [Route]                NVARCHAR (50)    NULL,
    [Order]                INT              NULL,
    [Address]              NVARCHAR (200)   NOT NULL,
    [Latitude]             DECIMAL (18, 15) NOT NULL,
    [Longitude]            DECIMAL (18, 15) NOT NULL,
    [driver]               NVARCHAR (50)    NULL,
    [vehicle]              NVARCHAR (50)    NULL,
    [observation]          NVARCHAR (200)   NULL,
    [IsIncluded]           BIT              NOT NULL,
    [IsDelivery]           BIT              NOT NULL,
    [ServiceStatus]        NVARCHAR (30)    NULL,
    [EstimatedTimeArrival] DATETIME         NULL);

