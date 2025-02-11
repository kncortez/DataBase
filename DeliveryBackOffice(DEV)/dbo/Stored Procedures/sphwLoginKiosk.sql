-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-11-19>
-- Description:	<Login - Método validar pais, estacion y codigo de kiosko asignado>
-- =============================================

CREATE PROCEDURE [dbo].[sphwLoginKiosk]
    @KioskCode INT,
    @IdCountry NVARCHAR(2),
    @IdStation INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY


        -- Validar si el código de kiosco es incorrecto para la estación existente
        IF NOT EXISTS (
            SELECT 1
            FROM DeliveryBackOffice.dbo.del_ParametrosFactura FAC
            INNER JOIN DeliveryBackOffice.dbo.CatStation CAT
            ON FAC.dpf_VpCodeOfReference = CAT.CodeOfReference
            WHERE FAC.KioskCode = @KioskCode
              AND CAT.IdStation = @IdStation
              AND CAT.CountryId = @IdCountry
        )
        BEGIN
            SELECT 400 AS [StatusCode],
				   'El código de kiosco no es válido para esta estación.' AS [Description]
            RETURN;
        END

        -- Consulta principal
        SELECT 
			200						AS [StatusCode],
			'Informacion Obtenida'	AS [Description],
            CAT.IdStation			AS [IdStation],
            CAT.CountryId			AS [CountryId],	
			CAT.StationName			AS [StationName],
            FAC.KioskCode			AS [KioskCode]
        FROM 
            DeliveryBackOffice.dbo.VisitPointClient VPC WITH(NOLOCK)
        INNER JOIN 
            DeliveryBackOffice.dbo.CatStation CAT WITH(NOLOCK)
            ON VPC.CodeOfReference = CAT.CodeOfReference
        INNER JOIN 
            DeliveryBackOffice.dbo.del_ParametrosFactura FAC WITH(NOLOCK)
            ON VPC.CodeOfReference = FAC.dpf_VpCodeOfReference 
        WHERE 
            VPC.IdKindOfVPBusiness IN (8, 21) -- EXPRESS CENTER
            AND VPC.StatusClient = 1
            AND FAC.KioskCode = @KioskCode
            AND CAT.CountryId = @IdCountry
            AND CAT.IdStation = @IdStation
        ORDER BY 
            VPC.IdVisitPointClient ASC;
    END TRY
    BEGIN CATCH
        -- Capturar errores
        DECLARE 
            @ErrorMessage NVARCHAR(4000),
            @ErrorSeverity INT,
            @ErrorState INT;

        SELECT 
            @ErrorMessage = ERROR_MESSAGE(),
            @ErrorSeverity = ERROR_SEVERITY(),
            @ErrorState = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
