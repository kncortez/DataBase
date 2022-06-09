-- =============================================
-- Author:		<Edwin,Ramirez>
-- Create date: <2021-25-11>
-- Description:	<actualiza los registros de usuarios forza delivery>
-- =============================================
CREATE PROCEDURE [dbo].[sphdSetUser]
	-- Add the parameters for the stored procedure here
	@CodeUser AS BIGINT =  100088,
	@Username AS NVARCHAR(50) =  'edwin.ramirez',
	@Password AS NVARCHAR(50) = 'wXoG945XvwMXqVE17c8euA==',
	@Country AS NVARCHAR(3) = 'GT',
	@FirstName AS NVARCHAR(50) =  'Edwin',
	@LastName AS NVARCHAR(50) = 'Ramirez',
	@Gender AS CHAR(1) = 'M',
	@DPI AS NVARCHAR(50) = '1608 67126 1209',
	@Birthdate AS DATE = '1985-11-09',
	@Email AS NVARCHAR(50) = 'edwin.ramirez@forzalatam.com',
	@IdSystems AS NVARCHAR(50) = '1,3,5',
	@IdRols AS NVARCHAR(50) = '2,4,5,12',
	@IdStations AS NVARCHAR(50) = '6,61,70,72',
	@Token AS NVARCHAR(50) =   '5Y5-4DM1ND3V',
	@Status AS BIT = 'TRUE',
	@ParIdPerson AS BIGINT = 2, -- <=0 create , >0 update
	@ParIdRegisterUsr AS BIGINT = 2, -- <=0 create , >0 update
	@Par@IdEmployee AS INT = 1, 
	@PadIdAccount AS INT = 2
