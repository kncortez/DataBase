
-- =============================================
-- Author:		<Andres,Ruiz>
-- Create date: <2021-07-06>
-- Description:	<Su funcion es modificar los datos de ubicacion de recoleccion de guias>
-- =============================================

CREATE PROCEDURE "SetNewOriginGuides"
	@TblOrderGuides AS [TblOrderGuides] READONLY,
	@NewSenderAddress AS NVARCHAR(200),
	@NewSenderTownship AS NVARCHAR(100),
	@NewSenderProvince AS NVARCHAR(100),
	@NewSenderTownshipID AS INT
AS
BEGIN
	BEGIN TRANSACTION;
	BEGIN TRY
		UPDATE [dbo].[DeliveryOrder]
		SET
			[Sender_Address] = @NewSenderAddress,
			[Sender_Town] = @NewSenderTownship,
			[Sender_Department] = @NewSenderProvince,
			[SenderIdTownship] = @NewSenderTownshipID
		FROM
			[dbo].[DeliveryOrder] DO
			INNER JOIN
			@TblOrderGuides TOG ON TOG.[Guide_Serie] = DO.[Guide_Serie]
			AND TOG.[Guide_Number] = DO.[Guide_Number];

		UPDATE [dbo].SchedulePickup
		SET
			[AddressPickup] = @NewSenderAddress
		FROM
			[dbo].[SchedulePickup] SP
			INNER JOIN
			[dbo].[DeliveryOrderPaymentDetail] DOPD ON SP.[SchedulePickupId] = DOPD.[IdHeaderRecolection]
			INNER JOIN
			@TblOrderGuides TOG ON TOG.[Guide_Serie] = DOPD.[GuideSerie]
			AND TOG.[Guide_Number] = DOPD.[GuideNumber];
	END TRY
	BEGIN CATCH
        DECLARE @jsonOutput1 NVARCHAR(MAX);
        SET @jsonOutput1 =
        (
            SELECT ''
                    + STUFF(
                                (
                                    SELECT ',{"Status":"' + ERROR_MESSAGE() + '"}' 
									FOR XML PATH(''), TYPE
                                ).value('.', 'varchar(max)'),
                                1,
                                1,
                                ''
                            ) + ''
        );

        SELECT ('[' + @jsonOutput1 + ']') jsonOutput1;
		ROLLBACK TRANSACTION;
	END CATCH;

    IF @@TRANCOUNT > 0
    BEGIN
        COMMIT TRANSACTION;

        DECLARE @jsonOutput2 NVARCHAR(MAX);
        SET @jsonOutput2 =
        (
            SELECT '' + STUFF(
                                    (
                                        SELECT ',{"Status":"Ubicacion guardada exitosamente"}'
                                        FOR XML PATH(''), TYPE
                                    ).value('.', 'varchar(max)'),
                                    1,
                                    1,
                                    ''
                                ) + ''
        );

        SELECT ('[' + @jsonOutput2 + ']') jsonOutput2;
    END;
END;