BEGIN TRY
    BEGIN TRAN;

	IF NOT EXISTS (SELECT 1 FROM sys.types WHERE name = 'TblBuyerInfo')
    BEGIN
        PRINT 'creando type TblBuyerInfo...';
        CREATE TYPE [dbo].[TblBuyerInfo] AS TABLE
        (
             DistrictCode          VARCHAR (100) NULL,
             StateCode             VARCHAR (100) NULL,
             ActivityCode          VARCHAR (100) NULL,
             ActivityDescription   VARCHAR (500) NULL,
             NRC                   VARCHAR (20) NULL,
             TypeDocument          VARCHAR (100) NULL,
             IdDocument            VARCHAR (100) NULL,
             Phone                 VARCHAR (100) NULL,
             OperationConditionCode       INT           NULL
        )
        END;
     ELSE
     BEGIN
          PRINT 'Tipo TblBuyerInfo creado';
    END;
	COMMIT TRAN;
    PRINT 'Proceso completado con éxito.';

END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK;

    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT 'ERROR: ' + @Err;
    THROW;
END CATCH;

