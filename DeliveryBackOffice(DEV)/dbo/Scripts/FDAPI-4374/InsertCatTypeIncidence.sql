BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (
        SELECT 1 
        FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] 
        WHERE [NameIncidence] = 'El destinatario cambio de residencia'
        AND [CountryId] = 'HN'
    )
    BEGIN
        INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
            ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],
                [TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],
                [IsForcedIncidence],[ValidatesLocation],[HasConfirmationProcess],[NotifiesOrigin],
                [NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
        VALUES
            ('El destinatario cambio de residencia','El destinatario cambio de residencia',1,'SYS-TGARCIA',GETDATE(),
                NULL,NULL,'DELIVERY',1,NULL,1,1,0,1,1,NULL,1,NULL,'HN');
    END;


    IF NOT EXISTS (
        SELECT 1 
        FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] 
        WHERE [NameIncidence] = 'Zona roja o inaccesible'
        AND [CountryId] = 'HN'
    )
    BEGIN
        INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
            ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],
                [TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],
                [IsForcedIncidence],[ValidatesLocation],[HasConfirmationProcess],[NotifiesOrigin],
                [NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
        VALUES
            ('Zona roja o inaccecible','Zona roja o inaccesible',1,'SYS-TGARCIA',GETDATE(),
                NULL,NULL,'DELIVERY',1,NULL,1,1,0,1,1,NULL,1,NULL,'HN');
    END;


    IF NOT EXISTS (
        SELECT 1 
        FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] 
        WHERE [NameIncidence] = 'Destinatario no localizado'
        AND [CountryId] = 'HN'
    )
    BEGIN
        INSERT INTO [DeliveryBackOffice].[dbo].[CatTypeIncidence]
            ([NameIncidence],[DescriptionIncidence],[RowStatus],[TokenCreated],[DateCreated],
                [TokenUpdated],[DateUpdated],[ServiceType],[OrderId],[Code],[IncidenceClasificationId],
                [IsForcedIncidence],[ValidatesLocation],[HasConfirmationProcess],[NotifiesOrigin],
                [NameIncidencePublic],[EvidenceRequirement],[CourierInstructions],[CountryId])
        VALUES
            ('Destinatario no localizado','Destinatario no localizado',1,'SYS-TGARCIA',GETDATE(),
                NULL,NULL,'DELIVERY',1,NULL,1,1,0,1,1,NULL,1,NULL,'HN');
    END;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;