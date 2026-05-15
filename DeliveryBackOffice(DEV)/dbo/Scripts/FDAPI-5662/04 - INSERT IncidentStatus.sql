use DeliveryBackOffice

BEGIN TRY

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.IncidentStatus WITH (NOLOCK)
        WHERE [Name] = 'Pending'
    )
    BEGIN
        INSERT INTO DeliveryBackOffice.dbo.IncidentStatus
        ([Name], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated], [RowStatus])
        VALUES('Pending', GETDATE(), 'SYS-EHERNANDEZ', NULL, NULL, 1);
    END
    ELSE
    BEGIN
         PRINT 'Estado Pending ya existe'
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.IncidentStatus WITH (NOLOCK)
        WHERE [Name] = 'In Progress'
    )
    BEGIN
        INSERT INTO DeliveryBackOffice.dbo.IncidentStatus
        ([Name], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated], [RowStatus])
        VALUES('In Progress', GETDATE(), 'SYS-EHERNANDEZ', NULL, NULL, 1);
    END
    ELSE
    BEGIN
         PRINT 'Estado In Progress ya existe'
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.IncidentStatus WITH (NOLOCK)
        WHERE [Name] = 'Resolved'
    )
    BEGIN
        INSERT INTO DeliveryBackOffice.dbo.IncidentStatus
        ([Name], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated], [RowStatus])
        VALUES('Resolved', GETDATE(), 'SYS-EHERNANDEZ', NULL, NULL, 1);
    END
    ELSE
    BEGIN
         PRINT 'Estado Resolved ya existe'
    END

    IF NOT EXISTS
    (
        SELECT 1
        FROM DeliveryBackOffice.dbo.IncidentStatus WITH (NOLOCK)
        WHERE [Name] = 'Cancelled'
    )
    BEGIN
        INSERT INTO DeliveryBackOffice.dbo.IncidentStatus
        ([Name], [DateCreated], [TokenCreated], [DateUpdated], [TokenUpdated], [RowStatus])
        VALUES('Cancelled', GETDATE(), 'SYS-EHERNANDEZ', NULL, NULL, 1);
    END
    ELSE
    BEGIN
         PRINT 'Estado Cancelled ya existe'
    END

END TRY
BEGIN CATCH

    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;

END CATCH;