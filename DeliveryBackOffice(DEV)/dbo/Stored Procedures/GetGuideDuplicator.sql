-- =============================================  
-- Author:  <Cristian Suazo  
-- Update date: <2025-02-10>  
-- Description: <Valida si ticket number contiene mas de una guia>  
-- ============================================= 
CREATE PROCEDURE [dbo].[GetGuideDuplicator]
    @GuideNumber INT,
    @GuideSerie NVARCHAR(2),
    @TicketNumber NVARCHAR(300) = 'ZULY ',
    @IdCustomer INT
AS
BEGIN
    DECLARE @Valid INT,
            @Counter INT


	
    --VALIDAMOS SI TIENE MAS DE UN GUIA ASOCIADA
    IF @TicketNumber IS NOT NULL AND @TicketNumber != ''
    BEGIN
        SELECT @Valid = COUNT(Guide_Number)
        FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
        WHERE Ticket_Number = @TicketNumber
    END
	ELSE IF @TicketNumber = ''
	BEGIN
		PRINT ' NO ENTRO'
		SELECT @Valid = COUNT(Guide_Number)
		FROM DeliveryBackOffice.dbo.DeliveryOrder WITH (NOLOCK)
		WHERE Guide_Number = @GuideNumber
		AND Guide_Serie = @GuideSerie
	END

    IF @Valid > 1
    BEGIN
        IF @IdCustomer IS NULL
           OR @IdCustomer = ''
        BEGIN
            SELECT 200 AS StatusCode,
                   'Se encontro más de una guía' AS [Message]

            SELECT DO.Guide_Serie,
                   DO.Guide_Number,
                   DO.IdCustomer,
                   CU.Name AS CustomerName
            FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
                INNER JOIN DeliveryBackOffice.dbo.Customer CU WITH (NOLOCK)
                    ON DO.IdCustomer = CU.IdCustomer
            WHERE Ticket_Number = @TicketNumber
        END
        ELSE
        BEGIN

            IF EXISTS
            (
                SELECT TOP 1
                    1
                FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.Customer CU WITH (NOLOCK)
                        ON DO.IdCustomer = CU.IdCustomer
                WHERE Ticket_Number = @TicketNumber
                      AND CU.IdCustomer = @IdCustomer
            )
            BEGIN
                SELECT @Counter = COUNT(Guide_Number)
                FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
                    INNER JOIN DeliveryBackOffice.dbo.Customer CU WITH (NOLOCK)
                        ON DO.IdCustomer = CU.IdCustomer
                WHERE Ticket_Number = @TicketNumber
                      AND CU.IdCustomer = @IdCustomer

                IF @Counter > 1
                BEGIN
                    SELECT 200 AS StatusCode,
                           'Se ha encontrado más de una guía' AS [Message]

                    SELECT DO.Guide_Serie,
                           DO.Guide_Number,
                           DO.IdCustomer,
                           CU.Name AS CustomerName
                    FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH (NOLOCK)
                        INNER JOIN DeliveryBackOffice.dbo.Customer CU WITH (NOLOCK)
                            ON DO.IdCustomer = CU.IdCustomer
                    WHERE Ticket_Number = @TicketNumber
                          AND CU.IdCustomer = @IdCustomer
                END
                ELSE IF @Counter = 0
                BEGIN
                    SELECT 1 AS StatusCode,
                           'No se encontraron coincidencias' AS [Message]
                END
                ELSE
                BEGIN
                    SELECT 1 AS StatusCode,
                           'Ticket number con una sola guía' AS [Message]
                END
            END
            ELSE
            BEGIN
                SELECT 1 AS StatusCode,
                       'No se ah encontrado guías con este ticketnumber y customer' AS [Message]
            END
        END
    END
	ELSE IF @Valid = 0
	BEGIN
		SELECT 1 AS StatusCode,
                   'La guía no existe' AS [Message]
	END
    ELSE
    BEGIN
        SELECT 1 AS StatusCode,
               'Ticket number con una sola guia' AS [Message]
    END
END