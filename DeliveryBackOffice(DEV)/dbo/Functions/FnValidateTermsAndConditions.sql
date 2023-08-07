
--Devuelve el valor si un usuario ha aceptado los términos y condiciones actuales
CREATE FUNCTION [dbo].[FnValidateTermsAndConditions](
    @Username VARCHAR(MAX),	-- Nombre del usuario que hay que validar
	@Usercode INT,	-- Código del usuario cuando es un usuario corporativo
	@Login INT		-- Indica si es un usuario individual = 1 o un usuario corporativo = 2
)
RETURNS INT
AS
BEGIN
    
	DECLARE @IDTerms INT;		-- Guardará el ID de la tabla TermsAndConditionsByUser si ya ha aceptado los términos
	DECLARE @TAC INT;			-- Valor que retornará para indicar si el usuario ha aceptado o no los últimos términos y condiciones
	DECLARE @ActualTerms INT;	-- Variable que almacenará el ID de los términos y condiciones actuales.

	SET @ActualTerms = (SELECT IdTAC FROM [dbo].[TermsAndConditions]
						WHERE RowStatus = 1
						AND Name = 'New Termns And Conditions')

	-- Usuario individual
	IF(@Login = 1)
	BEGIN
		
		-- Verifica si ya aceptó los terminos y condiciones en algún momento
		SET @IDTerms = (SELECT TOP 1 IdTACByUser FROM [dbo].[TermsAndConditionsByUser] a1
											WHERE IdAccount = (SELECT ac.AccIdAccount FROM RegisterUser us
                                                INNER JOIN [dbo].Person pe
                                                    ON pe.PerIdPerson = us.UsrIdPerson
                                                       AND pe.PerRowStatus = 1
                                                INNER JOIN [dbo].[RolByUserByAccount] rua
                                                    ON rua.RuaIdUser = us.UsrIdUser
                                                       AND rua.RuaRowStatus = 1
                                                INNER JOIN [dbo].CatRol ro
                                                    ON ro.RolIdRol = rua.RuaIdRol
                                                INNER JOIN [dbo].Account ac
                                                    ON ac.AccIdAccount = rua.RuaIdAccount
                                                       AND ac.AccRowStatus = 1
                                                INNER JOIN [dbo].CatTypeAccount ta
                                                    ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
                                            WHERE us.UsrEmail = @Username
                                                  AND us.UsrRowStatus = 1
												  
												  )
												  AND TACId=1
												  ORDER BY a1.IdTACByUser desc
												  )
	
		-- El usuario ha aceptado los términos y condiciones con anterioridad
		IF (@IDTerms IS NOT NULL)
		BEGIN
			SET @TAC = (SELECT TAC FROM [dbo].[TermsAndConditionsByUser]
								WHERE IdTACByUser = @IDTerms
									AND TACId = @ActualTerms)

			-- Indica que no ha aceptado los términos y condiciones actuales
			IF(@TAC IS NULL)
			BEGIN
				SET @TAC = 0
			END
		END
		
		ELSE
		BEGIN
			SET @TAC = 0
		END
	END

	-- Usuario corporativo
	IF(@Login = 2)
	BEGIN
		SET @IDTerms = (SELECT IdTACByUser FROM [dbo].[TermsAndConditionsByUser]
						WHERE IdAccount = (SELECT ac.AccIdAccount FROM DeliveryBackOffice.dbo.RegisterUser us
											INNER JOIN DeliveryBackOffice.dbo.Person pe 
												ON pe.PerIdPerson = us.UsrIdPerson
												AND pe.PerRowStatus = 1
											INNER JOIN DeliveryBackOffice.dbo.[RolByUserByAccount] rua 
												ON rua.RuaIdUser = us.UsrIdUser
												AND rua.RuaRowStatus = 1
											INNER JOIN DeliveryBackOffice.dbo.CatRol ro 
												ON ro.RolIdRol = rua.RuaIdRol
											INNER JOIN DeliveryBackOffice.dbo.Account ac 
												ON ac.AccIdAccount = rua.RuaIdAccount
												AND ac.AccRowStatus = 1
											INNER JOIN DeliveryBackOffice.dbo.CatTypeAccount ta 
												ON ta.TacIdTypeAccount = ac.AccIdTypeAccount
											INNER JOIN DeliveryBackOffice.dbo.InternalUser iu 
												ON iu.RegisterUserID = UsrIdUser
										WHERE iu.UserName = @UserName 
												AND iu.IdUser=@UserCode 
												AND iu.RowStatus = 1))

		-- El usuario ha aceptado los términos y condiciones con anterioridad
		IF (@IDTerms IS NOT NULL)
		BEGIN
			SET @TAC = (SELECT TAC FROM [dbo].[TermsAndConditionsByUser]
								WHERE IdTACByUser = @IDTerms
									AND TACId = @ActualTerms)

			-- Indica que no ha aceptado los términos y condiciones actuales
			IF(@TAC IS NULL)
			BEGIN
				SET @TAC = 0
			END
		END
		
		ELSE
		BEGIN
			SET @TAC = 0
		END
	END
    
    RETURN @TAC
 
END
