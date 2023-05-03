



-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-11>
-- Description:	<Recotizacion>
-- =============================================


CREATE PROCEDURE [dbo].[GetCourierPhoneToken]
    -- Add the parameters for the stored procedure here
    @Phone NVARCHAR(20) = '48119415',
    @Token VARCHAR(MAX) = '21a31fd231as23d1f21ads'
AS
BEGIN
	SET @Phone = (SELECT Phone FROM dbo.SenderReceiver WHERE UniqueCode = @Phone )

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @GuideRegexData NVARCHAR(500) =
            (
                SELECT TOP 1
                       CP.[Value]
                FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH (NOLOCK)
                WHERE CP.[Name] = 'GuideRegex' COLLATE Latin1_General_CI_AI
            );

    DECLARE @GuideRegexScannerData NVARCHAR(500) =
            (
                SELECT TOP 1
                       CP.[Value]
                FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH (NOLOCK)
                WHERE CP.[Name] = 'GuideRegexScanner' COLLATE Latin1_General_CI_AI
            );

    DECLARE @jsonResult NVARCHAR(MAX);

    -- insertar en tabla temporal posbibles mensajes de respuesta

    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;
    SELECT *
    INTO #responsemessage
    FROM
    (
        SELECT 200 AS IdResult,
               'Estado  cambiado correctamente' AS Message,
               'OK' AS Id
        UNION
        SELECT 500 AS IdResult,
               'Error faltal intente de nuevo mas tarde' AS Message,
               'Transac' AS Id
    ) AS errror;

    BEGIN TRANSACTION;
    BEGIN TRY
        -------------------------------------------------------------------------------------------------------------------------
        DECLARE @pheon INT =
                (
                    SELECT TOP 1 ID FROM SenderReceiver WHERE Phone LIKE '%' + @Phone + '%'
                );

        DECLARE @TokenInavt VARCHAR(MAX) =
                (
                    SELECT TOP 1
                           LogTokenPOD
                    FROM LogTokenPOD WITH (NOLOCK)
                    WHERE IdCourierman = @pheon
                          AND RowStatus = 1
                    ORDER BY DateCreated DESC
                );

        UPDATE LogTokenPOD
        SET RowStatus = 0
        WHERE LogTokenPOD = @TokenInavt;
        ------------------------------------------------------------------------------------------------------------------------

        DECLARE @phon VARCHAR(10) =
                (
                    SELECT TOP 1
                           ID
                    FROM SenderReceiver WITH (NOLOCK)
                    WHERE Phone LIKE '%' + @Phone + '%'
                );


        INSERT INTO dbo.LogTokenPOD
        (
            LogTokenPOD,
            IdCourierman,
            RowStatus,
            DateCreated,
            DateUpdate
        )
        VALUES
        (@Token, @phon, 1, GETDATE(), NULL);

        DECLARE @jsonResult1 NVARCHAR(MAX);

        --CONVERT(varchar,@Existingdate,3) as [DD/MM/YY]
        DECLARE @DefaultEmail NVARCHAR(50) =
                (
                    SELECT ISNULL(cf.Value, '')
                    FROM dbo.ConfigParams cf
                    WHERE cf.Name = 'BillingEmailCAPP'
                );

        DECLARE @DefaultPickupManifestEmail NVARCHAR(50) =
                (
                    SELECT ISNULL(cf.Value, '')
                    FROM dbo.ConfigParams cf
                    WHERE cf.Name = 'PickUpManifestEmailCAPP'
                );

        SET @jsonResult1 =
        (
            SELECT STUFF(
                            (
                                SELECT TOP 1
                                       ',{"IdCourier":"'
                                       + CONVERT(VARCHAR, ISNULL(CONVERT(VARCHAR(10), pod.IdCourierman), 'N/A')) + '",'
                                       + '"DateToken":"' + ISNULL(CONVERT(VARCHAR, pod.DateCreated, 23), 'N/A') + '",'
                                       + '"FirstName":"' + ISNULL(CONVERT(VARCHAR, sr.First_Name), 'N/A') + '",'
                                       + '"LastName":"' + ISNULL(CONVERT(VARCHAR, sr.Last_Name), 'N/A') + '",'
                                       + '"Vehicle":"' + ISNULL(CONVERT(VARCHAR, vh.Plate), 'N/A') + '",' + '"Route":"'
                                       + ISNULL(CONVERT(VARCHAR, cr.CodeRoute), 'N/A') + '",' + '"GuideRegex":"'
                                       + ISNULL(CONVERT(VARCHAR(500), @GuideRegexData), '')
                                       + '",' -- Para validar solo los digitos de la guía
                                       + '"GuideRegexEscaner":"'
                                       + ISNULL(CONVERT(VARCHAR(500), @GuideRegexScannerData), '')
                                       + '",' -- Para el input del escaner de la courier
                                       + '"BillingEmail":"' + ISNULL(CONVERT(VARCHAR(50), @DefaultEmail), 'N/A') + '",'
                                       + '"PickUpManifestEmail":"'
                                       + ISNULL(CONVERT(VARCHAR(50), @DefaultPickupManifestEmail), 'N/A') + '",'
                                       + '"Token":"' + ISNULL(LogTokenPOD, '') + +'"}'
                                FROM LogTokenPOD pod WITH (NOLOCK)
                                    INNER JOIN SenderReceiver sr WITH (NOLOCK)
                                        ON (sr.ID = pod.IdCourierman)
                                    LEFT JOIN dbo.RouteAssigment ras WITH (NOLOCK)
                                        ON ras.IdCurrierMan = sr.ID
                                           AND DateOfRoute = CONVERT(DATE, GETDATE())
                                    LEFT JOIN dbo.CatVehicle vh WITH (NOLOCK)
                                        ON vh.IdVehicle = ras.IdVehicle
                                    LEFT JOIN dbo.CatRoute cr WITH (NOLOCK)
                                        ON cr.IdRoute = ras.IdRoute
                                WHERE LogTokenPOD = @Token
                                ORDER BY 1 DESC
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
        PRINT 'ingresa2';
        PRINT @jsonResult;


        --select * from SenderReceiver
        --where Phone like '%55832214%'

        --select * from LogTokenPOD

        -- retornar resultado en formato json
        IF @jsonResult1 IS NULL
        BEGIN

            SET @jsonResult1 =
            (
                SELECT STUFF(
                                (
                                    SELECT ',{"IdResult":204,' + '"Message":" No se encontraron registros"}'
                                    FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            )
            );
        END;

        SELECT ('[' + @jsonResult1 + ']') jsonResult1;



        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"' + Message
                                       + '"}'
                                FROM #responsemessage
                                WHERE Id = 'OK'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE();
        -- retornar mensaje de error
        SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT '"IdResult":' + CONVERT(VARCHAR, IdResult) + ',' + '"Message":"'
                                       + CONVERT(NVARCHAR(MAX), ERROR_MESSAGE()) + '"}'
                                FROM #responsemessage
                                WHERE Id = 'Invalid'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END CATCH;
    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;

    END;

    -- destruir tablas temporales

    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;

    -- retornar resultado en formato json

    SELECT ('[' + @jsonResult + ']') jsonResult;

END;



