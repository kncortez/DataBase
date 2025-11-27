CREATE PROCEDURE SUPPORTLHMANIFEST
	@hublogisticid int,
	@userid int,
	@Token varchar(50)

AS
BEGIN
IF NOT EXISTS (SELECT 1 FROM HubLogisticByUser WITH(NOLOCK) WHERE UserId = @userid and HubLogisticId = @hublogisticid)
BEGIN
INSERT INTO HubLogisticByUser
	(
	HubLogisticId,
	UserId,
	RowStatus,
	TokenCreated,
	DateCreated,
	TokenUpdated,
	DateUpdated
	)
VALUES
	(
	@hublogisticid, --ID HUB
	@userid, --REGISTER USER
	1,
	@Token, --TOKEN 'SYS-KOLIVA'
	GETDATE(),
	NULL,
	NULL
	);
	SELECT 'USUARIO AGREGADO EXITOSAMENTE' AS Mensaje;
	END
	ELSE
	BEGIN
	SELECT 'YA EXISTE UN REGISTRO PARA ESTE UN REGISTRO DE ESTE HUB PARA ESTE USUARIO' AS Mesaje;
	END 
	END;
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SUPPORTLHMANIFEST] TO [cvaldes]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SUPPORTLHMANIFEST] TO [cvaldes]
    AS [dbo];

