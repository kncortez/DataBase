SET NOCOUNT ON;

BEGIN TRY

    -- Cambiar datos según lo requerido
    DECLARE @TokenCreated NVARCHAR(20) = 'SYS-TGARCIA'
    DECLARE @AeropostID INT = 95591;
    DECLARE @CodeOfReference INT = 1666202;

    INSERT INTO [dbo].[APExecutionSchedule]
            ([CountryCode]
            ,[StartTime]
            ,[Description]
            ,[AeroPostIdByCountry]
            ,[CodeOfReference]
            ,[RowStatus]
            ,[TokenCreated]
            ,[DateCreated]
            ,[TokenUpdated]
            ,[DateUpdated])
    SELECT * FROM (
        VALUES
            ('HN','02:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','04:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','06:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','07:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','08:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','09:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','10:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','11:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','12:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','13:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','14:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','15:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','16:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','17:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','18:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','20:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','22:00','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL),
            ('HN','23:59','Horiario de HN',@AeropostID,@CodeOfReference,1,@TokenCreated,GETDATE(),NULL,NULL)
    ) AS SourceData(CountryCode, StartTime, Description, AeroPostIdByCountry, CodeOfReference, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
    WHERE NOT EXISTS (
        SELECT 1 
        FROM [dbo].[APExecutionSchedule] WITH(NOLOCK)
        WHERE CountryCode = SourceData.CountryCode 
        AND StartTime = SourceData.StartTime
        AND AeroPostIdByCountry = SourceData.AeroPostIdByCountry
    );

    DECLARE @CountAPExecution INT = @@ROWCOUNT;
    PRINT 'APExecutionSchedule: ' + CAST(@CountAPExecution AS VARCHAR) + ' nuevos registros insertados.';

    INSERT INTO [dbo].[ConfigParams]
            ([Name],[Description],[Value],[Status],[CreateDate],[IdCountry],[IdCurrencyCOD])
    SELECT * FROM (
        VALUES
            ('AeropostApiHeaders','Authorization','Bearer 146|7H6yZAXoqqxF9mxAIhUyu3IPLd07Ut7Yag7D9TKK7f475d8e',1,GETDATE(),'HN',NULL),
            ('AeropostApiHeaders','Accept','application/json',1,GETDATE(),'HN',NULL)
    ) AS SourceData([Name],[Description],[Value],[Status],[CreateDate],[IdCountry],[IdCurrencyCOD])
    WHERE NOT EXISTS (
        SELECT 1 
        FROM [dbo].[ConfigParams] WITH(NOLOCK)
        WHERE [Name] = SourceData.[Name]
        AND [Description] = SourceData.[Description]
        AND [IdCountry] = SourceData.[IdCountry]
    );

    DECLARE @CountConfigParams INT = @@ROWCOUNT;
    PRINT 'ConfigParams: ' + CAST(@CountConfigParams AS VARCHAR) + ' nuevos registros insertados.';

    INSERT INTO [dbo].[CatSystem]
            ([SysNameSystem],[SysPlataform],[SysDescription],[SysRowStatus],[SysTokenCreated],[SysDateCreated],[SysTokenUpdated],[SysDateUpdated])
    SELECT * FROM (
        VALUES
            ('Aeropost Service','Aeropost Service','Servicio Worker para creación de guías Aeropost',1,@TokenCreated,GETDATE(),NULL,NULL)
    ) AS SourceData([SysNameSystem],[SysPlataform],[SysDescription],[SysRowStatus],[SysTokenCreated],[SysDateCreated],[SysTokenUpdated],[SysDateUpdated])
    WHERE NOT EXISTS (
        SELECT 1 
        FROM [dbo].[CatSystem] WITH(NOLOCK)
        WHERE [SysNameSystem] = SourceData.[SysNameSystem]
    );

    DECLARE @CountCatSystem INT = @@ROWCOUNT;
    PRINT 'CatSystem: ' + CAST(@CountCatSystem AS VARCHAR) + ' nuevos registros insertados.';

    INSERT INTO [dbo].[CatModule]
            ([ModName],[ModIdModuleParent],[ModPath],[ModDescription],[ModOrder],[ModMetadata],[ModVisible],[ModRowStatus],[ModTokenCreated],[ModDateCreated],[ModTokenUpdated],[ModDateUpdated],[ModGroup])
    SELECT * FROM (
        VALUES
            ('Aeropost Service',NULL,'Aeropost Service','Servicio Worker para creación de guías Aeropost',1,NULL,1,1,@TokenCreated,GETDATE(),NULL,NULL,NULL)
    ) AS SourceData([ModName],[ModIdModuleParent],[ModPath],[ModDescription],[ModOrder],[ModMetadata],[ModVisible],[ModRowStatus],[ModTokenCreated],[ModDateCreated],[ModTokenUpdated],[ModDateUpdated],[ModGroup])
    WHERE NOT EXISTS (
        SELECT 1 
        FROM [dbo].[CatModule] WITH(NOLOCK)
        WHERE [ModName] = SourceData.[ModName]
    );

    DECLARE @CountCatModule INT = @@ROWCOUNT;
    PRINT 'CatModule: ' + CAST(@CountCatModule AS VARCHAR) + ' nuevos registros insertados.';

    INSERT INTO [dbo].[APRegionGuides]
            ([City],[Region],[CountryCode],[IdTownship],[HeaderCode],[RowStatus],[TokenCreated],[DateCreated])
    SELECT * FROM (
        VALUES
            ('San Pedro de Copan','Copan','HN',404,'H0420',1,@TokenCreated,GETDATE())
    ) AS SourceData([City],[Region],[CountryCode],[IdTownship],[HeaderCode],[RowStatus],[TokenCreated],[DateCreated])
    WHERE NOT EXISTS (
        SELECT 1 
        FROM [dbo].[APRegionGuides] WITH(NOLOCK)
        WHERE [City] = SourceData.[City]
        AND [Region] = SourceData.[Region]
        AND [CountryCode] = SourceData.[CountryCode]
        AND [IdTownship] = SourceData.[IdTownship]
        AND [HeaderCode] = SourceData.[HeaderCode]
    );

    DECLARE @CountAPRegionGuides INT = @@ROWCOUNT;
    PRINT 'APRegionGuides: ' + CAST(@CountAPRegionGuides AS VARCHAR) + ' nuevos registros insertados.';

    PRINT '=== RESUMEN FINAL ==='
    PRINT 'APExecutionSchedule: ' + CAST(@CountAPExecution AS VARCHAR) + ' registros'
    PRINT 'ConfigParams: ' + CAST(@CountConfigParams AS VARCHAR) + ' registros'
    PRINT 'CatSystem: ' + CAST(@CountCatSystem AS VARCHAR) + ' registros'
    PRINT 'CatModule: ' + CAST(@CountCatModule AS VARCHAR) + ' registros'
    PRINT 'APRegionGuides: ' + CAST(@CountAPRegionGuides AS VARCHAR) + ' registros'
    PRINT 'Total de nuevos registros insertados: ' + CAST((@CountAPExecution + @CountConfigParams + @CountCatSystem + @CountCatModule + @CountAPRegionGuides) AS VARCHAR)

END TRY
BEGIN CATCH
    DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT;
    SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY();
    RAISERROR('Error ejecutando el script: %s', @ErrSeverity, 1, @ErrMsg);
END CATCH;
