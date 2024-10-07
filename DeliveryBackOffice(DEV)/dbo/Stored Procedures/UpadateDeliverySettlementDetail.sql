CREATE PROCEDURE UpadateDeliverySettlementDetail

			@RowStatus INT,
			@ID_DeliveryOrderBySettlement INT,
			@Guide_Serie VARCHAR(10),
			@Guide_Number INT

	AS
	BEGIN
		UPDATE DeliverySettlementDetail
		SET RowStatus = @RowStatus
		WHERE
	ID_DeliveryOrderBySettlement = @ID_DeliveryOrderBySettlement
		AND Guide_Serie = @Guide_Serie
		AND Guide_Number = @Guide_Number;
		END