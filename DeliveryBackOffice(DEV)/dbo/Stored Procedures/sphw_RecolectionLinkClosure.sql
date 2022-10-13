-- =============================================
-- Author:		<Alberto Ixchop>
-- Create date: <21-09-2022>
-- Description:	<Cierra un link de recolección y genera una solciitud de recolección agrupado por codigo de referencia>
-- =============================================
CREATE PROCEDURE sphw_RecolectionLinkClosure
	@VisitPointDataLinkId BIGINT,
	@TAC1 BIT,
	@TAC2 BIT,
	@TypeVehicleId int,
	@Regularpiezer int,
	@RecollectionLatitude varchar(50),
	@RecollectionLongitude varchar(50),
	@Token nvarchar(100),
	@IdAccount int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @TranCounter INT;  
    SET @TranCounter = @@TRANCOUNT;  
    IF @TranCounter > 0  
        SAVE TRANSACTION RecolectionLinkClosurePT;
    ELSE  
        BEGIN TRANSACTION;  

	DECLARE @RESULTREGISTERRECOLECTION TABLE
	(StatusCode INT, 
		Description NVARCHAR(100),
		ServiceId INT
	)		
	BEGIN TRY


		--CREANDO SOLICITUD DE RECOLECCIÓN
		DECLARE @CodeOfReference INT;
		DECLARE @CustomerId INT;
		SELECT 
			@CodeOfReference=VPDL.VisitPointId,
			@CustomerId=VPDL.CustomerId
		FROM DBO.VisitPointDataLink VPDL
		WHERE VPDL.IdVisitPointDataLink=@VisitPointDataLinkId;

		DECLARE @Scheduled bit = 0--SE CREARA UNA RECOLECCIÓN NO PROGRAMADA


		INSERT INTO @RESULTREGISTERRECOLECTION
		(
			StatusCode,
			Description,
			ServiceId
		)
		EXECUTE [dbo].[sphw_RegisterRecolectionRequest] 
			@TAC1
			,@TAC2
			,@Scheduled
			,@CodeOfReference
			,@TypeVehicleId
			,@RecollectionLatitude
			,@RecollectionLongitude
			,@Regularpiezer
			,NULL
			,NULL
			,@Token
			,@IdAccount;

		
		IF (SELECT StatusCode FROM @RESULTREGISTERRECOLECTION) =1
		BEGIN
			--CERRANDO LINK
			UPDATE DBO.VisitPointDataLink SET
				DataLinkStatusId= (SELECT IdCatDataLinkStatus FROM DBO.CatDataLinkStatus WHERE DataLinkStatusName = 'Completado')
			WHERE IdVisitPointDataLink=@VisitPointDataLinkId;
			SELECT StatusCode 'StatusCode',Description 'Description',ServiceId 'ServiceId' FROM @RESULTrEGISTERRECOLECTION;

			IF @TranCounter = 0  
				COMMIT TRANSACTION;
		END
		ELSE
		BEGIN
			SELECT StatusCode 'StatusCode',Description 'Description',ServiceId 'ServiceId' FROM @RESULTrEGISTERRECOLECTION;
		END


    END TRY
    BEGIN CATCH        
        IF @TranCounter = 0  
            ROLLBACK TRANSACTION;  
        ELSE IF XACT_STATE() <> -1  
			ROLLBACK TRANSACTION ProcedureSave2;  
		SELECT 0 'StatusCode', 
		CONCAT(ERROR_MESSAGE(),' LINE:',ERROR_LINE()) 'Description';
    END CATCH;

END