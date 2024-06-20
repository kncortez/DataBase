
-- =============================================
-- Author:		<Cristian,Azurdia>
-- Create date: <2024-06-18>
-- Description:	<Recotizacion>
-- =============================================

CREATE procedure [dbo].[GetCourierPhoneTokenOld]
    -- Add the parameters for the stored procedure here
    @Phone nvarchar(20) = '48119415'
  , @Token varchar(max) = '21a31fd231as23d1f21ads'
  , @LoginToken NVARCHAR(6) = '123456'
  , @IdCountry nvarchar(8) = 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    SET NOCOUNT ON;

    -- insertar en tabla temporal posbibles mensajes de respuesta

    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
    DROP TABLE #responsemessage;

    SELECT	[IdResult]
		  , [Message]
		  , [Id]
	INTO #responsemessage
    FROM
    (
        SELECT 200											as [IdResult]
             , 'Estado  cambiado correctamente'				as [Message]
             , 'OK'											as [Id]
        UNION
        SELECT 500											as [IdResult]
             , 'Error faltal intente de nuevo mas tarde'	as [Message]
             , 'Transac'									as [Id]
    ) as errror;

    BEGIN TRANSACTION;
    BEGIN TRY
        -------------------------------------------------------------------------------------------------------------------------
        DECLARE @phon int =
                (
                    SELECT	TOP 1
							ID
                    FROM	[DeliveryBackOffice].[dbo].[SenderReceiver] with (nolock)
                    WHERE	IdCountry = @IdCountry
						AND	Phone like '%' + @Phone + '%'
                        AND Estatus = 1
                );

        DECLARE @TokenInavt varchar(max) =
                (
                    SELECT TOP 1
                           LogTokenPOD
                    FROM [DeliveryBackOffice].[dbo].[LogTokenPOD] WITH (nolock)
                    WHERE IdCourierman = @phon
                          and RowStatus = 1
                    ORDER BY DateCreated DESC
                );


        UPDATE [DeliveryBackOffice].[dbo].[LogTokenPOD]
        SET RowStatus = 0
        WHERE LogTokenPOD = @TokenInavt;


        ------------------------------------------------------------------------------------------------------------------------

        IF EXISTS
        (
            SELECT 1
            FROM [DeliveryBackOffice].[dbo].[SenderReceiverLoginToken]
            WHERE SenderReceiverId = @phon
                  and LoginToken = @LoginToken
                  and RowStatus = 1
        )
        BEGIN

            UPDATE [DeliveryBackOffice].[dbo].[SenderReceiverLoginToken]
            SET RowStatus = 0
              , DateUpdated = getdate()
              , TokenUpdated = @Token
            WHERE SenderReceiverId = @phon
                  and LoginToken = @LoginToken
                  and RowStatus = 1;

            INSERT INTO [DeliveryBackOffice].[dbo].[LogTokenPOD]
            (
                LogTokenPOD
              , IdCourierman
              , RowStatus
              , DateCreated
              , DateUpdate
            )
            VALUES
            (@Token, @phon, 1, getdate(), null);

			DECLARE @GuideRegexData nvarchar(500) =
					(
					SELECT TOP 1
						   CP.[Value]
					FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP with (nolock)
					WHERE CP.[Name] = 'GuideRegex'
				);

			DECLARE @GuideRegexScannerData nvarchar(500) =
				(
                SELECT TOP 1
                       CP.[Value]
                FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP with (nolock)
                WHERE CP.[Name] = 'GuideRegexScanner'
            );

			--CONVERT(varchar,@Existingdate,3) as [DD/MM/YY]
            DECLARE @DefaultEmail nvarchar(50) =
                    (
                        SELECT isnull(cf.Value, '')
						FROM [DeliveryBackOffice].[dbo].[ConfigParams] cf WITH (NOLOCK)
                        WHERE cf.Name = 'BillingEmailCAPP'
                    );

            DECLARE @DefaultPickupManifestEmail nvarchar(50) =
                    (
                        SELECT isnull(cf.Value, '')
                        FROM [DeliveryBackOffice].[dbo].[ConfigParams] cf WITH (NOLOCK)
                        WHERE cf.Name = 'PickUpManifestEmailCAPP'
                    );

            SELECT	TOP 1
				    isnull(convert(varchar(10), pod.IdCourierman), 'N/A')				[IdCourier]
				  , isnull(convert(varchar, pod.DateCreated, 23), 'N/A')				[TakeToken]
				  , isnull(convert(varchar, sr.First_Name), 'N/A')						[FirstName]
				  , isnull(convert(varchar, sr.Last_Name), 'N/A')						[LastName]
				  , isnull(convert(varchar, vh.Plate), 'N/A')							[Vehicle]
				  , isnull(convert(varchar, cr.CodeRoute), 'N/A')						[Route]
				  , isnull(convert(varchar(500), @GuideRegexData), '')					[GuideRegex]
				  , isnull(convert(varchar(500), @GuideRegexScannerData), '')			[GuideRegexEscaner]
				  , isnull(convert(varchar(50), @DefaultEmail), 'N/A')					[BillingEmail]
				  , isnull(convert(varchar(50), @DefaultPickupManifestEmail), 'N/A')	[PickUpManifestEmail]
				  , isnull(pod.LogTokenPOD, '')											[Token]				
            FROM [dbo].[LogTokenPOD]               pod WITH (NOLOCK)
                INNER JOIN [DeliveryBackOffice].[dbo].[SenderReceiver]  sr  WITH (NOLOCK)
                    ON sr.ID = pod.IdCourierman
                LEFT JOIN [DeliveryBackOffice].[dbo].[RouteAssigment]	ras WITH (NOLOCK)
                    ON	ras.IdCurrierMan = sr.ID
                    AND DateOfRoute = convert(date, getdate())
                LEFT JOIN [DeliveryBackOffice].[dbo].[CatVehicle]		vh  WITH (NOLOCK)
                    ON vh.IdVehicle = ras.IdVehicle
                LEFT JOIN [DeliveryBackOffice].[dbo].[CatRoute]			cr  WITH (NOLOCK)
                    ON cr.IdRoute = ras.IdRoute
            WHERE	pod.LogTokenPOD = @Token
				AND pod.RowStatus = 1
            ORDER BY 1 DESC

            
        END;
		ELSE
		BEGIN

			select 204 [IdResult], 'No se encontraron registros' [Message]
 
        END;

		SELECT  convert(varchar, IdResult) [IdResult]
			,   Message [Message]
        FROM #responsemessage
        WHERE Id = 'OK'

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        -- retornar mensaje de error
        SELECT  convert(varchar, IdResult) [IdResult]
				,convert(nvarchar(max), error_message()) [Message]
        FROM #responsemessage
        WHERE Id = 'Invalid'

    END CATCH;

    IF @@trancount > 0
    BEGIN
        COMMIT TRANSACTION;
    END;

    -- destruir tablas temporales

    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;

END;