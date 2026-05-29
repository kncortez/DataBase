/* =================================================
   SP:        [dbo].[SetIncidenceService]
   Propósito: Recollection Incidence
   Autor:     Hugo, Gomez
   Historia:  
   Fecha:     2021-02-16
   === CHANGELOG ============================
2026-04-14 | Historia/épica: FDAPI-6061 | Autor: Erick Hernandez | Se agrega verificacion de hub y pais not null al insertar la incidencia
=========================================== */
CREATE PROCEDURE [dbo].[SetIncidenceService]
	-- Add the parameters for the stored procedure here	
	@TblIncidenceLink AS TblIncidenceLink READONLY,
	@ServiceManagementId  INT = 0,
	@IncidenceTypeId   INT = 0,
	@DescriptionIncidence  varchar (200) = 'Problemas de ubicacion',
	@Accuracy    varchar (200) = '44',
	@Latitude varchar  (200) = '55798797342',
	@Longitude varchar  (200) = '546689',
	@Token varchar (200) = '545656asdf564afd'
	--@Photos varchar (MAX) = 'jkjadshkjfhjadhflkjads',
	

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

	-- Variables de incidencias terminales - 
	DECLARE @DuplicateId INT = (SELECT TOP 1 CTI.IdIncidenceType FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH(NOLOCK) WHERE CTI.NameIncidence = 'Servicio duplicado' COLLATE Latin1_General_CI_AI);
	DECLARE @CanceledId INT = (SELECT TOP 1 CTI.IdIncidenceType FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH(NOLOCK) WHERE CTI.NameIncidence = 'Cliente cancelo servicio' COLLATE Latin1_General_CI_AI);
	DECLARE @AlreadyPickedId INT = (SELECT TOP 1 CTI.IdIncidenceType FROM [DeliveryBackOffice].[dbo].[CatTypeIncidence] CTI WITH(NOLOCK) WHERE CTI.NameIncidence = 'Recolectada en otra ruta' COLLATE Latin1_General_CI_AI);

	-- Variables de estado cancelado -
	DECLARE @CanceledStatusId INT = (SELECT TOP 1 CSS.IdServiceStatus FROM [DeliveryBackOffice].[dbo].[CatServiceStatus] CSS WITH(NOLOCK) WHERE CSS.[Name] = 'Cancelado' COLLATE Latin1_General_CI_AI);

	DECLARE @jsonToken NVARCHAR(MAX)
	declare @jsonService NVARCHAR(MAX)
	-- declare @TokenAct int  = (select top 1 RowStatus from LogTokenPOD WITH(NOLOCK) where LogTokenPOD LIKE '%' + @Token + '%' order by DateCreated desc)
	--declare @hourtoken int = (select top 1 DATEDIFF(HOUR, DateCreated, GETDATE() ) as horas from LogTokenPOD WITH(NOLOCK) where LogTokenPOD  LIKE '%' + @Token + '%' order by DateCreated desc)
	declare @servicio int = (select COUNT(IdServiceManagement) from ServiceManagement WITH(NOLOCK) where IdServiceManagement = @ServiceManagementId)

	--print 'validando token'
	--if ( (@TokenAct = 1 and @hourtoken <= 8) OR 1 = 1 )
	--	begin 
				--print 'token validado'
	
						
					declare @validate int  = (select ServiceStatusId from ServiceManagement WITH(NOLOCK) where IdServiceManagement =  @ServiceManagementId)
								
				 --print 'validando status'  
				 --print @validate
				 
							
					if(@servicio > 0)
								begin 
							
									if(@validate <> 4)
										begin
													SET NOCOUNT ON;
				
													DECLARE @jsonResult NVARCHAR(MAX) 
												
														-- insertar en tabla temporal posbibles mensajes de respuesta
															
														IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
															select * INTO #responsemessage from (SELECT  200 AS IdResult
																	,'Estado  cambiado correctamente' AS Message
																	,'OK' as Id 
															union
															SELECT  500 AS IdResult
																	,'Error faltal intente de nuevo mas tarde' AS Message
																	,'Transac' as Id 
														 )  as errror
															BEGIN TRANSACTION
																BEGIN TRY
								
																	insert into DeliveryBackOffice.dbo.IncidenceServices(ServiceManagementId,IncidenceTypeId, DescriptionIncidence, Latitude, Longitude, Accuracy, RowStatus, TokenCreated, DateCreated, TokenUpdated, DateUpdated)
																	values (@ServiceManagementId, @IncidenceTypeId, @DescriptionIncidence, @Latitude, @Longitude, @Accuracy, 1, @Token, GETDATE(), null, null)
																	
																	declare @incidence int  = SCOPE_IDENTITY()
																	
																	INSERT INTO DeliveryBackOffice.dbo.ProofIncidence
																	(IncidenceId
																	,PathIncidence
																	,RowStatus
																	,TokenCreated
																	,DateCreated
																	,TokenUpdated
																	,DateUpdated
																	)
																	SELECT @incidence
																	,li.PathIncidence
																	,1
																	,@Token
																	,GETDATE()
																	,null
																	,null
																	FROM @TblIncidenceLink li


																	------- CODE SNIPPET ONLY FOR PICKUP INCIDENT MICROSERVICE
																	DECLARE @CourierID INT;
																	DECLARE @PATH NVARCHAR (500);
																	DECLARE @HubID INT;
																	DECLARE @CountryID VARCHAR (2);
																	DECLARE @INCIDENT_SERVICE_STATUS_ID INT = 4;

																	SELECT @PATH = PathIncidence FROM @TblIncidenceLink;

																	SELECT TOP 1 @CourierID = idCourierman
																	FROM DeliveryBackOffice.dbo.LogTokenPOD WITH(NOLOCK) 
																	WHERE LogTokenPOD = @Token
																	AND RowStatus = 1
																	ORDER BY DateCreated desc

																	SELECT @HubID = SP.IdHubLogistics, @CountryID = H.IdCountry
																	FROM DeliveryBackOffice.dbo.ServiceManagement SM WITH(NOLOCK)
																	INNER JOIN DeliveryBackOffice.dbo.SchedulePickup SP WITH(NOLOCK)
																		ON SP.SchedulePickupId = SM.IdSchedulePickup
																	INNER JOIN DeliveryBackOffice.dbo.HubLogistics H WITH(NOLOCK)
																		ON H.IdHubLogistic = SP.IdHubLogistics
																	WHERE SM.IdServiceManagement = @ServiceManagementId;

																	IF @HubID IS NOT NULL AND @CountryID IS NOT NULL
																	BEGIN
																		EXEC dbo.SaveServiceIncident @ServiceManagementId, @CourierID, @INCIDENT_SERVICE_STATUS_ID, @IncidenceTypeId, @DescriptionIncidence, @CountryID, @HubID, @Latitude, @Longitude, @PATH, @Token;
																	END
																	-------
				
																	---------------------------------------------- Actualiza el Status del Pickup  -------------------------------------------------------------------------
																
																	declare @Status int = (	select IdServiceStatus from  CatServiceStatus WITH(NOLOCK) where IdServiceStatus =  4)
													
																	update ServiceManagement set ServiceStatusId = @Status, DateUpdated = GETDATE(), TokenUpdated = @Token
																		from ServiceManagement WITH(NOLOCK)
																		where IdServiceManagement = @ServiceManagementId
													
																		declare @transac int = (select top 1 IdServiceManagement from ServiceManagement WITH(NOLOCK) where IdServiceManagement = @ServiceManagementId)
																
																   ---------------------------------------------- Inserta en EventService el comportamiento del Pickup  -------------------------------------------------------------------------	
																	
																	insert into EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
																	values( @transac, @Status, 1, @Token, GETDATE(), @DescriptionIncidence )

																	IF(@IncidenceTypeId = @DuplicateId OR @IncidenceTypeId = @CanceledId OR @IncidenceTypeId = @AlreadyPickedId)
																	BEGIN

																		update ServiceManagement set ServiceStatusId = @CanceledStatusId, DateUpdated = GETDATE(), TokenUpdated = @Token
																		from ServiceManagement WITH(NOLOCK)
																		where IdServiceManagement = @ServiceManagementId
																	
																		insert into EventService (ServiceManagementId, ServiceStatusId, RowStauts, TokenCreated, DateCreated, Observations)
																		values( @transac, @CanceledStatusId, 1, @Token, GETDATE(), @DescriptionIncidence )

																		--Se cancela la solicitud
																		UPDATE sp 
																		SET sp.SchedulePickupStatus = 0
																		FROM SchedulePickup sp WITH(NOLOCK)
																		INNER JOIN ServiceManagement sm WITH(NOLOCK)
																			ON sm.IdSchedulePickup = sp.SchedulePickupId
																		WHERE sm.IdServiceManagement = @ServiceManagementId

																	END
																
																END TRY
																BEGIN CATCH
																	ROLLBACK TRANSACTION
																	select ERROR_MESSAGE()
																		-- retornar mensaje de error
																	set @jsonResult =(
																		SELECT STUFF(( 
																		SELECT '"IdResult":' +  convert(varchar,IdResult)    +',' 
																		+ '"Message":"' + convert( nvarchar(max),ERROR_MESSAGE()) + '"}' from #responsemessage where Id ='Invalid'
																		FOR XML PATH(''), TYPE
																		).value('.', 'varchar(max)'),1,1,''
																			  ) 
																	)
																END CATCH;
																IF @@TRANCOUNT > 0 BEGIN
																	COMMIT TRANSACTION;
																
																
																	set @jsonResult = (SELECT STUFF(( 
																	SELECT 
																	  ',"Messege":"Incidente Guardado exitosamente"}'
																
																	FOR XML PATH(''), TYPE
																					).value('.', 'varchar(max)'),1,1,''
																							) )
																
																	--- succesfull
																END
																
																-- destruir tablas temporales
																
																
																IF OBJECT_ID('tempdb.dbo.#responsemessage', 'U') IS NOT NULL DROP TABLE #responsemessage;
																
																-- retornar resultado en formato json
																
															select ('[{' + @jsonResult +  ']') jsonResult
												
										
											end			-----------------------------------------------------------------------------------------------------------------------------------------------------------
															else if (@validate = 4)
																begin
																		Select 'OK' 
																end
											end 
											else if( @servicio <= 0)
													begin
														SET @jsonService = (
																   SELECT STUFF((
		   															SELECT  
																	',{"IdResult":' + '403' + ',' +
																	'"DescriptionError":"' + 'Servicio Invalido'  + '"' +	  	  
																	'}' 
																	FOR XML PATH(''), TYPE
																   ).value('.', 'varchar(max)'),1,1,''
		   																	  ) 
																   )
																	 select '['+ @jsonService + ']' jsonService
	
																   return 
											        END 
		--end

		--else if(@TokenAct = 0 or @TokenAct is null or @hourtoken > 8)
		--begin 
		--		  print 'token inválido'
		--			SET @jsonToken = (
		--		   SELECT STUFF((
		--   			SELECT  
		--			',{"IdResult":' + '403' + ',' +
		--			'"DescriptionError":"' + 'Token inválido'  + '"' +	  	  
		--			'}' 
		--			FOR XML PATH(''), TYPE
		--		   ).value('.', 'varchar(max)'),1,1,''
		--   					  ) 
		--		   )
		--			 select '['+ @jsonToken + ']' jsonToken
	
		--		   return
	 --   END

END