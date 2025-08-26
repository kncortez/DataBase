---Juan Ramirez
---FDAPI-4143
---Valores para CatArticleSAP
BEGIN TRY
    BEGIN TRANSACTION;

    USE DeliveryBackOffice;

    --CatArticleSAP con valores de GT
    INSERT INTO CatArticleSAP
          (CatCategoryArticleSAPId, 
           [Name], 
           [Description], 
           SAPCode, 
           RowSatus, 
           TokenCreated, 
           DateCreated, 
           TokenUpdated, 
           DateUpdated, 
           Category, 
           Price, 
           CardPercent, 
           CardAmount, 
           IsSurcharge, 
           SendAlmacenExp, 
           IdCountry)
    SELECT CatCategoryArticleSAPId, 
           [Name], 
           [Description], 
           SAPCode, 
           RowSatus, 
           'SYS-JRAMIREZ', 
           GETDATE(), 
           NULL, 
           NULL, 
           Category, 
           Price, 
           CardPercent, 
           CardAmount, 
           IsSurcharge, 
           SendAlmacenExp, 
           'SV'
      FROM CatArticleSAP WITH(NOLOCK)
     WHERE IdCountry IS NULL
       AND RowSatus = 1
     ORDER BY 1 DESC

    SELECT *
      FROM CatArticleSAP WITH(NOLOCK)
     WHERE IdCountry = 'SV'
       AND RowSatus = 1
     ORDER BY 1 DESC

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;