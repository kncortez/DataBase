CREATE TYPE [dbo].[TblExtPlatSimpliroutePickup] AS TABLE (
    [IdService]            INT              NOT NULL,
    [ServiceId]            INT              NOT NULL,
    [TrackingData]         NVARCHAR (150)   NULL,
    [PlanData]             NVARCHAR (50)    NULL,
    [RouteId]              NVARCHAR (50)    NULL,
    [OrderNo]              NVARCHAR (50)    NULL,
    [AddressData]          NVARCHAR (200)   NOT NULL,
    [Latitude]             DECIMAL (18, 15) NOT NULL,
    [Longitude]            DECIMAL (18, 15) NOT NULL,
    [Driver]               NVARCHAR (50)    NULL,
    [Vehicle]              NVARCHAR (50)    NULL,
    [Observation]          NVARCHAR (200)   NULL,
    [IsIncluded]           BIT              NOT NULL,
    [IsDelivery]           BIT              NOT NULL,
    [ServiceStatus]        NVARCHAR (30)    NULL,
    [EstimatedTimeArrival] DATETIME         NULL,
    PRIMARY KEY CLUSTERED ([IdService] ASC));

