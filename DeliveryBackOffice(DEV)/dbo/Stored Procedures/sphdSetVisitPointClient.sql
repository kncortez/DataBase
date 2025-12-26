-- =============================================
-- Author:		<Edwin Ramirez>
-- Create date: <2021-06-04>
-- Description:	<creación o modificación de valores>
-- =============================================
-- =============================================
-- Author:		<Edelman>
-- Create date: <2023-03-31>
-- Description:	<agragar campos para configuración de tiempo de facturación y volumen de facturación>
-- =============================================
-- =============================================
-- Modified:	<Brandon Pedroza>
-- Update date: <2025-08-14>
-- Description:	<Guias Rapidas - Se guarda nuevo campo RestrictionByArticle, indica si restringue uso a tarifario por articulo>
-- =============================================
-- Modified:	<Bilkar Morataya>
-- Update date: <2025-12-26>
-- Description:	<Parser - Se guarda combinación de posibles tipos de guías a crear por un VisitPoint>
-- =============================================
CREATE PROCEDURE [dbo].[sphdSetVisitPointClient]
    -- Add the parameters for the stored procedure here
    @IdVisitPoint AS INT,
    @DescriptionOfClient NVARCHAR(100),
    @CountryId VARCHAR(2),
    @CustomerID INT,
    @Address AS NVARCHAR(600),
    @Zone AS NVARCHAR(100),
    @Township AS NVARCHAR(100),
    @Province AS NVARCHAR(100),
    @Phone AS NVARCHAR(50),
    @ContactName AS NVARCHAR(50),
    @IdKindOfVPClient AS INT,
    @IdKindOfVPBusiness AS INT,
    @IdSettlement AS BIGINT,
    @Email AS NVARCHAR(200),
    @IdTownship AS INT = NULL,
    @Latitude AS NVARCHAR(50) = NULL,
    @Longitude AS NVARCHAR(50) = NULL,
    @Accuracy AS NVARCHAR(50) = NULL,
    @BranchCode AS NVARCHAR(50) = NULL,
    @IdHubLogistics AS INT = NULL,
    @IdTransportCompany AS INT = NULL,
    @AveragePackageDaily AS INT = NULL,
    @DateStartOperation AS DATETIME = NULL,
    @CODAccountBankID AS INT = NULL,
    @CODAccountName AS NVARCHAR(50) = NULL,
    @CODAccountNumber AS NVARCHAR(50) = NULL,
    @CODAccountBankTypeID AS INT = NULL,
    @CODAccountCurrencyID AS INT = NULL,
	@CODExcludedPriceShipping AS BIT = 'FALSE',
	@CODExcludedCommission AS BIT = 'FALSE',
    @RowStatus AS BIT = 'TRUE',
    @Token AS NVARCHAR(50) = NULL,
    @TblVPFrequency AS TblVPFrequency READONLY,
    @TblVPItinerary AS TblVPItinerary READONLY,
    @TblVPCoverage AS TblVPCoverage READONLY,
    @TblVPDestination AS TblVPDestination READONLY,
    @IdVPConfiguration AS BIGINT = NULL,
    @Option AS INT, --1 Insert Into , 2 Update,
	@CatBusinessSegmentId INT = NULL,
	@AllowScheduledPickups AS BIT = NULL,
	@CatBillingTimeId INT = 0,
	@CatBillingVolumeId INT = 0,
	@BillingCut_offDate AS DATE=NULL,
	@RestrictionByArticle AS BIT = 'FALSE',
	@ParserGuideTypes AS NVARCHAR(500) = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;


	IF (@CatBillingTimeId = -1)
	 Set @CatBillingTimeId =(Select IdCatBillingTime From [dbo].[CatBillingTime] CBT Where CBT.DescriptionBillingTime='Default(Cada domingo del mes y el día 2 del siguiente mes)')

	 IF(@CatBillingVolumeId = -1)
	 Set @CatBillingVolumeId =(Select IdCatBillingVolume From [dbo].[CatBillingVolume] CBV Where CBV.DescriptionBillingVolume ='Una guía por factura')

    DECLARE @blnCotinue AS BIT = 'TRUE';
	DECLARE @MessageError AS NVARCHAR(100) = '';
	DECLARE @IdResultVPConfig AS BIGINT = -1;
	DECLARE @IdResultVPFrequency AS BIGINT = -1;
    IF (@Token <> '')
    BEGIN
	    BEGIN TRANSACTION
        BEGIN TRY
				PRINT 'Begin Transaction'
				PRINT 'Begin Try'
		    IF (@Option = 1)
            BEGIN
                PRINT 'Insert visitpoint @Option 1'
				IF ((@CustomerID > 0)  AND (@IdVisitPoint = -1)
				   AND NOT EXISTS(SELECT vpc.IdVisitPointClient FROM dbo.VisitPointClient vpc 
									WHERE vpc.DescriptionOfClient =  @DescriptionOfClient 
									AND (vpc.CustomerID = @CustomerID)))
                BEGIN

					 DECLARE @CodeOfReference AS INT = -1;
					 SET @CodeOfReference = (SELECT TOP (1) vpc3.CodeOfReference + 1 FROM dbo.VisitPointClient vpc3 ORDER BY vpc3.CodeOfReference DESC)
					
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
						CatBusinessSegmentId,
						AllowScheduledPickups,
						RestrictionByArticle,
						ParserGuideTypes
                    )
                    VALUES
                    (   @CodeOfReference,        -- CodeOfReference - int
                        @DescriptionOfClient,	 -- DescriptionOfClient - nvarchar(100)
                        'TRUE',						-- StatusClient - bit
                        @CountryId,           -- CountryId - nvarchar(2)
                        NULL,                 -- VisitPointId - bigint
                        @Token,               -- TokenCreated - nvarchar(50)
                        GETDATE(),            -- DateCreated - datetime
                        NULL,                 -- TokenUpdated - nvarchar(50)
                        NULL,                 -- DateUpdated - datetime
                        @CustomerID,          -- CustomerID - int
                        @Address,             -- Address - nvarchar(600)
                        @Zone,                -- Zone - nvarchar(100)
                        @Township,            -- Town - nvarchar(100)
                        @Province,            -- Department - nvarchar(100)
                        @Phone,               -- Phone - nvarchar(50)
                        @ContactName,         -- ContactName - nvarchar(200)
                        4,--@IdKindOfVPClient,    -- IdKindOfVPClient - int
                        @IdKindOfVPBusiness,  -- IdKindOfVPBusiness - int
                        @IdSettlement,        -- IdSettlement - bigint
                        @Email,               -- Email - nvarchar(200)
                        @IdTownship,          -- IdTownship - int
                        @Latitude,            -- Latitude - varchar(50)
                        @Longitude,           -- Longitude - varchar(50)
                        @Accuracy,            -- Accuracy - varchar(50)
                        @BranchCode           -- BranchCode - nvarchar(50)
						,@IdKindOfVPClient,
						@CODExcludedPriceShipping,
						@CODExcludedCommission,
						@CatBusinessSegmentId,
						ISNULL(@AllowScheduledPickups, 1),
						@RestrictionByArticle,
						@ParserGuideTypes
                        )
					DECLARE @IDVP AS INT = -1
                    SET @IDVP = SCOPE_IDENTITY()
					SET @IdVisitPoint = @CodeOfReference
										PRINT 'Paso 1 VisitPointClient - @IDVP'
										PRINT @IDVP
										PRINT '@CodeOfReference' 
										PRINT @CodeOfReference
                    IF (@IDVP > 0)
                    BEGIN
                        INSERT INTO dbo.VisitPointConfiguration
                        (
                            VisitPointID,
                            TransportCompanyID,
                            HubLogisticID,
                            CODAccountBankID,
                            CODAccountName,
                            CODAccountNumber,
                            CODAccountBankTypeID,
                            CODAccountCurrencyID,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            TokenUpdated,
                            DateUpdated,
                            AveragePackageDaily,
                            DateStartOperation,
							CatBillingTimeId,
							CatBillingVolumeId,
							BillingCut_offDate
                        )
                        VALUES
                        (   @CodeOfReference,				   -- VisitPointID - int
                            @IdTransportCompany,   -- TransportCompanyID - int
                            @IdHubLogistics,       -- HubLogisticID - int
                            @CODAccountBankID,     -- CODAccountBankID - int
                            @CODAccountName,       -- CODAccountName - nvarchar(50)
                            @CODAccountNumber,     -- CODAccountNumber - nvarchar(50)
                            @CODAccountBankTypeID, -- CODAccountBankTypeID - int
                            @CODAccountCurrencyID, -- CODAccountCurrencyID - int
                            'TRUE',				   -- RowStatus - bit
                            @Token,                -- TokenCreated - nvarchar(50)
                            GETDATE(),             -- DateCreated - datetime
                            NULL,                  -- TokenUpdated - nvarchar(50)
                            NULL,                  -- DateUpdated - datetime
                            @AveragePackageDaily,  -- AveragePackageDaily - int
                            @DateStartOperation,    -- DateStartOperation - datetime
							@CatBillingTimeId,
							@CatBillingVolumeId,
							@BillingCut_offDate

                            )
                        DECLARE @IDVPCONF AS INT = -1
                        SET @IDVPCONF = SCOPE_IDENTITY()
						SET @IdResultVPConfig = @IDVPCONF
										PRINT 'Paso 2 VisitPointConfiguration - @IDVPCONF'
										PRINT @IDVPCONF
                        IF (@IDVPCONF > 0)
                        BEGIN
                            INSERT INTO dbo.VisitPointFrequency
                            (
                                VPConfigurationID,
                                SeasonID,
                                VisitsOnSunday,
                                VisitsOnMonday,
                                VisitsOnTuesday,
                                VisitsOnWednesday,
                                VisitsOnThursday,
                                VisitsOnFriday,
                                VisitsOnSaturday,
                                HubLogisticID,
                                RowStatus,
                                TokenCreated,
                                DateCreated,
                                TokenUpdated,
                                DateUpdated
                            )
                            (SELECT @IDVPCONF,
                                    vfq.[SeasonID],
                                    vfq.[VisitsOnSunday],
                                    vfq.[VisitsOnMonday],
                                    vfq.[VisitsOnTuesday],
                                    vfq.[VisitsOnWednesday],
                                    vfq.[VisitsOnThursday],
                                    vfq.[VisitsOnFriday],
                                    vfq.[VisitsOnSaturday],
                                    vfq.[HubLogisticID],
                                   'TRUE',
                                    @Token,
                                    GETDATE(),
                                    NULL,
                                    NULL
                             FROM @TblVPFrequency vfq)

                            DECLARE @IDVPFREQ AS BIGINT = -1
                            SET @IDVPFREQ = SCOPE_IDENTITY()
							SET @IdResultVPFrequency = @IDVPFREQ 
										PRINT 'Paso 3 VisitPointFrequency - @IDVPFREQ'
										PRINT @IDVPFREQ
                            IF (@IDVPFREQ > 0)
                            BEGIN

                                INSERT INTO dbo.VisitPointItinerary
                                (
                                    VPFrequencyID,
                                    DayOfVisit,
                                    InitializationTimeOfVisit,
                                    FinalizationTimeOfVisit,
                                    OrderSequence,
                                    --RouteCodeID,
                                    HubLogisticID,
                                    RowStatus,
                                    TokenCreated,
                                    DateCreated,
                                    TokenUpdated,
                                    DateUpdated
                                )
                                (SELECT @IDVPFREQ,
                                        vpi.[DayOfVisit],
                                        vpi.[InitializationTimeOfVisit],
                                        vpi.[FinalizationTimeOfVisit],
                                        1,--vpi.[OrderSequence],
                                        --vpi.[RouteCodeID],
                                        vpi.[HubLogisticID],
                                        'TRUE',
                                        @Token,
                                        GETDATE(),
                                        NULL,
                                        NULL
                                 FROM @TblVPItinerary vpi)
										PRINT 'Paso 4 VisitPointItinerary'

                                INSERT INTO dbo.VisitPointCoverage
                                (
                                    VisitPointId,
                                    HubLogisticId,
                                    SegmentId,
                                    RowStatus,
                                    TokenCreated,
                                    DateCreated,
                                    TokenUpdated,
                                    DateUpdated
                                )
                                (SELECT @CodeOfReference,
                                        vpcov.[HubLogisticId],
                                        vpcov.[SegmentId],
                                        'TRUE',
                                        @Token,
                                        GETDATE(),
                                        NULL,
                                        NULL
                                 FROM @TblVPCoverage vpcov);
										PRINT 'Paso 5 VisitPointCoverage'
                                INSERT INTO dbo.VisitPointDestination
                                (
                                    IdVPSource,
                                    IDVPDestiny,
                                    IsGuard,
                                    IsTransit,
                                    IsDefault,
                                    RowStatus,
                                    TokenCreated,
                                    DateCreated,
                                    TokenUpdated,
                                    DateUpdated
                                )
                                (SELECT @CodeOfReference,
                                        vpd.[IDVPDestiny],
                                        vpd.[IsGuard],
                                        vpd.[IsTransit],
                                        vpd.[IsDefault],
                                        'TRUE',
                                        @Token,
                                        GETDATE(),
                                        NULL,
                                        NULL
                                 FROM @TblVPDestination vpd);
										PRINT 'Paso 6 VisitPointDestination'
								--COMMIT

								SET @IdVisitPoint = @CodeOfReference
                                
                            END
							ELSE
                            BEGIN
									PRINT 'Paso 3.1 - No Trae VisitPointFrequency - @IDVPFREQ'
									PRINT @IDVPFREQ
								SET @MessageError = 'Paso 3 No Trae VisitPointFrequency - @IDVPFREQ'
								SET @blnCotinue = 'false'
                            END 
                        END
						ELSE
						BEGIN
									PRINT 'Paso 2.1 - No Trae  VisitPointConfiguration - @IDVPCONF'
									PRINT @IDVPCONF
							SET @MessageError = 'Paso 2 No Trae  VisitPointConfiguration - @IDVPCONF'
							SET @blnCotinue = 'false'
						END 
                    END
					ELSE
					BEGIN
										PRINT 'Paso 1.1 No Trae VisitPointClient- @IDVP'
										PRINT @IDVP
						SET @MessageError = 'Paso 1 VisitPointClient - No Trae VisitPointClient- @IDVP'
						SET @blnCotinue = 'false'
					END
					
                END
                ELSE
                BEGIN
					SET @MessageError = 'Option does not match with record exist in VisitPointClient'
					SET @blnCotinue = 'FALSE'
                END
            END

            IF (@Option = 2)
            BEGIN
				PRINT 'Update visitpoint @Option 2'
                IF ((@IdVisitPoint > 0) AND EXISTS (SELECT vpc.IdVisitPointClient FROM dbo.VisitPointClient vpc WHERE vpc.CodeOfReference = @IdVisitPoint)) 
                BEGIN
                    UPDATE DeliveryBackOffice.dbo.VisitPointClient
                    SET [DescriptionOfClient] = @DescriptionOfClient,
                        [StatusClient] = @RowStatus,
                        [CountryId] = @CountryId,
                        [TokenUpdated] = @Token,
                        [DateUpdated] = GETDATE(),
                        [CustomerID] = @CustomerID,
                        [Address] = @Address,
                        [Zone] = @Zone,
                        [Town] = @Township,
                        [Department] = @Province,
                        [Phone] = @Phone,
                        [ContactName] = @ContactName,
                        [IdKindOfVPClient] = [IdKindOfVPClient],--@IdKindOfVPClient,
                        [IdKindOfVPBusiness] = @IdKindOfVPBusiness,
                        [IdSettlement] = @IdSettlement,
                        [Email] = @Email,
                        [IdTownship] = @IdTownship,
                        [Latitude] = @Latitude,
                        [Longitude] = @Longitude,
                        [Accuracy] = @Accuracy,
                        [BranchCode] = @BranchCode,
						[SaleChannelId] = @IdKindOfVPClient,
						[ExcludePriceShippingCOD] = @CODExcludedPriceShipping,
						[ExcludeCommissionCOD] = @CODExcludedCommission,
						[CatBusinessSegmentId] = @CatBusinessSegmentId,
						[AllowScheduledPickups] = @AllowScheduledPickups,
						[RestrictionByArticle] = @RestrictionByArticle,
						[ParserGuideTypes] = @ParserGuideTypes
                    WHERE [CodeOfReference] = @IdVisitPoint;
										PRINT @@ROWCOUNT
										PRINT 'Paso 1 Affected VisitPointClient Updated - @IdVisitPoint'
										PRINT @IdVisitPoint
					DECLARE @IDVCONF AS INT = -1
										PRINT 'Valida Existencia VPConfiguracion - @IdVisitPoint'
                    IF ((@IdVPConfiguration > 0) 
						AND EXISTS  ( SELECT vpconf.IdVPConfiguration FROM dbo.VisitPointConfiguration vpconf WHERE vpconf.IdVPConfiguration = @IdVPConfiguration AND vpconf.VisitPointID = @IdVisitPoint))
                    BEGIN
                        -- UPDATE RECORD 
										PRINT 'Paso 2 Si Existe VisitPointConfiguration - @IdVPConfiguration'
                        UPDATE dbo.VisitPointConfiguration
                        SET [TransportCompanyID] = @IdTransportCompany,
                            [HubLogisticID] = @IdHubLogistics,
                            [CODAccountBankID] = @CODAccountBankID,
                            [CODAccountName] = @CODAccountName,
                            [CODAccountNumber] = @CODAccountNumber,
                            [CODAccountBankTypeID] = @CODAccountBankTypeID,
                            [CODAccountCurrencyID] = @CODAccountCurrencyID,
                            [TokenUpdated] = @Token,
                            [DateUpdated] = GETDATE(),
                            [AveragePackageDaily] = @AveragePackageDaily,
                            [DateStartOperation] = @DateStartOperation,
							[CatBillingTimeId]= @CatBillingTimeId,
							[CatBillingVolumeId] = @CatBillingVolumeId,
							[BillingCut_offDate] = @BillingCut_offDate
                        WHERE IdVPConfiguration = @IdVPConfiguration
                              AND VisitPointID = @IdVisitPoint
										PRINT @@ROWCOUNT
										PRINT 'Paso 2 Affected VisitPointConfiguration updated - @IdVPConfiguration'
										PRINT @IdVPConfiguration
										PRINT '@IDVCONF'
                        SET @IDVCONF = @IdVPConfiguration
						SET @IdResultVPConfig = @IDVCONF;
										PRINT @IDVCONF
                    END
                    ELSE
                    BEGIN
                        --INSERT RECORD
										PRINT 'Paso 2.1 No Existe, se insertara VisitPointConfiguration - @IdVPConfiguration'
                        INSERT INTO dbo.VisitPointConfiguration
                        (
                            VisitPointID,
                            TransportCompanyID,
                            HubLogisticID,
                            CODAccountBankID,
                            CODAccountName,
                            CODAccountNumber,
                            CODAccountBankTypeID,
                            CODAccountCurrencyID,
                            RowStatus,
                            TokenCreated,
                            DateCreated,
                            TokenUpdated,
                            DateUpdated,
                            AveragePackageDaily,
                            DateStartOperation,
							CatBillingTimeId,
							CatBillingVolumeId,
							BillingCut_offDate
                        )
                        VALUES
                        (   @IdVisitPoint,         -- VisitPointID - int
                            @IdTransportCompany,   -- TransportCompanyID - int
                            @IdHubLogistics,       -- HubLogisticID - int
                            @CODAccountBankID,     -- CODAccountBankID - int
                            @CODAccountName,       -- CODAccountName - nvarchar(50)
                            @CODAccountNumber,     -- CODAccountNumber - nvarchar(50)
                            @CODAccountBankTypeID, -- CODAccountBankTypeID - int
                            @CODAccountCurrencyID, -- CODAccountCurrencyID - int
                            @RowStatus,            -- RowStatus - bit
                            @Token,                -- TokenCreated - nvarchar(50)
                            GETDATE(),             -- DateCreated - datetime
                            NULL,                  -- TokenUpdated - nvarchar(50)
                            NULL,                  -- DateUpdated - datetime
                            @AveragePackageDaily,  -- AveragePackageDaily - int
                            @DateStartOperation,    -- DateStartOperation - datetime
							@CatBillingTimeId,  -- Configuración de tiempo de facturación
							@CatBillingVolumeId, --confioguración de volumen de facturación
							@BillingCut_offDate  --fecha de corte
                            )

                        SET @IDVCONF = SCOPE_IDENTITY()
						SET @IdResultVPConfig = @IDVCONF
										PRINT 'Paso 2.2 Inserted VisitPointConfiguration - @IDVCONF'
										PRINT @IDVCONF
                    END

										PRINT 'Valida si @IDVCONF > 0'
										PRINT @IDVCONF
                    IF (@IDVCONF > 0)
                    BEGIN
										PRINT 'Valida si existe configuracion VisitPointFrequency - @IDVCONF'
										PRINT @IDVCONF
                        DECLARE @IDROWFREQ AS BIGINT = -1;
                        --validar si existe frequency
                        IF (EXISTS(SELECT vpfreq.IdVPFrequency FROM dbo.VisitPointFrequency vpfreq JOIN @TblVPFrequency tblfreq  
																											ON tblfreq.IdVPFrequency = vpfreq.IdVPFrequency
																											AND tblfreq.VPConfigurationID = vpfreq.VPConfigurationID
																WHERE vpfreq.VPConfigurationID = @IDVCONF )
                            AND EXISTS (SELECT tblfreq.[IdVPFrequency] FROM @TblVPFrequency tblfreq WHERE tblfreq.[VPConfigurationID] = @IDVCONF))
                        BEGIN
                            --update records vp frequencies
										PRINT 'Paso 3 Si, si existe, se actualizara VisitPointFrequency - @IDVCONF'
                            UPDATE Freq
                            SET Freq.[SeasonID] = tblfreq.[SeasonID],
                                Freq.[VisitsOnSunday] = tblfreq.[VisitsOnSunday],
                                Freq.[VisitsOnMonday] = tblfreq.[VisitsOnMonday],
                                Freq.[VisitsOnTuesday] = tblfreq.[VisitsOnTuesday],
                                Freq.[VisitsOnWednesday] = tblfreq.[VisitsOnWednesday],
                                Freq.[VisitsOnThursday] = tblfreq.[VisitsOnThursday],
                                Freq.[VisitsOnFriday] = tblfreq.[VisitsOnFriday],
                                Freq.[VisitsOnSaturday] = tblfreq.[VisitsOnSaturday],
                                Freq.[HubLogisticID] = tblfreq.[HubLogisticID],
                                Freq.[RowStatus] = IIF(@RowStatus = 0 OR @AllowScheduledPickups = 0, 0, tblfreq.[RowStatus]),
                                Freq.[TokenUpdated] = @Token,
                                Freq.[DateUpdated] = GETDATE()
                            FROM dbo.VisitPointFrequency Freq
                            INNER JOIN @TblVPFrequency tblfreq
                                    ON Freq.[VPConfigurationID] = tblfreq.[VPConfigurationID]
                                       AND Freq.IdVPFrequency = tblfreq.IdVPFrequency
									   AND Freq.VPConfigurationID = @IDVCONF
									   
										PRINT @@ROWCOUNT
										PRINT 'Paso 3 Se actualizaron registros VisitPointFrequency affected - @IDVCONF'
										PRINT @IDVCONF
							DECLARE @tempfreq AS BIGINT = -1
							SET @tempfreq = (SELECT TOP 1 freq.IdVPFrequency FROM @TblVPFrequency freq WHERE freq.VPConfigurationID = @IDVCONF)
							IF @tempfreq > 0 
							BEGIN
								SET @IDROWFREQ = @tempfreq
							END 
							ELSE
							BEGIN 
								SET @IDROWFREQ = (  SELECT TOP (1) VPFrequency.IdVPFrequency
												FROM dbo.VisitPointFrequency VPFrequency
												WHERE VPFrequency.VPConfigurationID = @IDVCONF
												AND VPFrequency.RowStatus = 'true'
												ORDER BY VPFrequency.DateUpdated DESC 
											 )
							END 
							SET @IdResultVPFrequency = @IDROWFREQ
										PRINT 'Paso 3 @IDROWFREQ'
										PRINT @IDROWFREQ
                        END
                        ELSE
                        BEGIN
                            -- insert vp frequencies
										PRINT 'Paso 3.1 No, No existe, se insertaran VisitPointFrequency -  @IDVCONF'
										PRINT  @IDVCONF
                            INSERT INTO dbo.VisitPointFrequency
                            (
                                VPConfigurationID,
                                SeasonID,
                                VisitsOnSunday,
                                VisitsOnMonday,
                                VisitsOnTuesday,
                                VisitsOnWednesday,
                                VisitsOnThursday,
                                VisitsOnFriday,
                                VisitsOnSaturday,
                                HubLogisticID,
                                RowStatus,
                                TokenCreated,
                                DateCreated,
                                TokenUpdated,
                                DateUpdated
                            )
                            (SELECT @IDVCONF, --tblfreq.VPConfigurationID, -- VPConfigurationID - bigint
                                    tblfreq.SeasonID,
                                    tblfreq.VisitsOnSunday,
                                    tblfreq.VisitsOnMonday,
                                    tblfreq.VisitsOnTuesday,
                                    tblfreq.VisitsOnWednesday,
                                    tblfreq.VisitsOnThursday,
                                    tblfreq.VisitsOnFriday,
                                    tblfreq.VisitsOnSaturday,
                                    tblfreq.HubLogisticID,
                                    @RowStatus,
                                    @Token,
                                    GETDATE(),
                                    NULL,
                                    NULL
                             FROM @TblVPFrequency tblfreq
                            --WHERE tblfreq.VPConfigurationID = @IDVCONF
                            )

                            SET @IDROWFREQ = SCOPE_IDENTITY()
							SET @IdResultVPFrequency = @IDROWFREQ
										PRINT 'Paso 3.2 Inserted VisitPointFrequency -  @IDROWFREQ'
										PRINT  @IDROWFREQ

                        END
										PRINT 'Paso 4 Valida si @IDROWFREQ > 0'
                        IF (@IDROWFREQ > 0)
                        BEGIN
							--actualizo los registros existententes
										PRINT 'Paso 4 si, si es mayor, se actualizara  VisitPointItinerary -  @IDROWFREQ'
										PRINT  @IDROWFREQ
                            UPDATE VPIti
                            SET VPIti.[DayOfVisit] = tblIti.DayOfVisit,
                                VPIti.[InitializationTimeOfVisit] = CASE WHEN tblIti.InitializationTimeOfVisit = '__:__' THEN  VPIti.[InitializationTimeOfVisit]  ELSE tblIti.InitializationTimeOfVisit END,
                                VPIti.[FinalizationTimeOfVisit] = CASE WHEN tblIti.FinalizationTimeOfVisit =  '__:__' THEN VPIti.[FinalizationTimeOfVisit] ELSE tblIti.FinalizationTimeOfVisit END,
                                --VPIti.[OrderSequence] = tblIti.OrderSequence,
								--Edicion de la ruta inhabilitada
                                --VPIti.[RouteCodeID] = CASE WHEN tblIti.RouteCodeID <= 0 THEN VPIti.[RouteCodeID] ELSE tblIti.RouteCodeID END ,
                                VPIti.[HubLogisticID] = tblIti.HubLogisticID,
                                VPIti.[RowStatus] = IIF(@RowStatus = 0 OR @AllowScheduledPickups = 0, 0, tblIti.RowStatus),
                                VPIti.[TokenUpdated] = @Token,
                                VPIti.[DateUpdated] = GETDATE()
                            FROM dbo.VisitPointItinerary VPIti
                                INNER JOIN @TblVPItinerary tblIti
                                    ON VPIti.VPFrequencyID = tblIti.VPFrequencyID
									AND tblIti.IdVPItinerary = VPIti.IdVPItinerary
                            WHERE tblIti.VPFrequencyID = @IDROWFREQ
							AND tblIti.IdVPItinerary > 0
							AND ISNULL(tblIti.InitializationTimeOfVisit, '__:__') != '__:__'
							AND ISNULL(tblIti.FinalizationTimeOfVisit, '__:__') != '__:__'
							
								PRINT @@ROWCOUNT
								PRINT 'Se actualizaron VisitPointItinerary -  @@ROWCOUNT'
										
                            UPDATE VPIti
                            SET VPIti.[RowStatus] = 0,
                                VPIti.[TokenUpdated] = @Token,
                                VPIti.[DateUpdated] = GETDATE()
                            FROM dbo.VisitPointItinerary VPIti
                                INNER JOIN @TblVPItinerary tblIti
                                    ON VPIti.VPFrequencyID = tblIti.VPFrequencyID
									AND tblIti.IdVPItinerary = VPIti.IdVPItinerary
                            WHERE tblIti.VPFrequencyID = @IDROWFREQ
							AND tblIti.IdVPItinerary > 0
							AND ISNULL(tblIti.InitializationTimeOfVisit, '__:__') = '__:__'
							AND ISNULL(tblIti.FinalizationTimeOfVisit, '__:__') = '__:__'
							
								PRINT @@ROWCOUNT
								PRINT 'Se inactivaron VisitPointItinerary -  @@ROWCOUNT'
										
								PRINT 'Paso 5 se insertaran VisitPointItinerary - @IDROWFREQ'
								PRINT  @IDROWFREQ
							--creo los registros que no estan en la tabla 
							INSERT INTO dbo.VisitPointItinerary
                            (
                                VPFrequencyID,
                                DayOfVisit,
                                InitializationTimeOfVisit,
                                FinalizationTimeOfVisit,
                                OrderSequence,								
								--Edicion de la ruta inhabilitada
                                --RouteCodeID,
                                HubLogisticID,
                                RowStatus,
                                TokenCreated,
                                DateCreated,
                                TokenUpdated,
                                DateUpdated
                            )
                            (
								SELECT  @IDROWFREQ,--tblIti.VPFrequencyID,
										tblIti.DayOfVisit,
										tblIti.InitializationTimeOfVisit,
										tblIti.FinalizationTimeOfVisit,
										1,--tblIti.OrderSequence,
										--Edicion de la ruta inhabilitada
										--tblIti.RouteCodeID,
										tblIti.HubLogisticID,
										tblIti.RowStatus,
										@Token,
										GETDATE(),
										NULL,
										NULL
								FROM @TblVPItinerary tblIti
                                    --WHERE tblIti.VPFrequencyID = @IDROWFREQ
								WHERE tblIti.IdVPItinerary <= 0
								AND ISNULL(tblIti.InitializationTimeOfVisit, '__:__') != '__:__'
								AND ISNULL(tblIti.FinalizationTimeOfVisit, '__:__') != '__:__'
							)
										PRINT @@ROWCOUNT			
										PRINT 'Se insertaron VisitPointItinerary -  @@ROWCOUNT'
										
                        END
						ELSE
						BEGIN
								SET @MessageError = 'Paso 3 @IDROWFREQ Es menor a cero, no se puede continuar'
								SET @blnCotinue= 'false'
										PRINT 'Paso 3 Es menor a cero @IDROWFREQ'
										PRINT @IDROWFREQ
						END
                    END
					ELSE
                    BEGIN
						SET @MessageError = 'Paso 2 @IDVCONF Es menor a cero, no se puede continuar'
						SET @blnCotinue= 'false'
										PRINT 'Paso 2 Es menor a cero @IDVCONF'
										PRINT @IDVCONF
                    END
										
					--Operar Destinos
										PRINT 'Paso 6 se valida existencia destinos VisitPointDestination - IdSource @IdVisitPoint'
										PRINT  @IdVisitPoint
					IF (EXISTS (  SELECT vpdest.IDVPDestiny FROM dbo.VisitPointDestination vpdest WHERE vpdest.IdVPSource = @IdVisitPoint ))
					BEGIN
										PRINT 'Paso 6 Si, si existen destinos, se actualizara VisitPointDestination - IdSource @IdVisitPoint'
						UPDATE VPDest
						SET VPDest.IsGuard = tblDestination.IsGuard,
							VPDest.IsTransit = tblDestination.IsTransit,
							VPDest.IsDefault = tblDestination.IsDefault,
							VPDest.RowStatus = tblDestination.RowStatus,
							VPDest.TokenUpdated = @Token,
							VPDest.DateUpdated = GETDATE()
						FROM dbo.VisitPointDestination VPDest
							INNER JOIN @TblVPDestination tblDestination
								ON VPDest.IdVPSource = tblDestination.IdVPSource
									AND VPDest.IDVPDestiny = tblDestination.IDVPDestiny
						AND VPDest.IdVPSource = @IdVisitPoint
										PRINT @@ROWCOUNT
										PRINT 'Se actualizaron VisitPointDestination -  @@ROWCOUNT'
					END
					ELSE
					BEGIN
										PRINT 'Paso 6 se insertaran destinos VisitPointDestination - IdSource @IdVisitPoint'
										PRINT @IdVisitPoint
						INSERT INTO dbo.VisitPointDestination
						(
							IdVPSource,
							IDVPDestiny,
							IsGuard,
							IsTransit,
							IsDefault,
							RowStatus,
							TokenCreated,
							DateCreated,
							TokenUpdated,
							DateUpdated
						)
						(SELECT tblDest.IdVPSource,
								tblDest.IDVPDestiny,
								tblDest.IsGuard,
								tblDest.IsTransit,
								tblDest.IsDefault,
								tblDest.RowStatus,
								@Token,
								GETDATE(),
								NULL,
								NULL
							FROM @TblVPDestination tblDest
							WHERE tblDest.IdVPSource = @IdVisitPoint)
										PRINT @@ROWCOUNT
										PRINT 'Paso 6 inserted VisitPointDestination - IdSource @IdVisitPoint'
					END

										PRINT 'Paso 7 Valida existencia coberturas VisitPointCoverage - @IdVisitPoint'
										PRINT  @IdVisitPoint
					--Operar Coberturas
					IF (EXISTS ( SELECT vpcoverage.IdVpbySegment FROM dbo.VisitPointCoverage vpcoverage WHERE vpcoverage.VisitPointId = @IdVisitPoint ))
					BEGIN
											PRINT 'Paso 7 Si si existe, se actualizara VisitPointDestination - @IdVisitPoint'
											PRINT @IdVisitPoint
						UPDATE VPCov
						SET VPCov.SegmentId = tblCoverage.SegmentId,
							VPCov.RowStatus = tblCoverage.RowStatus,
							VPCov.TokenUpdated = @Token,
							VPCov.DateUpdated = GETDATE()
						FROM dbo.VisitPointCoverage VPCov
							INNER JOIN @TblVPCoverage tblCoverage
								ON tblCoverage.VisitPointId = VPCov.VisitPointId
									AND tblCoverage.HubLogisticId = VPCov.HubLogisticId
						AND VPCov.VisitPointId = @IdVisitPoint
											PRINT @@ROWCOUNT
											PRINT 'Paso 7 VisitPointDestination updated - VisitPointId @IdVisitPoint'
						INSERT INTO dbo.VisitPointCoverage
						(
							VisitPointId,
							HubLogisticId,
							SegmentId,
							RowStatus,
							TokenCreated,
							DateCreated,
							TokenUpdated,
							DateUpdated
						)
						(SELECT tblCoverage.VisitPointId,
								tblCoverage.HubLogisticId,
								tblCoverage.SegmentId,
								tblCoverage.RowStatus,
								@Token,
								GETDATE(),
								NULL,
								NULL
							FROM @TblVPCoverage tblCoverage
								LEFT JOIN dbo.VisitPointCoverage vpcoverage
									ON tblCoverage.VisitPointId = vpcoverage.VisitPointId
									AND tblCoverage.HubLogisticId = vpcoverage.HubLogisticId
							WHERE tblCoverage.VisitPointId = @IdVisitPoint
							AND tblCoverage.IdVpbySegment <= 0)
										PRINT @@ROWCOUNT
										PRINT 'Paso 7 VisitPointCoverage inserted - VisitPointId @IdVisitPoint'
					END
					ELSE
					BEGIN
											PRINT 'Paso 7 No existe, se insertaran VisitPointDestination - @IdVisitPoint'
											PRINT @IdVisitPoint
						INSERT INTO dbo.VisitPointCoverage
						(
							VisitPointId,
							HubLogisticId,
							SegmentId,
							RowStatus,
							TokenCreated,
							DateCreated,
							TokenUpdated,
							DateUpdated
						)
						(SELECT tblCoverage.VisitPointId,
								tblCoverage.HubLogisticId,
								tblCoverage.SegmentId,
								tblCoverage.RowStatus,
								@Token,
								GETDATE(),
								NULL,
								NULL
							FROM @TblVPCoverage tblCoverage
								LEFT JOIN dbo.VisitPointCoverage vpcoverage
									ON tblCoverage.VisitPointId = vpcoverage.VisitPointId
									AND tblCoverage.HubLogisticId = vpcoverage.HubLogisticId
							WHERE tblCoverage.VisitPointId = @IdVisitPoint)
										PRINT @@ROWCOUNT
										PRINT 'Paso 7 VisitPointCoverage inserted - VisitPointId @IdVisitPoint'
										

					END

					
                END
                ELSE
                BEGIN
                  SET @MessageError = 'Option does not match record not exist in VisitPointClient'
				  SET @blnCotinue = 'FALSE'
                END
            END

			IF @blnCotinue = 'TRUE'
			BEGIN
				COMMIT TRANSACTION
				SELECT 'TRUE' [blnResult],
					CAST(@IdVisitPoint AS VARCHAR(50)) [IdResult],
					CAST(@IdResultVPConfig AS VARCHAR(50)) [IdVPConfResult],
					CAST(@IdResultVPFrequency AS VARCHAR(50)) [IdVPFreqResult],
					'' AS [ErrorNumber],
					'' AS [ErrorSeverity],
					'' AS [ErrorState],
					'' AS [ErrorProcedure],
					'' AS [ErrorLine],
					'Success' AS [Message]

				PRINT 'Commit Transaction'
			END
			ELSE
			BEGIN
				ROLLBACK TRANSACTION
				SELECT 'FALSE' [blnResult],
					CAST(@IdVisitPoint AS VARCHAR(10)) AS [IdResult],
					CAST(@IdResultVPConfig AS VARCHAR(50)) AS [IdVPConfResult],
					CAST(@IdResultVPFrequency AS VARCHAR(50)) [IdVPFreqResult],
					'' AS [ErrorNumber],
					'' AS [ErrorSeverity],
					'' AS [ErrorState],
					'' AS [ErrorProcedure],
					'' AS [ErrorLine],
					@MessageError AS [Message];
				PRINT 'Rollback Transaction'
			END

        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION
			SELECT 'FALSE' [blnResult],
				   CAST(@IdVisitPoint AS VARCHAR(10)) AS [IdResult],
				   CAST(@IdResultVPConfig AS VARCHAR(50)) AS [IdVPConfResult],
				   CAST(@IdResultVPFrequency AS VARCHAR(50)) [IdVPFreqResult],
                   CAST(ERROR_NUMBER() AS VARCHAR) AS [ErrorNumber],
                   CAST(ERROR_SEVERITY() AS VARCHAR) AS [ErrorSeverity],
                   CAST(ERROR_STATE() AS VARCHAR) AS [ErrorState],
                   CAST(ERROR_PROCEDURE() AS VARCHAR) AS [ErrorProcedure],
                   CAST(ERROR_LINE() AS VARCHAR) AS [ErrorLine],
                   CAST(ERROR_MESSAGE() AS NVARCHAR(MAX)) AS [Message]
			PRINT 'Catch Exception Rollback Transaction;'
        END CATCH
    END
    ELSE
    BEGIN
		SELECT 'FALSE' [blnResult],
			   '' AS [IdResult],
			   '' AS [IdVPConfResult],
			   '' AS [IdVPFreqResult],
               '' AS [ErrorNumber],
               '' AS [ErrorSeverity],
               '' AS [ErrorState],
               '' AS [ErrorProcedure],
               '' AS [ErrorLine],
               'Token inválido' AS [Message];
		PRINT 'Token is not valid'
    END


END;