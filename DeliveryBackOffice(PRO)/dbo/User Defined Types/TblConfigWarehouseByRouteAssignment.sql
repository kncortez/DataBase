CREATE TYPE [dbo].[TblConfigWarehouseByRouteAssignment] AS TABLE (
    [RouteAssignmentId]            INT           NOT NULL,
    [WarehouseLocation]            NVARCHAR (30) NOT NULL,
    [WarehouseLocationServiceType] NVARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([RouteAssignmentId] ASC, [WarehouseLocationServiceType] ASC));

