-- =============================================
-- Author:		<César Aquino>
-- Create date: <11-07-2023>
-- Description:	<Crear nuevo punto de visita de tipo exc>
-- =============================================
CREATE PROCEDURE [dbo].[supportCreateNewExc]
    @DescriptionOfClient NVARCHAR(100)
  , @TokenSupport NVARCHAR(50)
  , @Address NVARCHAR(600)
  , @IdTownship INT
  , @zone INT = 0
  , @Phone NVARCHAR(10)
  , @ContactName NVARCHAR(100)
  , @Email NVARCHAR(100)
  , @DescriptionCC NVARCHAR(100)
  , @EstablishmentNumber NVARCHAR(15)
  , @SapInvoiceSerie NVARCHAR(50)
  , @SapCreditNoteSerie NVARCHAR(50)
  , @SapPaymetSerie NVARCHAR(50)
  , @SapCardCode NVARCHAR(50)
  , @SapOcrCode NVARCHAR(50)
AS
BEGIN

    BEGIN TRY


        IF NOT EXISTS -- verifica que el punto de visita no exista
        (
            SELECT *
            FROM dbo.VisitPointClient vp
            WHERE vp.DescriptionOfClient = @DescriptionOfClient
        )
        BEGIN
            BEGIN TRANSACTION;
            -- obtener numero

            DECLARE @CodeOfReference INT;

            SELECT @CodeOfReference = MAX(vp.CodeOfReference) + 1
            FROM dbo.VisitPointClient vp
            WHERE vp.IdKindOfVPBusiness = 8;

            -- Obtener departamento y municipio

            DECLARE @IdProvice INT;
            DECLARE @ProvinceName NVARCHAR(100);
            DECLARE @TownshipName NVARCHAR(100);


            SELECT @IdProvice    = pr.IdProvince
                 , @ProvinceName = pr.ProvinceName
                 , @TownshipName = tw.TownshipName
            FROM dbo.Township           tw
                INNER JOIN dbo.Province pr
                    ON pr.IdProvince = tw.IdProvince
            WHERE tw.IdTownship = @IdTownship;


            INSERT INTO dbo.VisitPointClient
            (
                CodeOfReference
              , DescriptionOfClient
              , StatusClient
              , CountryId
              , VisitPointId
              , TokenCreated
              , DateCreated
              , TokenUpdated
              , DateUpdated
              , CustomerID
              , Address
              , Zone
              , Town
              , Department
              , Phone
              , ContactName
              , IdKindOfVPClient
              , IdKindOfVPBusiness
              , IdSettlement
              , Email
              , IdTownship
              , Latitude
              , Longitude
              , Accuracy
              , BranchCode
              , SaleChannelId
              , ExcludePriceShippingCOD
              , ExcludeCommissionCOD
              , IsOriginVisitPoint
              , LogLatitude
              , LogLongitude
              , DescriptionCC
              , CatBusinessSegmentId
              , AllowScheduledPickups
            )
            VALUES
            (   @CodeOfReference                        -- CodeOfReference - int
              , @DescriptionOfClient                    -- DescriptionOfClient - nvarchar(100)
              , 1                                       -- StatusClient - bit
              , N'GT'                                   -- CountryId - nvarchar(2)
              , NULL                                    -- VisitPointId - bigint
              , @TokenSupport                           -- TokenCreated - nvarchar(50)
              , GETDATE()                               -- DateCreated - datetime
              , NULL                                    -- TokenUpdated - nvarchar(50)
              , NULL                                    -- DateUpdated - datetime
              , 81                                      -- CustomerID - int
              , @Address                                -- Address - nvarchar(600)
              , CONVERT(NVARCHAR(2), @zone)             -- Zone - nvarchar(100)
              , @TownshipName                           -- Town - nvarchar(100)
              , @ProvinceName                           -- Department - nvarchar(100)
              , @Phone                                  -- Phone - nvarchar(50)
              , @ContactName                            -- ContactName - nvarchar(200)
              , 1                                       -- IdKindOfVPClient - int Express Center
              , 8                                       -- IdKindOfVPBusiness - int EXPRESS CENTER
              , NULL                                    -- IdSettlement - bigint
              , @Email                                  -- Email - nvarchar(200)
              , @IdTownship                             -- IdTownship - int
              , NULL                                    -- Latitude - varchar(50)
              , NULL                                    -- Longitude - varchar(50)
              , NULL                                    -- Accuracy - varchar(50)
              , CONVERT(NVARCHAR(50), @CodeOfReference) -- BranchCode - nvarchar(50)
              , 1                                       -- SaleChannelId - int Express Center
              , NULL                                    -- ExcludePriceShippingCOD - bit
              , NULL                                    -- ExcludeCommissionCOD - bit
              , 1                                       -- IsOriginVisitPoint - bit
              , NULL                                    -- LogLatitude - nvarchar(20)
              , NULL                                    -- LogLongitude - nvarchar(20)
              , @DescriptionCC                          -- DescriptionCC - nvarchar(100)
              , 10                                      -- CatBusinessSegmentId - int 10	C2C
              , DEFAULT                                 -- AllowScheduledPickups - bit
                );


            IF NOT EXISTS
            (
                SELECT *
                FROM dbo.del_ParametrosFactura pr
                WHERE pr.dpf_VpCodeOfReference = @CodeOfReference
            )
            BEGIN

                INSERT INTO dbo.del_ParametrosFactura
                (
                    dpf_VpCodeOfReference
                  , dpf_FELRequestor
                  , dpf_FELTransaction
                  , dpf_FELCountry
                  , dpf_FELEntity
                  , dpf_FELUser
                  , dpf_FELUserName
                  , dpf_FELData1
                  , dpf_FELData3
                  , dpf_FELCorreo
                  , dpf_FELAsuntoCorreoFactura
                  , dpf_FELAsuntoCorreoNotaCredito
                  , dpf_FELEstablecimiento
                  , dpf_FELCorreoCCO
                  , dpf_SAPServidorLicencias
                  , dpf_SAPCompania
                  , dpf_SAPUsuario
                  , dpf_SAPContrasenia
                  , dpf_SAPServidor
                  , dpf_SAPUsuarioBD
                  , dpf_SAPContraseniaBD
                  , dpf_SAPserieFactura
                  , dpf_SAPserieNC
                  , dpf_SAPseriePago
                  , dpf_SAPcardCode
                  , dpf_SAParticulo
                  , dpf_SAPvendor
                  , dpf_SAPcreditCard
                  , dpf_OcrCode
                  , dpf_OcrCode2
                  , dpf_StatusFACE
                  , dpf_WarehouseCode
                )
                SELECT @CodeOfReference
                     , pr.dpf_FELRequestor
                     , pr.dpf_FELTransaction
                     , pr.dpf_FELCountry
                     , pr.dpf_FELEntity
                     , pr.dpf_FELUser
                     , pr.dpf_FELUserName
                     , pr.dpf_FELData1
                     , pr.dpf_FELData3
                     , pr.dpf_FELCorreo
                     , pr.dpf_FELAsuntoCorreoFactura
                     , pr.dpf_FELAsuntoCorreoNotaCredito
                     , @EstablishmentNumber
                     , @Email
                     , pr.dpf_SAPServidorLicencias
                     , pr.dpf_SAPCompania
                     , pr.dpf_SAPUsuario
                     , pr.dpf_SAPContrasenia
                     , pr.dpf_SAPServidor
                     , pr.dpf_SAPUsuarioBD
                     , pr.dpf_SAPContraseniaBD
                     , @SapInvoiceSerie
                     , @SapCreditNoteSerie
                     , @SapPaymetSerie
                     , @SapCardCode
                     , pr.dpf_SAParticulo
                     , pr.dpf_SAPvendor
                     , pr.dpf_SAPcreditCard
                     , @SapOcrCode
                     , pr.dpf_OcrCode2
                     , pr.dpf_StatusFACE
                     , @SapOcrCode
                FROM dbo.del_ParametrosFactura pr
                WHERE pr.dpf_VpCodeOfReference = 999;

            END;
            ELSE
            BEGIN
                SELECT 'No se configuró información de facturación porque ya existia';
            END;

            COMMIT;


            SELECT vp.CodeOfReference
                 , vp.DescriptionOfClient
                 , vp.TokenCreated
                 , vp.Address
                 , vp.Town
                 , vp.Department
                 , vp.Email
            FROM dbo.VisitPointClient vp WITH (NOLOCK)
            WHERE vp.CodeOfReference = @CodeOfReference;


            SELECT *
            FROM dbo.del_ParametrosFactura pr
            WHERE pr.dpf_VpCodeOfReference = @CodeOfReference;
        END;
        ELSE
        BEGIN
            SELECT 'Este punto de visita ya existe';
        END;




    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT ERROR_LINE()
             , ERROR_MESSAGE()
             , ERROR_NUMBER()
             , ERROR_STATE();

    END CATCH;

END;