





-- =============================================
-- Author:		<Gomez, Hugo>
-- Create date: <2021-02-02>
-- Description:	<Registrar favoritos >
-- =============================================
CREATE PROCEDURE [dbo].[spwsSetWizardAccountUpdate]
	
	@IdAccount int = null,
	@IdWizard int = null,
	@TokenUpdate varchar(max) = null,
	@Status int



AS
BEGIN



	UPDATE DeliveryBackOffice.dbo.DeliveryWizardAccount
	SET   StatusAccountWiz = @Status, TokenUpdate = @TokenUpdate, DateUpdate = GETDATE()
	WHERE AccIdAccount = @IdAccount and IdWiz = @IdWizard

	SELECT  'Se ha actualizado actualizado sus registros' as Response



END