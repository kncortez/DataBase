
CREATE PROCEDURE [dbo].[sps_user_datacreate_denarius_delivery]
		@CODIGO_DENARIUS INT  -- INGRESO CODIGO DENARIUS.
		,@CONTRASEÑA NVARCHAR(1000)   --GESTION DE CONTRASEÑA
AS
BEGIN
	--,@CODIGO_SOCIO  INT = 224279
   DECLARE @SOCIO_TEXTO NVARCHAR(100) = NULL
   DECLARE @COUNTRY NVARCHAR(2) = NULL
   DECLARE @IDWEB INT = NULL
   DECLARE @USER NVARCHAR(100) =NULL
   DECLARE @LAST NVARCHAR(100) = NULL
   DECLARE @EMAIL NVARCHAR(100) = NULL
   DECLARE @CODIGO_BACKOFF NVARCHAR(100) = NULL

   
   SET @SOCIO_TEXTO = (SELECT ACY_ClientCardCode FROM DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints RV WITH (NOLOCK)
   INNER JOIN DenariusDesktop_Dev.dbo.ADM_SYS_Client AC ON AC.ACY_ClientCardCode = rv.RVP_SAPcardCode
	WHERE RVP_VisitPointId = @CODIGO_DENARIUS)

	 SET @COUNTRY= (SELECT ACY_Country FROM DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints RV WITH (NOLOCK)
	INNER JOIN DenariusDesktop_Dev.dbo.ADM_SYS_Client AC WITH (NOLOCK) ON AC.ACY_ClientCardCode = rv.RVP_SAPcardCode
	WHERE RVP_VisitPointId = @CODIGO_DENARIUS)

	SET @USER = ( SELECT rvp_clientid FROM DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints WITH (NOLOCK)
	WHERE RVp_VisitPointid = @CODIGO_DENARIUS)

	SET @LAST = ( SELECT rvp_u_codPrince FROM DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints WITH (NOLOCK)
	WHERE RVp_VisitPointid = @CODIGO_DENARIUS)

	SET @EMAIL =( SELECT rvp_email FROM DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints WITH (NOLOCK)
	WHERE RVp_VisitPointid = @CODIGO_DENARIUS)

	SET @CODIGO_BACKOFF = (SELECT RVP_Building FROM DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints WITH (NOLOCK)
	WHERE RVp_VisitPointid = @CODIGO_DENARIUS)
   

	UPDATE DeliveryBackOffice.dbo.VisitPointClient
	SET VisitPointId = @CODIGO_DENARIUS
	WHERE CodeOfReference = @CODIGO_BACKOFF

	insert into [DenariusWeb_Dev].[dbo].[User]  
	  values
	  (
      'true'
      ,'ADMINISTRACIÓN FORZA DELIVERY EXPRESS'
      ,lower(@USER)+'.'+lower(@LAST)+'@forzadelivery.com'
      ,'0000-0000'
      ,UPPER(@USER)
      ,UPPER(@LAST)
      ,@SOCIO_TEXTO
      ,'Direccion Facturacion'
      ,00000000
      ,''
      ,''
      ,0
      ,''
      ,0
      ,@EMAIL
      ,00000000
      ,0
      ,''
      ,''
      ,''
      ,@CODIGO_DENARIUS
      ,''
      ,'dunbar-logo.png'
      ,@COUNTRY
      ,0
      ,NULL
      ,NULL
      ,NULL
  )

  SET @IDWEB =( SELECT MAX(USR_WebClientId) FROM DenariusWeb_Dev.dbo.[User] WITH (NOLOCK))

  insert into [DenariusUser_Dev].[dbo].[LGN_User]
		  values		  
		  (
			   @CODIGO_DENARIUS
			  ,lower(@USER)+'.'+lower(@LAST)
			  ,@CONTRASEÑA
			  ,NULL
			  ,NULL
			  ,@IDWEB
			  ,0
			  ,NULL
			  ,lower(@USER)+'.'+lower(@LAST)+'@forzadelivery.com'
			  ,''
			  ,GETDATE()+180
			  ,''
			  ,''
			  ,''
			  ,''
			  ,''
			  ,''
			  ,''
			  ,''
			  ,''
			  ,''
			  ,''
			  ,null
			  ,NULL 
			  ,NULL
			  ,NULL
			  ,GETDATE()
			  ,NULL
			  ,NULL
			  ,NULL
			  ,0
			  ,NULL
			  ,NULL
			  ,NULL
			  ,NULL
			  ,NULL
		  )
  


  --INGRESO DE SISTEMA TRAKING DELIVERY
   INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
			  VALUES
			  (
			  875
			  ,@CODIGO_DENARIUS
			  ,(SELECT STN_IdStation FROM DenariusUser_Dev.dbo.LGN_Station WITH (NOLOCK)
				WHERE STN_IdCountry = @COUNTRY
				AND STN_IdStation LIKE '%-%')
			  ,@COUNTRY
			  ,lower(@USER)+'.'+lower(@LAST)
			  ,1
			  )

  --INGRESO DE SISTEMA PLATAFORMA DE GUIAS
   INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
			  VALUES
			  (
			  904
			  ,@CODIGO_DENARIUS
			  ,(SELECT STN_IdStation FROM DenariusUser_Dev.dbo.LGN_Station WITH (NOLOCK)
				WHERE STN_IdCountry = @COUNTRY
				AND STN_IdStation LIKE '%-%')
			  ,@COUNTRY
			  ,lower(@USER)+'.'+lower(@LAST)
			  ,1
			  )

--- INGRESO DE SISTEMA
		  INSERT INTO [DenariusUser_Dev].[dbo].[LGN_Restriction]
  VALUES
  (
       @CODIGO_DENARIUS
      ,lower(@USER)+'.'+lower(@LAST)
      ,12
      ,10
      ,'ACTIVE'
      ,0
      ,GETDATE()
      ,NULL
      ,NULL
      ,NULL
  )
			  
		  INSERT INTO [DenariusUser_Dev].[dbo].[LGN_Restriction]
  VALUES
  (
       @CODIGO_DENARIUS
      ,lower(@USER)+'.'+lower(@LAST)
      ,16
      ,10
      ,'ACTIVE'
      ,0
      ,GETDATE()
      ,NULL
      ,NULL
      ,NULL
  )

  SELECT * FROM DeliveryBackOffice.dbo.VisitPointClient
  WHERE CodeOfReference = @CODIGO_BACKOFF

  SELECT * FROM DenariusUser_Dev.dbo.LGN_User WITH (NOLOCK)
  WHERE USR_IdUser = @CODIGO_DENARIUS

  SELECT * FROM DenariusUser_Dev.dbo.LGN_Restriction WITH (NOLOCK)
  WHERE RST_IdUser = @CODIGO_DENARIUS

END
GO
GRANT EXECUTE
    ON OBJECT::[dbo].[sps_user_datacreate_denarius_delivery] TO [jlopez]
    AS [dbo];


GO



GO
DENY EXECUTE
    ON OBJECT::[dbo].[sps_user_datacreate_denarius_delivery] TO [ngarcia]
    AS [dbo];

