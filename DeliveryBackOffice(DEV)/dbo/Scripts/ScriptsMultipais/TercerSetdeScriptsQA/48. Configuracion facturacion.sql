use deliverybackoffice
go
/*
Pasos 
1. Generar socio de negocio FORZA Delivery Express (idCountry HN)
2. Asociar el Punto de Visita 'EXPRESS CENTER CLUBFORZA' con el socio creado anteriormente
*/
BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @CustomerId int;
    DECLARE @VpCustomer int

    SELECT * 
      FROM Customer 
     WHERE [name] = 'Forza Delivery Express HN' 
       AND CountryId = 'HN'

    SELECT *
      FROM VisitPointClient 
     WHERE DescriptionOfClient = 'EXPRESS CENTER CLUBFORZA' 
       AND CountryId = 'HN'

    --1. Generar socio de negocio FORZA Delivery Express (idCountry HN)
    INSERT INTO Customer ([Name],[Description],Domain,RegexSubject,RegexEmail,RegexFilename,Abbreviation,IdCustomerType,ConditionOfPaymentID,CountryID,CommercialName,CustomerPhone, WebsiteURI,ContactName,ContactEmail,NotificationAddress,SaleAdvisorID,DateUpService,DateDownService,TypeOfBusinessID,BusinessSegmentId,BusinessActivityID,CommercialSegmentID,OperationContactName,OperationContactPhone,HasAgreement,AgreementNumber,AgreementDateStart,AgreementDateEnd,InvoiceContactPhone,RowSatus,TokenCreated,DateCreated,ExcludePriceShippingCOD,ExcludeCommissionCOD,CatBillingVolumeId,NumImgEvidence,IsCOD)
    VALUES ('Forza Delivery Express HN','Forza Delivery Express','@gmail.com','^.*solicitud.*$','TMP-^andyb5641@gmail.com$','^envios_.*\.xls$','Forza Delivery Express',3,NULL,'HN',NULL,NULL,NULL,NULL,NULL,NULL,72,NULL,NULL,16,10,28,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,'CAZURDIA-SYS',GETDATE(),NULL,NULL,2,NULL,NULL)

    SELECT @CustomerId = IdCustomer FROM Customer WHERE Name = 'Forza Delivery Express HN' and CountryID = 'HN'
    SELECT @VpCustomer = (MAX(CodeOfReference) + 1)  FROM VisitPointClient

    --2. Asociar el Punto de Visita 'EXPRESS CENTER CLUBFORZA' con el socio creado anteriormente
    INSERT INTO VisitPointClient(CodeOfReference,DescriptionOfClient, statusClient, CountryId, VisitPointId, TokenCreated, DateCreated, TokenUpdated, DateUpdated, CustomerId, [Address], [Zone], [Town], [Department], Phone, ContactName, IdKindOfVPClient, idKindOfVPBusiness, IdSettlement, Email, IdTownship, Latitude, Longitude, Accuracy, BranchCode, SaleChannelId, ExcludePriceShippingCOD, ExcludeCommissionCOD, IsOriginVisitPoint,DescriptionCC, CatBusinessSegmentId)
    VALUES (@VpCustomer,'EXPRESS CENTER CLUBFORZA',1,'HN',NULL,'CAZURDIA-SYS',getdate(),NULL,NULL, @CustomerId,  'Bvd. San Juan Bosco, Edificio Corp Torre Alianza 2, Piso 10. 1005/1006 Tegucigalpa',1,'HONDURAS','HODURAS', '(504) 8900-0175','32490189',1,1,2777,'x_express.@forzadelivery.com',357,'','',NULL,'',2,0,0,1,'EXPRESS CENTER CLUBFORZA',10)
	
    SELECT * 
      FROM Customer 
     WHERE [name] = 'Forza Delivery Express HN' 
       AND CountryId = 'HN'

    SELECT * 
      FROM VisitPointClient 
     WHERE DescriptionOfClient = 'EXPRESS CENTER CLUBFORZA' 
       AND CountryId = 'HN'

    COMMIT TRANSACTION;
END TRY 
    
BEGIN CATCH
	select  ERROR_MESSAGE() 
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
	
END CATCH;




/*
Pasos 
1. Agregar datos de Facturación 
*/

