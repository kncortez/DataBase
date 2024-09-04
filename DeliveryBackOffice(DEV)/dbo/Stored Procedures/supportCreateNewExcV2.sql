-- =============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <07-30-2024>
-- Description:	<Crear nuevo punto de visita de tipo exc para multipais>
-- =============================================
CREATE PROCEDURE [dbo].[supportCreateNewExcV2]
    @DescriptionOfClient NVARCHAR(100),
    @TokenSupport NVARCHAR(50),
    @Address NVARCHAR(600),
    @IdTownship INT,
    @zone INT = 0,
    @Phone NVARCHAR(10),
    @ContactName NVARCHAR(100),
    @Email NVARCHAR(100),
    @DescriptionCC NVARCHAR(100),
    @EstablishmentNumber NVARCHAR(15),
    @SapInvoiceSerie NVARCHAR(50),
    @SapCreditNoteSerie NVARCHAR(50),
    @SapPaymetSerie NVARCHAR(50),
    @SapCardCode NVARCHAR(50),
    @SapOcrCode NVARCHAR(50),
	@SapOcrCode2 NVARCHAR(50),
    @IdCountry NVARCHAR(2) = 'GT'
AS
BEGIN

    BEGIN TRY
	
		BEGIN TRANSACTION;
            
	DECLARE @PhoneNumber VARCHAR(50);
	-- Verificar si el formato es correcto (8 dígitos)
		IF @Phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		BEGIN
			-- Formatear la cadena
			SET @PhoneNumber = '('+IIF(@IdCountry = 'HN','504','502')+') ' + SUBSTRING(@Phone, 1, 4) + '-' + SUBSTRING(@Phone, 5, 4)
		END
		ELSE
		BEGIN
			--SELECT 'Formato telefonico incorrecto'
			RAISERROR('Formato telefonico incorrecto', 16, 1);
			RETURN;
		END

		IF NOT EXISTS
		(
			SELECT pr.IdProvince,
                   pr.ProvinceName,
                   tw.TownshipName
            FROM dbo.Township tw
                INNER JOIN dbo.Province pr
                    ON pr.IdProvince = tw.IdProvince
            WHERE  tw.IdTownship = @IdTownship
			AND ISNULL(pr.IdCountry,'GT') = @IdCountry
		)
		BEGIN
			RAISERROR('El municipio no pertene al pais especificado', 16, 1);
			RETURN;
		END

        IF NOT EXISTS -- verifica que el punto de visita no exista
        (
            SELECT *
            FROM dbo.VisitPointClient vp
            WHERE vp.DescriptionOfClient = @DescriptionOfClient
        )
        BEGIN		

            DECLARE @CodeOfReference INT;
            DECLARE @IdKindOfVPBusiness INT;
            DECLARE @IdKindOfVPClient INT;
            DECLARE @IdBusinessSegment INT;
			DECLARE @IdCustomer INT;

            SELECT @IdKindOfVPBusiness = IdKindOfVPBusiness
            FROM KindOfVPBusiness WITH(NOLOCK)
            WHERE Shorthand = 'EXP'
                  AND ISNULL(IdCountry, 'GT') = @IdCountry

            SELECT @IdKindOfVPClient = IdKindOfVPClient
            FROM KindOfVPClient WITH(NOLOCK)
            WHERE KindOfVPName = 'Express Center'
                  AND ISNULL(IdCountry, 'GT') = @IdCountry

            SELECT @IdBusinessSegment = IdBusinessSegment
            FROM CatBusinessSegment WITH(NOLOCK)
            WHERE BusinessSegmentName = 'C2C'
                  AND ISNULL(IdCountry, 'GT') = @IdCountry

			SELECT @IdCustomer = IdCustomer
            FROM Customer WITH(NOLOCK)
            WHERE Name like '%FD EXPRESS CENTER%'
				  AND IdCustomer IN(81, 68381)
                  AND ISNULL(CountryID, 'GT') = @IdCountry

            SELECT @CodeOfReference = MAX(vp.CodeOfReference) + 1
            FROM dbo.VisitPointClient vp
            --WHERE vp.IdKindOfVPBusiness = @IdKindOfVPBusiness;
            -- Obtener departamento y municipio

            DECLARE @IdProvice INT;
            DECLARE @ProvinceName NVARCHAR(100);
            DECLARE @TownshipName NVARCHAR(100);
			DECLARE @IdSettlement INT;


            SELECT TOP 1
					@IdProvice = pr.IdProvince,
					@ProvinceName = pr.ProvinceName,
					@TownshipName = tw.TownshipName,
					@IdSettlement = se.IdSettlement
            FROM dbo.Township tw
                INNER JOIN dbo.Province pr
                    ON pr.IdProvince = tw.IdProvince
				INNER JOIN dbo.Settlement se
					ON se.IdProvince = pr.IdProvince AND se.IdTownship = tw.IdTownship
            WHERE tw.IdTownship = @IdTownship;
	

            INSERT INTO dbo.VisitPointClient
            (
                CodeOfReference,
                DescriptionOfClient,
                StatusClient,
                CountryId,
                VisitPointId,
                TokenCreated,
                DateCreated,
                TokenUpdated,
                DateUpdated,
                CustomerID,
                Address,
                Zone,
                Town,
                Department,
                Phone,
                ContactName,
                IdKindOfVPClient,
                IdKindOfVPBusiness,
                IdSettlement,
                Email,
                IdTownship,
                Latitude,
                Longitude,
                Accuracy,
                BranchCode,
                SaleChannelId,
                ExcludePriceShippingCOD,
                ExcludeCommissionCOD,
                IsOriginVisitPoint,
                LogLatitude,
                LogLongitude,
                DescriptionCC,
                CatBusinessSegmentId,
                AllowScheduledPickups
            )
            VALUES
            (   @CodeOfReference,                        -- CodeOfReference - int
                @DescriptionOfClient,                    -- DescriptionOfClient - nvarchar(100)
                1,                                       -- StatusClient - bit
                @IdCountry,                              -- CountryId - nvarchar(2)
                NULL,                                    -- VisitPointId - bigint
                @TokenSupport,                           -- TokenCreated - nvarchar(50)
                GETDATE(),                               -- DateCreated - datetime
                NULL,                                    -- TokenUpdated - nvarchar(50)
                NULL,                                    -- DateUpdated - datetime
                @IdCustomer,                             -- CustomerID - int
                @Address,                                -- Address - nvarchar(600)
                CONVERT(NVARCHAR(2), @zone),             -- Zone - nvarchar(100)
                @TownshipName,                           -- Town - nvarchar(100)
                @ProvinceName,                           -- Department - nvarchar(100)
                @PhoneNumber,                            -- Phone - nvarchar(50)   (50x) xxxx-xxxx
                @ContactName,                            -- ContactName - nvarchar(200)
                @IdKindOfVPClient,                       -- IdKindOfVPClient - int Express Center   -- 1 EXC para GT, 12 EXC para HN
                @IdKindOfVPBusiness,                     -- IdKindOfVPBusiness - int EXPRESS CENTER -- 8 EXC para GT, 21 EXC para HN
                @IdSettlement,                           -- IdSettlement - bigint
                @Email,                                  -- Email - nvarchar(200)
                @IdTownship,                             -- IdTownship - int
                NULL,                                    -- Latitude - varchar(50)
                NULL,                                    -- Longitude - varchar(50)
                NULL,                                    -- Accuracy - varchar(50)
                CONVERT(NVARCHAR(50), @CodeOfReference), -- BranchCode - nvarchar(50)
                1,                                       -- SaleChannelId - int Express Center
                NULL,                                    -- ExcludePriceShippingCOD - bit
                NULL,                                    -- ExcludeCommissionCOD - bit
                1,                                       -- IsOriginVisitPoint - bit
                NULL,                                    -- LogLatitude - nvarchar(20)
                NULL,                                    -- LogLongitude - nvarchar(20)
                @DescriptionCC,                          -- DescriptionCC - nvarchar(100)
                @IdBusinessSegment,                      -- CatBusinessSegmentId - int 10	C2C GT --- int 21 C2C HN
                DEFAULT                                  -- AllowScheduledPickups - bit
            );

			IF(@IdCountry = 'HN')
			BEGIN
				IF NOT EXISTS
				(
					SELECT *
					FROM dbo.del_ParametrosFactura pr
					WHERE pr.dpf_VpCodeOfReference = @CodeOfReference
				)
				BEGIN
					INSERT INTO dbo.del_ParametrosFactura
					(
						dpf_VpCodeOfReference,
						dpf_FELRequestor,
						dpf_FELTransaction,
						dpf_FELCountry,
						dpf_FELEntity,
						dpf_FELUser,
						dpf_FELUserName,
						dpf_FELData1,
						dpf_FELData3,
						dpf_FELCorreo,
						dpf_FELAsuntoCorreoFactura,
						dpf_FELAsuntoCorreoNotaCredito,
						dpf_FELEstablecimiento,
						dpf_FELCorreoCCO,
						dpf_SAPServidorLicencias,
						dpf_SAPCompania,
						dpf_SAPUsuario,
						dpf_SAPContrasenia,
						dpf_SAPServidor,
						dpf_SAPUsuarioBD,
						dpf_SAPContraseniaBD,
						dpf_SAPserieFactura,
						dpf_SAPserieNC,
						dpf_SAPseriePago,
						dpf_SAPcardCode,
						dpf_SAParticulo,
						dpf_SAPvendor,
						dpf_SAPcreditCard,
						dpf_OcrCode,
						dpf_OcrCode2,
						dpf_StatusFACE,
						dpf_WarehouseCode,
						inv_cmp_name,
						inv_cmp_nameComercial
					)
					SELECT @CodeOfReference,
						   pr.dpf_FELRequestor,
						   pr.dpf_FELTransaction,
						   pr.dpf_FELCountry,
						   pr.dpf_FELEntity,
						   pr.dpf_FELUser,
						   pr.dpf_FELUserName,
						   pr.dpf_FELData1,
						   pr.dpf_FELData3,
						   pr.dpf_FELCorreo,
						   pr.dpf_FELAsuntoCorreoFactura,
						   pr.dpf_FELAsuntoCorreoNotaCredito,
						   @EstablishmentNumber,
						   @Email,
						   pr.dpf_SAPServidorLicencias,
						   pr.dpf_SAPCompania,
						   pr.dpf_SAPUsuario,
						   pr.dpf_SAPContrasenia,
						   pr.dpf_SAPServidor,
						   pr.dpf_SAPUsuarioBD,
						   pr.dpf_SAPContraseniaBD,
						   @SapInvoiceSerie,
						   @SapCreditNoteSerie,
						   @SapPaymetSerie,
						   @SapCardCode,
						   pr.dpf_SAParticulo,
						   pr.dpf_SAPvendor,
						   pr.dpf_SAPcreditCard,
						   @SapOcrCode,
						   @SapOcrCode2,
						   pr.dpf_StatusFACE,
						   @SapOcrCode,
						   'DELIVERY EXPRESS HONDURAS',
						   'DELIVERY EXPRESS HN'
					FROM dbo.del_ParametrosFactura pr
					WHERE pr.dpf_VpCodeOfReference = 677882;
				END;
				ELSE
				BEGIN
					RAISERROR('No se configuró información de facturación porque ya existia', 16, 1);
				END;
			END;
			ELSE
			BEGIN
				IF NOT EXISTS
				(
					SELECT *
					FROM dbo.del_ParametrosFactura pr
					WHERE pr.dpf_VpCodeOfReference = @CodeOfReference
				)
				BEGIN

					INSERT INTO dbo.del_ParametrosFactura
					(
						dpf_VpCodeOfReference,
						dpf_FELRequestor,
						dpf_FELTransaction,
						dpf_FELCountry,
						dpf_FELEntity,
						dpf_FELUser,
						dpf_FELUserName,
						dpf_FELData1,
						dpf_FELData3,
						dpf_FELCorreo,
						dpf_FELAsuntoCorreoFactura,
						dpf_FELAsuntoCorreoNotaCredito,
						dpf_FELEstablecimiento,
						dpf_FELCorreoCCO,
						dpf_SAPServidorLicencias,
						dpf_SAPCompania,
						dpf_SAPUsuario,
						dpf_SAPContrasenia,
						dpf_SAPServidor,
						dpf_SAPUsuarioBD,
						dpf_SAPContraseniaBD,
						dpf_SAPserieFactura,
						dpf_SAPserieNC,
						dpf_SAPseriePago,
						dpf_SAPcardCode,
						dpf_SAParticulo,
						dpf_SAPvendor,
						dpf_SAPcreditCard,
						dpf_OcrCode,
						dpf_OcrCode2,
						dpf_StatusFACE,
						dpf_WarehouseCode
					)
					SELECT @CodeOfReference,
						   pr.dpf_FELRequestor,
						   pr.dpf_FELTransaction,
						   pr.dpf_FELCountry,
						   pr.dpf_FELEntity,
						   pr.dpf_FELUser,
						   pr.dpf_FELUserName,
						   pr.dpf_FELData1,
						   pr.dpf_FELData3,
						   pr.dpf_FELCorreo,
						   pr.dpf_FELAsuntoCorreoFactura,
						   pr.dpf_FELAsuntoCorreoNotaCredito,
						   @EstablishmentNumber,
						   @Email,
						   pr.dpf_SAPServidorLicencias,
						   pr.dpf_SAPCompania,
						   pr.dpf_SAPUsuario,
						   pr.dpf_SAPContrasenia,
						   pr.dpf_SAPServidor,
						   pr.dpf_SAPUsuarioBD,
						   pr.dpf_SAPContraseniaBD,
						   @SapInvoiceSerie,
						   @SapCreditNoteSerie,
						   @SapPaymetSerie,
						   @SapCardCode,
						   pr.dpf_SAParticulo,
						   pr.dpf_SAPvendor,
						   pr.dpf_SAPcreditCard,
						   @SapOcrCode,
						   pr.dpf_OcrCode2,
						   pr.dpf_StatusFACE,
						   @SapOcrCode
					FROM dbo.del_ParametrosFactura pr
					WHERE pr.dpf_VpCodeOfReference = 999;

				END;
				ELSE
				BEGIN
				
					RAISERROR('No se configuró información de facturación porque ya existia', 16, 1);
				END;
			END;
            COMMIT;

			INSERT INTO CatStation VALUES (@DescriptionOfClient, @IdCountry,2,NULL,@CodeOfReference,1,@TokenSupport,GETDATE(),NULL,NULL);


            SELECT vp.CodeOfReference,
                   vp.DescriptionOfClient,
                   vp.TokenCreated,
                   vp.Address,
                   vp.Town,
                   vp.Department,
                   vp.Email
            FROM dbo.VisitPointClient vp WITH (NOLOCK)
            WHERE vp.CodeOfReference = @CodeOfReference;


            SELECT *
            FROM dbo.del_ParametrosFactura pr
            WHERE pr.dpf_VpCodeOfReference = @CodeOfReference;

			SELECT *
			FROM CatStation 
			WHERE CodeOfReference = @CodeOfReference

        END;
        ELSE
        BEGIN
            SELECT 'Este punto de visita ya existe';
        END;




    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_LINE(),
               ERROR_MESSAGE(),
               ERROR_NUMBER(),
               ERROR_STATE();

    END CATCH;

END;