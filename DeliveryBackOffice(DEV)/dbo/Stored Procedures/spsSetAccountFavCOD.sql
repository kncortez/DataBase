
-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2021-01-27>
-- Description:	<Registrar favoritos >
-- =============================================
CREATE PROCEDURE [dbo].[spsSetAccountFavCOD]
	@Id int = null,
	@Alias VARCHAR(50),
	@IDBank int,
	@NameAccount NVARCHAR(30),
	@TypeAccount varchar(30),
	@DocID varchar(30),
	@IdAcount int,
	@Token  varchar (30) = null,
	@NumberAcc varchar(30),
	@TokenUpdate varchar(30) = null,
	@Status int = 1,
	@IsDefault BIT = 0

AS
BEGIN

	BEGIN TRY
		BEGIN TRANSACTION

		--Adición funcionalidad cunenta por defecto
		--Oscar Morales - 2022-08-25
		IF(@Id is null or @Id = 0)
		BEGIN
		
			IF (@IsDefault = 1)
			BEGIN
				UPDATE DeliveryFavCOD
				SET IsDefault = 0
				WHERE StatusFavCOD = 1
				AND IdAccountFavCOD = @IdAcount
			END
			ELSE IF NOT EXISTS (SELECT TOP 1 1 FROM DeliveryFavCOD WHERE StatusFavCOD = 1 AND IdAccountFavCOD = @IdAcount)
			BEGIN
				SET @IsDefault = 1
			END

			INSERT INTO DeliveryBackOffice.dbo.DeliveryFavCOD (AliasFavCOD, NameAccountFavCOD, TypeAccountFavCOD, DocumentIdFavCOD, StatusFavCOD, IdAccountFavCOD, TokenCreated, DateCreated, TokenUpdate, DateUpdate, IdBank, NumberAccFavCOD, IsDefault)
				VALUES (@Alias, @NameAccount, @TypeAccount, @DocID, 1, @IdAcount, @Token, GETDATE(), NULL, NULL, @IdBank, @NumberAcc, @IsDefault)
	
			SELECT
				1 [blnResult]
			   ,'Se ha guardado correctamente sus registros' [Description]
			   ,SCOPE_IDENTITY() [Id]
		END

		ELSE IF( @Id is not null )
		BEGIN 

			if (@Status =1) -- estado activo
				begin

					IF (@IsDefault = 1)
					BEGIN
						UPDATE DeliveryFavCOD
						SET IsDefault = 0
						WHERE StatusFavCOD = 1
						AND IdAccountFavCOD = @IdAcount
					END

					UPDATE DeliveryBackOffice.dbo.DeliveryFavCOD
					SET  AliasFavCOD = @Alias , NameAccountFavCOD = @NameAccount, TypeAccountFavCOD = @TypeAccount, DocumentIdFavCOD = @DocID, StatusFavCOD = 1, IdAccountFavCOD = @IdAcount, TokenUpdate = @Token, DateUpdate = GETDATE(), IdBank = @IDBank, NumberAccFavCOD = @NumberAcc, IsDefault = @IsDefault
					WHERE IdDeliveryFavCOD = @Id
					
					SELECT
						1 [blnResult]
					   ,'Se ha actualizado actualizado sus registros' AS [Description]
					   ,@Id [Id]
				end
			else 
				begin
					UPDATE DeliveryBackOffice.dbo.DeliveryFavCOD set StatusFavCOD = @Status, IsDefault = 0
					WHERE IdDeliveryFavCOD = @Id
					
					SELECT
						1 [blnResult]
					   ,'Registro eliminado' AS [Description]
					   ,@Id [Id]
				end
		END

		IF @@TRANCOUNT > 0
			COMMIT TRANSACTION
	END TRY
	BEGIN CATCH 
		ROLLBACK TRANSACTION;

		SELECT
			0 [blnResult]
			,ERROR_MESSAGE() [Description]
			,0 [Id]
			,ERROR_NUMBER() [ErrorNumber]
			,ERROR_SEVERITY() [ErrorSeverity]
			,ERROR_STATE() [ErrorState]
			,ERROR_PROCEDURE() [ErrorProcedure]
			,ERROR_LINE() [ErrorLine]
			,ERROR_MESSAGE() [ErrorMessage];
	END CATCH
END


