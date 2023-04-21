-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <2022-08-29>
-- Description:	<SP para Modificar bandera de devolución (IsLastMileReturn)>
-- =============================================
CREATE PROCEDURE [dbo].[SPHD_ModifyReturnStatement] 
	@TblListGuideActa TblListGuideActa READONLY,
	@Token NVARCHAR(50)
AS
BEGIN	
  
	SET NOCOUNT ON;

	BEGIN TRANSACTION
	BEGIN TRY
	
	
	DECLARE @StatusReversal INT= (Select StatusOrderId From dbo.StatusOrder Where OrderDescription='Guía revertida para entrega') 

	DECLARE @Numero AS INT;
	DECLARE @Serie  AS NVARCHAR(2);
	DECLARE @STATUS AS INT; 
	DECLARE @STATUSDECLAREDRETURNED_DO INT = (SELECT TOP 1 SO.StatusOrderId FROM DBO.StatusOrder SO WITH(NOLOCK) WHERE OrderDescription = 'Declarado para Devolución');
	DECLARE @RevalueGuides AS TABLE(
				GuideSerie NVARCHAR(2),
				GuideNumber INT)
	DECLARE @GuidesModify AS TABLE(
				GuideSerie NVARCHAR(2),
				GuideNumber INT)

	INSERT INTO @RevalueGuides
				SELECT
					SUBSTRING(lg.NumberGuidePice,1,2)
				    ,CAST(SUBSTRING(LTRIM(lg.NumberGuidePice), 3, CAST(LEN(lg.NumberGuidePice) AS INT)) AS INT)
				FROM @TblListGuideActa lg

