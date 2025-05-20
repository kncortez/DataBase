-- =============================================
-- Author:      <Daniel, Ramirez>
-- Create date: <2024-05-24>
-- Description: < Se agrega filtro por pais, por defect GT >
-- =============================================
-- =============================================
-- Author:      <Walter, Orozco>
-- Create date: <2025-05-19>
-- Description: <Se realizan mejoras en Nirphone para multipaís SV.>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_saveVisitPoint]
    @DescriptionOfClient AS NVARCHAR(100),
    @IdSettlement AS BIGINT,
    @TokenCreated AS NVARCHAR(50),
    @CustomerID AS INT,
    @Address AS NVARCHAR(600),
    @Town AS NVARCHAR(100),
    @Department AS NVARCHAR(100),
	@NirPhone NVARCHAR(4) = '502',
    @Phone AS NVARCHAR(50),
    @ContactName AS NVARCHAR(200),
    @Email AS NVARCHAR(200),
    @Latitude NVARCHAR(20) = NULL,
    @Longitude NVARCHAR(20) = NULL,
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN
    -- Control de identificador de registro
    DECLARE @CodeOfReference AS INT = -1;

    SET @CodeOfReference =
    (
        SELECT TOP (1)
               vpc.CodeOfReference + 1
        FROM dbo.VisitPointClient vpc
        ORDER BY vpc.CodeOfReference DESC
    );

    -- Verificación de municipio
    DECLARE @IdTownship AS INT = -1;
    SET @IdTownship =
    (
        SELECT IdTownship FROM dbo.Township WHERE TownshipName = @Town
    );

    -- Verificación de poblado
    IF (@IdSettlement = 0)
        SET @IdSettlement = NULL;

    BEGIN TRANSACTION;
    BEGIN TRY

        INSERT INTO [dbo].[VisitPointClient]
        (
            [CodeOfReference],
            [DescriptionOfClient],
            [StatusClient],
            [CountryId],
            [IdSettlement],
            [TokenCreated],
            [DateCreated],
            [CustomerID],
            [Address],
            [Town],
            [Department],
            [Phone],
            [ContactName],
            [Email],
            [IdTownship],
            [Latitude],
            [Longitude]
        )
        VALUES
        (@CodeOfReference, @DescriptionOfClient, 'TRUE', @IdCountry, @IdSettlement, @TokenCreated, GETDATE(), @CustomerID,
         @Address, @Town, @Department, @Phone, @ContactName, @Email, @IdTownship, @Latitude, @Longitude);


        --DECLARE @regexPhoneNumber varchar(max)='[(][0-9][0-9][0-9][)]%';			
        SET @Phone = REPLACE(@Phone, '-', '');
        SET @Phone = REPLACE(@Phone, ' ', '');

        DECLARE @Idplace AS INT =
                (
                    SELECT ISNULL(IdCityPlace, -1)
                      FROM dbo.CatCityPlace
                     WHERE CityPlace = 'No Aplica'
                       AND IdCountry = @IdCountry
                );

        SET @IdCountry =
                (
                    SELECT CC.IdCountry
                    FROM dbo.CatCountry CC
                        LEFT JOIN dbo.Province PRV
                            ON PRV.IdCountry = CC.IdCountry
                        LEFT JOIN dbo.Township TS
                            ON TS.IdProvince = PRV.IdProvince
                    WHERE IdTownship = @IdTownship
                );

        DECLARE @IdAccount INT =
                (
                    SELECT AccIdAccount FROM dbo.Account ACC WHERE IdCustomer = @CustomerID
                );


        INSERT INTO dbo.UserAddress
        (
            UadIdTownship,
            UadIdCountry,
            UadAddress1,
            --UadAddress2 NO SE MODIFICA
            UadNirPhone,
            UadPhone,
            UadAdditionalInstructions,
            UadTokenCreated,
            UadDateCreated,
            CodeOfReference,
            UadIdSettlement,
            UadFullName,
            IdCityPlace,
            UadIdAccount,
            UadRowStatus
        )
        VALUES
        (@IdTownship, @IdCountry, @Address, @NirPhone, @Phone, '', @TokenCreated, GETDATE(), @CodeOfReference,
         @IdSettlement, @DescriptionOfClient, @Idplace, @IdAccount, 1);

        IF (@@TRANCOUNT > 0) COMMIT TRANSACTION;

        SELECT 1 [blnResult],
               'Datos ingresados exitosamente' [Message];

    END TRY
    BEGIN CATCH

        SELECT 0 [blnResult],
               ERROR_NUMBER() AS [ErrorNumber],
               ERROR_SEVERITY() AS [ErrorSeverity],
               ERROR_STATE() AS [ErrorState],
               ERROR_PROCEDURE() AS [ErrorProcedure],
               ERROR_LINE() AS [ErrorLine],
               ERROR_MESSAGE() AS [ErrorMessage];

        ROLLBACK TRANSACTION;

    END CATCH;
END;