BEGIN TRY
    BEGIN TRANSACTION;

    DECLARE @VPCustomerMK int;

     SELECT  @VPCustomerMK = CodeOfReference 
       FROM VisitPointClient 
      WHERE DescriptionOfClient = 'EXPRESS CENTER CLUBFORZA' 
        AND CountryID = 'HN'

    SELECT *
      FROM del_ParametrosFactura 
     WHERE dpf_VpCodeOfReference = 825781

     --Tienda Virtual - Usuario individual
    INSERT INTO del_ParametrosFactura(dpf_VpCodeOfReference,dpf_FELRequestor,dpf_FELTransaction,dpf_FELCountry,dpf_FELEntity,dpf_FELUser,dpf_FELUserName,dpf_FELData1,dpf_FELData3,dpf_FELCorreo,dpf_FELAsuntoCorreoFactura,dpf_FELAsuntoCorreoNotaCredito,dpf_FELEstablecimiento,dpf_FELCorreoCCO,dpf_SAPServidorLicencias,dpf_SAPCompania,dpf_SAPUsuario,dpf_SAPContrasenia,dpf_SAPServidor,dpf_SAPUsuarioBD,dpf_SAPContraseniaBD,dpf_SAPserieFactura,dpf_SAPserieNC,dpf_SAPseriePago,dpf_SAPcardCode,dpf_SAParticulo,dpf_SAPvendor,dpf_SAPcreditCard,dpf_OcrCode,dpf_OcrCode2,dpf_StatusFACE,dpf_WarehouseCode,inv_cmp_name,inv_cmp_nameComercial)
    VALUES (@VPCustomerMK,'','','HN',800000001111,'','','','','bidcar.herrera@forzadelivery.com','Forza Delivery Factura','Forza Delivery - Nota de Crédito',0,'bidcar.herrera@forzadelivery.com','WIN-QF1OUTS7TLC','ZZZ_DELIVERYHONDURAS','RPA_AGENT','Del$2025','172.19.2.30','delivery','R;XF%269z]$VG!HM=w<}PC',477,93,401,'CSEC20101','',1,97,10100,400000,'A',10100,'DELIVERY EXPRESS HONDURAS','DELIVERY EXPRESS HN')

    -- POD
    --INSERT INTO del_ParametrosFactura(dpf_VpCodeOfReference,dpf_FELRequestor,dpf_FELTransaction,dpf_FELCountry,dpf_FELEntity,dpf_FELUser,dpf_FELUserName,dpf_FELData1,dpf_FELData3,dpf_FELCorreo,dpf_FELAsuntoCorreoFactura,dpf_FELAsuntoCorreoNotaCredito,dpf_FELEstablecimiento,dpf_FELCorreoCCO,dpf_SAPServidorLicencias,dpf_SAPCompania,dpf_SAPUsuario,dpf_SAPContrasenia,dpf_SAPServidor,dpf_SAPUsuarioBD,dpf_SAPContraseniaBD,dpf_SAPserieFactura,dpf_SAPserieNC,dpf_SAPseriePago,dpf_SAPcardCode,dpf_SAParticulo,dpf_SAPvendor,dpf_SAPcreditCard,dpf_OcrCode,dpf_OcrCode2,dpf_StatusFACE,dpf_WarehouseCode,inv_cmp_name,inv_cmp_nameComercial)
    --VALUES (825781,'','','HN',800000001111,'','','','','bidcar.herrera@forzadelivery.com','Forza Delivery Factura','Forza Delivery - Nota de Crédito',0,'bidcar.herrera@forzadelivery.com','WIN-QF1OUTS7TLC','ZZZ_DELIVERYHONDURAS','RPA_AGENT','Del$2025','172.19.2.30','delivery','R;XF%269z]$VG!HM=w<}PC',477,93,401,'CSEC20101','',1,97,10100,400000,'A',10100,'DELIVERY EXPRESS HONDURAS','DELIVERY EXPRESS HN')
	
    SELECT *
      FROM del_ParametrosFactura
     WHERE dpf_VpCodeOfReference = 825830--825781
	 

    COMMIT TRANSACTION;
END TRY 
    
BEGIN CATCH
	select  ERROR_MESSAGE() 
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH;




BEGIN TRY
    BEGIN TRANSACTION;
	UPDATE del_ParametrosFactura 
	SET dpf_FELRequestor = '8A454E3F-CEA1-41D8-A13A-A748A4891BBF',
		dpf_FELEntity = '800000001026',
		dpf_FELUser = '0D9502F3-144F-4B41-AF42-D6118F3B49FE'
	WHERE dpf_VpCodeOfReference = 999
	COMMIT TRANSACTION 
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
END CATCH