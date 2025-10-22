--SELECT * FROM dbo.CatRateSegment WITH (NOLOCK)

DECLARE @Token NVARCHAR(25) = 'SYS-WOROZCO'
DECLARE @IdCountry NVARCHAR(2) = 'SV'
DECLARE @Country NVARCHAR(55) = (SELECT CountryNameES FROM DeliveryBackOffice.dbo.CatCountry WITH(NOLOCK) WHERE IdCountry = @IdCountry)

BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO [dbo].[CatRateSegment]
           ([CrsName],[CrsShortName],[CrsDescription],[CrsRowStatus],[CrsTokenCreated],[CrsDateCreated],[CrsTokenUpdated],[CrsDateUpdated])
     VALUES
           ('METRO ' + @IdCountry,'ME' + LEFT(@IdCountry, 1),'Metro ' + @Country,1,@Token,GETDATE(),NULL,NULL),
           ('LOCAL ' + @IdCountry,'LO' + LEFT(@IdCountry, 1),'Local ' + @Country,1,@Token,GETDATE(),NULL,NULL),
           ('DEPARTAMENTAL ' + @IdCountry,'DE' + LEFT(@IdCountry, 1),'Departamental ' + @Country,1,@Token,GETDATE(),NULL,NULL),
           ('REGIONAL ' + @IdCountry,'RE' + LEFT(@IdCountry, 1),'Regional ' + @Country,1,@Token,GETDATE(),NULL,NULL),
           ('ESPECIAL ' + @IdCountry,'ES' + LEFT(@IdCountry, 1),'Especial ' + @Country,1,@Token,GETDATE(),NULL,NULL),
           ('NACIONAL ' + @IdCountry,'NA' + LEFT(@IdCountry, 1),'Nacional ' + @Country,1,@Token,GETDATE(),NULL,NULL);
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;

    -- Manejo de errores con PRINT
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
