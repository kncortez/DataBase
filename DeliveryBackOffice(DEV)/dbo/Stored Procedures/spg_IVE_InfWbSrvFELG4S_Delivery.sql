/* =================================================
   SP: spg_IVE_InfWbSrvFELG4S_Delivery
   Propósito: Retorna información de factura para consumo de web service FEL G4S,
              incluyendo impuestos, dirección del emisor y centro de costo dinámico
   Autor:Luis Fernando Coti Itzep
   Historia:
   Fecha: 2020-10-06
================================================= */
/* === CHANGELOG ============================
2026-04-13 | Historia/épica: FDAPI-6057  | Autor: Pedro Macajol     | Correccion de centro de costo dinamico.
2024-08-12 | Historia/épica: (pendiente) | Autor: Cristian Suazo    | Se agrega la dirección del emisor del punto de visita
2024-06-28 | Historia/épica: (pendiente) | Autor: Daniel Ramirez    | Retorna valor de configuracion para porcentaje de impuesto segun el pais de uso
=========================================== */

CREATE PROCEDURE [dbo].[spg_IVE_InfWbSrvFELG4S_Delivery]
	@VpCodeOfReference as varchar(100)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @country AS VARCHAR(2),
            @taxes   AS VARCHAR(50),
			@Address AS NVARCHAR(25);

	SELECT @country = CountryId,
		   @Address = Address
	FROM DeliveryBackOffice.dbo.VisitPointClient WITH(NOLOCK)
	WHERE CodeOfReference = @VpCodeOfReference

    SELECT @taxes = [value]
      FROM DeliveryBackOffice.dbo.ConfigParams WITH(NOLOCK)
     WHERE [name] = 'TaxPercentage'
       AND IdCountry = @country

	DECLARE @establecimiento as varchar(15),
			@correoCCO as varchar(200)
	
	SELECT 
		dpf.dpf_VpCodeOfReference,
		dpf.dpf_FELRequestor,
		dpf.dpf_FELTransaction,
		dpf.dpf_FELCountry,
		dpf.dpf_FELEntity,
		dpf.dpf_FELUser,
		dpf.dpf_FELUserName,
		dpf.dpf_FELData1,
		dpf.dpf_FELData3,
		dpf.dpf_FELCorreo,
		dpf.dpf_FELAsuntoCorreoFactura,
		dpf.dpf_FELAsuntoCorreoNotaCredito,
		dpf.dpf_FELEstablecimiento,
		dpf.dpf_FELCorreoCCO,
		dpf.dpf_SAPServidorLicencias,
		dpf.dpf_SAPCompania,
		dpf.dpf_SAPUsuario,
		dpf.dpf_SAPContrasenia,
		dpf.dpf_SAPServidor,
		dpf.dpf_SAPUsuarioBD,
		dpf.dpf_SAPContraseniaBD,
		dpf.dpf_SAPserieFactura,
		dpf.dpf_SAPserieNC,
		dpf.dpf_SAPseriePago,
		dpf.dpf_SAPcardCode,
		dpf.dpf_SAParticulo,
		dpf.dpf_SAPvendor,
		dpf.dpf_SAPcreditCard,
		dpf.dpf_OcrCode,
		--Reemplazo seguro sin duplicar filas
		ISNULL(csc.OcrCode2, dpf.dpf_OcrCode2) AS dpf_OcrCode2,
		dpf.dpf_StatusFACE,
		dpf.dpf_WarehouseCode,
		dpf.inv_cmp_name,
		dpf.inv_cmp_nameComercial,
		dpf.KioskCode,
		@taxes AS TaxPercentage,
		@Address AS AddressEmisor
	FROM DeliveryBackOffice.dbo.del_ParametrosFactura dpf WITH(NOLOCK)
		OUTER APPLY (
			SELECT TOP 1 csc.OcrCode2
			FROM DeliveryBackOffice.dbo.CatSAPCodeCentroCosto csc WITH(NOLOCK)
			WHERE csc.SAPCode   = dpf.dpf_SAParticulo
			  AND csc.IdCountry = @country
			  AND csc.RowStatus = 1
		) csc
	WHERE dpf.dpf_VpCodeOfReference = @VpCodeOfReference;
END