
-- =============================================
-- Author:		<Andres Ruiz>
-- Create date: <2022-03-11>
-- Description:	< Obtiene información de guías respecto a pagos de CoD pendientes y otros datos >
-- =============================================
CREATE PROCEDURE [dbo].[GetPendingCoDReport]
	@StartDate DATE = NULL,
	@FinishingDate DATE = NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON; 

	SELECT 
		sub.[Creación de Guía],
		CONCAT(sub.[Serie de guía], sub.[Número de guía]) 'Guía',
		sub.[Hub],
		sub.[CoD],
		sub.[Estado],
		sub.[Fecha úlimo estado],
       IIF(sub.CatCheckpointTypeId = 3,
           DATEDIFF(DAY, sub.[Creación de Guía], sub.[Fecha úlimo estado]),
           DATEDIFF(DAY, sub.[Creación de Guía], GETDATE())) 'Dias sin dar finalizado'
		,COALESCE(rug.UsrEmail, tkn.SSN_Username, IIF(sub.[Token] LIKE '%SYS%' COLLATE Latin1_General_CI_AI, 'Sistema',  CONCAT(srv.First_Name, ' ', srv.Last_Name, '[Courierman]'))) 'Responsable de último estado'
	FROM
	(
		SELECT
			--TOP 50
			ord.DateCreated 'Creación de Guía',
			ord.Guide_Serie 'Serie de guía',
			ord.Guide_Number 'Número de guía',
			st.OrderDescription 'Estado',
			dbo.fn_get_hub_destiny(ord.Guide_Serie, ord.Guide_Number) 'Hub',
			ord.Collect_OnDelivery 'CoD',
			st.CatCheckpointTypeId,
			cct.CheckpointTypeDescription 'Tipo de estado',
			(
				SELECT TOP 1
					  ISNULL(dot.DateCreatedInSystem, dot.DateCreated)
				FROM dbo.DeliveryOrderDetail dot WITH (NOLOCK)
				WHERE dot.Guide_Serie = ord.Guide_Serie
					  AND dot.Guide_Number = ord.Guide_Number
					  AND dot.StatusOrderId = ord.StatusOrderId
				ORDER BY dot.DateCreated DESC
			) 'Fecha úlimo estado'
			,(SELECT TOP 1
					  dot.UserCreated
				FROM dbo.DeliveryOrderDetail dot WITH (NOLOCK)
				WHERE dot.Guide_Serie = ord.Guide_Serie
					  AND dot.Guide_Number = ord.Guide_Number
					  AND dot.StatusOrderId = ord.StatusOrderId
				ORDER BY dot.DateCreated DESC
			) 'token'
			--,(
			--    SELECT TOP 1
			--           COALESCE(rgu.UsrEmail, tkd.SSN_Username, CONCAT(srv.First_Name, ' ', srv.Last_Name, '[Courierman]'))
			--    FROM dbo.DeliveryOrderDetail dot WITH (NOLOCK)
			--        LEFT JOIN dbo.TokenLog tkl WITH (NOLOCK)
			--            ON tkl.TknIdToken = dot.UserCreated
			--        LEFT JOIN dbo.LogTokenPOD tkp WITH (NOLOCK)
			--            ON tkp.LogTokenPOD = dot.UserCreated
			--        LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tkd WITH (NOLOCK)
			--            ON tkd.SSN_IdToken = dot.UserCreated
			--        LEFT JOIN dbo.SenderReceiver srv WITH (NOLOCK)
			--            ON srv.ID = tkp.IdCourierman
			--        LEFT JOIN dbo.RegisterUser rgu WITH (NOLOCK)
			--            ON rgu.UsrIdUser = tkl.TknIdUser
			--    WHERE dot.Guide_Serie = ord.Guide_Serie
			--          AND dot.Guide_Number = ord.Guide_Number
			--          AND dot.StatusOrderId = ord.StatusOrderId
			--    ORDER BY dot.DateCreated DESC
			--) 'Usuario'
		FROM dbo.DeliveryOrder ord WITH (NOLOCK)
			LEFT JOIN dbo.DeliveryOrderPaid dp WITH (NOLOCK)
				ON dp.Guide_Serie = ord.Guide_Serie
				   AND dp.Guide_Number = ord.Guide_Number
			LEFT JOIN dbo.StatusOrder st WITH (NOLOCK)
				ON st.StatusOrderId = ord.StatusOrderId
			LEFT JOIN dbo.CatCheckpointType cct
				ON st.CatCheckpointTypeId = cct.IdCatCheckpointType
		WHERE CONVERT(DATE, ord.DateCreated)
			  BETWEEN @StartDate AND @FinishingDate
			  AND ord.Collect_OnDelivery > 0
			  AND ord.StatusOrderId NOT IN ( 1, 15, 7 )
			  AND dp.Guide_Serie IS NULL
	) sub
		LEFT JOIN dbo.TokenLog tkl WITH (NOLOCK) ON tkl.TknIdToken = sub.token
		LEFT JOIN dbo.RegisterUser rug WITH (NOLOCK) ON rug.UsrIdUser = tkl.TknIdUser
		LEFT JOIN DenariusUser_Dev.dbo.LGN_LogByToken tkn WITH (NOLOCK) ON tkn.SSN_IdToken = sub.token AND tkn.SSN_IdSystem = 13
		LEFT JOIN dbo.LogTokenPOD tkp  WITH (NOLOCK) ON tkp.LogTokenPOD = sub.token
		LEFT JOIN dbo.SenderReceiver srv WITH (NOLOCK) ON srv.ID = tkp.IdCourierman
	ORDER BY sub.[Creación de Guía];

END