------------Modificar Bandera campo IsLastMileReturn ----------------------------
WHILE EXISTS (SELECT TOP 1 1 FROM @RevalueGuides)
BEGIN
					SELECT TOP 1
						@Serie  =  rg.GuideSerie,
						@Numero =  rg.GuideNumber	
				   FROM @RevalueGuides rg

				   SELECT @STATUS = StatusOrderId
				   FROM [dbo].[DeliveryOrderDetail] WITH (NOLOCK)
				   WHERE Guide_Serie = @Serie AND Guide_Number = @Numero

                  IF (EXISTS(SELECT TOP 1 1 FROM [dbo].[DeliveryOrder]  WITH (NOLOCK) 
				  WHERE Guide_Serie = @Serie AND Guide_Number = @Numero AND
				        (IsLastMileReturn = 0 OR IsLastMileReturn IS NULL) )
					  )
				   BEGIN

							-- Activar guía para devolución y asignar estado de "Declarado para devolución"
							UPDATE 
								[dbo].[DeliveryOrder] 
							SET 
								IsLastMileReturn = 1,
								StatusOrderId= @STATUSDECLAREDRETURNED_DO,
								TokenUpdated=@Token,
								DateUpdated=GETDATE()
							WHERE 
								Guide_Serie = @Serie 
								AND 
								Guide_Number = @Numero
							UPDATE [dbo].[DeliveryOrder] SET IsLastMileReturn = 1 WHERE Guide_Serie = @Serie AND Guide_Number = @Numero
							INSERT INTO @GuidesModify(GuideSerie,GuideNumber) VALUES (@Serie, @Numero)

							-- Ingresar nuevo estado al historico
							INSERT INTO 
								[DeliveryBackOffice].[dbo].[DeliveryOrderDetail]
								(Guide_Serie, Guide_Number, StatusOrderId, UserCreated, DateCreated, DateCreatedInSystem, RowStatus)
							VALUES
								(@Serie, @Numero, @STATUSDECLAREDRETURNED_DO, @Token, GETDATE(), GETDATE(), 1)
				   END
					   ELSE
					   BEGIN
							-- Para revisar estado del historico
							DECLARE @TOPSTATUS INT;
							DECLARE @TOPSTATUSROWDATE DATETIME;
							-- En caso sea necesario recuperar un estado
							DECLARE @NEWTOPSTATUS INT;

							-- Revisar último estado de la guía
							SELECT
								TOP 1
									@TOPSTATUS = DOD.StatusOrderId,
									@TOPSTATUSROWDATE = ISNULL(DOD.DateCreatedInSystem, DOD.DateCreated)
							FROM
								[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
							WHERE
								DOD.Guide_Serie = @Serie
								AND
								DOD.Guide_Number = @Numero
								AND
								DOD.RowStatus = 1
							ORDER BY
								ISNULL(DOD.DateCreatedInSystem, DOD.DateCreated) DESC

							-- Si la guía esta como "Declarado para devolución"
							IF(@TOPSTATUS = @STATUSDECLAREDRETURNED_DO)
							BEGIN

						    UPDATE [dbo].[DeliveryOrder] SET IsLastMileReturn = 0, StatusOrderId = @StatusReversal
							WHERE Guide_Serie = @Serie AND Guide_Number = @Numero
							
								-- Inactivar estado de declarado
								UPDATE 
									DeliveryBackOffice.dbo.DeliveryOrderDetail 
								SET 
									RowStatus = 0,
									Observations = 'Declaración de devolución revertido.'
								WHERE 
									Guide_Serie =  @Serie
									AND Guide_Number = @Numero
									AND StatusOrderId = @TOPSTATUS
									AND ISNULL(DateCreatedInSystem, DateCreated) = @TOPSTATUSROWDATE
									
								-- Rescatar último estado de la guía previo a la declaración para devolución
								SELECT
									TOP 1
										@NEWTOPSTATUS = DOD.StatusOrderId
								FROM
									[DeliveryBackOffice].[dbo].[DeliveryOrderDetail] DOD WITH(NOLOCK)
								WHERE
									DOD.Guide_Serie = @Serie
									AND
									DOD.Guide_Number = @Numero
									AND
									DOD.RowStatus = 1
								ORDER BY
									ISNULL(DOD.DateCreatedInSystem, DOD.DateCreated) DESC
									
								-- Revertir bandera de devolución de la guía y asignar estado previo
								UPDATE 
									[dbo].[DeliveryOrder] 
								SET 
									IsLastMileReturn = 0,
									StatusOrderId = @NEWTOPSTATUS,
									TokenUpdated=@Token,
									DateUpdated=GETDATE()
								WHERE 
									Guide_Serie = @Serie 
									AND 
									Guide_Number = @Numero
							END
							-- Último estado de la guía no es declaración para devolución
							ELSE
							BEGIN
							INSERT INTO [dbo].[DeliveryOrderDetail](Guide_Serie,
							                                        Guide_Number,
																	StatusOrderId,
																	UserCreated,	
																	DateCreated,
																	DateCreatedInSystem,
																	Observations,
																	Temperature_Celsius,
																	PieceId,
																	RowStatus)
							VALUES(
							        @Serie,
									@Numero,
									@StatusReversal,
									'Reversión de Declaración',
									Getdate(),
									GETDATE(),
									NULL,
									NULL,
									NULL,
									1

							        )

								-- Solo actualizar bandera de devolución de la guía
								UPDATE 
									[dbo].[DeliveryOrder] 
								SET 
									IsLastMileReturn = 0,
									TokenUpdated=@Token,
									DateUpdated=GETDATE()
								WHERE 
									Guide_Serie = @Serie 
									AND 
									Guide_Number = @Numero

							END
						    INSERT INTO @GuidesModify(GuideSerie,GuideNumber) VALUES (@Serie, @Numero)
					   END
				 
	DELETE FROM @RevalueGuides
	WHERE GuideSerie = @Serie AND GuideNumber = @Numero

END
			COMMIT TRANSACTION;
			SELECT GuideSerie,
				   GuideNumber 
			FROM @GuidesModify 
          
	   END TRY
			 BEGIN CATCH
				ROLLBACK TRANSACTION
				
			SELECT
			0 [blnResult]
			,ERROR_MESSAGE() [Description]
			,0 [NumTransferID]
			,ERROR_NUMBER() [ErrorNumber]
			,ERROR_SEVERITY() [ErrorSeverity]
			,ERROR_STATE() [ErrorState]
			,ERROR_PROCEDURE() [ErrorProcedure]
			,ERROR_LINE() [ErrorLine]
			,ERROR_MESSAGE() [ErrorMessage];
	  END CATCH




END