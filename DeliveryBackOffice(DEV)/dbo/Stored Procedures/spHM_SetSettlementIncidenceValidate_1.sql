-- =============================================
-- Author:		<Cristian Azurdia>
-- Update date: <2024-10-1>
-- Description: <Validar incidencias de liquidaciones>

-- =============================================
CREATE PROCEDURE [dbo].[spHM_SetSettlementIncidenceValidate]
	@ManifestSettlementIncidenceId INT = 0,
	@ResolutionComment NVARCHAR(600) = '',
	@Token NVARCHAR(64),
	@UserId INT = 0
AS
BEGIN
	
	DECLARE @ManagementLevel INT;
	DECLARE @MaxAmount DECIMAL (14,2);
	DECLARE @User NVARCHAR(32);

	SELECT  @ManagementLevel = mlbu.CatManagementLevelId
		  , @MaxAmount = cml.MaxAmount
		  , @User = CONCAT(p.PerFirstName, ' ', p.PerLastName)
	from ManagementLevelByUser    mlbu  WITH(NOLOCK)
	INNER JOIN RegisterUser        ru    WITH(NOLOCK)
		ON ru.UsrIdUser = mlbu.RegisterUserId
	INNER JOIN InternalUser        iu    WITH(NOLOCK)
		ON iu.RegisterUserID  = ru.UsrIdUser
	INNER JOIN Person p				 WITH (NOLOCK)
		ON P.PerIdPerson = ru.UsrIdPerson
	INNER JOIN	CatManagementLevel cml	 WITH(NOLOCK)
		ON mlbu.CatManagementLevelId = cml.IdCatManagementLevel
	WHERE mlbu.RowStatus = 1
	AND  iu.IdUser = @UserId

    BEGIN TRANSACTION
	BEGIN TRY


		UPDATE ManifestSettlementIncidence
		SET IncidenceApproved = 1
			,ResolutionComment = @ResolutionComment
			,IdValidator = @UserId
			,DateValidator = GetDate()
			,TokenUpdated = @Token
			,DateUpdated = GETDATE()
		WHERE IdManifestSettlementIncidence = @ManifestSettlementIncidenceId
			  AND IIF(TotalAmount <= @MaxAmount, 1, 0) = 1

	IF @@ROWCOUNT = 0
	BEGIN
		SELECT
				'400' [StatusCode]
				,'Usuario NO Autorizado para Validadr' [Message] 

	END

	COMMIT TRANSACTION

		SELECT
				'200' [StatusCode]
				,'Incidencia validada correctamente.' [Message] 

	END TRY
	BEGIN CATCH

		ROLLBACK TRANSACTION

		SELECT
			'-1' 'StatusCode'
		   ,ERROR_MESSAGE() 'Description' 
		   ,'' 'LoginToken'

	END CATCH

END