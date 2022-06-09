CREATE TYPE [dbo].[TblCourierLocation] AS TABLE (
    [CourierPhone]           NVARCHAR (10) NOT NULL,
    [CourierLatitude]        NVARCHAR (20) NOT NULL,
    [CourierLongitude]       NVARCHAR (20) NOT NULL,
    [VehicleType]            INT           NULL,
    [VehicleTypeDescription] NVARCHAR (50) NULL);

