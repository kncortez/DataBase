/* =================================================
   SP:        [dbo].[SPHDSaveBillingCustomerBySV]
   Propósito: Facturacion SV - Guardar datos de direccion para clientes de El Salvador.
   Autor:     Brandon Pedroza
   Historia:  FDAPI-4028
   Fecha:     2025-06-12
===== CHANGELOG ============================
2025-11-03 | Historia/épica: FDAPI-4923 | Autor: Cristian AzurdiaS|
2025-08-28 | Historia/épica: FDAPI-4452 | Autor: Brandon Pedroza |
2025-06-12 | Historia/épica: FDAPI-4028 | Autor: Brandon Pedroza |
=========================================== */

CREATE PROCEDURE [dbo].[SPHDSaveBillingCustomerBySV]
    @IdCustomer INT,
    @DistrictId INT = NULL,
    @StateId INT = NULL,
    @ActivityId INT = NULL,
    @NRC NVARCHAR(20) = NULL,
    @TokenUser VARCHAR(50),
    @Nirphone NVARCHAR(5),
    @Phone NVARCHAR(20),
    @IdProvince INT,
    @IdTownship INT,
    @TypeIdentificationDocumentCode NVARCHAR(100),
    @IdDocument NVARCHAR(100),
    @Inv_type INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM BillingCustomerBySV WITH(NOLOCK) WHERE IdCustomer = @IdCustomer)
        BEGIN
		DECLARE @IdDistrict INT, @IdState INT;
			
            UPDATE BillingCustomerBySV
            SET
                DistrictId = @DistrictId,
                StateId = @StateId,
                ActivityId = @ActivityId,
                NRC = @NRC,
                TypeIdentificationDocumentCode = @TypeIdentificationDocumentCode,
                IdDocument = @IdDocument,
                Inv_type = @Inv_type,
                Nirphone = @Nirphone,
                Phone = @Phone,
                TokenUpdated = @TokenUser,
                DateUpdated = GETDATE(),
                IdProvince = @IdProvince,
                IdTownship = @IdTownship
            WHERE IdCustomer = @IdCustomer;
        END
        ELSE
        BEGIN
            INSERT INTO BillingCustomerBySV (
                IdCustomer,
                DistrictId,
                StateId,
                ActivityId,
                NRC,
                TypeIdentificationDocumentCode,
                IdDocument,
                Inv_type,
                Nirphone,
                Phone,
                RowStatus,
                TokenCreated,
                DateCreated,
                IdProvince,
                IdTownship
            )
            VALUES (
                @IdCustomer,
                @DistrictId,
                @StateId,
                @ActivityId,
                @NRC,
                @TypeIdentificationDocumentCode,
                @IdDocument,
                @Inv_type,
                @Nirphone,
                @Phone,
                1,
                @TokenUser,
                GETDATE(),
                @IdProvince,
                @IdTownship
            );
        END
		SELECT '200' AS StatusCode,
		'Registro guardado correctamente' AS [Message];

	SELECT
        BL.Id,
        BL.IdCustomer,
        BL.IdProvince AS [IdProvince],
        BL.IdTownship AS [IdTownship],
        BL.ActivityId AS CodeActivity,
        BL.NRC,
        BL.TypeIdentificationDocumentCode,
        BL.IdDocument,
        BL.Inv_type,
        BL.Nirphone,
        BL.Phone
    FROM dbo.BillingCustomerBySV BL WITH(NOLOCK)		
    WHERE BL.IdCustomer = @IdCustomer
        AND BL.RowStatus = 1;
    END TRY
    BEGIN CATCH

        DECLARE @ErrorMessage NVARCHAR(4000);
        DECLARE @ErrorSeverity INT;
        DECLARE @ErrorState INT;


        SELECT
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);

    END CATCH

END;