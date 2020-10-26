-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Hernandez,Josselyn>
-- Create date: <2020/10/22 9:30AM,>
-- Description:	<Guarda las Imagenes y Actualiza el status a Delivered>
-- =============================================
CREATE PROCEDURE sps_add_proof_image 
	-- Add the parameters for the stored procedure here
									 @Guide_Serie  NVARCHAR(2), 
                                     @Guide_Number INT, 
                                     @Image        VARCHAR(max), 
                                     @Type         VARCHAR(18),
									 @tokenid	   VARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

     IF ( @Type = 'DRY' ) 
	 BEGIN
		INSERT INTO DeliveryBackOffice.dbo.DeliveryProof (Guide_Serie,Guide_Number,Date_Photo,Proof_Dry,Proof_Cold,Proof_Incident,user_created,date_created)
		VALUES (@Guide_Serie, @Guide_Number, GETDATE(), (Cast(N'' AS XML).value('xs:base64Binary(sql:variable("@Image"))', 'varbinary(max)') ), NULL, NULL, @tokenid, GETDATE());		   
		 UPDATE [DeliveryBackOffice].[dbo].[DeliveryAttempt] SET Delivered = 1 WHERE Guide_Number = @Guide_Number	
	 END
	 ELSE IF ( @Type = 'COLD' ) 
      BEGIN 
          INSERT INTO DeliveryBackOffice.dbo.DeliveryProof (Guide_Serie,Guide_Number,Date_Photo,Proof_Dry,Proof_Cold,Proof_Incident,user_created,date_created)
          VALUES (@Guide_Serie, @Guide_Number, GETDATE(), NULL, (Cast(N'' AS XML).value('xs:base64Binary(sql:variable("@Image"))', 'varbinary(max)')),NULL, @tokenid, GETDATE()); 
		  UPDATE [DeliveryBackOffice].[dbo].[DeliveryAttempt] SET Delivered = 1 WHERE Guide_Number = @Guide_Number	
      END 
    ELSE IF ( @Type = 'INCIDENT' ) 
      BEGIN 
          INSERT INTO DeliveryBackOffice.dbo.DeliveryProof (Guide_Serie,Guide_Number,Date_Photo,Proof_Dry,Proof_Cold,Proof_Incident,user_created,date_created)
          VALUES (@Guide_Serie, @Guide_Number, GETDATE(), NULL, NULL, (Cast(N'' AS XML).value('xs:base64Binary(sql:variable("@Image"))', 'varbinary(max)') ), @tokenid, GETDATE()); 
      END 

END
GO
