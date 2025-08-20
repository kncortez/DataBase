-- =============================================
-- Author:      <Brandon Pedroza>
-- Create date: <2025-06-12>
-- Description: <Facturacion SV - Guardar datos de direccion para clientes de El Salvador>
-- =============================================
CREATE PROCEDURE [dbo].[SPHDSaveBillingCustomerBySV]
    @IdCustomer INT,
    @DistrictId INT = NULL,
    @StateId INT = NULL,
    @ActivityId INT = NULL,
	@NRC NVARCHAR(20) = NULL,
    @TokenUser VARCHAR(50),
	@Nirphone NVARCHAR(5),
	@Phone NVARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM BillingCustomerBySV WITH(NOLOCK) WHERE IdCustomer = @IdCustomer)
        BEGIN

            UPDATE BillingCustomerBySV
            SET
                DistrictId = @DistrictId,
                StateId = @StateId,
                ActivityId = @ActivityId,
				NRC = @NRC,
				Nirphone = @Nirphone,
				Phone = @Phone,
                TokenUpdated = @TokenUser,
                DateUpdated = GETDATE()
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
				Nirphone,
				Phone,
                RowStatus,
                TokenCreated,
                DateCreated
            )
            VALUES (
                @IdCustomer,
                @DistrictId,
                @StateId,
                @ActivityId,
				@NRC,
				@Nirphone,
				@Phone,
                1,
                @TokenUser,
                GETDATE()
            );
        END
		SELECT '200' AS StatusCode,
		'Registro guardado correctamente' AS [Message];

	SELECT
		BL.Id,
		BL.IdCustomer,
		BL. DistrictId AS [CodeDistrict],
		BL.StateId AS [CodeState],
		BL.ActivityId AS CodeActivity,
		BL.NRC,
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
