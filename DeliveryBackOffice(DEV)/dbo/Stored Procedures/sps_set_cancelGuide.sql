CREATE PROCEDURE [dbo].[sps_set_cancelGuide]
    @TblListGuides AS TblGuidesCancel READONLY,
    @IdClient INT,
	@Token NVARCHAR(100)

	AS
BEGIN

    DECLARE @Output VARCHAR(MAX);
	 IF OBJECT_ID('tempdb.dbo.#listGuidesEnabled', 'U') IS NOT NULL
            DROP TABLE #listGuidesEnabled;
        IF OBJECT_ID('tempdb.dbo.#listGuidesDisabled', 'U') IS NOT NULL
		 DROP TABLE #listGuidesDisabled;
	 IF OBJECT_ID('tempdb.dbo.#listGuidesNotFound', 'U') IS NOT NULL
		 DROP TABLE #listGuidesNotFound;

	--Variabes Membresías y suscripciones
	DECLARE @MembershipId INT
	DECLARE @SubscriptionId INT
	DECLARE @MembershipSubscriptionLogId BIGINT
	DECLARE @i INT
	DECLARE @TblGuidesMembership TABLE(
		Id INT IDENTITY(1,1),
		GuideSerie NVARCHAR(2),
		GuideNumber INT,
		UNIQUE NONCLUSTERED (Id)
	)
	DECLARE @GuideSerieMembership NVARCHAR(2)
	DECLARE @GuideNumberMembership INT
	-------------------------------------

	SELECT *
    INTO #TblListGuides
    FROM @TblListGuides;

--Guias que cumplen con estado para anular-------------------
	SELECT lg.Guide_Serie,
           lg.Guide_Number
    INTO #listGuidesEnabled
    FROM #TblListGuides lg
           INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
            ON lg.Guide_Serie = do.Guide_Serie
            AND lg.Guide_Number = do.Guide_Number
		    AND do.IdCustomer = @IdClient
            WHERE do.StatusOrderId IN (1)

--Guias que no cumplen estado para anular (existen pero no son cancelables)-------------------
	SELECT lg.Guide_Serie,
           lg.Guide_Number
    INTO #listGuidesDisabled
    FROM #TblListGuides lg
           INNER JOIN DeliveryBackOffice.dbo.DeliveryOrder do
            ON lg.Guide_Serie = do.Guide_Serie
            AND lg.Guide_Number = do.Guide_Number
            WHERE do.StatusOrderId NOT IN (1)
			OR do.IdCustomer <> @IdClient

--Guias que no existen en DeliveryOrder (inexistentes)-------------------
	SELECT lg.Guide_Serie,
           lg.Guide_Number
    INTO #listGuidesNotFound
    FROM #TblListGuides lg
           LEFT JOIN DeliveryBackOffice.dbo.DeliveryOrder do
            ON lg.Guide_Serie = do.Guide_Serie
            AND lg.Guide_Number = do.Guide_Number
    WHERE do.Guide_Number IS NULL

