/* =================================================
   SP:        [dbo].[supportCreateNewExcV2]
   Propósito: Crear nuevo punto de visita de tipo exc para multipais.
   Autor:     Brandon Pedroza
   Historia:  ---
   Fecha:     2024-07-30

=== CHANGELOG ============================

2025-10-29 | Historia/épica: FDAPI-4454 | Autor: Brandon Pedroza |

-- =============================================
-- Author:		<Kevin Oliva>
-- Create date: <2025-12-26>
-- Description:	<Se agrega la generacion de kiokocode automatica>
-- =============================================

-- =============================================
-- Author:		<Kevin Oliva>
-- Create date: <2026-02-17>
-- Description:	<se cambia instruccion de Alter a Create>
-- =============================================

=========================================== */

CREATE PROCEDURE [dbo].[supportCreateNewExcV2]
    @DescriptionOfClient NVARCHAR(100),
    @TokenSupport NVARCHAR(50),
    @Address NVARCHAR(600),
    @IdSettlement INT,
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

	DECLARE @PrefixNumber VARCHAR(8);
	DECLARE @PhoneNumber VARCHAR(50);
	-- Verificar si el formato es correcto (8 dígitos)
		IF @Phone LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
		BEGIN
			SET @PrefixNumber = (SELECT PrefixNumber FROM DefaultValuesPerCountry WHERE IdCountry = @IdCountry)
			-- Formatear la cadena
			SET @PhoneNumber = @PrefixNumber + SUBSTRING(@Phone, 1, 4) + '-' + SUBSTRING(@Phone, 5, 4)
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
            FROM dbo.Township tw WITH (NOLOCK)
                INNER JOIN dbo.Province pr WITH (NOLOCK)
                    ON pr.IdProvince = tw.IdProvince
				INNER JOIN dbo.Settlement st WITH(NOLOCK)
					ON st.IdProvince = pr.IdProvince
					AND st.IdTownship = tw.IdTownship
            WHERE  st.IdSettlement = @IdSettlement
			AND st.IdCountry = @IdCountry
			AND st.SettlementSatus = 1
		)
		BEGIN
			RAISERROR('El poblado no pertene al pais especificado o esta inhabilitado', 16, 1);
			RETURN;
		END

        IF NOT EXISTS -- verifica que el punto de visita no exista
        (
            SELECT 1
            FROM dbo.VisitPointClient vp
            WHERE vp.DescriptionOfClient = @DescriptionOfClient
                  AND CountryId = @IdCountry
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
                  AND IdCountry = @IdCountry

            SELECT @IdKindOfVPClient = IdKindOfVPClient
            FROM KindOfVPClient WITH(NOLOCK)
            WHERE KindOfVPName = 'Express Center'
                  AND IdCountry = @IdCountry

            SELECT @IdBusinessSegment = IdBusinessSegment
            FROM CatBusinessSegment WITH(NOLOCK)
            WHERE BusinessSegmentName = 'C2C'
                  AND IdCountry = @IdCountry

            IF(@IdCountry != 'GT')
            BEGIN
                SELECT TOP 1 @IdCustomer = IdCustomer
                FROM Customer WITH(NOLOCK)
                WHERE Name like '%FD EXPRESS CENTER%'
                      --AND IdCustomer IN(81, 68381)
                      AND CountryID = @IdCountry
            END
            ELSE
            BEGIN
                SELECT TOP 1 @IdCustomer = IdCustomer
                FROM Customer WITH(NOLOCK)
                WHERE Name like '%FD EXPRESS CENTER ' + @IdCountry + '%'
                      --AND IdCustomer IN(81, 68381)
                      AND CountryID = @IdCountry
            END

            SELECT @CodeOfReference = MAX(vp.CodeOfReference) + 1
            FROM dbo.VisitPointClient vp
            --WHERE vp.IdKindOfVPBusiness = @IdKindOfVPBusiness;
            -- Obtener departamento y municipio

            DECLARE @IdProvice INT;
            DECLARE @ProvinceName NVARCHAR(100);
            DECLARE @TownshipName NVARCHAR(100);
            DECLARE @IdTownship INT;


            SELECT TOP 1
					@IdProvice = pr.IdProvince,
					@ProvinceName = pr.ProvinceName,
					@TownshipName = tw.TownshipName,
					@IdTownship = tw.IdTownship
            FROM dbo.Township tw WITH (NOLOCK)
                INNER JOIN dbo.Province pr WITH (NOLOCK)
                    ON pr.IdProvince = tw.IdProvince
				INNER JOIN dbo.Settlement se WITH (NOLOCK)
					ON se.IdProvince = pr.IdProvince AND se.IdTownship = tw.IdTownship
            WHERE se.IdSettlement = @IdSettlement;


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

            -- Generar KioskCode único
            DECLARE @Codigo INT;
            DECLARE @CodigoFinal VARCHAR(4);
            SET @Codigo = FLOOR(RAND() * 10000);
            
            WHILE EXISTS (SELECT 1 FROM dbo.del_ParametrosFactura WITH(NOLOCK) WHERE kioskcode = @Codigo)
            BEGIN
                SET @Codigo = FLOOR(RAND() * 10000);
            END
            
            SET @CodigoFinal = RIGHT('0000' + CAST(@Codigo AS VARCHAR(4)), 4);

			IF(@IdCountry <> 'GT')
			BEGIN
				IF NOT EXISTS
				(
					SELECT 1
					FROM dbo.del_ParametrosFactura pr WITH (NOLOCK)
					WHERE pr.dpf_VpCodeOfReference = @CodeOfReference
					AND pr.dpf_FELCountry = @IdCountry
				)
				BEGIN

					DECLARE @CountryName AS NVARCHAR(32);
					DECLARE @vpCodeOfReference AS INT;

					SET @CountryName = (SELECT CountryNameES FROM CatCountry WHERE IdCountry = @IdCountry)
					SET @vpCodeOfReference = (SELECT TOP 1  dpf_VpCodeOfReference FROM del_ParametrosFactura WHERE dpf_FELCountry = @IdCountry)

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
						inv_cmp_nameComercial,
						kioskcode
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
						   'Delivery Express ' + @CountryName +' S.A. De C.V.',
						   'DELIVERY EXPRESS ' + @IdCountry,
						   @CodigoFinal
					FROM dbo.del_ParametrosFactura pr WITH (NOLOCK)
					WHERE pr.dpf_VpCodeOfReference = @vpCodeOfReference;
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
					SELECT 1
					FROM dbo.del_ParametrosFactura pr WITH (NOLOCK)
					WHERE pr.dpf_VpCodeOfReference = @CodeOfReference
					AND pr.dpf_FELCountry = @IdCountry
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
						kioskcode
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
						   @SapOcrCode,
						   @CodigoFinal
					FROM dbo.del_ParametrosFactura pr WITH (NOLOCK)
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


            SELECT dpf_VpCodeOfReference
                  ,dpf_FELRequestor
                  ,dpf_FELTransaction
                  ,dpf_FELCountry
                  ,dpf_FELEntity
                  ,dpf_FELUser
                  ,dpf_FELCorreo
                  ,kioskcode
            FROM dbo.del_ParametrosFactura pr WITH (NOLOCK)
            WHERE pr.dpf_VpCodeOfReference = @CodeOfReference;

            SELECT IdStation
                  ,StationName
                  ,CountryId
                  ,StationType
                  ,HubLogisticId
                  ,CodeOfReference
            FROM CatStation WITH (NOLOCK)
            WHERE CodeOfReference = @CodeOfReference

        END;
        ELSE
        BEGIN
            SELECT 'Este punto de visita ya existe';
        END;

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        SELECT ERROR_LINE() AS ErrorLine,
               ERROR_MESSAGE() AS ErrorMessage,
               ERROR_NUMBER() AS ErrorNumber,
               ERROR_STATE() AS ErrorState;

    END CATCH;

END;
GO
