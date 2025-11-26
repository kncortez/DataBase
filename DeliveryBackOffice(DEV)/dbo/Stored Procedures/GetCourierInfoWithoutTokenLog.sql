/* =================================================
   SP:        [dbo].[GetCourierInfoWithoutTokenLog]
   Propósito: <Consultar datos de courier con solo mandar numero de telefono>
   Autor:     <Eduardo Lopez>
   Historia:  <>   
   Fecha:     2024-04-08
============================================
=== CHANGELOG ================================
-- 2025-11-25 | Historia/épica: FDAPI-5100 | Autor: Cristian Suazo |
-- 2025-11-17 | Historia/épica: FDAPI-4976 | Autor: Cristian Suazo |
=========================================== */


CREATE procedure [dbo].[GetCourierInfoWithoutTokenLog]
    -- Add the parameters for the stored procedure here
    @Phone nvarchar(20) = '48119415'
  , @Token varchar(max) = '21a31fd231as23d1f21ads'
  , @IdCountry nvarchar(8)	= 'GT'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.

    set nocount on;

    -- insertar en tabla temporal posbibles mensajes de respuesta

    DECLARE @responsemessage TABLE(
        [IdResult] INT,
        [Message] VARCHAR(100),
        [Id] VARCHAR(20)
    );

    INSERT INTO @responsemessage
    SELECT *    
    FROM
    (
        SELECT 200                              AS IdResult
             , 'Estado  cambiado correctamente' AS Message
             , 'OK'                             AS Id
        UNION
        SELECT 500                                       AS IdResult
             , 'Error faltal intente de nuevo mas tarde' AS Message
             , 'Transac'                                 AS Id
    ) AS error;

    BEGIN TRANSACTION;
    BEGIN TRY
        -------------------------------------------------------------------------------------------------------------------------
        DECLARE @phon INT,
				@StationId INT

                    SELECT	TOP 1
						@phon = SR.ID,
						@StationId = HL.IdStation
					FROM	[DeliveryBackOffice].[dbo].[SenderReceiver] SR WITH (NOLOCK)
					LEFT JOIN DeliveryBackOffice.dbo.HubLogistics HL WITH (NOLOCK)
						ON SR.HubLogisticId = HL.IdHubLogistic
					WHERE	SR.IdCountry = @IdCountry
						AND	SR.Phone like '%' + @Phone + '%'
						AND SR.Estatus = 1

        DECLARE @TokenInavt VARCHAR(MAX) =
                (
                    SELECT TOP 1
                           LogTokenPOD
                    FROM DeliveryBackOffice.dbo.LogTokenPOD WITH (NOLOCK)
                    WHERE IdCourierman = @phon
                          AND RowStatus = 1
                    ORDER BY DateCreated DESC
                );

        UPDATE LogTokenPOD
        SET RowStatus = 0
        WHERE LogTokenPOD = @TokenInavt;
        ------------------------------------------------------------------------------------------------------------------------

            INSERT INTO dbo.LogTokenPOD
            (
                LogTokenPOD
              , IdCourierman
              , RowStatus
              , DateCreated
              , DateUpdate
            )
            VALUES
            (@Token, @phon, 1, GETDATE(), null);

			DECLARE @GuideRegexData NVARCHAR(500) =
            (
                SELECT TOP 1
                       CP.[Value]
                FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH (NOLOCK)
                WHERE CP.[Name] = 'GuideRegex' 
            );

			DECLARE @GuideRegexScannerData NVARCHAR(500) =
            (
                SELECT TOP 1
                       CP.[Value]
                FROM [DeliveryBackOffice].[dbo].[ConfigParams] CP WITH (NOLOCK)
                WHERE CP.[Name] = 'GuideRegexScanner' 
            );

            --CONVERT(varchar,@Existingdate,3) as [DD/MM/YY]
            DECLARE @DefaultEmail NVARCHAR(50) =
                    (
                        SELECT ISNULL(cf.Value, '')
                        FROM DeliveryBackOffice.dbo.ConfigParams cf WITH (NOLOCK)
                        WHERE cf.Name = 'BillingEmailCAPP'
                    );

            DECLARE @DefaultPickupManifestEmail nvarchar(50) =
                    (
                        SELECT isnull(cf.Value, '')
                        FROM dbo.ConfigParams cf WITH (NOLOCK)
                        WHERE cf.Name = 'PickUpManifestEmailCAPP'
                    );
			IF EXISTS 
			(
				SELECT TOP 1 1
				FROM DeliveryBackOffice.dbo.LogTokenPOD   pod WITH (NOLOCK)
                INNER JOIN SenderReceiver    sr WITH (NOLOCK)
                    ON (sr.ID = pod.IdCourierman)
                LEFT JOIN DeliveryBackOffice.dbo.RouteAssigment ras WITH (NOLOCK)
                    ON ras.IdCurrierMan = sr.ID
                        and DateOfRoute = CONVERT(DATE, GETDATE())
                LEFT JOIN DeliveryBackOffice.dbo.CatVehicle     vh WITH (NOLOCK)
                    ON vh.IdVehicle = ras.IdVehicle
                LEFT JOIN DeliveryBackOffice.dbo.CatRoute       cr WITH (NOLOCK)
                    ON cr.IdRoute = ras.IdRoute
				WHERE pod.LogTokenPOD = @Token
					AND pod.RowStatus = 1
			)
			BEGIN
				SELECT TOP 1 pod.IdCourierman AS IdCourier,
						pod.DateCreated AS DateToken,
						sr.First_Name AS FirstName,
						sr.Last_Name AS LastName,
						vh.Plate AS Vehicle,
						cr.CodeRoute AS Route,
						@GuideRegexData AS GuideRegex,
						@GuideRegexScannerData AS GuideRegexEscaner,
						@DefaultEmail AS BillingEmail,
						@DefaultPickupManifestEmail AS PickUpManifestEmail,
						LogTokenPOD AS Token,
						@StationId AS StationId
				FROM DeliveryBackOffice.dbo.LogTokenPOD   pod WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.SenderReceiver    sr WITH (NOLOCK)
                    ON (sr.ID = pod.IdCourierman)
                LEFT JOIN DeliveryBackOffice.dbo.RouteAssigment ras WITH (NOLOCK)
                    ON ras.IdCurrierMan = sr.ID
                        AND DateOfRoute = CONVERT(DATE, GETDATE())
                LEFT JOIN DeliveryBackOffice.dbo.CatVehicle     vh WITH (NOLOCK)
                    ON vh.IdVehicle = ras.IdVehicle
                LEFT JOIN DeliveryBackOffice.dbo.CatRoute       cr WITH (NOLOCK)
                    ON cr.IdRoute = ras.IdRoute
				where pod.LogTokenPOD = @Token
					AND pod.RowStatus = 1

				SELECT IdResult,
						Message
				FROM @responsemessage
				WHERE Id = 'OK'
			END
			ELSE
			BEGIN
				SELECT 204 AS IdResult,
					   'No se encontraron registros' AS Message
			END

        
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE();
        -- retornar mensaje de error
		SELECT IdResult,
			   ERROR_MESSAGE() AS Message
		FROM @responsemessage

    END CATCH;
    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;

    END;

END;