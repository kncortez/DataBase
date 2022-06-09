
-- =============================================
-- Author:      <Sazo,Cesar>
-- Create date: <2021-11-30>
-- Description: <Obtener información para reversión de guía cargada>
-- =============================================

CREATE PROCEDURE [dbo].[sphd_getGuideInfo] @Guide_Serie VARCHAR(2),
@Guide_Number INT
AS
BEGIN

	--Estados validos para la reversión
	DECLARE @ValidStares TABLE (
		Id TINYINT
	)
	INSERT INTO @ValidStares
		VALUES (5),
		(22)

	DECLARE @Operador NVARCHAR(250)
		   ,@DateCreated DATETIME;

	SELECT
	TOP 1
		@Operador = ru.UsrNickName
	   ,@DateCreated = dod.DateCreated
	FROM dbo.DeliveryOrderDetail dod
	INNER JOIN dbo.TokenLog tl
		ON dod.UserCreated = tl.TknIdToken
	INNER JOIN dbo.RegisterUser ru
		ON tl.TknIdUser = ru.UsrIdUser
	INNER JOIN @ValidStares vs
		ON vs.Id = dod.StatusOrderId
	WHERE dod.Guide_Serie = @Guide_Serie
	AND dod.Guide_Number = @Guide_Number;

	IF @Operador IS NULL
	BEGIN
		SELECT
		TOP 1
			@Operador = sr.First_Name + ' ' + sr.Last_Name
		   ,@DateCreated = dod.DateCreated
		FROM dbo.DeliveryOrderDetail dod
		INNER JOIN dbo.LogTokenPOD ltp
			ON dod.UserCreated = ltp.LogTokenPOD
		INNER JOIN dbo.SenderReceiver sr
			ON ltp.IdCourierman = sr.Id
		INNER JOIN @ValidStares vs
			ON vs.Id = dod.StatusOrderId
		WHERE dod.Guide_Serie = @Guide_Serie
		AND dod.Guide_Number = @Guide_Number
	END
	
	IF @Operador IS NULL
	BEGIN
		SELECT
		TOP 1
			@Operador = lbt.SSN_Username
		   ,@DateCreated = dod.DateCreated
		FROM dbo.DeliveryOrderDetail dod
		INNER JOIN DenariusUser_Dev.dbo.LGN_LogByToken lbt
			ON dod.UserCreated = lbt.SSN_IdToken
		INNER JOIN @ValidStares vs
			ON vs.Id = dod.StatusOrderId
		WHERE dod.Guide_Serie = @Guide_Serie
		AND dod.Guide_Number = @Guide_Number
	END

	SELECT
	TOP 1
		so.OrderDescription
	   ,@DateCreated DateCreated
	   ,ISNULL(@Operador, '') Operador
	   ,(CASE so.StatusOrderId
			WHEN
				5 THEN 1
			WHEN
				22 THEN 1
			ELSE 0
		END)
		Valid
	FROM dbo.DeliveryOrder do
	INNER JOIN dbo.StatusOrder so
		ON do.StatusOrderId = so.StatusOrderId
	WHERE do.Guide_Serie = @Guide_Serie
	AND do.Guide_Number = @Guide_Number
END