IF ((SELECT COUNT(1) FROM #listGuidesNotFound) > 0)
	BEGIN
		  SET @Output
                            = '[ { ' + '"Rejects": [ '
                              +
                              (
                                  SELECT STUFF(
                                         (
                                             SELECT ' {"DescriptionResult": "La guía '
                                                    + lnf.Guide_Serie
                                                    + CAST(lnf.Guide_Number AS VARCHAR(8))
                                                    + ' no existe en el sistema." }, '
                                             FROM #listGuidesNotFound lnf
                                             FOR XML PATH('')
                                         ),
                                         1,
                                         1,
                                         ''
                                              )
                              ) + '] } ]';

                        SET @Output
                            = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                              + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                        SELECT @Output FormatJson, 404 StatusResult;
	END
ELSE IF ((SELECT COUNT(1) FROM #listGuidesDisabled) > 0)
	BEGIN
		  SET @Output
                            = '[ { ' + '"Rejects": [ '
                              +
                              (
                                  SELECT STUFF(
                                         (
                                             SELECT ' {"DescriptionResult": "'
                                                    + ('No se pudo realizar la operacion debido a que las guìas no cumplen las condiciones.')
                                                    + '" }, '
                                             FOR XML PATH('')
                                         ),
                                         1,
                                         1,
                                         ''
                                              )
                              ) + '] } ]';

                        SET @Output
                            = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                              + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                        SELECT @Output FormatJson, 409 StatusResult;
	END
ELSE IF ((SELECT COUNT(1) FROM #listGuidesEnabled) = 0)
	BEGIN
		SELECT '[ { "Rejects": [ { "DescriptionResult": "No se encontraron guías para anular." } ] } ]' FormatJson, 409 StatusResult;
	END
ELSE
	BEGIN --COMIENZA


        BEGIN TRANSACTION;
			BEGIN TRY

			 UPDATE do
                SET do.StatusOrderId = 7
                FROM DeliveryOrder do
                     INNER JOIN #listGuidesEnabled lge
                     ON lge.Guide_Number = do.Guide_Number
                     AND lge.Guide_Serie = do.Guide_Serie;


			  INSERT INTO DeliveryBackOffice.dbo.DeliveryOrderDetail
                                (
                                    Guide_Serie,
                                    Guide_Number,
                                    StatusOrderId,
                                    UserCreated,
                                    DateCreated
                                )
                                SELECT lge.Guide_Serie,
                                       lge.Guide_Number,
                                       7,
                                       @Token UserCreated,
                                       GETDATE()
                                FROM #listGuidesEnabled lge

			--Membresías y suscripciones
			--Oscar Morales 25/07/2022

			INSERT INTO @TblGuidesMembership (GuideSerie, GuideNumber)
				SELECT
					Guide_Serie
				   ,Guide_Number
				FROM #listGuidesEnabled

			SET @i = 0;

			WHILE EXISTS (SELECT TOP 1
					1
				FROM @TblGuidesMembership)
			BEGIN
				SET @i = @i + 1;
				SELECT
					@GuideSerieMembership = GuideSerie
				   ,@GuideNumberMembership = GuideNumber
				FROM @TblGuidesMembership
				WHERE Id = @i

				DELETE FROM @TblGuidesMembership
				WHERE Id = @i

				SET @MembershipSubscriptionLogId = NULL

				SELECT
					@MembershipSubscriptionLogId = IdMembershipSubscriptionLog
					,@MembershipId = MembershipId
					,@SubscriptionId = SubscriptionId
				FROM MembershipSubscriptionLog
				WHERE LogGuideSerie = @GuideSerieMembership
				AND LogGuideNumber = @GuideNumberMembership
				AND RowStatus = 1

				IF @MembershipSubscriptionLogId IS NOT NULL
				BEGIN

					UPDATE MembershipSubscriptionLog
					SET RowStatus = 0
						,TokenUpdated = @Token
						,DateUpdated = GETDATE()
					WHERE IdMembershipSubscriptionLog = @MembershipSubscriptionLogId

					IF @SubscriptionId IS NULL
					BEGIN

						UPDATE Membership
						SET ActualServiceCount = ActualServiceCount - 1
							,TokenUpdated = @Token
							,DateUpdated = GETDATE()
						WHERE IdMembership = @MembershipId
					END
					ELSE
					BEGIN

						UPDATE Subscription
						SET ActualServiceCount = ActualServiceCount - 1
							,TokenUpdated = @Token
							,DateUpdated = GETDATE()
						WHERE IdSubscription = @SubscriptionId
					END

				END
			END
			--Termina Membresías y suscripciones

			END TRY
			BEGIN CATCH

				SELECT 'ERROR' AS message,
					   'FALSE' blnResult,
					   CAST(500 AS VARCHAR(5)) StatusResult,
					   CAST(ERROR_NUMBER() AS VARCHAR) AS ErrorNumber,
					   CAST(ERROR_SEVERITY() AS VARCHAR) AS ErrorSeverity,
					   CAST(ERROR_STATE() AS VARCHAR) AS ErrorState,
					   CAST(ERROR_PROCEDURE() AS VARCHAR) AS ErrorProcedure,
					   CAST(ERROR_LINE() AS VARCHAR) AS ErrorLine,
					   CAST(ERROR_MESSAGE() AS VARCHAR(100)) AS ResultMessage;

				ROLLBACK TRANSACTION;

			END CATCH
			PRINT @@TRANCOUNT
		 IF @@TRANCOUNT > 0
			BEGIN

			 COMMIT TRANSACTION;

			  SET @Output
                            = '[ { ' + '"Result": [ '
                              +
                              (
                                  SELECT STUFF(
                                         (
                                             SELECT ' {"DescriptionResult": "La anulaciòn de la guía '
                                                    + lge.Guide_Serie
                                                    + CAST(lge.Guide_Number AS VARCHAR(8))
                                                    + ' fue realizada exitosamente." }, '
                                             FROM #listGuidesEnabled lge
                                             FOR XML PATH('')
                                         ),
                                         1,
                                         1,
                                         ''
                                              )
                              ) + '] } ]';

                        SET @Output
                            = SUBSTRING(@Output, 1, (LEN(@Output) - 7))
                              + SUBSTRING(@Output, (LEN(@Output) - 5), LEN(@Output));

                        SELECT @Output FormatJson, 200 StatusResult;

		    END;

    END --TERMINA


END


