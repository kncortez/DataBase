-- ============================================
-- Author:		<Brandon, Pedroza>
-- Create date: <2024-10-04>
-- Description:	<Crear un link para usuarios que no esten logueados>
-- =============================================
CREATE PROCEDURE [dbo].[SPHW_CreateDeliveryLinkWithoutLogin]
    @AccountId INT,
    @IdCountry NVARCHAR(2),
    @SenderName NVARCHAR(200),
    @SenderAddress NVARCHAR(1200),
    @SenderZone NVARCHAR(50),
    @Phone NVARCHAR(50),
    @IdSettlement INT,
    @Latitude NVARCHAR(40),
    @Longitude NVARCHAR(40),
    @Email NVARCHAR(400),
	@SenderNeighborhood NVARCHAR(200),
	@SenderAdditionalInstuctions NVARCHAR(500),
    @ReceiverName NVARCHAR(200),
    @ReceiverPhone NVARCHAR(50),
    @ReceiverSettlementId INT,
    @ReceiverEmail NVARCHAR(100),
    @CatPaymentTypeId INT,
    @CatTypeServiceId INT,
    @IsInsurance BIT,
    @InsuranceAmount DECIMAL(14, 2),
    @DeliveryFavCODId INT,
    @CollectOnDelivery DECIMAL(14, 2),
	@ReceiverZone  NVARCHAR(100),
	@ReceiverCatCityPlaceId INT,
	@ReceiverNeighborhood   NVARCHAR(50),
	@ReceiverAddress        NVARCHAR(600),
	@ReceiverAdditionalInstuctions NVARCHAR(250),
	@IsDeliveryLink BIT = 1
