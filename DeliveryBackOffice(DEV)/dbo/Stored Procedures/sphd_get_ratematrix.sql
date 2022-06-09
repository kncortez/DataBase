-- =============================================
-- Author:		<Alberto, Ixchop>
-- Create date: <2022-01-04>
-- Description:	<Obtiene la matriz de tarifas de un tipo de servicio (SDD,NDD,TDA)>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_get_ratematrix]
	@RATEID INT,
	--@TYPESERVICE INT
	@TypeService VARCHAR(3)
AS
BEGIN
	BEGIN TRY

    DECLARE @idTypeService INTEGER=(SELECT CtsId FROM DBO.CatTypeService WHERE CtsShortName=UPPER(@TypeService));
    IF @idTypeService IS NULL
        RAISERROR(N'No existe el tipo de servicio especificado', 10, -1)
    DECLARE @RATEIDSTRING NVARCHAR= CONVERT(Nvarchar(MAX), @RATEID);
    DECLARE @TYPESERVICESTRING NVARCHAR =CONVERT(Nvarchar(MAX), @idTypeService );
    DECLARE @sql NVARCHAR(MAX)--A QUERY ARMED BY A STRING WILL BE SAVED HERE
    --Sending header list
    SELECT h1.IdHubLogistic IdHub, h1.HubAbbreviation Hub FROM dbo.HubLogistics h1
        WHERE h1.HubStatus=1
        ORDER BY h1.IdHubLogistic;
    ----------------    
    --START BUILDING STRING WITH HUBS HEADER FOR SQL QUERY
    DECLARE @DinamicHeadersText NVARCHAR (max)
    SET @DinamicHeadersText = '';
    SELECT @DinamicHeadersText = 
        (@DinamicHeadersText +  ',MAX(CASE WHEN seq = '+[IdHubDestiny]+' THEN  RateValue END) '''+[IdHubDestiny]+'''
        ')
    FROM (
        SELECT CONVERT(NVARCHAR(MAX), hl.IdHubLogistic )[IdHubDestiny]
            ,CONVERT(NVARCHAR(MAX), ROW_NUMBER() OVER(ORDER BY IdHubLogistic ASC)  ) rownum  
                FROM dbo.HubLogistics hl WHERE HubStatus=1        
    )HEADERS
    -----------------
    --START ARMING SQL QUERY
    SET @sql =
        '
		SELECT   
			[IdHubSource] IdHub,
			[HubAbr] HubAbr
		';
    SET @sql = @sql+@DinamicHeadersText;
    SET @sql =(@sql+
				'
		    FROM (
                SELECT hbo.HubAbbreviation HubAbr ,hbo.IdHubLogistic [IdHubSource],hbd.IdHubLogistic [IdHubDestiny],rd.RateValue [RateValue]
		            ,hbd.IdHubLogistic seq
		        FROM HubLogistics hbo
		        	LEFT JOIN dbo.RateData rd
		        		ON hbo.IdHubLogistic = rd.HubSourceId AND rd.RateId = '+@RATEIDSTRING+' AND  RD.TypeServiceId='+@TYPESERVICESTRING+'
		        		AND rd.ArticleId IS NULL
		        		AND rd.TypeSegmentId IS NULL
		        		AND rd.HubSourceId is not null and rd.HubDestinyId is not null 
		        		AND rd.RowStatus=1
                    LEFT JOIN dbo.CatTypeService ct
                        ON ct.CtsId = rd.TypeServiceId
                    LEFT JOIN dbo.CatRateSegment sg
                        ON sg.CrsId = rd.TypeSegmentId
                    LEFT JOIN dbo.HubLogistics hbd
                        ON hbd.IdHubLogistic = rd.HubDestinyId
		        	where hbo.HubStatus=1 

		    )M GROUP BY IdHubSource,HubAbr
		');
    EXEC SP_EXECUTESQL @sql
    PRINT @sql
	END TRY    
	BEGIN CATCH  
			SELECT 'FALSE'	[blnResult]
				,CAST(ERROR_NUMBER() AS VARCHAR) AS [ErrorNumber]
				,CAST(ERROR_SEVERITY() AS VARCHAR) AS [ErrorSeverity]
				,CAST(ERROR_STATE() AS VARCHAR) AS [ErrorState]
				,CAST(ERROR_PROCEDURE() AS VARCHAR) AS [ErrorProcedure]
				,CAST(ERROR_LINE() AS VARCHAR) AS [ErrorLine]  
				,CAST(ERROR_MESSAGE() AS NVARCHAR(MAX)) AS [Message];  
			ROLLBACK TRANSACTION;  
	END CATCH;      

END
