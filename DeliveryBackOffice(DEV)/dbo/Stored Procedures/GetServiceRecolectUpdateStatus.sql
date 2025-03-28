
-- =============================================
-- Author:		<Hugo,Gomez>
-- Create date: <2021-02-06>
-- Description:	<Recotizacion>
-- =============================================
-- =============================================
-- Author:		<Cristian,Suazo>
-- Create date: <2025-03-28>
-- Description:	<Se pasa a entidades el Json>
-- =============================================


CREATE PROCEDURE [dbo].[GetServiceRecolectUpdateStatus]
    --	-- Add the parameters for the stored procedure here
    @InGuides NVARCHAR(400) = 'FD199242' --'FD22221,FD22361,FD22223,FD22359,FD22226',
  , @Iscollected BIT = 'FALSE'
  , @status INT = 1
  , @ShipmentCompleted BIT = 'TRUE'
  , @Token NVARCHAR(50) = 'sys_system'
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    DECLARE @jsonResult NVARCHAR(MAX);

    -- insertar en tabla temporal posbibles mensajes de respuesta

    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;
    SELECT *
    INTO #responsemessage
    FROM
    (
        SELECT 200                              AS IdResult
             , 'Estado  cambiado correctamente' AS Message
             , 'OK'                             AS Id
        UNION
        SELECT 500                                       AS IdResult
             , 'Error faltal intente de nuevo mas tarde' AS Message
             , 'Transac'                                 AS Id
    ) AS errror;
    BEGIN TRANSACTION;
    BEGIN TRY

        IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
            DROP TABLE #listGuides;

        CREATE TABLE #listGuides
        (
            ItemSerie NVARCHAR(2)
          , ItemNumber INT
        );

        CREATE NONCLUSTERED INDEX tempSerie8899
        ON #listGuides (
                           ItemSerie
                         , ItemNumber
                       );

        INSERT INTO #listGuides
        (
            ItemSerie
          , ItemNumber
        )
        SELECT SUBSTRING(Item, 1, 2)         ItemSerie
             , SUBSTRING(Item, 3, LEN(Item)) ItemNumber
        --into #listGuides
        FROM DeliveryBackOffice.dbo.SplitUnlimited(@InGuides, ',');

        UPDATE DeliveryOrder
        SET StatusOrderId = @status
        FROM #listGuides                 ls
            INNER JOIN dbo.DeliveryOrder od
                ON od.Guide_Serie = ls.ItemSerie
                   AND od.Guide_Number = ls.ItemNumber;

        UPDATE DeliveryOrderPaymentDetail
        SET ShipmentCompleted = @ShipmentCompleted
        FROM #listGuides                              ls
            INNER JOIN dbo.DeliveryOrderPaymentDetail od
                ON od.GuideSerie = ls.ItemSerie
                   AND od.GuideNumber = ls.ItemNumber;

        ---	 insertar checkpoint de Solicitado.	
        INSERT INTO dbo.DeliveryOrderDetail
        (
            [Guide_Serie]
          , [Guide_Number]
          , [StatusOrderId]
          , [UserCreated]
          , [DateCreated]
          , [DateCreatedInSystem]
          , [Observations]
          , [Temperature_Celsius]
        )
        SELECT DISTINCT
               ls.ItemSerie
             , ls.ItemNumber
             , 1
             , @Token
             , GETDATE()
             , GETDATE()
             , NULL
             , NULL
        FROM #listGuides                                               ls
            LEFT JOIN [DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH (NOLOCK)
                ON ls.ItemSerie = DOD.Guide_Serie
                   AND ls.ItemNumber = DOD.Guide_Number
                   AND DOD.StatusOrderId IN ( 1, 21 )
                   AND DOD.RowStatus = 1
        WHERE DOD.DateCreated IS NULL;


		IF EXISTS
		(
			SELECT TOP 1
				1
			FROM DeliveryOrder ord WITH (NOLOCK)
				INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
					ON (
						   dopd.GuideNumber = ord.Guide_Number
						   AND dopd.GuideSerie = ord.Guide_Serie
					   )
			WHERE ord.Guide_Number IN (
										  SELECT ItemNumber FROM #listGuides
									  )
		)
		BEGIN
			SELECT IdResult AS IdResult,
				   [Message]
			FROM #responsemessage
			WHERE Id = 'OK'

			SELECT ISNULL(CONCAT(Guide_Serie, Guide_Number), 'N/A') AS Guide,
				   ISNULL(StatusOrderId, 'N/A') AS [Status],
				   ShipmentCompleted AS ShipmentCompleted
			FROM DeliveryOrder ord WITH (NOLOCK)
				INNER JOIN DeliveryOrderPaymentDetail dopd WITH (NOLOCK)
					ON (
						   dopd.GuideNumber = ord.Guide_Number
						   AND dopd.GuideSerie = ord.Guide_Serie
					   )
			WHERE ord.Guide_Number IN (
										  SELECT ItemNumber FROM #listGuides
									  )

		END
		ELSE
		BEGIN

			SELECT '500' AS IdResult,
				   'No se encontraron registros' AS [Message]

		END

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_MESSAGE();
        -- retornar mensaje de error

        SELECT IdResult,
                ERROR_MESSAGE() AS [Message] 
        FROM #responsemessage
        WHERE Id = 'Invalid'

    END CATCH;
    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;
    --- succesfull
    END;

    -- destruir tablas temporales

    IF OBJECT_ID('tempdb.dbo.#listGuides', 'U') IS NOT NULL
        DROP TABLE #listGuides;
    IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL
        DROP TABLE #responsemessage;

END;
