BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO [DeliveryBackOffice].[dbo].[IncidenceStatusMapping]
           ([StatusOrderId],[IncidenceTypeId],[AttemptNumber],[NewCode],
            [RowStatus],[TokenCreated],[DateCreated],[TokenUpdated],[DateUpdated])
    SELECT v.StatusOrderId, v.IncidenceTypeId, v.AttemptNumber, v.NewCode,
        v.RowStatus, v.TokenCreated, v.DateCreated, v.TokenUpdated, v.DateUpdated
    FROM
    (
        VALUES
            (4,NULL,2,420,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (5,NULL,1,1000,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (5,NULL,2,1000,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (22,NULL,1,1000,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (22,NULL,2,1000,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (14,NULL,1,1210,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (14,NULL,2,1210,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (23,NULL,1,1210,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (23,NULL,2,1210,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (35,NULL,2,1120,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,128,1,702,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,129,1,702,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,132,1,703,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,127,1,705,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,137,1,706,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,135,1,708,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,131,1,708,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,133,1,708,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,134,1,708,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,136,1,708,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,138,1,708,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,130,1,708,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,208,1,709,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,207,1,704,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,206,1,701,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,128,2,1202,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,129,2,1202,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,132,2,1203,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,127,2,1205,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,137,2,1206,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,135,2,1208,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,130,2,1208,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,133,2,1208,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,134,2,1208,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,136,2,1208,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,138,2,1208,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,208,2,1209,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,207,2,1204,1,'SYS-TGARCIA',GETDATE(),NULL,NULL),
            (50,206,2,1201,1,'SYS-TGARCIA',GETDATE(),NULL,NULL)
    ) v (StatusOrderId, IncidenceTypeId, AttemptNumber, NewCode,
        RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
    WHERE NOT EXISTS (
        SELECT 1
        FROM [DeliveryBackOffice].[dbo].[IncidenceStatusMapping] t
        WHERE t.StatusOrderId   = v.StatusOrderId
        AND ISNULL(t.IncidenceTypeId, -1) = ISNULL(v.IncidenceTypeId, -1)
        AND t.AttemptNumber  = v.AttemptNumber
    );

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;