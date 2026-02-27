/*
  Name: APIForzaDeliveryEXC_SetVoucherClosureHeaderVisitPoint_Update_byIdClosure
  Summary: Modifica los valores de Voucher1, Bag1, Voucher2, Bag2 de un cierre.
  Inputs:
    @IdCierre bigint, obligatorio
    @Voucher1  varchar(50) = '0', opcional, default = 0
    @Bag1      varchar(50) = '0', opcional, default = 0
    @Voucher2  varchar(50) = '0', opcional, default = 0
    @Bag2      varchar(50) = '0', opcional, default = 0
  Outputs:
    ResultSet1: Mensaje de confirmación de proceso o error.
  Notes:
    -
  Author: <Bilkar Morataya> | Created: 2026-02-26 | Module: Portal | Version: 1.0.0
  Ticket: <JIRA/FDAPI-5584>
  CHANGELOG:
    - 2026-02-26 <Bilkar Morataya> V1: Creación
*/
CREATE PROCEDURE APIForzaDeliveryEXC_SetVoucherClosureHeaderVisitPoint_Update_byIdClosure
(
    @IdCierre  BIGINT,              -- obligatorio
    @TokenUpdated NVARCHAR(50),      -- opcional
    @Voucher1  NVARCHAR(50) = N'0',  -- opcional, default = 0
    @Bag1      NVARCHAR(50) = N'0',  -- opcional, default = 0
    @Voucher2  NVARCHAR(50) = N'0',  -- opcional, default = 0
    @Bag2      NVARCHAR(50) = N'0'   -- opcional, default = 0
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF @IdCierre IS NULL
        BEGIN
            SELECT
                CAST(400 AS INT) AS StatusCode,
                CAST(N'IdCierre es obligatorio.' AS NVARCHAR(200)) AS Message;
            RETURN;
        END;

        UPDATE H
           SET H.Voucher1 = @Voucher1,
               H.Bag1     = @Bag1,
               H.Voucher2 = @Voucher2,
               H.Bag2     = @Bag2,
               H.TokenUpdated = @TokenUpdated,
               H.DateUpdated = GETDATE()
        FROM DeliveryBackOffice.dbo.AccountingClosuresHeaderVisitPoint AS H
        WHERE H.IdAccountingClosuresHeaderVisitPoint = @IdCierre;

        IF @@ROWCOUNT = 0
        BEGIN
            SELECT
                CAST(404 AS INT) AS StatusCode,
                CAST(N'No existe un registro para el IdCierre indicado.' AS NVARCHAR(200)) AS Message;
            RETURN;
        END;

        SELECT
            CAST(200 AS INT) AS StatusCode,
            CAST(N'Registro modificado correctamente.' AS NVARCHAR(200)) AS Message;
    END TRY
    BEGIN CATCH
        SELECT
            CAST(500 AS INT) AS StatusCode,
            CAST(ERROR_MESSAGE() AS NVARCHAR(200)) AS Message;
    END CATCH
END;