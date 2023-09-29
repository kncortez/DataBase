-- =============================================
-- Author:		<Andrés, Ruíz>
-- Create date: <2023-04-28>
-- Description:	< ingreso de incidencia manual desde hermes desktop >
-- =============================================
CREATE PROCEDURE [dbo].[spHD_SetGuideIncidence]

	@GuideSerie NVARCHAR(2),
	@GuideNumber INT,
	@SimulatedDate DATETIME,
	@Incidence INT,
	@Observations NVARCHAR(200) = '',
	@Token NVARCHAR(50)

AS
BEGIN

	-- Variables globales
	DECLARE @DateInSystem DATETIME = GETDATE();
	DECLARE @IncidenceDescription NVARCHAR(200);
	DECLARE @SystemOrigin INT = 
	(
		SELECT 
			TOP (1)
				[CS].[SysIdSystem] 
		FROM
			[DeliveryBackOffice].[dbo].[CatSystem] CS  WITH(NOLOCK)	
		WHERE
			[CS].[SysNameSystem] = 'Hermes Desktop'  COLLATE Latin1_General_CI_AI 
	);
	DECLARE @EmailNotificationMedium INT = 
	(
		SELECT 
			TOP (1) 
				[CNM].[IdCatNotificationMedium] 
		FROM 
			[DeliveryBackOffice].[dbo].[CatNotificationMedium] CNM  WITH(NOLOCK) 
		WHERE
			[CNM].[NotificationMediumName] = 'Correo SMTP'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @NotificationType BIGINT =
	(
		SELECT 
			TOP (1) 
				[CNT].[IdCatNotificationType] 
		FROM 
			[DeliveryBackOffice].[dbo].[CatNotificationType] CNT  WITH(NOLOCK) 
		WHERE
			[CNT].[NotificationTypeName] = 'DailyGuideIncidenceToOrigin'  COLLATE Latin1_General_CI_AI 
	)
	DECLARE @FailedDeliveryVisitStatus INT = 
	(
		SELECT 
			TOP (1)
				[SO].[StatusOrderId] 
		FROM
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			[SO].[OrderDescription] = 'Intento de entrega fallida'  COLLATE Latin1_General_CI_AI 
	);
	DECLARE @OnRouteStatus INT = 
	(
		SELECT 
			TOP (1)
				[SO].[StatusOrderId] 
		FROM
			[DeliveryBackOffice].[dbo].[StatusOrder] SO  WITH(NOLOCK) 
		WHERE
			[SO].[OrderDescription] = 'En ruta'  COLLATE Latin1_General_CI_AI 
	);

	-- Variables de control de flujo
	-- Primera salida a ruta de guía
	DECLARE @FirstOnRouteDate DATETIME =
	(
		SELECT 
			TOP (1) 
				ISNULL([DOD].[DateCreated], [DOD].[DateCreatedInSystem]) 
		FROM 
			[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD  WITH(NOLOCK) 
		WHERE
			[DOD].[Guide_Serie] = @GuideSerie
			AND
			[DOD].[Guide_Number] = @GuideNumber
			AND
			[DOD].[StatusOrderId] = @OnRouteStatus
			AND
			[DOD].[RowStatus] = 1
		ORDER BY
			ISNULL([DOD].[DateCreated], [DOD].[DateCreatedInSystem]) DESC
	);
	-- Guía para entrega o devolución
	DECLARE @IsGuideLastMileReturn BIT = 0;
	-- Datos de notificación
	DECLARE @NotificationCustomerId INT;
	DECLARE @NotificationEmail NVARCHAR(200);
	-- Flujos de incidencia
	DECLARE @NotifyOrigin BIT = 0;
	-- Ingreso de nuevo intento de entrega
	DECLARE @DeliveryAttemptInserted TABLE
	(
		IdDeliveryAttempt BIGINT NULL
	);
	-- Ingreso de nuevo estado a bitácora
	DECLARE @DeliveryOrderDetailInserted TABLE
	(
		IdDeliveryOrderDetail INT NULL
	);
	-- Actualización de intentos
	DECLARE @DeliveryOrderAttemptDataUpdated TABLE
	(
		IdDeliveryOrderAttemptData INT NULL
	);
	--Validar si aun tiene incidencias disponibles
	DECLARE @Incidentsavailable INT = (
	
			 Select ISNULL([DOAD].[GuideDeliveryMaxAttemptCount],0) -ISNULL([DOAD].[GuideDeliveryAttemptCount],0) 
				From [DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD WITH (NOLOCK)
			 Where 
			  GuideNumber =  @GuideNumber
	
	);

	IF ( @FirstOnRouteDate IS NULL )
	BEGIN
	    
		SELECT
			204 [ResponseCode],
			'Guía no ha sido despachada a ruta anteriormente, no es posible ingresar incidencia.' [ResponseMessage]

	END
	ELSE IF ( @SimulatedDate <= @FirstOnRouteDate )
	BEGIN
	    
		SELECT
			204 [ResponseCode],
			'Incidencia no puede ser ingresada antes de fecha y hora de primera salida a ruta.' [ResponseMessage]

	END
	ELSE IF(@Incidentsavailable <= 0)
	BEGIN
	SELECT
	         204 [ResponseCode],
			'Excedió la cantidad disponible de incidencias.' [ResponseMessage]
	END
    BEGIN

		BEGIN TRANSACTION 
		BEGIN TRY

			-- Obtener datos generales para procesamiento de la incidencia manual
			SELECT 
				TOP (1) 
					@IsGuideLastMileReturn = ISNULL(DO.[IsLastMileReturn], 0),
					@NotificationEmail = 
						(
							CASE
								WHEN LTRIM(RTRIM(ISNULL([DO].[Sender_Mail], ''))) <> '' THEN [DO].[Sender_Mail]
								WHEN LTRIM(RTRIM(ISNULL([Cu].[CODContactEmail], ''))) <> '' THEN [Cu].[CODContactEmail]
							END
						),
					@NotificationCustomerId = [DO].[IdCustomer]
			FROM
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
				LEFT JOIN
					[DeliveryBackOffice].[dbo].[Customer] Cu  WITH(NOLOCK) 
					ON
						[Cu].[IdCustomer] = [DO].[IdCustomer]
			WHERE
				[DO].[Guide_Serie] = @GuideSerie
				AND
				[DO].[Guide_Number] = @GuideNumber

			-- Revisar que procesos de incidencia proceden
			SELECT 
				TOP (1) 
					@NotifyOrigin = [CTI].[NotifiesOrigin],
					@IncidenceDescription = [CTI].[NameIncidence]
			FROM 
				[DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI  WITH(NOLOCK) 
			WHERE
				[CTI].[IdIncidenceType] = @Incidence
				AND
				[CTI].[RowStatus] = 1;

			-- Ingreso manual de intento de entrega para proceso
			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryAttempt]
			(
				[Guide_Serie],
				[Guide_Number],
				[Dry],
				[Cold],
				[Latitude],
				[Longitude],
				[Delivered],
				[ID_Courier],
				[ID_DeliveryOrderBySettlement],
				[User_Created],
				[Date_Created],
				[ID_Proof],
				[Verified],
				[Accepted],
				[User_Verified],
				[Date_Verified],
				[Accuracy],
				[ID_Incident],
				[Guide_Piece],
				[LogLatitude],
				[LogLongitude],
				[ConfirmationOfIncidenceId]
			)
			OUTPUT [Inserted].[ID] INTO	@DeliveryAttemptInserted ([IdDeliveryAttempt])
			SELECT 
				TOP (1) 
					@GuideSerie
					,@GuideNumber
					,[DO].[Pieces_Dry]
					,[DO].[Pieces_Cold]
					,NULL
					,NULL
					,0
					,NULL
					,NULL
					,@Token
					,@DateInSystem
					,NULL
					,0
					,0
					,NULL
					,NULL
					,NULL
					,@Incidence
					,NULL
					,NULL
					,NULL
					,NULL
			FROM 
				[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
			WHERE
				[DO].[Guide_Serie] = @GuideSerie
				AND
				[DO].[Guide_Number] = @GuideNumber

			-- Ingresar a bitácora de estados el intento de entrega fallido para la guía
			INSERT INTO [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
			(
				[Guide_Serie],
				[Guide_Number],
				[StatusOrderId],
				[UserCreated],
				[DateCreated],
				[DateCreatedInSystem],
				[Observations],
				[Temperature_Celsius],
				[PieceId],
				[RowStatus],
				[DeliveryAttemptId],
				[SystemOrigin]
			)
			OUTPUT [Inserted].[Guide_Number] INTO @DeliveryOrderDetailInserted ([IdDeliveryOrderDetail])
			SELECT
				TOP (1)
					@GuideSerie,       -- Guide_Serie - nvarchar(2)
					@GuideNumber,         -- Guide_Number - int
					@FailedDeliveryVisitStatus,         -- StatusOrderId - tinyint
					@Token,       -- UserCreated - nvarchar(50)
					@SimulatedDate, -- DateCreated - datetime
					@DateInSystem,      -- DateCreatedInSystem - datetime
					@Observations,      -- Observations - nvarchar(200)
					NULL,      -- Temperature_Celsius - decimal(5, 2)
					NULL,      -- PieceId - int
					1,   -- RowStatus - bit
					[DAI].[IdDeliveryAttempt],
					@SystemOrigin
			FROM
				@DeliveryAttemptInserted DAI

			-- Incrementar intentos de entrega de guía respecto a flujo correspondiente
			IF ( ISNULL(@IsGuideLastMileReturn, 0) = 0 )
			BEGIN
		    
				-- Flujo de entrega
				UPDATE
					[DOAD]
				SET
					[DOAD].[GuideDeliveryAttemptCount] = [DOAD].[GuideDeliveryAttemptCount] + 0
					,[DOAD].[TokenUpdated] = @Token
					,[DOAD].[DateUptaded] = @DateInSystem
				OUTPUT [Inserted].[IdDeliveryOrderAttemptData] INTO @DeliveryOrderAttemptDataUpdated ([IdDeliveryOrderAttemptData])
				FROM
					[DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD
				WHERE
					[DOAD].[GuideSerie] = @GuideSerie
					AND
					[DOAD].[GuideNumber] = @GuideNumber

			END
			ELSE
			BEGIN
            
				-- Flujo de devolución
				UPDATE
					[DOAD]
				SET
					[DOAD].[GuideReturnAttemptCount] = [DOAD].[GuideReturnAttemptCount] + 1
					,[DOAD].[TokenUpdated] = @Token
					,[DOAD].[DateUptaded] = @DateInSystem
				OUTPUT [Inserted].[IdDeliveryOrderAttemptData] INTO @DeliveryOrderAttemptDataUpdated ([IdDeliveryOrderAttemptData])
				FROM
					[DeliveryBackOffice].[dbo].[DeliveryOrderAttemptData] DOAD
				WHERE
					[DOAD].[GuideSerie] = @GuideSerie
					AND
					[DOAD].[GuideNumber] = @GuideNumber

			END

			-- Generar proceso de notificación a remitente
			IF ( ISNULL(@NotifyOrigin, 0) = 1 )
			BEGIN
				    
				-- Debe procesar notificación por correo a remitente

				-- Notificación activa para destino de notificación y tipo de notificación
				DECLARE @NotificationQueueId BIGINT =
				(
					SELECT 
						TOP (1) 
							[NQ].[IdNotificationQueue] 
					FROM 
						[DeliveryBackOffice].[dbo].[NotificationQueue] NQ  WITH(NOLOCK) 
					WHERE 
						[NQ].[CustomerId] = @NotificationCustomerId 
						AND
						[NQ].[CatNotificationTypeId] = @NotificationType
						AND
						[NQ].[CatNotificationMediumId] = @EmailNotificationMedium
						AND
						[NQ].[IsSent] = 0
						AND
						[NQ].[RowStatus] = 1
						AND
						[NQ].[DateToSend] = CAST(GETDATE() AS DATE)
					ORDER BY
						[NQ].[DateToSend] ASC
				)

				-- Revisar si existe notificación activa para el destino de notificación y tipo de notificación
				IF 
				( 
					ISNULL(@NotificationQueueId, 0) > 0
				)
				BEGIN
					-- Existe un registro activo pendiente para adjuntar información

					-- Revisar si la guía ya existe en detalle
					IF
					(
						NOT EXISTS 
						( 
							SELECT 
								TOP 1 
									1 
							FROM 
								[DeliveryBackOffice].[dbo].[NotificationQueueDetail] NQD  WITH(NOLOCK) 
							WHERE 
								[NQD].[NotificationQueueId] = @NotificationQueueId 
								AND 
								[NQD].[GuideSerie] = @GuideSerie 
								AND 
								[NQD].[GuideNumber] = @GuideNumber 
								AND 
								[NQD].[RowStatus] = 1 
						)
					)
					BEGIN

						-- Adicionar guía a detalle de notificaciones si no existe
						INSERT INTO [DeliveryBackOffice].[dbo].[NotificationQueueDetail]
						(
							[NotificationQueueId],
							[GuideSerie],
							[GuideNumber],
							[MembershipId],
							[SubscriptionId],
							[RowStatus],
							[TokenCreated],
							[DateCreated],
							[TokenUpdated],
							[DateUpdated]
						)
						VALUES
						(   
							@NotificationQueueId,         -- NotificationQueueId - bigint
							@GuideSerie,      -- GuideSerie - nvarchar(10)
							@GuideNumber,      -- GuideNumber - int
							NULL,      -- MembershipId - int
							NULL,      -- SubscriptionId - int
							1,   -- RowStatus - bit
							N'sps_proof_onincident',       -- TokenCreated - nvarchar(50)
							GETDATE(), -- DateCreated - datetime
							NULL,      -- TokenUpdated - nvarchar(50)
							NULL       -- DateUpdated - datetime
						);

					END

				END
				ELSE
				BEGIN

					-- No existe registro activo pendiente, generar uno
					DECLARE @NotificationOutput TABLE 
					(
						NotificationQueueId BIGINT NULL
					)

					INSERT INTO [DeliveryBackOffice].[dbo].[NotificationQueue]
					(
						[CatNotificationMediumId],
						[CatNotificationTypeId],
						[CustomerId],
						[AccountId],
						[DestinationPhone],
						[DestinationEmail],
						[NotificationDate],
						[DateToSend],
						[IsSent],
						[RowStatus],
						[TokenCreated],
						[DateCreated],
						[TokenUpdated],
						[DateUpdated]
					)
					OUTPUT [Inserted].[IdNotificationQueue] INTO @NotificationOutput ([NotificationQueueId])
					VALUES
					(   
						@EmailNotificationMedium,         -- CatNotificationMediumId - int
						@NotificationType,         -- CatNotificationTypeId - bigint
						@NotificationCustomerId,      -- CustomerId - int
						NULL,      -- AccountId - bigint
						NULL,      -- DestinationPhone - nvarchar(200)
						@NotificationEmail,      -- DestinationEmail - nvarchar(200)
						GETDATE(), -- NotificationDate - date
						GETDATE(), -- DateToSend - date
						0,   -- IsSent - bit
						1,   -- RowStatus - bit
						N'sps_proof_onincident',       -- TokenCreated - nvarchar(50)
						GETDATE(), -- DateCreated - datetime
						NULL,      -- TokenUpdated - nvarchar(50)
						NULL       -- DateUpdated - datetime
					)

					SET @NotificationQueueId = 
					(
						SELECT 
							TOP (1) 
								[NotO].[NotificationQueueId] 
						FROM 
							@NotificationOutput NotO
					)
						
					INSERT INTO [DeliveryBackOffice].[dbo].[NotificationQueueDetail]
					(
						[NotificationQueueId],
						[GuideSerie],
						[GuideNumber],
						[MembershipId],
						[SubscriptionId],
						[RowStatus],
						[TokenCreated],
						[DateCreated],
						[TokenUpdated],
						[DateUpdated]
					)
					VALUES
					(   
						@NotificationQueueId,         -- NotificationQueueId - bigint
						@GuideSerie,      -- GuideSerie - nvarchar(10)
						@GuideNumber,      -- GuideNumber - int
						NULL,      -- MembershipId - int
						NULL,      -- SubscriptionId - int
						1,   -- RowStatus - bit
						N'sps_proof_onincident',       -- TokenCreated - nvarchar(50)
						GETDATE(), -- DateCreated - datetime
						NULL,      -- TokenUpdated - nvarchar(50)
						NULL       -- DateUpdated - datetime
					);

				END
					 
			END

			IF 
			( 
				-- Ingreso intento de entrega
				EXISTS 
				( 
					SELECT 
						TOP 1 
							1 
					FROM 
						@DeliveryAttemptInserted 
				)
				AND
				-- Ingreso estado a bitácora de guía
				EXISTS 
				( 
					SELECT 
						TOP 1 
							1 
					FROM 
						@DeliveryOrderDetailInserted 
				)
				AND
				-- Actualizo contadores de intentos
				EXISTS 
				( 
					SELECT 
						TOP 1 
							1 
					FROM 
						@DeliveryOrderAttemptDataUpdated 
				)
			)
			BEGIN
		    
				COMMIT TRANSACTION;

				SELECT
					200 [ResponseCode],
					'Información ingresada correctamente' [ResponseMessage]

				SELECT 
					TOP (1) 
						CONCAT([DO].[Guide_Serie], [DO].[Guide_Number]) [Guide] 
						,@IncidenceDescription [IncidenceDescription]
						,FORMAT(@SimulatedDate, 'dd/MM/yyyy hh:mm:ss') [IncidenceDate]
						,FORMAT(@DateInSystem, 'dd/MM/yyyy hh:mm:ss') [RegistryDate] 
				FROM 
					[DeliveryBackOffice].[dbo].[DeliveryOrder] DO  WITH(NOLOCK) 
				WHERE
					[DO].[Guide_Serie] = @GuideSerie
					AND
					[DO].[Guide_Number] = @GuideNumber

			END
			ELSE
			BEGIN
		    
				ROLLBACK TRANSACTION;

				SELECT
					204 [ResponseCode],
					'No se culmino el proceso completo de forma exitosa' [ResponseMessage]

			END

		END TRY
		BEGIN CATCH

			ROLLBACK TRANSACTION;

			SELECT
				500 [ResponseCode],
				CONCAT('Mensaje: ', ERROR_MESSAGE(),'| Linea aproximada: ', ERROR_LINE()) [ResponseMessage]
	    
		END CATCH
        
    END

END