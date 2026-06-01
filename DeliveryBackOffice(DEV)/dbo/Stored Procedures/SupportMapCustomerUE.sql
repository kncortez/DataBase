-- =============================================
-- Author:		<César,Aquino>
-- Create date: <2025-09-16>
-- Description:	<Reasignación de un articulo a Article by Customer>
-- =============================================
--=================================================================================
--== Proyecto Ultra Entregas  --  WeebhookService
--== REF.: https://cashlogisticsgroup.atlassian.net/browse/FDAPI-4063
--== Configuración Inicial
--=================================================================================

CREATE PROCEDURE [dbo].SupportMapCustomerUE
    @CustomerForzaId INT --= 6
  , @CustomerEUId INT    --= 'Caja 30'
  , @Token NVARCHAR(50)  --= 'SYS-CAQUINO'

AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        -- Setear el customer de Ultra Entregas y el usuario que va hacer el registro
        DECLARE @CUSTOMER    INT
              , @CUSTOMER_UE INT
              , @User        NVARCHAR(50);
        SET @CUSTOMER = @CustomerForzaId;
        SET @CUSTOMER_UE = @CustomerEUId;
        SET @User = @Token;

        -- Se configura el id del cliente de UE con el cliente de Forza
        UPDATE Customer
        SET CustomerUEId = @CUSTOMER_UE
        WHERE IdCustomer = @CUSTOMER;

        -- 1. Registro de nuevo tipo de conexión en [WebhookCatTypeConnection] correspondiente a "Ultra Entregas",
        --    necesario para definir el canal de integración con servicios externos.

        IF NOT EXISTS
        (
            SELECT 1
            FROM [dbo].[WebhookCatTypeConnection]
            WHERE [CatTypeConnectionName] = N'ULTRAENTREGAS'
        )
        BEGIN

            INSERT INTO dbo.WebhookCatTypeConnection
            (
                IdCatTypeConnection
              , CatTypeConnectionName
              , RowStatus
              , DateCreated
              , TokenCreated
              , DateUpdated
              , TokenUpdated
            )
            VALUES
            (   3 -- IdCatTypeConnection - int

              , N'ULTRAENTREGAS', 1, GETDATE(), @User, NULL, NULL);
        END;

        -- 2. Registro del nuevo tipo de evento en [WebhookType] para representar la acción de creación, anulacion y entrega de guías en el contexto de integración con Ultra Entregas.

        IF NOT EXISTS
        (
            SELECT 1
            FROM [dbo].[WebhookType]
            WHERE [WebhookName] = N'CreatedGuides'
        )
        BEGIN
            INSERT INTO [dbo].[WebhookType]
            (
                [WebhookName]
              , [WebhookDescription]
              , [RowStatus]
              , [DateCreated]
              , [TokenCreated]
              , [DateUpdated]
              , [TokenUpdated]
            )
            VALUES
            (N'CreatedGuides', N'Creación de guías', 1, GETDATE(), @User, NULL, NULL);
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM [dbo].[WebhookType]
            WHERE [WebhookName] = N'VoidedGuides'
        )
        BEGIN
            INSERT INTO [dbo].[WebhookType]
            (
                [WebhookName]
              , [WebhookDescription]
              , [RowStatus]
              , [DateCreated]
              , [TokenCreated]
              , [DateUpdated]
              , [TokenUpdated]
            )
            VALUES
            (N'VoidedGuides', N'Anulación de guías', 1, GETDATE(), @User, NULL, NULL);
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM [dbo].[WebhookType]
            WHERE [WebhookName] = N'DeliveredGuides'
        )
        BEGIN
            INSERT INTO [dbo].[WebhookType]
            (
                [WebhookName]
              , [WebhookDescription]
              , [RowStatus]
              , [DateCreated]
              , [TokenCreated]
              , [DateUpdated]
              , [TokenUpdated]
            )
            VALUES
            (N'DeliveredGuides', N'Cambio de estado de guía a entregado', 1, GETDATE(), @User, NULL, NULL);
        END;

        DECLARE @CONN_UE_ID INT;
        DECLARE @WTYPE_CREATED_ID INT;
        DECLARE @WTYPE_VOIDED_ID INT;
        DECLARE @WTYPE_DELIVERY_ID INT;
        DECLARE @UE_URL NVARCHAR(250) = N'https://portal.ultraentregashn.com/services_api/waybill';
        DECLARE @KEY NVARCHAR(MAX)
            = N'Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwczovL3BvcnRhbC51bHRyYWVudHJlZ2FzaG4uY29tIiwiYXVkIjoiaHR0cHM6Ly9wb3J0YWwudWx0cmFlbnRyZWdhc2huLmNvbSIsImlhdCI6MTc0NzQyNjQ0NiwibmJmIjoxNzQ3NDI2NDQ2LCJkYXRhIjp7InVzZXJJZCI6IkZPUlpBIiwiY29kY2xpIjoiMCIsImNvZHByaSI6IjAiLCJjb2RjaXUiOiIwIiwidGlwcGVyIjoiMSJ9fQ.JA7G1W--wJEcT-bDue9sJTXdEZt4eSMzW7CwzE_YzR8';
        DECLARE @WH_EPOINT_CREATED_ID INT;
        DECLARE @WH_EPOINT_VOIDED_ID INT;
        DECLARE @WH_EPOINT_DELIVERY_ID INT;


        SET @CONN_UE_ID =
        (
            SELECT IdCatTypeConnection
            FROM [dbo].[WebhookCatTypeConnection]
            WHERE [CatTypeConnectionName] = N'ULTRAENTREGAS'
        );
        SET @WTYPE_CREATED_ID =
        (
            SELECT IdWebhookType
            FROM [dbo].[WebhookType]
            WHERE [WebhookName] = N'CreatedGuides'
        );
        SET @WTYPE_VOIDED_ID =
        (
            SELECT IdWebhookType
            FROM [dbo].[WebhookType]
            WHERE [WebhookName] = N'VoidedGuides'
        );
        SET @WTYPE_DELIVERY_ID =
        (
            SELECT IdWebhookType
            FROM [dbo].[WebhookType]
            WHERE [WebhookName] = N'DeliveredGuides'
        );

        -- 3. Configuración del nuevo endpoint de integración para Ultra Entregas en [WebhookEndpoint], incluyendo su cabecera personalizada en [WebhookEndpointHeader] si se requiere token/API key.
        -- IMPORTANTE:  Estas inserciones se tienen que realizar por cada cliente de Ultra Entregas

        -- Validar e insertar WebhookEndpoint para CreatedGuides
        IF NOT EXISTS
        (
            SELECT 1
            FROM [dbo].[WebhookEndpoint]
            WHERE [WebhookTypeId] = @WTYPE_CREATED_ID
                  AND [CustomerId] = @CUSTOMER
                  AND [WebhookEndpointURI] = @UE_URL
        )
        BEGIN
            INSERT INTO [dbo].[WebhookEndpoint]
            (
                [WebhookTypeId]
              , [CustomerId]
              , [WebhookEndpointURI]
              , [RowStatus]
              , [DateCreated]
              , [TokenCreated]
              , [DateUpdated]
              , [TokenUpdated]
              , [TypeConnectionId]
              , [Hostname]
              , [UserName]
              , [Password]
              , [Port]
              , [RemoteRoute]
            )
            VALUES
            (@WTYPE_CREATED_ID, @CUSTOMER, @UE_URL, 1, GETDATE(), @User, NULL, NULL, @CONN_UE_ID, NULL, N'Bearer Token'
           , NULL, NULL, NULL);
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM [dbo].[WebhookEndpoint]
            WHERE [WebhookTypeId] = @WTYPE_VOIDED_ID
                  AND [CustomerId] = @CUSTOMER
                  AND [WebhookEndpointURI] = @UE_URL
        )
        BEGIN
            INSERT INTO [dbo].[WebhookEndpoint]
            (
                [WebhookTypeId]
              , [CustomerId]
              , [WebhookEndpointURI]
              , [RowStatus]
              , [DateCreated]
              , [TokenCreated]
              , [DateUpdated]
              , [TokenUpdated]
              , [TypeConnectionId]
              , [Hostname]
              , [UserName]
              , [Password]
              , [Port]
              , [RemoteRoute]
            )
            VALUES
            (@WTYPE_VOIDED_ID, @CUSTOMER, @UE_URL, 1, GETDATE(), @User, NULL, NULL, @CONN_UE_ID, NULL, N'Bearer Token'
           , NULL, NULL, NULL);
        END;

        IF NOT EXISTS
        (
            SELECT 1
            FROM [dbo].[WebhookEndpoint]
            WHERE [WebhookTypeId] = @WTYPE_DELIVERY_ID
                  AND [CustomerId] = @CUSTOMER
                  AND [WebhookEndpointURI] = @UE_URL
        )
        BEGIN
            INSERT INTO [dbo].[WebhookEndpoint]
            (
                [WebhookTypeId]
              , [CustomerId]
              , [WebhookEndpointURI]
              , [RowStatus]
              , [DateCreated]
              , [TokenCreated]
              , [DateUpdated]
              , [TokenUpdated]
              , [TypeConnectionId]
              , [Hostname]
              , [UserName]
              , [Password]
              , [Port]
              , [RemoteRoute]
            )
            VALUES
            (@WTYPE_DELIVERY_ID, @CUSTOMER, @UE_URL, 1, GETDATE(), @User, NULL, NULL, @CONN_UE_ID, NULL
           , N'Bearer Token', NULL, NULL, NULL);
        END;


        -- 4. Configuración de los Headers

        SET @WH_EPOINT_CREATED_ID =
        (
            SELECT IdWebhookEndpoint
            FROM WebhookEndpoint WITH (NOLOCK)
            WHERE WebhookTypeId = @WTYPE_CREATED_ID
                  AND CustomerId = @CUSTOMER
        );
        SET @WH_EPOINT_VOIDED_ID =
        (
            SELECT IdWebhookEndpoint
            FROM WebhookEndpoint WITH (NOLOCK)
            WHERE WebhookTypeId = @WTYPE_VOIDED_ID
                  AND CustomerId = @CUSTOMER
        );
        SET @WH_EPOINT_DELIVERY_ID =
        (
            SELECT IdWebhookEndpoint
            FROM WebhookEndpoint WITH (NOLOCK)
            WHERE WebhookTypeId = @WTYPE_DELIVERY_ID
                  AND CustomerId = @CUSTOMER
        );

        INSERT [dbo].[WebhookEndpointHeader]
        (
            [WebhookEndpointId]
          , [WebhookHeaderName]
          , [WebhookHeaderValue]
          , [RowStatus]
          , [DateCreated]
          , [TokenCreated]
          , [DateUpdated]
          , [TokenUpdated]
        )
        VALUES
        (@WH_EPOINT_CREATED_ID, N'Authorization', @KEY, 1, GETDATE(), @User, NULL, NULL);

        INSERT [dbo].[WebhookEndpointHeader]
        (
            [WebhookEndpointId]
          , [WebhookHeaderName]
          , [WebhookHeaderValue]
          , [RowStatus]
          , [DateCreated]
          , [TokenCreated]
          , [DateUpdated]
          , [TokenUpdated]
        )
        VALUES
        (@WH_EPOINT_VOIDED_ID, N'Authorization', @KEY, 1, GETDATE(), @User, NULL, NULL);

        INSERT [dbo].[WebhookEndpointHeader]
        (
            [WebhookEndpointId]
          , [WebhookHeaderName]
          , [WebhookHeaderValue]
          , [RowStatus]
          , [DateCreated]
          , [TokenCreated]
          , [DateUpdated]
          , [TokenUpdated]
        )
        VALUES
        (@WH_EPOINT_DELIVERY_ID, N'Authorization', @KEY, 1, GETDATE(), @User, NULL, NULL);

        COMMIT TRANSACTION;

        SELECT 'Cliente configurado correctamente';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER();
    END CATCH;

END;