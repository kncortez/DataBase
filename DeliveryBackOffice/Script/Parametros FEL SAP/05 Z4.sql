USE [DeliveryBackOffice]
GO

Declare @VpCodeOfReference as int = 4250,
@FELestablecimiento as int = 5,
@FELcorreoExpressCenter as varchar(500) = 'express.z4@forzadelivery.com',
@SAPserieFactura as varchar(10) = '61',
@SAPserieNC as varchar(10) = '65',
@SAPseriePago as varchar(10) = '69',
@SAPCardCode as varchar(150) = 'CEC0005',
@SAPCreditCard as varchar(15) = '4'

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
           ,'192.168.130.106'
           ,'ZZZ_DELIVERY_FORZA'
           ,'prdun05'
           ,'12345'
           ,'192.168.130.107'
           ,'lcoti'
           ,'\bFy%5yT##x5%dq6'
           ,@SAPserieFactura
           ,@SAPserieNC
           ,@SAPseriePago
           ,@SAPCardCode
           ,'409010101'
           ,'1'
           ,@SAPCreditCard)
GO