AS
BEGIN
    BEGIN TRANSACTION spCreateLinkWL
    BEGIN TRY
		-- proceso para creacion de visitpoint
		DECLARE @IdTownship INT,
					@IdCustomer INT,
					@TownshipName NVARCHAR(200),
					@ProvinceName NVARCHAR(200),
					@IdBussinessSegment INT,
					@IdKindOfVPClient INT,
					@IdKindOfVPBussiness INT,
					@CodeOfReference NVARCHAR(50);
		
		SELECT @IdTownship = TW.IdTownship,
				   @TownshipName = TW.TownshipName,
				   @ProvinceName = PR.ProvinceName
		FROM Settlement ST WITH (NOLOCK)
			INNER JOIN Township TW WITH (NOLOCK)
				ON ST.IdTownship = TW.IdTownship
			INNER JOIN Province PR WITH (NOLOCK)
				ON ST.IdProvince = PR.IdProvince
		WHERE IdSettlement = @IdSettlement

		SET @IdCustomer =	(
								SELECT IdCustomer
								FROM Account A WITH (NOLOCK)
								WHERE AccIdAccount = @AccountId
							);


		SET @IdBussinessSegment =	(
										SELECT IdBusinessSegment
										FROM CatBusinessSegment WITH (NOLOCK)
										WHERE BusinessSegmentName = 'C2C'
												AND ISNULL(IdCountry, 'GT') = @IdCountry
									);

		SET @IdKindOfVPBussiness =	(
										SELECT IdKindOfVPBusiness
										FROM KindOfVPBusiness WITH (NOLOCK)
										WHERE KindOfVPNameBussiness = 'CASA'
												AND ISNULL(IdCountry, 'GT') = @IdCountry
									);

		SET @IdKindOfVPClient =	(
									SELECT IdKindOfVPClient
									FROM KindOfVPClient WITH (NOLOCK)
									WHERE KindOfVPName = 'Api Client'
											AND ISNULL(IdCountry, 'GT') = @IdCountry
								);

		SET @CodeOfReference = (
									SELECT MAX(CodeOfReference) + 1 FROM VisitPointClient WITH (NOLOCK)
								);


		-- Insertando los datos en la tabla VisitPointClients
		INSERT INTO VisitPointClient
		(
			[CodeOfReference],
			[DescriptionOfClient],
			[StatusClient],
			[CountryId],
			[VisitPointId],
			[TokenCreated],
			[DateCreated],
			[TokenUpdated],
			[DateUpdated],
			[CustomerID],
			[Address],
			[Zone],
			[Town],
			[Department],
			[Phone],
			[ContactName],
			[IdKindOfVPClient],
			[IdKindOfVPBusiness],
			[IdSettlement],
			[Email],
			[IdTownship],
			[Latitude],
			[Longitude],
			[Accuracy],
			[BranchCode],
			[SaleChannelId],
			[ExcludePriceShippingCOD],
			[ExcludeCommissionCOD],
			[IsOriginVisitPoint],
			[LogLatitude],
			[LogLongitude],
			[DescriptionCC],
			[CatBusinessSegmentId],
			[AllowScheduledPickups]
		)
		VALUES
		(
			@CodeOfReference,
			@SenderName,
			1  ,
			@IdCountry,
			NULL,
			'SYS-ADMIN',
			GETDATE(),
			NULL,
			NULL,
			@IdCustomer,
			@SenderAddress,
			@SenderZone,
			@TownshipName,
			@ProvinceName,
			@Phone,
			NULL,
			@IdKindOfVPClient,
			@IdKindOfVPBussiness,
			@IdSettlement,
			@Email,
			@IdTownship,
			@Latitude,
			@Longitude,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			1  ,
			NULL,
			NULL,
			NULL,
			@IdBussinessSegment,
			1
		);	

		--proceso para creacion de link

		DECLARE @StatusId INT = (
                                    SELECT TOP 1
                                        IdDeliveryLinkStatus
                                    FROM dbo.DeliveryLinkStatus
                                    WHERE Name = 'Enviado'
                                )
		DECLARE @cadena NVARCHAR(20) = CONVERT(NVARCHAR(20), @ReceiverPhone)

        INSERT INTO DeliveryBackOffice.dbo.DeliveryLink
        (
            Token,
            AccountId,
            OriginCodeOfReference,
            ReceiverName,
            ReceiverPhone,
            ReceiverSettlementId,
            ReceiverEmail,
			ReceiverCatCityPlaceId,
			ReceiverZone,
			ReceiverNeighborhood,
			ReceiverAddress,
			ReceiverAdditionalInstuctions,
            CatPaymentTypeId,
            CatTypeServiceId,
            IsInsurance,
            InsuranceAmount,
            DeliveryFacCODId,
            CollectOnDelivery,
            DeliveryLinkStatusId,
            ExpirationDate,
            RowStatus,
            UserCreated,
            DateCreated,
			IsUserWithoutLogin,
			NirPhone
        )
        VALUES
        ('',
         @AccountId,
         @CodeOfReference,
         @ReceiverName,
         SUBSTRING(@cadena, 4, LEN(@cadena) - 3),
         @ReceiverSettlementId,
         @ReceiverEmail,
		 @ReceiverCatCityPlaceId,
		 @ReceiverZone,
		 @ReceiverNeighborhood,
		 @ReceiverAddress,
		 @ReceiverAdditionalInstuctions,
         @CatPaymentTypeId,
         @CatTypeServiceId,
         @IsInsurance,
         @InsuranceAmount,
         @DeliveryFavCODId,
         @CollectOnDelivery,
         @StatusId,
         DATEADD(DAY, 1, GETDATE()),
         1  ,
         'SYSTEM',
         GETDATE(),
		 1,
		 CONCAT('+',LEFT(@cadena, 3))
        )

        DECLARE @DeliveryLinkID INT;
        DECLARE @hash VARBINARY(16); -- El tamaño del hash MD5 es de 16 bytes (128 bits)
        DECLARE @hashResultado VARCHAR(32); -- El hash MD5 en formato hexadecimal tiene 32 caracteres
        SET @DeliveryLinkID = @@IDENTITY;
        SET @hash = HASHBYTES('MD5', CONCAT(CAST(@DeliveryLinkID AS VARCHAR(50)), CAST(@AccountId AS VARCHAR(50))));
        SET @hashResultado = CONVERT(VARCHAR(32), @hash, 2); -- El hash MD5 en hexadecimal tiene 32 caracteres

        UPDATE DeliveryBackOffice.dbo.DeliveryLink
        SET Token = @hashResultado
        WHERE IdDeliveryLink = @DeliveryLinkID
        COMMIT TRANSACTION spCreateLinkWL

        SELECT 200 AS 'StatusCode',
               'Registro guardado correctamente' AS 'Description'

        SELECT @DeliveryLinkID AS 'IdDeliveryLink',
               @hashResultado AS 'Token',
               DATEADD(DAY, 1, GETDATE()) AS 'ExpirationDate',
               2 AS 'DeliveryLinkStatusId'
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        SELECT 400 AS 'StatusCode',
               'Error al registrar Link de Entrega' AS 'Description'
    END CATCH
END
