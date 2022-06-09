CREATE PROCEDURE [dbo].[setUpdate_imag_for_url]
@ID INT,
@Guide_Number INT,
@Url VARCHAR (300),
@Type VARCHAR (300)

AS
BEGIN
	IF(@Type = 'Dry')
		BEGIN
			UPDATE DeliveryProof
			SET Proof_Dry = NULL,
			    Path_Dry = @Url
				WHERE ID = @ID AND Guide_Number = @Guide_Number

			UPDATE ContImg
			SET IdDeliveryProof = @ID
			WHERE Id = 1
		END

	IF(@Type = 'Cold')
		BEGIN
			UPDATE DeliveryProof
			SET Proof_Cold = NULL,
			    Path_Cold = @Url
				WHERE ID = @ID AND Guide_Number = @Guide_Number

			UPDATE ContImg
			SET IdDeliveryProof = @ID
			WHERE Id = 1
		END


	IF(@Type = 'incident')
		BEGIN
			UPDATE DeliveryProof
			SET Proof_Incident = NULL,
			    Path_Incident = @Url
				WHERE ID = @ID AND Guide_Number = @Guide_Number

			UPDATE ContImg
			SET IdDeliveryProof = @ID
			WHERE Id = 1
		END
END