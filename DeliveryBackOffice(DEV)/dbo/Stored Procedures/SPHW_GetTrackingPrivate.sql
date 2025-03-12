-- =============================================
-- Author:		<Walter Orozco>
-- Create date: <2024-10-10>
-- Description:	<Delivery Tracking - Método para obtener información privada para rastreo de parquete.>
-- =============================================
-- =============================================
-- Author:		<Cristian Suazo>
-- Create date: <2024-11-08>
-- Description:	<Se agrega la imagen  la longitud y latutud para el trakin>
-- =============================================

CREATE PROCEDURE [dbo].[SPHW_GetTrackingPrivate]
@GuideSerie NVARCHAR(4),
@GuideNumber INT,
@Phone NVARCHAR(200)
AS
BEGIN
BEGIN TRY

	IF OBJECT_ID('tempdb..#Temp') IS NOT NULL
    DROP TABLE #Temp;


	DECLARE @GuideDeliveryLatitude NVARCHAR(20) = N'';
    DECLARE @GuideDeliveryLongitude NVARCHAR(20) = N'';
    DECLARE @StatusIncident INT;
    DECLARE @StatusIncidentValidated INT;

	DECLARE @Receiver_Phone NVARCHAR(200) = (SELECT RIGHT(LTRIM(RTRIM(Receiver_Phone)), 8) FROM DeliveryBackOffice.dbo.DeliveryOrder WITH(NOLOCK)
											 WHERE Guide_Serie = @GuideSerie AND Guide_Number = @GuideNumber)

	DECLARE @CodeArea NVARCHAR(5) = (
		SELECT 
			CASE 
				-- Caso 1: El número comienza con '+' y tiene al menos 11 dígitos (ej. +50244444444)
				WHEN LEFT(DO.Receiver_Phone, 1) = '+' AND LEN(DO.Receiver_Phone) >= 11 THEN 
					SUBSTRING(DO.Receiver_Phone, 2, 3)

				-- Caso 2: El número comienza con un código de área sin '+' y tiene al menos 10 dígitos (ej. 50244444444)
				WHEN LEN(DO.Receiver_Phone) >= 10 AND ISNUMERIC(LEFT(DO.Receiver_Phone, 3)) = 1 THEN 
					LEFT(DO.Receiver_Phone, 3)

				-- Caso 3: Si no tiene código de área válido, devuelve NULL (ej. 2345-6789)
				ELSE ISNULL(C.[Value],'502')
			END AS 'AreaCode'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.ConfigParams C WITH(NOLOCK)
			ON C.[Name] = 'AreaCode' AND ISNULL(DO.ReceiverCountryId,'GT') = C.IdCountry
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber
	)

	DECLARE @ExternalTypeId INT =
            (
                SELECT CST.IdCatStatusType
                FROM [DeliveryBackOffice].[dbo].[CatStatusType] CST WITH (NOLOCK)
                WHERE CST.StatusType = 'Externo'
            );

	SET @StatusIncident =
    (
        SELECT StatusOrderId
        FROM StatusOrder WITH (NOLOCK)
        WHERE OrderDescription = 'Incidencia en ruta'
    );
    SET @StatusIncidentValidated =
    (
        SELECT StatusOrderId
        FROM StatusOrder WITH (NOLOCK)
        WHERE OrderDescription = 'Incidencia Validada'
    );

	SELECT TOP 1
           @GuideDeliveryLatitude  = DA.Latitude
         , @GuideDeliveryLongitude = DA.Longitude
    FROM [DeliveryBackOffice].[dbo].[DeliveryAttempt]          DA WITH (NOLOCK)
        INNER JOIN [DeliveryBackOffice].[dbo].[DeliveryProof]  DP WITH (NOLOCK)
            ON DA.Guide_Number = DP.Guide_Number
               AND DA.Guide_Serie = DP.Guide_Serie
    WHERE DA.Guide_Serie = @GuideSerie
          AND DA.Guide_Number = @GuideNumber
          AND DA.Delivered = 1
    ORDER BY DA.Date_Created DESC;

	--Validación del telefono
	IF((@Phone = @Receiver_Phone) OR (@Phone = @CodeArea + @Receiver_Phone) OR (@Phone = '+' + @CodeArea + @Receiver_Phone))
	BEGIN
		SELECT 
			  200						 AS 'IdResult'
			, 'Exitoso.'				 AS 'Message'
			, ISNULL(S.Settlement,'')    AS 'Poblado'
			, IIF(T.TownshipName IS NOT NULL,T.TownshipName,ISNULL(T2.TownshipName,'')) AS 'Municipio'
			, IIF(P.ProvinceName IS NOT NULL,P.ProvinceName,ISNULL(P2.ProvinceName,'')) AS 'Departamento'
			, ISNULL(DO.Receiver_Address,'')											AS 'AddressDestiny'
		FROM DeliveryBackOffice.dbo.DeliveryOrder DO WITH(NOLOCK)
		LEFT JOIN DeliveryBackOffice.dbo.Settlement S WITH(NOLOCK)
			ON DO.ReceiverIdSettlement = S.IdSettlement
		LEFT JOIN DeliveryBackOffice.dbo.Township T WITH(NOLOCK)
			ON S.IdTownship = T.IdTownship
		LEFT JOIN DeliveryBackOffice.dbo.Province P WITH(NOLOCK)
			ON S.IdProvince = P.IdProvince
		LEFT JOIN DeliveryBackOffice.dbo.Township T2 WITH(NOLOCK)
			ON DO.ReceiverIdTownship = T2.IdTownship
		LEFT JOIN DeliveryBackOffice.dbo.Province P2 WITH(NOLOCK)
			ON T2.IdProvince = P2.IdProvince
		WHERE DO.Guide_Serie = @GuideSerie AND DO.Guide_Number = @GuideNumber


		SELECT TOP 1 CASE
                    WHEN dod.StatusOrderId = 5 THEN
                        @GuideDeliveryLatitude
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
                    (
                        SELECT TOP 1
                               Latitude
                        FROM DeliveryAttempt                   dt WITH (NOLOCK)
                            INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
                                ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
                        WHERE dod.Guide_Serie = @GuideSerie
                              AND dod.Guide_Number = @GuideNumber
                              AND dod.DeliveryAttemptId = dt.ID
                              AND dt.Delivered = 0
                              AND
                              (
                                  cfo.IsDenied = 0
                                  OR cfo.IsDenied IS NULL
                              )
                    )
                    ELSE
                        ''
                END                                                                            AS [Latitude],
				CASE
                    WHEN dod.StatusOrderId = 5 THEN
                        @GuideDeliveryLongitude
                    WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
                    (
                        SELECT TOP 1
                               Longitude
                        FROM DeliveryAttempt                   dt WITH (NOLOCK)
                            INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
                                ON dt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
                        WHERE dod.Guide_Serie = @GuideSerie
                              AND dod.Guide_Number = @GuideNumber
                              AND dt.Delivered = 0
                              AND dod.DeliveryAttemptId = dt.ID
                              AND
                              (
                                  cfo.IsDenied = 0
                                  OR cfo.IsDenied IS NULL
                              )
                    )
                    ELSE
                        ''
                END                                                                            AS [Longitude]
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]		dod WITH (NOLOCK)
            INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]		so  WITH (NOLOCK)
                ON [so].[StatusOrderId] = [dod].[StatusOrderId]
            INNER JOIN [dbo].[CatCheckpointType]					CCT WITH (NOLOCK)
                ON [so].[CatCheckpointTypeId] = [CCT].[IdCatCheckpointType]
        WHERE dod.Guide_Serie = @GuideSerie
              AND dod.Guide_Number = @GuideNumber
              AND so.CatStatusTypeId = @ExternalTypeId
		ORDER BY dod.DateCreated DESC


		SELECT CASE
					WHEN dod.StatusOrderId = 5 THEN
						IIF((
								SELECT TOP 1
										Path_Dry
								FROM DeliveryProof WITH (NOLOCK)
								WHERE Guide_Serie = @GuideSerie
										AND Guide_Number = @GuideNumber
							) IS NOT NULL
							, (
								SELECT TOP 1
										Path_Dry
								FROM DeliveryProof WITH (NOLOCK)
								WHERE Guide_Serie = @GuideSerie
										AND Guide_Number = @GuideNumber
							)
							, (
								SELECT TOP 1
										Path_Cold
								FROM DeliveryProof WITH (NOLOCK)
								WHERE Guide_Serie = @GuideSerie
										AND Guide_Number = @GuideNumber
							))
					WHEN dod.StatusOrderId = @StatusIncidentValidated THEN
					(
						SELECT TOP 1
								dlp.Path_Incident
						FROM dbo.DeliveryAttempt               datt WITH (NOLOCK)
							INNER JOIN ConfirmationOfIncidence cfo WITH (NOLOCK)
								ON datt.ConfirmationOfIncidenceId = cfo.IdConfirmationOfIncidence
							INNER JOIN dbo.DeliveryProof       dlp WITH (NOLOCK)
								ON datt.ID_Proof = dlp.ID
						WHERE dod.Guide_Serie = @GuideSerie
								AND dod.Guide_Number = @GuideNumber
								AND dod.DeliveryAttemptId = datt.ID
								AND
								(
									cfo.IsDenied = 0
									OR cfo.IsDenied IS NULL
								)
					)
					ELSE
						NULL
				END                                                                            AS [ImagePath],
				IIF(
                   COI.ValidPhotographicEvidence IS NULL
                   AND dod.StatusOrderId = 50
                 , IIF(IsConfirmed = 1 AND IsDenied = 0 AND dod.StatusOrderId = 50, 1, 0)
                 , IIF(COI.ValidPhotographicEvidence = 1 AND dod.StatusOrderId = 50, 1, 0))		AS [ValidPhotographicEvidence]
		INTO #Temp
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]		dod WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]		so  WITH (NOLOCK)
				ON [so].[StatusOrderId] = [dod].[StatusOrderId]
			INNER JOIN [dbo].[CatCheckpointType]					CCT WITH (NOLOCK)
				ON [so].[CatCheckpointTypeId] = [CCT].[IdCatCheckpointType]
			LEFT JOIN [dbo].[DeliveryAttempt]						da  WITH (NOLOCK)
				ON [dod].[DeliveryAttemptId] = [da].[ID]
			LEFT JOIN [dbo].[ConfirmationOfIncidence]				COI WITH (NOLOCK)
				ON [da].[ConfirmationOfIncidenceId] = [COI].[IdConfirmationOfIncidence]
		WHERE dod.Guide_Serie = @GuideSerie
				AND dod.Guide_Number = @GuideNumber
				AND so.CatStatusTypeId = @ExternalTypeId

		SELECT ImagePath,
			   ValidPhotographicEvidence
		FROM #Temp 
		WHERE ImagePath IS NOT NULL;		

		SELECT so.OrderDescription AS [Status]
		FROM [DeliveryBackOffice].[dbo].[DeliveryOrderDetail]		dod WITH (NOLOCK)
			INNER JOIN [DeliveryBackOffice].[dbo].[StatusOrder]		so  WITH (NOLOCK)
				ON [so].[StatusOrderId] = [dod].[StatusOrderId]
		WHERE dod.Guide_Serie = @GuideSerie
			AND dod.Guide_Number = @GuideNumber
			AND dod.rowstatus = 1
			AND dod.StatusOrderId = 5;

	END
	ELSE
	BEGIN
		SELECT 
		  409 AS 'IdResult'
		, 'El número ingresado no coincide con el registrado para este envío.' AS 'Message'
	END

END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(4000);
    SELECT @ErrorMessage = ERROR_MESSAGE();
    PRINT 'Error: ' + @ErrorMessage;
END CATCH;
END;