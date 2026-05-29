BEGIN TRY
    IF COL_LENGTH('dbo.WorkflowStatusMap', 'CountryId') > 0 AND COL_LENGTH('dbo.WorkflowStatusMap', 'WorkflowStatusMapId') > 0
    BEGIN
        -- Step 1: Drop existing PK
        ALTER TABLE DeliveryBackOffice.dbo.WorkflowStatusMap
        DROP CONSTRAINT PK_WorkflowStatusMap;

        -- Step 2: Drop identity column
        ALTER TABLE DeliveryBackOffice.dbo.WorkflowStatusMap
        DROP COLUMN WorkflowStatusMapId;

        -- Step 3: Drop default country GT
        ALTER TABLE DeliveryBackOffice.dbo.WorkflowStatusMap
        DROP CONSTRAINT DF_WorkflowStatusMap_CountryId;

        -- Step 4: Create the new PK
        ALTER TABLE DeliveryBackOffice.dbo.WorkflowStatusMap
        ADD CONSTRAINT PK_WorkflowStatusMap 
        PRIMARY KEY (WorkflowId, StatusOrderId, CountryId);

        -- Step 5: Drop index on columns WorkflowId and StatusOrderId
        DROP INDEX UQ_WorkflowStatusMap_Workflow_Status_Active ON DeliveryBackOffice.dbo.WorkflowStatusMap;

        PRINT 'Migración completada'
    END
    ELSE
    BEGIN
        PRINT 'No existen las columnas WorkflowStatusMapId y/o CountryId.'
    END

END TRY
BEGIN CATCH
    PRINT 'Error: ' + ERROR_MESSAGE();
    THROW;
END CATCH;