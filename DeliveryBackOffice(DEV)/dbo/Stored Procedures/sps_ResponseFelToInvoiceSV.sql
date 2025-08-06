
-- =============================================
-- Author:      Juan Daniel Ramirez Coroy
-- Create date: 2025-06-11
-- Description: Actualiza estado de factura por respueta de Digifact
-- =============================================
ALTER PROCEDURE [dbo].[sps_ResponseFelToInvoiceSV]
(
  @id                    BIGINT,
  @documentSend          VARCHAR(max),
  @documentRecieved      VARCHAR(max),
  @certificationFEL      VARCHAR(200),
  @serieFEL              VARCHAR(200),
  @numberFEL             VARCHAR(50),
  @descriptionFEL        VARCHAR(500),
  @RequestorFEL          VARCHAR(250),
  @TransactionFEL        VARCHAR(100),
  @CountryFEL            VARCHAR(4),
  @EntityFEL             VARCHAR(50),
  @UserFEL               VARCHAR(150),
  @UserName              VARCHAR(150),
  @Data1FEL              VARCHAR(150),
  @Data3FEL              VARCHAR(150),
  @MailSendFEL           VARCHAR(150),
  @subjectFEL            VARCHAR(150),
  @establecimientoFEL    VARCHAR(5),
  @status                INT,
  @token                 VARCHAR(50),
  @emisorNombre          VARCHAR(500),
  @emisorNombreComercial VARCHAR(500),
  @emisorDireccion       VARCHAR(500),
  @cmp_nameFEL           VARCHAR(2000),
  @fechaHoraFEL          VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @secuencia INT,
            @rowcount  INT;
    -- Insert statements for procedure here
    UPDATE DeliveryBackOffice.dbo.invoiceHeader
       SET inv_documentSend = @documentSend,
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
     WHERE inv_pk_id = @id;

     SET @rowcount = @@rowcount

     IF(@rowcount > 1)
     BEGIN 
        SELECT @secuencia = [Value]
         FROM AddInfoByConfigSV WITH(NOLOCK)
        WHERE RowStatus = 1
          AND [Name] = 'Secuencial'
          AND [Node] = 'Header.AdditionalIssueDocInfo'

       UPDATE AddInfoByConfigSV
          SET [Value] = @secuencia + 1
        WHERE [Name] = 'Secuencial'
     END

    SELECT @rowcount 'rowCount'
END