AS
BEGIN
	
	BEGIN  -- temporals tables
		/* 
		Tablas de apoyo para el registro a base datos de sistema, rol y estación
		*/

		DECLARE @MaxCountR AS INT=0
		DECLARE @MaxCountS AS INT=0
		DECLARE @MaxCountSt AS INT=0
		DECLARE @cntR INT=1
		DECLARE @cntS INT=1
		DECLARE @cntSt INT=1

		DECLARE @ParFiletrR INT=1
		DECLARE @ParFiletrS INT=1
		DECLARE @ParFiletrSt INT=1


		IF OBJECT_ID('tempdb.dbo.#tblParSystem', 'U') IS NOT NULL DROP TABLE #tblParSystem;
		IF OBJECT_ID('tempdb.dbo.#tblParRol', 'U') IS NOT NULL DROP TABLE #tblParRol;
		IF OBJECT_ID('tempdb.dbo.#tblParStation', 'U') IS NOT NULL DROP TABLE #tblParStation;

		SELECT a.id,
			   a.Item
			   INTO #tblParRol
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdRols,',') a

		SELECT a.id,
			   a.Item
			   INTO #tblParSystem
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdSystems,',') a

		SELECT a.id,
			   a.Item
			   INTO #tblParStation
		FROM DeliveryBackOffice.dbo.SplitUnlimited(@IdStations,',') a

		SELECT @MaxCountR=count(*) 
		FROM #tblParRol

		select @MaxCountS=count(*) 
		FROM #tblParSystem

		SELECT @MaxCountSt=COUNT(*) 
		FROM #tblParStation

		--SELECT pr.id,
		--       pr.Item 
		--FROM #tblParRol pr

		--SELECT ps.id,
		--       ps.Item
		--FROM #tblParSystem ps

		--SELECT pst.id,
		--       pst.Item 
		--FROM #tblParStation pst
	END
		
	BEGIN TRY

	BEGIN TRANSACTION MNGMNTUSR
		
		DECLARE @IdPerson AS BIGINT = -1
		PRINT '1- valid existence dbo.Person'
		 IF EXISTS(	SELECT prs.PerIdPerson 
					FROM DeliveryBackOffice.dbo.Person prs 
					WHERE prs.PerIdPerson = @ParIdPerson
				  ) 
			BEGIN 
				SET @IdPerson = @ParIdPerson
				PRINT '1. dbo.Person exists @IdPerson=' + CAST(@IdPerson AS VARCHAR(10))
			END 
		ELSE 
			BEGIN
				-- 1  Makes an insert into table person
				INSERT INTO DeliveryBackOffice.dbo.Person  
								(PerFirstName
								,PerLastName
								,PerGender
								,PerBirthdate
								,PerIdentification
								,PerNationality
								,PerRowStatus
								,PerTokenCreated
								,PerDateCreated)
				SELECT @FirstName  [FirstName],
					   @LastName   [LastName], 
					   @Gender     [Gender],
					   @Birthdate  [BirthDate],
					   @DPI        [DPI],
					   @Country    [Country],
					   'TRUE'      [RowStatus],
					   @Token      [Token],
					   GETDATE()   [DateCreated]

				SET @IdPerson =  SCOPE_IDENTITY()

				PRINT '1. INSERT dbo.Person @IdPerson=' + CAST(@IdPerson AS VARCHAR(10))
		END 

		DECLARE @ExpirationDate AS DATE = (SELECT DATEADD(DAY,90,GETDATE()));

		DECLARE @IdRegisterUser AS BIGINT =  -1
		PRINT '2- Valid existence dbo.RegisterUser'
		IF EXISTS(SELECT UsrIdUser FROM dbo.RegisterUser WHERE UsrIdUser = @ParIdRegisterUsr)
		BEGIN 
			SET @IdRegisterUser = @ParIdRegisterUsr
			PRINT '2. dbo.RegisterUser exists @IdRegisterUser= ' + CAST(@IdRegisterUser AS VARCHAR(10))
			UPDATE DeliveryBackOffice.dbo.RegisterUser 
				SET UsrEmail			  = @Email,
					UsrLastPassword		  = @Password,
					UsrPasswordExpiration = @ExpirationDate,
					UsrDeviceType		  = 'Desktop',
					UsrRowStatus          = @Status,
					UsrTokenUpdated		  = @Token,
					UsrDateUpdated		  = GETDATE()
			WHERE UsrIdUser = @IdRegisterUser
		END
		ELSE
		BEGIN 
			--2 Makes an insert into table RegisterUser once person was created
			INSERT INTO DeliveryBackOffice.dbo.RegisterUser  
									(UsrIdPerson
									,UsrNickName
									,UsrEmail
									,UsrAvatar
									,UsrLastPassword
									,UsrPasswordExpiration
									,UsrLang
									,UsrDeviceType
									,UsrCurrency
									,UsrEnable2FA
									,UsrRestrictionAddressIp
									,UsrRowStatus
									,UsrTokenCreated
									,UsrDateCreated)
			SELECT @IdPerson	[IdPerson], 
				   DeliveryBackOffice.dbo.CapitalizeFirstLetter(@FirstName + '.'+ @LastName)	[NickName],
				   @Email		[Email],
				   ''			[Avatar],
				   @Password	[Password],
				   @ExpirationDate [ExpirationDate],
				   'ES'			[Language],
				   'Desktop'	[DeviceType],
				   'GTQ'		[Currency],
				   NULL			[Enable2FA],
				   NULL			[RestrictionAddressIP],
				   'TRUE'		[RowStatus],
				   @Token		[Token],
				   GETDATE()	[DateCreated]
				   --,'dbo.RegisterUser' [Entity]

			SET @IdRegisterUser = SCOPE_IDENTITY()

			PRINT '2. INSERT dbo.RegisterUser @IdRegisterUser= ' + CAST(@IdRegisterUser AS VARCHAR(10))

		END 

		PRINT '3-  dbo.UserSystemRestriction'
		BEGIN  /*works with permutations for system and user
					Si existe tupla, actualiza de lo contrario inserta
			    */
			--Limpio todas las asignaciones de sistemas para el iduser
			UPDATE DeliveryBackOffice.dbo.UserSystemRestriction
			SET UstStatus = 'INACTIVE',
			UstAccessRetries = 10,
			UstRetries = 0,
			UstOperationDate = GETDATE()
			WHERE UstIdUser = @IdRegisterUser

			SET @ParFiletrS =1
			select @MaxCountS=count(*) 
			FROM #tblParSystem
		
			SET @cntS=1
			WHILE @cntS <= @MaxCountS
			BEGIN	
			-----------------------------------------------------------------------------			
				SELECT @ParFiletrS=ps.Item 
				FROM #tblParSystem ps 
				JOIN dbo.CatSystem cstm 
						ON ps.Item = cstm.SysIdSystem
				WHERE ps.id= @cntS		

				--si existe la tupla en catalogo sistema
				IF EXISTS(SELECT cstm.SysIdSystem
						  FROM #tblParSystem stm  
						  JOIN dbo.CatSystem cstm 
								ON stm.Item = cstm.SysIdSystem
						   WHERE stm.id= @cntS)
				BEGIN
				-----------------------------------------------------------------------------			
						--SELECT @ParFiletrS, @IdRegisterUser
						PRINT '3- valid existence dbo.UserSystemRestriction IdUser=' + CAST(@IdRegisterUser AS NVARCHAR(50)) + ' IdSystem=' + CAST(@ParFiletrS AS NVARCHAR(50))
						IF EXISTS(SELECT rest.UstIdRestriction 
									FROM DeliveryBackOffice.dbo.UserSystemRestriction rest 
									WHERE rest.UstIdUser = @IdRegisterUser
									AND rest.UstIdSystem = @ParFiletrS)
						BEGIN
								UPDATE DeliveryBackOffice.dbo.UserSystemRestriction 
    									SET UstStatus = (CASE WHEN @Status = 'TRUE' THEN 'ACTIVE' ELSE 'INACTIVE' END),
    									UstRowStatus = @Status ,
    									UstOperationDate = GETDATE()
								WHERE UstIdUser = @IdRegisterUser
								AND UstIdSystem = @ParFiletrS
								PRINT '3. UPDATE dbo.UserSystemRestriction IdUser=' + CAST(@IdRegisterUser AS NVARCHAR(50)) + ' IdSystem=' + CAST(@ParFiletrS AS NVARCHAR(50))
						END 
						ELSE
						BEGIN 
								--3 Makes an insert into table UserSystemRestriction once the user was registered
								INSERT INTO DeliveryBackOffice.dbo.UserSystemRestriction  
								(UstIdUser
								,UstIdSystem	-- System 1 equals to Hermes Web Portal
								,UstAccessRetries -- 10 attemps by default
								,UstRetries      -- Counter needs to start in 0
								,UstStatus		--- When is being created set up in ACTIVE
								,UstRowStatus
								,UstTokenCreated
								,UstDateCreated
								,UstOperationDate)
								SELECT DISTINCT 
										@IdRegisterUser	[IdUser], 
										@ParFiletrS		[IdSystem], 
										10				[Retries], 
										0				[AccessRetries], 
										'ACTIVE'		[Status], 
										'TRUE'			[RowStatus],
										@Token			[Token],
										GETDATE()		[DateCreated],
										GETDATE()		[DateOperation]
										--,'dbo.UserSystemRestriction' [Entity]
								PRINT '3. INSERT UserSystemRestriction IdUser=' + CAST(@IdRegisterUser AS NVARCHAR(50)) + ' IdSystem=' + CAST(@ParFiletrS AS NVARCHAR(50))
						END 
				-----------------------------------------------------------------------------			
				END 
				SET @cntS = @cntS + 1
			-----------------------------------------------------------------------------------------------
			END
		END 

		PRINT '4- dbo.RolByUserBySystem'
		BEGIN  --works with permutations for role, system, station and user 
			/*if exists update else insert record */
			--Limpia todos los registros de la asignacion de rol por sistema del iduser
			UPDATE DeliveryBackOffice.dbo.RolByUserBySystem
			SET RusRowStatus = 'FALSE',
			RusTokenUpdated = @Token,
			RusDateUpdated = GETDATE()
			WHERE RusIdUser = @IdRegisterUser
			
			SET @cntR=1
				SET @cntS=1
				SET @cntSt=1
				WHILE @cntSt <= @MaxCountSt
				BEGIN
					SET @cntS=1
					WHILE @cntS <= @MaxCountS
					BEGIN	
						SET @cntR=1
						WHILE @cntR <= @MaxCountR
						BEGIN
						-----------------------------------------------------------------------------			
							----SELECT @ParFiletrR=pr.Item FROM #tblParRol pr WHERE pr.id= @cntR		
							----SELECT @ParFiletrS=ps.Item FROM #tblParSystem ps WHERE ps.id= @cntS		
							----SELECT @ParFiletrSt=pst.Item FROM #tblParStation pst WHERE pst.id= @cntSt

							--obtiene el id del rol
							SELECT @ParFiletrR=pr.Item FROM #tblParRol pr JOIN dbo.CatRol rol ON pr.Item = rol.RolIdRol WHERE pr.id= @cntR	
					
							--obtiene el id del sistema
							SELECT @ParFiletrS=ps.Item FROM #tblParSystem ps JOIN dbo.CatSystem cstm ON ps.Item = cstm.SysIdSystem WHERE ps.id= @cntS		

							--obtiene el id de la station
							SELECT @ParFiletrSt = cstn.IdStation FROM #tblParStation pstn JOIN dbo.CatStation cstn ON pstn.Item = cstn.IdStation WHERE pstn.id= @cntSt

							----si existe la tupla en catalogo sistema, rol y estacion 
							IF EXISTS(SELECT pr.Item FROM #tblParRol pr JOIN dbo.CatRol rol ON pr.Item = rol.RolIdRol WHERE pr.id= @cntR)
							BEGIN
								IF EXISTS (SELECT ps.Item FROM #tblParSystem ps JOIN dbo.CatSystem cstm ON ps.Item = cstm.SysIdSystem WHERE ps.id= @cntS)
								BEGIN
									IF EXISTS(SELECT cstn.IdStation FROM #tblParStation pstn  JOIN dbo.CatStation cstn ON pstn.Item = cstn.IdStation WHERE pstn.id= @cntSt)
									BEGIN
									-----------------------------------------------------------------------------						
												--SELECT @ParFiletrR [IdRol], @ParFiletrS [IdSystem],  @ParFiletrSt [IdStation]
												PRINT 'Valid existence dbo.RolByUserBySystem IdRol='+ CAST(@ParFiletrR AS VARCHAR(50)) +' IdSystem='+ CAST(@ParFiletrS AS VARCHAR(50)) +' IdUser=' + CAST(@IdRegisterUser AS VARCHAR(50)) +' IdStation=' + CAST(@ParFiletrSt AS VARCHAR(50)) 
												IF EXISTS (SELECT TOP (1) rus.RusIdRol
															FROM DeliveryBackOffice.dbo.RolByUserBySystem rus
															WHERE rus.RusIdUser=@IdRegisterUser
															AND rus.RusIdRol=@ParFiletrR 
															AND rus.RusIdSystem=@ParFiletrS 
															AND rus.StationId=@ParFiletrSt)
												BEGIN	
														UPDATE DeliveryBackOffice.dbo.RolByUserBySystem
														SET RusTokenUpdated = @Token,
																RusDateUpdated = GETDATE(),
																RusRowStatus = @Status
														WHERE RusIdUser=@IdRegisterUser
														AND RusIdRol=@ParFiletrR 
														AND RusIdSystem=@ParFiletrS 
														AND StationId=@ParFiletrSt
									
														--SELECT @ParFiletrR RusIdRol,
														--		 @ParFiletrS RusIdSystem,
														--		 @ParFiletrSt StationId,
														--		 @IdRegisterUser IdRegisterUser
														--		,'dbo.RolByUserBySystem' [Entity]
														--		,'Update' [Operation]
													PRINT '4. UPDATE RolByUserBySystem IdRol='+ CAST(@ParFiletrR AS VARCHAR(50)) +' IdSystem='+ CAST(@ParFiletrS AS VARCHAR(50)) +' IdUser=' + CAST(@IdRegisterUser AS VARCHAR(50)) +' IdStation=' + CAST(@ParFiletrSt AS VARCHAR(50)) 
												END
												ELSE
												BEGIN
													--4 Makes an insert into table RolByUserBySystem once the user was registered
													INSERT INTO DeliveryBackOffice.dbo.RolByUserBySystem
																(RusIdRol
																,RusIdSystem
																,RusIdUser
																,RusRowStatus
																,RusTokenCreated
																,RusDateCreated
																,StationId)
													SELECT @ParFiletrR		[IdRol],
															@ParFiletrS		[RusIdSystem],
															@IdRegisterUser	[IdUser],
															'TRUE'			[RowStatus],
															@Token			[Token],
															GETDATE()		[DateCreated],
															@ParFiletrSt	[StationId]
															--,'dbo.RolByUserBySystem' [Entity]
															--,'Insert' [Operation]
													PRINT '4. INSERT dbo.RolByUserBySystem IdRol='+ CAST(@ParFiletrR AS VARCHAR(50)) +' IdSystem='+ CAST(@ParFiletrS AS VARCHAR(50)) +' IdUser=' + CAST(@IdRegisterUser AS VARCHAR(50)) +' IdStation=' + CAST(@ParFiletrSt AS VARCHAR(50)) 
												END
									-----------------------------------------------------------------------------						
									END 
								END
							END 
						-----------------------------------------------------------------------------						
						SET @cntR=@cntR+1
						END
						SET @cntS=@cntS+1	
					END
					SET @cntSt=@cntSt+1	
				END
		END 

		PRINT '5- valid existence dbo.InternalUser IdUser=' + CAST(@CodeUser AS VARCHAR(50)) + ' Username=' +  CAST(@Username AS VARCHAR(50)) + ' IdRegisterUser= ' +  CAST(@IdRegisterUser AS VARCHAR(50))
		IF EXISTS( SELECT ius.RegisterUserID 
					FROM DeliveryBackOffice.dbo.InternalUser ius
					WHERE ius.IdUser = @CodeUser
					AND ius.Username = @Username
					AND ius.RegisterUserID = @IdRegisterUser
				 )
		BEGIN
			UPDATE DeliveryBackOffice.dbo.InternalUser 
					SET IdEmployee = @Par@IdEmployee,
					RowStatus = @Status,
					TokenUpdated = @Token,
					DateUpdated = GETDATE()
			WHERE IdUser = @CodeUser
			AND Username = @Username
			AND RegisterUserID = @IdRegisterUser
			----SELECT  ius.RegisterUserID, 
				----		ius.IdEmployee,
				----		ius.RowStatus,
				----		ius.RegisterUserID, 
				----		@Token TokenUpdated, 
				----		GETDATE() DateUpdated, 
				----		'dbo.InternalUser' [Entity]
				----FROM DeliveryBackOffice.dbo.InternalUser ius
				----WHERE ius.IdUser = @CodeUser
				----AND ius.Username = @Username
				----AND ius.RegisterUserID = @IdRegisterUser
			PRINT '5. UPDATE dbo.InternalUser IdUser=' + CAST(@CodeUser AS VARCHAR(50)) + ' Username=' +  CAST(@Username AS VARCHAR(50)) + ' IdRegisterUser= ' +  CAST(@IdRegisterUser AS VARCHAR(50))
		END
		ELSE
		BEGIN 
				--	5 Makes an insert into table InternalUser once the user was registered
				INSERT INTO DeliveryBackOffice.dbo.InternalUser
								(IdUser
								,Username
								,RegisterUserID
								,IdEmployee
								,RowStatus
								,TokenCreated
								,DateCreated
								)
				SELECT  @CodeUser		[CodeUser],
						@Username		[Username],
						@IdRegisterUser	[IdRegisterUser],
						@Par@IdEmployee	[IdEmployee],
						'TRUE'			[RowStatus],
						@Token			[Token],
						GETDATE()		[DateCreated]
				PRINT '5. INSERT dbo.InternalUser IdUser=' + CAST(@CodeUser AS VARCHAR(50)) + ' Username=' +  CAST(@Username AS VARCHAR(50)) + ' IdRegisterUser= ' +  CAST(@IdRegisterUser AS VARCHAR(50))
		END 

		PRINT '6- Valid existence dbo.Account'
		DECLARE @IdAccount AS BIGINT = -1
		IF EXISTS(SELECT acc.AccIdAccount
				  FROM DeliveryBackOffice.dbo.Account acc 
				  WHERE acc.AccIdAccount = @PadIdAccount)
		BEGIN 
				SET @IdAccount = @PadIdAccount
				--6 update the record table Account with the id found
				UPDATE DeliveryBackOffice.dbo.Account
					SET AccName = CAST(concat('Cuenta ',@FirstName, '.', @LastName) AS VARCHAR(100)),
					AccIdTypeAccount = 1,
					AccRowStatus = @Status,
					AccTokenUpdated = @Token,
					AccDateUpdated = GETDATE()
				WHERE AccIdAccount = @IdAccount
				PRINT '6. UPDATE dbo.Account @IdAccount=' +  CAST(@IdAccount AS VARCHAR(10))
		END
		ELSE
		BEGIN 
				--6 Makes an insert into table Account once the internal user was created
				INSERT INTO DeliveryBackOffice.dbo.Account
									(AccName
									,AccIdTypeAccount
									,AccRowStatus
									,AccTokenCreated
									,AccDateCreated
									,IdCustomer
									,AccConfirm
									)
				SELECT CAST(concat('Cuenta ',@FirstName, '.', @LastName) AS VARCHAR(100)) [Account],
									1			[TypeAccount],
									'TRUE'		[RowStatus],
									@Token		[Token],
									GETDATE()	[DateCreated],
									6			[IdCustomer],  --FORZA Delivery Express
									'C'			[Confirm]
				SET @IdAccount =  SCOPE_IDENTITY();
				PRINT '6. INSERT dbo.Account @IdAccount=' +  CAST(@IdAccount AS VARCHAR(50))
		END

		PRINT '7- dbo.RolByUserByAccount'
		BEGIN  --works with permutations for role and account
				/*if exists update else insert record */

				--Limpia todas las aisgnaciones del rol por idaccount
				UPDATE dbo.RolByUserByAccount
					SET RuaRowStatus = 'FALSE',
					RuaTokenUpdated = @Token,
					RuaDateUpdated = GETDATE()
				WHERE RuaIdUser = @IdRegisterUser
				AND RuaIdAccount = @IdAccount


		 		SET @cntR=1
				SET @ParFiletrR=1
				WHILE @cntR <= @MaxCountR
				BEGIN
				-----------------------------------------------------------------------------			
					SELECT @ParFiletrR=pr.Item 
					FROM #tblParRol pr 
					JOIN dbo.CatRol rol ON pr.Item = rol.RolIdRol
					WHERE pr.id= @cntR	
					
					--SELECT pr.id,
					--	   pr.Item , 'ROL' AS 'TYPE'
					--	FROM #tblParRol pr JOIN dbo.CatRol rl ON rl.RolIdRol = pr.id
					--	WHERE pr.id= @cntR

					--si existe la tupla del rol en catalogo
					IF EXISTS(SELECT crol.RolIdRol
							  FROM #tblParRol prol 
							  JOIN dbo.CatRol crol
							       ON prol.Item = crol.RolIdRol
							   WHERE prol.id= @cntR)
					BEGIN
					-----------------------------------------------------------------------------						
						--SELECT @ParFiletrR, @cntR
						PRINT '7- Valid existence dbo.RolByUserByAccount IdUser=' + CAST(@IdRegisterUser AS VARCHAR(50)) +' IdRol='+ CAST(@ParFiletrR AS VARCHAR(50)) +' IdAccount='+ CAST(@IdAccount AS VARCHAR(50)) 
						IF EXISTS ( SELECT TOP (1) rua.RuaIdRol
									FROM DeliveryBackOffice.dbo.RolByUserByAccount rua
									WHERE rua.RuaIdUser = @IdRegisterUser
									AND rua.RuaIdRol = @ParFiletrR 
									AND rua.RuaIdAccount = @IdAccount
								   )
						BEGIN	
								UPDATE DeliveryBackOffice.DBO.RolByUserByAccount
								SET RuaRowStatus = @Status,
								RuaTokenUpdated = @Token,
								RuaDateUpdated = GETDATE()
								WHERE RuaIdUser = @IdRegisterUser
								AND RuaIdAccount = @IdAccount
								AND RuaIdRol = @ParFiletrR
						
								--SELECT  @ParFiletrR		IdRol,
								--		@IdRegisterUser IdRegisterUser,
								--		@IdAccount		IdAccount ,
								--		'TRUE'			[RowStatus], 
								--		@Token			[Token], 
								--		GETDATE()		[DateUpdated]
								--		,'dbo.RolByUserByAccount' [Entity],
								--		'UPDATE' [Operation]
								PRINT '7. UPDATE dbo.RolByUserByAccount @IdRegisterUser=' + CAST(@IdRegisterUser AS VARCHAR(50)) + '@IdRol = ' + CAST(@ParFiletrR AS NVARCHAR(50)) + ' @IdAccount=' + CAST(@IdAccount AS NVARCHAR(50))
						END
						ELSE
						BEGIN
								--7 Makes an insert into table RolByUserByAccount onse the account was created
								INSERT INTO DeliveryBackOffice.dbo.RolByUserByAccount
														(RuaIdRol
														,RuaIdUser
														,RuaIdAccount
														,RuaRowStatus
														,RuaTokenCreated
														,RuaDateCreated
														)
								SELECT	@ParFiletrR			[IdRol], 
										@IdRegisterUser		[IdRegisterUser], 
										@IdAccount			[IdAccount], 
										'TRUE'				[RowStatus], 
										@Token				[Token], 
										GETDATE()			[DateCreated]
										--,'dbo.RolByUserByAccount' [Entity]
										--,'INSERT' [Operation]
								PRINT '7. INSERT dbo.RolByUserByAccount IdRegisterUser=' + CAST(@IdRegisterUser AS VARCHAR(50)) + 'IdRol = ' + CAST(@ParFiletrR AS NVARCHAR(50)) + ' IdAccount=' + CAST(@IdAccount AS NVARCHAR(50)) 
						END
					-----------------------------------------------------------------------------						
					END
					SET @cntR=@cntR+1
				-----------------------------------------------------------------------------			
				END
		END 

		PRINT '8- dbo.VisitPointByUser'
		BEGIN  --works with permutations for visitpoint, stationId and user
				
				--limpia todos los registros existentes para el iduser
				UPDATE DeliveryBackOffice.dbo.VisitPointByUser
					SET RowStatus = 'FALSE',
					TokenUpdated = @Token,
					DateUpdated = GETDATE()
				WHERE RegisterUserID = @IdRegisterUser

				SET @cntSt=1
				SET @ParFiletrSt=1
				WHILE @cntSt <= @MaxCountSt
				BEGIN	
				-----------------------------------------------------------------------------			
					--Obtiene el ID del visitpointclient
					SELECT @ParFiletrSt = cstn.CodeOfReference --IdVisitPointClient
					FROM #tblParStation pstn  
					JOIN dbo.CatStation cstn 
							ON pstn.Item = cstn.IdStation
							AND cstn.StationType = 2 --EXC
					WHERE pstn.id= @cntSt
					--si existe la tupla es porque es un visitpoint de tipo express center
					IF EXISTS(SELECT cstn.CodeOfReference
							  FROM #tblParStation pstn  
							  JOIN dbo.CatStation cstn 
										ON pstn.Item = cstn.IdStation
										AND cstn.StationType = 2 --EXC
								WHERE pstn.id= @cntSt
							)
							BEGIN 
							-----------------------------------------------------------------------------			
								--SELECT @ParFiletrSt, @cntSt, @IdRegisterUser
								PRINT '8- Valid Existence dbo.VisitPointByUser RegisterUserID=' + CAST(@IdRegisterUser AS NVARCHAR(50)) + ' IdVisitPointClient=' + CAST(@ParFiletrSt AS NVARCHAR(50))
								IF EXISTS(SELECT vpu.IdVisitPointByUser
											FROM DeliveryBackOffice.dbo.VisitPointByUser vpu 
											WHERE vpu.RegisterUserID = @IdRegisterUser
											AND   vpu.IdVisitPointClient = @ParFiletrSt
										  )
								BEGIN 
										--8 update the record VisitPointByUser with the id found
										UPDATE DeliveryBackOffice.dbo.VisitPointByUser
										SET RowStatus = @Status,
										TokenUpdated = @Token,
										DateUpdated = GETDATE()
										WHERE RegisterUserID = @IdRegisterUser
										AND IdVisitPointClient = @ParFiletrSt	
						
										--SELECT 'dbo.VisitPointByUser'	[Entity],
										--	   'UPDATE'					[Operation]
										PRINT '8. UPDATE dbo.VisitPointByUser RegisterUserID=' +  CAST(@IdRegisterUser AS VARCHAR(10))  + ' IdVisitPointClient=' +  CAST(@ParFiletrSt AS NVARCHAR(50))
								END
								ELSE
								BEGIN
										--8 Makes an inser into table VisitPointByUser, so the user can add clients to the corporate 
										INSERT INTO DeliveryBackOffice.dbo.VisitPointByUser
													(IdVisitPointClient
													,RegisterUserID
													,RowStatus
													,TokenCreated
													,DateCreated)
										SELECT  @ParFiletrSt		[IdVisitPoint], 
												@IdRegisterUser		[IdRegisterUser], 
												'TRUE'				[RowStatus], 
												@Token	            [Token]	,
												GETDATE()	        [DateCreated]
												--SELECT 'dbo.VisitPointByUser'	[Entity],
												--	   'INSERT'					[Operation]
										PRINT '8. INSERT dbo.VisitPointByUser @IdRegisterUser=' +  CAST(@IdRegisterUser AS VARCHAR(10)) + ' IdVisitPointClient=' +  CAST(@ParFiletrSt AS NVARCHAR(50))
								END 
							-----------------------------------------------------------------------------			
							END 
					SET @cntSt = @cntSt + 1
				-----------------------------------------------------------------------------			
				END 
		END
        
		SELECT  CAST('TRUE' AS NVARCHAR(50))			[blnResult],
				CAST(@IdPerson AS NVARCHAR(50))			[IdPerson],
				CAST(@IdRegisterUser AS NVARCHAR(50))	[IdRegisterUser], 
				CAST(@Par@IdEmployee AS NVARCHAR(50))	[IdEmployee],
				CAST(@IdAccount	 AS NVARCHAR(50))		[IdAccount],
				CAST(@CodeUser AS NVARCHAR(50))			[CodeUserResult],
				CAST(@Username AS NVARCHAR(50))			[UserNameResult],
									'' 					[ErrorNumber],
									''					[ErrorSeverity],
									''					[ErrorState],
									''					[ErrorProcedure],
									''					[ErrorLine],
				'Successfull'							[Message]

		PRINT CAST(@@ROWCOUNT AS NVARCHAR(100))+ ' Operation Successful. ' --calculation cut out.
		COMMIT TRANSACTION MNGMNTUSR
	END TRY

	BEGIN CATCH 
	  IF (@@TRANCOUNT > 0)
	   BEGIN
		  ROLLBACK TRANSACTION MNGMNTUSR
		  PRINT 'Error detected, all changes reversed - rollback transaction'
	   END 
		SELECT
			CAST('FALSE' AS NVARCHAR(50))			[blnResult],
			CAST(@IdPerson AS NVARCHAR(50))			[IdPerson],
			CAST(@IdRegisterUser AS NVARCHAR(50))	[IdRegisterUser], 
			CAST(@Par@IdEmployee AS NVARCHAR(50))	[IdEmployee],
			CAST(@IdAccount	 AS NVARCHAR(50))		[IdAccount],
			CAST(@CodeUser AS NVARCHAR(50))			[CodeUserResult],
			CAST(@Username AS NVARCHAR(50))			[UserNameResult],
			CAST(ERROR_NUMBER() AS NVARCHAR(50))	[ErrorNumber],
			CAST(ERROR_SEVERITY() AS NVARCHAR(50))  [ErrorSeverity],
			CAST(ERROR_STATE() AS NVARCHAR(50))		[ErrorState],
			CAST(ERROR_PROCEDURE() AS NVARCHAR(MAX)) [ErrorProcedure],
			CAST(ERROR_LINE() AS NVARCHAR(50))		[ErrorLine],
			CAST(ERROR_MESSAGE() AS NVARCHAR(MAX))	[Message]
	END CATCH

	DROP TABLE #tblParSystem
	DROP TABLE #tblParRol
	DROP TABLE #tblParStation


END
