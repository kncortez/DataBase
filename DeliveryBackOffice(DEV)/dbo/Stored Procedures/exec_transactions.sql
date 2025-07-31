
create procedure exec_transactions 
as
begin
	SELECT A1.Codigo
		 , A1.Exc
		 , A1.Mes
		 , SUM(A1.Generadas)  [Generadas]
		 , SUM(A1.Recibidas)  [Recibidas]
		 , SUM(A1.Entregadas) [Entregadas]
		 , SUM(A1.Devueltas)  [Devueltas]
		 , A1.[Iscollect]     [Iscollect]
		 , SUM(A1.Precio)     [Precio]
		 , SUM(A1.COD)        [COD]
		 , SUM(A1.PrecioEntrega) [PrecioEntrega]
		 , SUM(A1.PrecioDevolucion) [PrecioDevolucion]
		 ,A1.Pais
	FROM
	(
		SELECT vp.CodeOfReference                                 [Codigo]
			 , vp.DescriptionOfClient                             [Exc]
			 , CONVERT(DATE, ord.DateCreated)                     [Mes]
			 , COUNT(ord.Guide_Number)                            [Generadas]
			 , 0                                                  [Recibidas]
			 , 0                                                  [Entregadas]
			 , 0                                                  [Devueltas]
			 , ord.IsCollect                                      [Iscollect]
			 , SUM(IIF(ord.IsCollect = 0, ord.PriceShippment, 0)) [Precio]
			 , 0                                                  [COD]
			 , 0 [PrecioEntrega]
			 , 0 [PrecioDevolucion]
			 , ISNULL(vp.CountryId , 'GT') [Pais]
		FROM dbo.VisitPointClient        vp WITH (NOLOCK)
			INNER JOIN dbo.DeliveryOrder ord WITH (NOLOCK)
				ON ord.Sender_ID = vp.CodeOfReference
		WHERE vp.IdKindOfVPBusiness IN(8,21)
			  AND vp.StatusClient = 1
			  AND CONVERT(DATE, ord.DateCreated) >= '2023-01-01'
			  AND ord.StatusOrderId NOT IN ( 7, 15 )
		GROUP BY vp.CodeOfReference
			   , vp.DescriptionOfClient
			   , CONVERT(DATE, ord.DateCreated)
			   , ord.IsCollect
			   ,ISNULL(vp.CountryId , 'GT')
		UNION
		SELECT vp.CodeOfReference
			 , vp.DescriptionOfClient
			 , CONVERT(DATE, dt.DateCreated)
			 , 0                               [Generadas]
			 , COUNT(DISTINCT dt.Guide_Number) [Recibidas]
			 , 0                               [Entregadas]
			 , 0                               [Devueltas]
			 , ord.IsCollect
			 , 0
			 , 0
			 , 0 [PrecioEntrega]
			 , 0 [PrecioDevolucion]
			 , ISNULL(vp.CountryId , 'GT') [Pais]
		FROM dbo.DeliveryOrderDetail        dt WITH (NOLOCK)
			INNER JOIN dbo.DeliveryOrder    ord WITH (NOLOCK)
				ON ord.Guide_Serie = dt.Guide_Serie
				   AND ord.Guide_Number = dt.Guide_Number
			INNER JOIN dbo.TokenLog         tk WITH (NOLOCK)
				ON tk.TknIdToken = dt.UserCreated
			INNER JOIN dbo.RegisterUser     rg WITH (NOLOCK)
				ON rg.UsrIdUser = tk.TknIdUser
			INNER JOIN dbo.VisitPointByUser vup WITH (NOLOCK)
				ON vup.RegisterUserID = rg.UsrIdUser
			INNER JOIN dbo.VisitPointClient vp WITH (NOLOCK)
				ON vp.IdVisitPointClient = vup.IdVisitPointClient
		WHERE CONVERT(DATE, dt.DateCreated) >= '2023-01-01'
			  AND dt.StatusOrderId = 21
		GROUP BY vp.CodeOfReference
			   , vp.DescriptionOfClient
			   , CONVERT(DATE, dt.DateCreated)
			   , ord.IsCollect
			   ,ISNULL(vp.CountryId , 'GT')
		UNION
		SELECT vp.CodeOfReference
			 , vp.DescriptionOfClient
			 , CONVERT(DATE, dt.DateCreated)
			 , 0                               [Generadas]
			 , 0                               [Recibidas]
			 , COUNT(DISTINCT dt.Guide_Number) [Entregadas]
			 , 0                               [Devueltas]
			 , ord.IsCollect
			 , 0
			 , SUM(ord.Collect_OnDelivery)     [COD]
			 , SUM(IIF(ord.IsCollect = 0, ord.PriceShippment, 0)) [PrecioEntrega]
			 , 0 [PrecioDevolucion]
			 , ISNULL(vp.CountryId , 'GT') [Pais]
		FROM dbo.DeliveryOrderDetail        dt WITH (NOLOCK)
			INNER JOIN dbo.DeliveryOrder    ord WITH (NOLOCK)
				ON ord.Guide_Serie = dt.Guide_Serie
				   AND ord.Guide_Number = dt.Guide_Number
			INNER JOIN dbo.TokenLog         tk WITH (NOLOCK)
				ON tk.TknIdToken = dt.UserCreated
			INNER JOIN dbo.RegisterUser     rg WITH (NOLOCK)
				ON rg.UsrIdUser = tk.TknIdUser
			INNER JOIN dbo.VisitPointByUser vup WITH (NOLOCK)
				ON vup.RegisterUserID = rg.UsrIdUser
			INNER JOIN dbo.VisitPointClient vp WITH (NOLOCK)
				ON vp.IdVisitPointClient = vup.IdVisitPointClient
		WHERE CONVERT(DATE, dt.DateCreated) >= '2023-01-01'
			  AND dt.StatusOrderId = 22
		GROUP BY vp.CodeOfReference
			   , vp.DescriptionOfClient
			   , CONVERT(DATE, dt.DateCreated)
			   , ord.IsCollect
			   ,ISNULL(vp.CountryId , 'GT')
		UNION
		SELECT vp.CodeOfReference
			 , vp.DescriptionOfClient
			 , CONVERT(DATE, dt.DateCreated)
			 , 0                               [Generadas]
			 , 0                               [Recibidas]
			 , 0                               [Entregadas]
			 , COUNT(DISTINCT dt.Guide_Number) [Devueltas]
			 , ord.IsCollect
			 , 0
			 , 0
			 , 0 [PrecioEntrega]
			 , SUM(IIF(ord.IsCollect = 0, ord.PriceShippment, 0)) [PrecioDevolucion]
			 , ISNULL(vp.CountryId , 'GT') [Pais]
		FROM dbo.DeliveryOrderDetail        dt WITH (NOLOCK)
			INNER JOIN dbo.DeliveryOrder    ord WITH (NOLOCK)
				ON ord.Guide_Serie = dt.Guide_Serie
				   AND ord.Guide_Number = dt.Guide_Number
			INNER JOIN dbo.TokenLog         tk WITH (NOLOCK)
				ON tk.TknIdToken = dt.UserCreated
			INNER JOIN dbo.RegisterUser     rg WITH (NOLOCK)
				ON rg.UsrIdUser = tk.TknIdUser
			INNER JOIN dbo.VisitPointByUser vup WITH (NOLOCK)
				ON vup.RegisterUserID = rg.UsrIdUser
			INNER JOIN dbo.VisitPointClient vp WITH (NOLOCK)
				ON vp.IdVisitPointClient = vup.IdVisitPointClient
		WHERE CONVERT(DATE, dt.DateCreated) >= '2023-01-01'
			  AND dt.StatusOrderId = 23
		GROUP BY vp.CodeOfReference
			   , vp.DescriptionOfClient
			   , CONVERT(DATE, dt.DateCreated)
			   , ord.IsCollect
			   ,ISNULL(vp.CountryId , 'GT')
	) A1
	GROUP BY A1.Codigo
		   , A1.Exc
		   , A1.Mes
		   , A1.Iscollect
		   , A1.Pais
	ORDER BY A1.Codigo
		   , A1.Mes;

end