
-- =============================================
-- Author:		Eduardo López
-- Create date: 10 Marzo 2023
-- Description:	Actualiza estado de Notas de credito por respueta de FEL
-- =============================================
CREATE PROCEDURE [dbo].[Set_ResponseFelToNoteCredit]
	-- Add the parameters for the stored procedure here
	@id bigint,
	@documentSend varchar(max),
	@documentRecieved varchar(max),
	@certificationFEL varchar(200),
	@serieFEL varchar(200),
	@numberFEL varchar(50),
	@descriptionFEL varchar(500),
	@RequestorFEL varchar(250),
	@TransactionFEL varchar(100),
	@CountryFEL varchar(4),
	@EntityFEL varchar(50),
	@UserFEL varchar(150),
	@UserName varchar(150),
	@Data1FEL varchar(150),
	@Data3FEL varchar(150),
	@MailSendFEL varchar(150),
	@subjectFEL varchar(150),
	@establecimientoFEL varchar(5),
	@status int,
	@token varchar(50),
	@emisorNombre varchar(500),
	@emisorNombreComercial varchar(500),
	@emisorDireccion varchar(500),
	@cmp_nameFEL varchar(2000),
	@fechaHoraFEL varchar(100)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	update  DeliveryBackOffice.dbo.invoiceHeader
	set 
		inv_documentSend = @documentSend,
		inv_documentRecieved = @documentRecieved,
		inv_certificationFEL = @certificationFEL,
		inv_serieFEL = @serieFEL,
		inv_numberFEL = @numberFEL,
		inv_descriptionFEL = @descriptionFEL,
		inv_RequestorFEL = @RequestorFEL,
		inv_TransactionFEL = @TransactionFEL,
		inv_CountryFEL = @CountryFEL,
		inv_EntityFEL = @EntityFEL,
		inv_UserFEL = @UserFEL,
		inv_UserName = @UserName,
		inv_Data1FEL = @Data1FEL,
		inv_Data3FEL = @Data3FEL,
		inv_MailSendFEL = @MailSendFEL,
		inv_subjectFEL = @subjectFEL,
		inv_status = @status,
		inv_dateUpdate = GETDATE(),
		inv_tokenUpdate = @token,
		inv_cmp_name = @emisorNombre,
		inv_cmp_nameComercial = @emisorNombreComercial,
		inv_cmp_adress = @emisorDireccion,
		inv_establecimientoFEL = @establecimientoFEL,
		inv_cmp_nameFEL = @cmp_nameFEL,
		inv_FechaHoraFEL = @fechaHoraFEL,
		inv_dateFEL = GETDATE()
	where inv_pk_id = @id

	SELECT inv_certificationFEL, inv_descriptionFEL FROM invoiceHeader WHERE inv_pk_id = @id

END