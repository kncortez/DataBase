USE [DeliveryBackOffice]
GO

Declare @VpCodeOfReference as int = 4262,--Codigo Visit Point Client
@FELestablecimiento as int = 7,--Establecimiento creado en la SAT proporcionado por Juan Carlos Grijalva
@FELcorreoExpressCenter as varchar(500) = 'express.reformador@forzadelivery.com',--Correo a donde se copian las facturas emitidas
@SAPserieFactura as varchar(10) = '77',--Serie SAP para las facturas del Express Center, proporcionado por Juan Carlos Grijalva
@SAPserieNC as varchar(10) = '82',--Serie SAP para las notas de credito del Express Center, proporcionado por Juan Carlos Grijalva
@SAPseriePago as varchar(10) = '87',--Serie SAP para los pagos del Express Center, proporcionado por Juan Carlos Grijalva
@SAPCardCode as varchar(150) = 'CEC0007',--Código del cliente SAP del Express Center, proporcionado por Juan Carlos Grijalva
@SAPCreditCard as varchar(15) = '6'--Código de la tarjeta de credito del Express Center, proporcionado por Juan Carlos Grijalva

delete del_ParametrosFactura
where dpf_VpCodeOfReference = @VpCodeOfReference

INSERT INTO [dbo].[del_ParametrosFactura]
           ([dpf_VpCodeOfReference]
           ,[dpf_FELRequestor]
           ,[dpf_FELTransaction]
           ,[dpf_FELCountry]
           ,[dpf_FELEntity]
           ,[dpf_FELUser]
           ,[dpf_FELUserName]
           ,[dpf_FELData1]
           ,[dpf_FELData3]
           ,[dpf_FELCorreo]
           ,[dpf_FELAsuntoCorreoFactura]
           ,[dpf_FELAsuntoCorreoNotaCredito]
           ,[dpf_FELEstablecimiento]
           ,[dpf_FELCorreoCCO]
           ,[dpf_SAPServidorLicencias]
           ,[dpf_SAPCompania]
           ,[dpf_SAPUsuario]
           ,[dpf_SAPContrasenia]
           ,[dpf_SAPServidor]
           ,[dpf_SAPUsuarioBD]
           ,[dpf_SAPContraseniaBD]
           ,[dpf_SAPserieFactura]
           ,[dpf_SAPserieNC]
           ,[dpf_SAPseriePago]
           ,[dpf_SAPcardCode]
           ,[dpf_SAParticulo]
           ,[dpf_SAPvendor]
           ,[dpf_SAPcreditCard])
     VALUES
           (@VpCodeOfReference
           ,'301767F2-BA4D-43A2-9131-E13C95857549'
           ,'SYSTEM_REQUEST'
           ,'GT'
           ,'86534599'
           ,'301767F2-BA4D-43A2-9131-E13C95857549'
           ,'ADMINISTRADOR'
           ,'POST_DOCUMENTGT'
           ,'XML'
           ,'no-reply@forzalatam.com'
           ,'Forza Delivery - Factura Electrónica'
           ,'Forza Delivery - Nota de Crédito'
           ,@FELestablecimiento
           ,@FELcorreoExpressCenter
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,''
           ,@SAPserieFactura
           ,@SAPserieNC
           ,@SAPseriePago
           ,@SAPCardCode
           ,'409010101'
           ,'1'
           ,@SAPCreditCard)
GO


