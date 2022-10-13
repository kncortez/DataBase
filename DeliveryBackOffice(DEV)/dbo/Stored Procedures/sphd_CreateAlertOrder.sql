
-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-11-30>
-- Description:	<crea una nueva alerta para una guia>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_CreateAlertOrder]
	-- Add the parameters for the stored procedure here
	@guideserie nvarchar(2) =NULL,
	@guidenumber int =NULL,
	@serviceManagementId int =NULL,
	@tokenuser nvarchar(50),
	@idTypealert int =1,
	@alertdescription nvarchar(500),
	@serviceTypeId bigint =Null,
	@flagModifyAlert bit,
	@idAlert int =NULL,
	@iduser bigint
AS
BEGIN
	BEGIN TRANSACTION
	
		BEGIN TRY
		BEGIN

		DECLARE @AlertForGuide BIT=0;
		DECLARE @AlertForService BIT=1;

		IF (@guideserie is not null and @guidenumber is not null )and @AlertForService is null
			SET @AlertForGuide=1;
		IF @serviceManagementId is not null and (@guideserie is null and @guidenumber is null )
			SET @AlertForService=1;			
	
		IF (SELECT @AlertForGuide ^ @AlertForService) =0
		BEGIN
			SELECT 
				0 AS 'StatusCode', 
				'Se esperaba solo serie y número de guía ó solo id de servicio' AS 'Description',
				0 'NumTransferID',
				' ' 'Guide';
		END
		ELSE 
		BEGIN 

			DECLARE @RModified INT
            IF @flagModifyAlert=1 --MODIFY ALERT
                BEGIN
                    UPDATE DBO.DeliveryOrderAlert
                    SET
                    GuideSerie=@guideserie,
                    GuideNumber=@guidenumber,
                    ServiceTypeId=@serviceTypeId,
                    AlertDescription=@alertdescription,
                    AlertTypeId=@idTypealert,
                    TokenUpdated=@tokenuser,
                    DateUpdated=GETDATE()
                    WHERE IdDeliveryOrderAlert=@idAlert;	

					SELECT 
						1 AS 'StatusCode', 
						'Alerta Modificada' AS 'Description',
						1 'NumTransferID',
						'' 'Guide';

                END
            ELSE
                BEGIN --CREATE ALERT
                    INSERT INTO DBO.DeliveryOrderAlert 
                    (
					GuideSerie,
                    GuideNumber,
                    ServiceTypeId,
                    AlertDescription,
                    AlertTypeId,
                    RowStatus,
                    TokenCreated,
                    DateCreated,
                    TokenUpdated,
                    DateUpdated,
					ServiceManagementId)
                    VALUES
                    (
                        @guideserie,
                        @guidenumber,
                        @serviceTypeId,
                        @alertdescription,
                        @idTypealert,
                        1,
                        @tokenuser,
                        GETDATE(),
                        NULL,
                        NULL,
						@serviceManagementId
                    );
					SET @idAlert = SCOPE_IDENTITY();
                    INSERT INTO DBO.DeliveryOrderAlertDetail
                    (
                        author,
                        username,
                        comment,
                        DeliveryOrderAlertId,
                        RowStatus,
                        TokenCreated,
                        DateCreated,
                        TokenUpdated,
                        DateUpdated
                    )
                    VALUES				
                    (
                        @iduser,
                        (SELECT Username FROM DBO.InternalUser WHERE IdUser=@iduser),
                        'Alerta creada',
						@idAlert,
                        1,
                        @tokenuser,
                        GETDATE(),
                        NULL,
                        NULL
                    ),
                    (
                        @iduser,
                        (SELECT Username FROM DBO.InternalUser WHERE IdUser=@iduser),
                        @alertdescription,
						IDENT_CURRENT('DeliveryOrderAlert'),
                        1,
                        @tokenuser,
                        GETDATE(),
                        NULL,
                        NULL
                    )  
					SELECT 
						1 AS 'StatusCode', 
						'Alerta creada' AS 'Description',
						1 'NumTransferID',
						'' 'Guide';

                END
		END



		END

		END TRY

		BEGIN CATCH
			SELECT 
				0 AS 'StatusCode', 
				ERROR_MESSAGE() AS 'Description', 
				CONVERT(BIGINT, 0) AS 'NumTransferID',
				@GuideSerie + convert(nvarchar,@GuideNumber) AS 'Guide'
			ROLLBACK TRANSACTION
		END CATCH
		COMMIT TRANSACTION;	
END        
		