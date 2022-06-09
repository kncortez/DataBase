CREATE PROCEDURE [dbo].[RevalueIgss]
AS
BEGIN
    DECLARE @Token NVARCHAR(50) = N'REVALUE-GOB-JOB';
    DECLARE @IdModule INT = 33;

    --DROP TABLE #RevalueGuides

    IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL
        DROP TABLE #RevalueGuides;

    CREATE TABLE #RevalueGuides
    (
        fila INT,
        Guide_Serie NVARCHAR(2),
        Guide_Number INT
    );

    CREATE NONCLUSTERED INDEX tempFila ON #RevalueGuides (fila);

    INSERT INTO #RevalueGuides
    (
        fila,
        Guide_Serie,
        Guide_Number
    )
    SELECT ROW_NUMBER() OVER (ORDER BY ord.Guide_Number ASC) AS fila,
           ord.Guide_Serie,
           ord.Guide_Number
    FROM dbo.DeliveryOrder ord WITH (NOLOCK)
        LEFT JOIN dbo.VisitPointClient vpc WITH (NOLOCK)
            ON vpc.CodeOfReference = ord.Sender_ID
        LEFT JOIN dbo.invoiceDetail ivd WITH (NOLOCK)
            ON ivd.dti_fk_orderSerie = ord.Guide_Serie
               AND ivd.dti_fk_orderNumber = ord.Guide_Number
        LEFT JOIN dbo.RatebyCustomer rbc WITH (NOLOCK)
            ON rbc.RbcCodeOfReference = vpc.CodeOfReference
               AND rbc.RbcIdCustomer = ISNULL(ord.IdCustomer, vpc.CustomerID)
    WHERE CONVERT(DATE, ord.DateCreated)
          BETWEEN '2022-04-01' AND CONVERT(DATE, GETDATE())
          AND ISNULL(ord.IdCustomer, vpc.CustomerID) IN ( 1 )
          AND ivd.dti_fk_header IS NULL
          AND ord.PriceShippment IS NULL;



    DECLARE @count INT = 1;
    DECLARE @RevalueSerie VARCHAR(10);
    DECLARE @RevalueGuide INT;
    DECLARE @IdMax INT =
            (
                SELECT MAX(fila)FROM #RevalueGuides
            );
    DECLARE @RC INT;

    WHILE @count <= @IdMax
    BEGIN

        PRINT '************************revalue**********************';
        PRINT CONVERT(VARCHAR(100), GETDATE(), 9);
        PRINT @RevalueSerie;
        PRINT @RevalueGuide;
        PRINT @count;
        SELECT @RevalueSerie = rv.Guide_Serie,
               @RevalueGuide = rv.Guide_Number
        FROM #RevalueGuides rv
        WHERE rv.fila = @count;

        EXECUTE @RC = DeliveryBackOffice.dbo.spws_revalue_guide @GuideSerie = @RevalueSerie,
                                                                @GuideNumber = @RevalueGuide,
                                                                @CodeApp = '',
                                                                @Format = 'Non',
                                                                @CalculateTaxes = 'true',
                                                                @IdModule = @IdModule,
                                                                @SetUpdate = 'true',
                                                                @Token = @Token,
                                                                @IsReturn = 'false';
        SET @count = @count + 1;

    END;

    IF OBJECT_ID('tempdb.dbo.#RevalueGuides', 'U') IS NOT NULL
        DROP TABLE #RevalueGuides;
END;