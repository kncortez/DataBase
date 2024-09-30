-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2024-09-27>
-- Description:	<Retorna el pais de origen de un servicio>
-- =============================================
CREATE PROCEDURE GetCountryOfPickupService
	@IdPickup BIGINT ,
	@Token NVARCHAR(50) = NULL
AS
BEGIN
	/*
	CASOS
	1 Buscar el pais por medio del senderid
	2 buscar el pais por el township
	3 buscar el pais por el account
	4 buscar el pais por el token que consulta
	5 buscar el pais por el token del servicio creado
	*/
	DECLARE  @IDCOUNTRY VARCHAR(2) =NULL;

	DECLARE @SENDERID INT  = NULL;
	DECLARE @TOWNSHIPID INT  = NULL;
	DECLARE @ACCOUNTID INT  = NULL;
	DECLARE @SERVICEPICUP_TOKEN_CREATED INT  = NULL;
	
	IF @SENDERID IS NOT NULL 
	BEGIN
		SELECT @IDCOUNTRY= ISNULL(VCP.CountryId,'GT')
			FROM DBO.SchedulePickup SP WITH(NOLOCK)
			INNER JOIN DBO.VisitPointClient VCP WITH(NOLOCK)
				ON VCP.CodeOfReference=SP.SenderId
			WHERE SP.SchedulePickupId=@IdPickup
	END
	
	IF @IDCOUNTRY IS NULL AND @TOWNSHIPID IS NOT NULL
	BEGIN
		SELECT @IDCOUNTRY=ISNULL(PR.IdCountry,'GT')
			FROM DBO.SchedulePickup SP WITH(NOLOCK)
			INNER JOIN DBO.Township TW WITH(NOLOCK)
				ON SP.SenderId= TW.IdTownship
			INNER JOIN DBO.Province PR WITH(NOLOCK)
				ON  TW.IdProvince=PR.IdProvince				
			WHERE SP.SchedulePickupId=@IdPickup
	END
	 
	IF @IDCOUNTRY IS NULL AND  @ACCOUNTID IS NOT  NULL
	BEGIN 	
		SELECT @IDCOUNTRY=ISNULL(CT.CountryID,'GT')
			FROM DBO.SchedulePickup SP WITH(NOLOCK)
			INNER JOIN ACCOUNT ACC WITH(NOLOCK)
				ON ACC.AccIdAccount=SP.AccountId
			INNER JOIN Customer CT WITH(NOLOCK)
				ON CT.IdCustomer = ACC.IdCustomer
			WHERE SP.SchedulePickupId=@IdPickup
	END
	
	IF @IDCOUNTRY IS NULL AND @Token IS NOT  NULL
	BEGIN		
		select 
			@IDCOUNTRY=ISNULL(sr.IdCountry,'GT')
		from LogTokenPOD WITH(NOLOCK)
			inner join dbo.SenderReceiver sr WITH(NOLOCK)
				on sr.ID=IdCourierman
		where LogTokenPOD= @Token
	END
	

	
	IF @IDCOUNTRY IS NULL 
	BEGIN
		--Busqueda de pais  por token de portal
		SELECT TOP 1 
			@IDCOUNTRY=DC.Currency_IdCountry 
		FROM TokenLog TL WITH(NOLOCK)
		INNER JOIN DBO.RegisterUser RU WITH(NOLOCK)
			ON RU.UsrIdUser=TL.TknIdUser
		INNER JOIN DBO.CatCurrencyCOD CTCOD WITH(NOLOCK)
			ON CTCOD.CodeISO=RU.UsrCurrency
		INNER JOIN DBO.DeliveryCurrency DC WITH(NOLOCK)
			ON DC.IdCurrencyCOD=CTCOD.IdCatCurrencyCOD
		WHERE TknIdToken = (SELECT TokenCreated FROM DBO.SchedulePickup SP WITH(NOLOCK) WHERE SchedulePickupId=@IdPickup)


	END

	IF @IDCOUNTRY IS NULL 
	BEGIN
		--Busqueda de pais  por token de desktop
		SELECT 
			@IDCOUNTRY=SSN_IdCountry 
		FROM DenariusUser_Dev.dbo.lgn_logbytoken WITH(NOLOCK)
		WHERE SSN_IdToken = (SELECT TokenCreated FROM DBO.SchedulePickup SP WITH(NOLOCK) WHERE SchedulePickupId=@IdPickup)
	END
	
	SELECT  @IDCOUNTRY IdCountry;
	
END
