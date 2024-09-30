


-- =============================================
-- Author:		 <Cano,Carlos>
-- Create date:  <13/Agosto/2020>
-- Description:	 <Listado de afiliados y su status actual sobre entregas>
-- Modificado:   <López, Marcos>
-- Modified:     <14/Sepiembre/2020>
-- Description:  <Se agregó la columna del total de guías por usuario>
-- Modificado:   <Ixchop,Alberto>
-- Modified:     <25/Enero/2022>
-- Description:  <Se optimizó el sp>
-- =============================================
-- Modificado:   <Pedroza,Brandon>
-- Modified:     <21/Mayo/2024>
-- Description:  <Se agrega parametro que indica país para obtener los hubs de un país>
-- =============================================
CREATE PROCEDURE [dbo].[spg_courier_dispatched_status]
    @DispatchedDate DATE
  , @IsLastMileReturn BIT = NULL
  , @IdCountry NVARCHAR(2) ='GT'

AS
BEGIN
    SET NOCOUNT ON;
    SELECT SR.ID                                                                                     AS ID_Courier
         , SR.First_Name + ' ' + SR.Last_Name                                                        AS Courier_Name
         , ISNULL(HL.HubAbbreviation, ' ')                                                           AS HUB
         , COUNT(DISTINCT Guide_Serie + CONVERT(NVARCHAR, (Guide_Number)))                           AS Cantidad_Guias
         , COUNT(SR.ID)                                                                              AS Dispatched
         , COUNT(   CASE
                        WHEN DATT.Delivered = 1 THEN
                            DATT.Delivered
                        ELSE
                            NULL
                    END
                )                                                                                    AS Delivered
         , COUNT(DATT.Verified)                                                                      AS Verified
         , (SUM(CAST(ISNULL(DATT.Verified, 0) AS INT)) - SUM(CAST(ISNULL(DATT.Accepted, 0) AS INT))) AS Failed
    FROM dbo.DeliveryAttempt         DATT WITH (NOLOCK)
        LEFT JOIN dbo.SenderReceiver SR WITH (NOLOCK)
            ON DATT.ID_Courier = SR.ID
        LEFT JOIN dbo.HubLogistics   HL WITH (NOLOCK)
            ON SR.HubLogisticId = HL.IdHubLogistic
    WHERE CONVERT(DATE, DATT.Date_Created) = @DispatchedDate
          AND
          (
              @IsLastMileReturn IS NULL
              OR ISNULL(DATT.IsLastMileReturn, 0) = @IsLastMileReturn
          )
		  AND HL.IdCountry = @IdCountry
    GROUP BY SR.ID
           , HL.HubAbbreviation
           , SR.First_Name
           , SR.Last_Name
           , HL.IdHubLogistic;
END;
