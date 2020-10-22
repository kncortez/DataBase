USE [DeliveryBackOffice]
GO

/****** Object:  StoredProcedure [dbo].[sps_ResponseFelToInvoice]    Script Date: 12/10/2020 00:15:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Luis Fernando Coti Itzep
-- Create date: 8 Octubre 2020
-- Description:	Actualiza estado de factura por respueta de FEL
-- =============================================
CREATE PROCEDURE [dbo].[sps_ResponseFelToInvoice]
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
	@status int,
	@token varchar(50)
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
		inv_tokenUpdate = @token
	where inv_pk_id = @id
END
GO


