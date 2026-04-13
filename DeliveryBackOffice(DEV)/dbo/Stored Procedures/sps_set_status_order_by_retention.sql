/* =================================================
   SP:        sps_set_status_order_by_retention
   Propósito: Declaración de Retención de guías
   Autor:     Mario Herrarte
   Historia:  ---
   Fecha:     2026-04-08

=== CHANGELOG ============================

=========================================== */
CREATE PROCEDURE [dbo].[sps_set_status_order_by_retention]
    @Guide_Serie  AS NVARCHAR(2),        -- guide serie
    @Guide_Number AS INT,                -- guide number
    @TokenId      AS NVARCHAR(50),       -- token user
    @StationId    AS INT = NULL,         -- station    
    @IdCountry    AS NVARCHAR(2) = 'GT'  -- country
AS
BEGIN
    DECLARE @ValidateOperation INT = 0;
    DECLARE @BelongCountry INT;
    DECLARE @IsStatusTerminal INT;
    DECLARE @IsLastMileReturn INT;

    SET NOCOUNT ON;

    IF (EXISTS
    (
        SELECT 1
        FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH (NOLOCK)
        WHERE Guide_Serie = @Guide_Serie
              AND Guide_Number = @Guide_Number
    ))
    BEGIN
        SELECT @IsStatusTerminal = ISNULL(
                                      (SELECT TOP 1 DO.StatusOrderId From [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)       
                                      INNER JOIN [dbo].[StatusOrder] SO  WITH(NOLOCK)
							            ON DO.StatusOrderId = SO.StatusOrderId
							          WHERE SO.CatCheckpointTypeId = 3 
                                        AND SO.RowStatus= 1 
							            AND DO.Guide_Serie= @Guide_Serie 
							            AND DO.Guide_Number =@Guide_Number 
							       ),0);

        SELECT @BelongCountry = CASE WHEN SenderCountryId = @IdCountry THEN 1 ELSE 0 END	
	                            FROM [DeliveryBackOffice].[dbo].[DeliveryOrder] WITH (NOLOCK)
	                            WHERE Guide_Serie = @Guide_Serie 
                                    AND Guide_Number = @Guide_Number;
        
       SELECT @IsLastMileReturn = ISNULL(
                                      (SELECT TOP 1 DO.StatusOrderId From [DeliveryBackOffice].[dbo].[DeliveryOrder] DO WITH(NOLOCK)       
							          WHERE DO.Guide_Serie = @Guide_Serie 
							            AND DO.Guide_Number = @Guide_Number 
                                        AND DO.IsLastMileReturn = 1
							       ),0);
    
        BEGIN TRANSACTION;
        BEGIN TRY

            IF @BelongCountry = 1
            BEGIN 
                IF @IsStatusTerminal = 0
                BEGIN 
                    IF @IsLastMileReturn != 0
                    BEGIN

                        UPDATE [DeliveryBackOffice].[dbo].[DeliveryOrder]
                        SET StatusOrderId = 28
                        WHERE Guide_Serie = @Guide_Serie AND Guide_Number = @Guide_Number;

                        SET @ValidateOperation = COALESCE(@@ROWCOUNT, 0);

                        IF @ValidateOperation > 0
                        BEGIN
                            INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
                                (
                                     Guide_Serie
                                    ,Guide_Number
                                    ,StatusOrderId
                                    ,UserCreated
                                    ,DateCreated
                                    ,DateCreatedInSystem
                                    ,StationId
                                )
                            VALUES
                                (
                                     @Guide_Serie
                                    ,@Guide_Number
                                    ,28
                                    ,@TokenId
                                    ,GETDATE()
                                    ,GETDATE()
                                    ,@StationId
                                );
                        END;
                    END;
                    ELSE
                        SET @ValidateOperation = -3;
                END;
                ELSE
                    SET @ValidateOperation = -2;
            END;
            ELSE 
                SET @ValidateOperation = -1;

        END TRY
        BEGIN CATCH
            SELECT
                0 AS 'StatusCode',
                ERROR_MESSAGE() AS 'Description';
            ROLLBACK TRANSACTION;
        END CATCH;

        IF @@TRANCOUNT > 0
        BEGIN
            IF @ValidateOperation > 0
            BEGIN
                SELECT
                    1 AS 'StatusCode',
                    'Registros guardados correctamente' AS 'Description';
            END; 
            ELSE IF (@ValidateOperation = -1)
            BEGIN
                SELECT 
                    -1 AS 'StatusCode',
                    'La guía no pertenece al país logueado' AS 'Description';
            END;
            ELSE IF (@ValidateOperation = -2)
		    BEGIN
		        SELECT			  
			        -2 AS 'StatusCode',
			        'Para operar una guía en este módulo no debe estar en un estado final.' AS 'Description';
		    END
            ELSE IF (@ValidateOperation = -3)
            BEGIN
                SELECT -3 AS 'StatusCode',
                       'La guía no se encuentra declarada para devolución' AS 'Description';
            END;
            ELSE
            BEGIN
                SELECT 0 AS 'StatusCode',
                       'No fue posible actualizar el registro' AS 'Description';
                PRINT 'REGISTER NOT EXISTS ' + CAST(COALESCE(@ValidateOperation, 0) AS VARCHAR);
            END;
            COMMIT TRANSACTION;  
        END;
    END;
    ELSE
    BEGIN
        SELECT 0 AS 'StatusCode',
        'El registro no existe' AS 'Description';
        PRINT 'REGISTER NOT EXISTS ' + CAST(COALESCE(@ValidateOperation, 0) AS VARCHAR);
    END;
END
GO
