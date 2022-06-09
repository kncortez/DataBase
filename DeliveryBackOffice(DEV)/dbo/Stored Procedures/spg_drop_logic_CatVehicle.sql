
-- =============================================
-- Author:		<Hugo, Gomez>
-- Create date: <2020-02-15>
-- Description:	<Elimina logicamente los vehiculos>
-- =============================================
CREATE PROCEDURE [dbo].[spg_drop_logic_CatVehicle]
	@IdVehicle INT=NULL,
	@Token varchar (50) 



AS
BEGIN
		BEGIN TRANSACTION
					BEGIN TRY

					declare @RowStatus	bit = 0 

					UPDATE dbo.CatVehicle SET RowStatus = 0--, TokenUpdated = @Token,
					,TokenUpdated= @Token
					,DateUpdated = GETDATE()
					WHERE IdVehicle = @IdVehicle

					END TRY
					BEGIN CATCH
						ROLLBACK TRANSACTION
							select ERROR_MESSAGE()
								-- retornar mensaje de error
						
					END CATCH;
					IF @@TRANCOUNT > 0 BEGIN
						COMMIT TRANSACTION;
						select 'Se guardo con éxito' as StatusCode 
						END

END

select * from  CatVehicle