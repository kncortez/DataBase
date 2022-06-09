

-- =============================================
-- Author:		<Alberto,Ixchop>
-- Create date: <2021-11-30>
-- Description:	<crea una nueva alerta para una guia>
-- =============================================
CREATE PROCEDURE [dbo].[sphd_CreateAlertOrder]
	-- Add the parameters for the stored procedure here
	@guideserie nvarchar(2),
	@guidenumber int,
	@tokenuser nvarchar(50),
	@idTypealert int,
	@alertdescription nvarchar(500),
	@serviceTypeId bigint,
	@flagModifyAlert bit,
	@idAlert int =NULL,
	@iduser bigint
AS
BEGIN
	BEGIN TRANSACTION
	
		BEGIN TRY
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
                    DateUpdated)
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
                        NULL		
                    );
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
						IDENT_CURRENT('DeliveryOrderAlert'),
                        1,
                        @tokenuser,
                        GETDATE(),
                        NULL,
                        NULL
                    )
					
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
		
