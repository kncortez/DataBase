BEGIN TRY
    BEGIN TRANSACTION

      IF NOT EXISTS (
          SELECT 1
          FROM sys.indexes i
          INNER JOIN sys.objects o
              ON i.object_id = o.object_id
          WHERE i.name = 'IDX_DOD_StationId_UserCreated'
            AND o.name = 'DeliveryOrderDetail'
      )
      BEGIN
          CREATE NONCLUSTERED INDEX IDX_DOD_StationId_UserCreated
          ON dbo.DeliveryOrderDetail (StationId, UserCreated);
      
          PRINT 'Índice IDX_DOD_StationId_UserCreated creado correctamente';
      END
      ELSE
      BEGIN
          PRINT 'El índice IDX_DOD_StationId_UserCreated ya existe';
    
      END
    
      COMMIT TRANSACTION
      PRINT 'Actualización realizada correctamente.'
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION

    PRINT 'Ocurrió un error al ejecutar la actualización.'
    PRINT ERROR_MESSAGE()
END CATCH