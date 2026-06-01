

-- =============================================
-- Author:		<Andres, Ruiz>
-- Update date: <2022-08-02>
-- Description:	< Corrección para actualizar la opción de entrega y la dirección destino de guías >
-- =============================================

CREATE PROCEDURE [dbo].[spput_modify_guide_to_receiverid]
    @Guide NVARCHAR(50),
    @ReceiverId INT,
    @TokenUpdated VARCHAR(50)
AS
BEGIN
DECLARE @GuideSerie NVARCHAR(10);
DECLARE @GuideNumber BIGINT;

-- Primeros 2 caracteres
SET @GuideSerie = SUBSTRING(@Guide, 1, 2);

-- Del 3er carácter en adelante (largo dinámico) convertido a número
SET @GuideNumber = TRY_CONVERT(BIGINT, SUBSTRING(@Guide, 3, LEN(@Guide)));



    -- Variables "globales"
    DECLARE @DateUpdated DATETIME = GETDATE();
    DECLARE @NewDeliveryOptionID INT =
            (
                SELECT TOP 1
                       CDO.IdDeliveryOption
                FROM [DeliveryBackOffice].[dbo].[CatDeliveryOptions] CDO WITH (NOLOCK)
                WHERE CDO.[Name] = 'Express Center' COLLATE Latin1_General_CI_AI
            );
    DECLARE @NewDeliveryAddress NVARCHAR(600) = N'';

    SELECT @NewDeliveryAddress = VPC.[Address]
    FROM [DeliveryBackOffice].[dbo].[VisitPointClient] VPC WITH (NOLOCK)
    WHERE VPC.CodeOfReference = @ReceiverId;

    BEGIN TRANSACTION;

    BEGIN TRY
        UPDATE dbo.DeliveryOrder
        SET Receiver_ID = @ReceiverId,
            IdDeliveryOption = @NewDeliveryOptionID,
            Receiver_Address = (CASE
                                    WHEN LTRIM(RTRIM(ISNULL(@NewDeliveryAddress, ''))) != '' THEN
                                        @NewDeliveryAddress
                                    ELSE
                                        Receiver_Address
                                END
                               ),
            TokenUpdated = @TokenUpdated,
            DateUpdated = @DateUpdated
        WHERE 
        --CONCAT(Guide_Serie, Guide_Number) = @Guide;
        Guide_Serie = @GuideSerie
        and Guide_Number = @GuideNumber
    END TRY
    BEGIN CATCH
        SELECT 'RollBackTransaction' AS message,
               @Guide AS Guide,
               'FALSE' blnResult,
               CAST(@ReceiverId AS VARCHAR(10)) IdResult,
               CAST(500 AS VARCHAR(5)) StatusResult,
               CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
               CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
               CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
               CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
               CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
               CAST(ERROR_MESSAGE() AS VARCHAR(MAX)) AS ResultMessage;

        ROLLBACK TRANSACTION;
    END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        SELECT 'Succesfull' AS message,
               @Guide AS Guide,
               'TRUE' blnResult,
               CAST(@ReceiverId AS VARCHAR(10)) IdResult,
               CAST(200 AS VARCHAR(50)) StatusResult,
               '' AS ErrorNumber,
               '' AS ErrorSeverity,
               '' AS ErrorState,
               '' AS ErrorProcedure,
               '' AS ErrorLine,
               'Success' AS ResultMessage;

        COMMIT TRANSACTION;
    END;

END;