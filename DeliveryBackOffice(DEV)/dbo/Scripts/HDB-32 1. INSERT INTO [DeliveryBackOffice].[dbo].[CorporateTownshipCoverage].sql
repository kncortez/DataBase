
BEGIN TRANSACTION
BEGIN TRY

	-- Tipo de segmento
	DECLARE @LocTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'LOC' COLLATE Latin1_General_CI_AI)
	DECLARE @MetTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'MET' COLLATE Latin1_General_CI_AI)
	DECLARE @ForTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'FOR' COLLATE Latin1_General_CI_AI)
	DECLARE @EspTypeId INT = (SELECT TOP 1 CRS.CrsId FROM [DeliveryBackOffice].[dbo].[CatRateSegment] CRS WITH(NOLOCK) WHERE CRS.CrsShortName = 'ESP' COLLATE Latin1_General_CI_AI)

	-- CABECERAS /// METROPOLITANO
	-- TODA CABECERA
	-- Tarifa normal
	INSERT INTO [DeliveryBackOffice].[dbo].[CorporateTownshipCoverage]
		(TownshipSourceId, TownshipDestinyId, SegmentTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT
		TwnOrig.IdTownship
		,TwnDest.IdTownship
		,@MetTypeId
		,1
		,'SYS-ARUIZ'
		,GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[Township] TwnOrig WITH(NOLOCK)
		CROSS JOIN
			(
				SELECT
					TwnDest.IdTownship
				FROM
					[DeliveryBackOffice].[dbo].[Township] TwnDest WITH(NOLOCK)
					INNER JOIN
						[DeliveryBackOffice].[dbo].[Province] Prov WITH(NOLOCK)
						ON
							TwnDest.IdProvince = Prov.IdProvince
							AND
							TwnDest.HeaderCode = CONCAT(Prov.LocalCode, '01')
			) TwnDest
	WHERE
		TwnOrig.IdTownship != TwnDest.IdTownship
		AND
		NOT EXISTS(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[CorporateTownshipCoverage] RTCCheck WITH(NOLOCK)
			WHERE
				RTCCheck.TownshipSourceId = TwnOrig.IdTownship
				AND
				RTCCheck.TownshipDestinyId = TwnDest.IdTownship
				AND
				RTCCheck.RowStatus = 1
		)

	-- ESPECIAL
	DECLARE @EspecialDestination AS TABLE (
		IdTownship INT
	);
	INSERT INTO @EspecialDestination
		(IdTownship)
	SELECT
		IdTownship
	FROM
		[DeliveryBackOffice].[dbo].[Township] Twn WITH(NOLOCK)
	WHERE
		Twn.TownshipName COLLATE Latin1_General_CI_AI IN (
			'Aguacatán',
			'Alotenango', --- NO ESTA
			'Cabricán',
			'Canillá',
			'Catarina',
			'Chahal',
			'Chajul',
			'Champerico',
			'Chicamán',
			'Chinique',
			'Chisec',
			'Chuarrancho',
			'Colotenango',
			'Comitancillo',
			'Concepción Huista',
			'Concepción Tutuapa',
			'Cubulco',
			'Cuilco',
			'Cunén',
			'Dolores',
			'El Estor',
			'El Quetzal',
			'Esquipulas Palo Gordo',
			'Fray Bartolomé de las Casas',
			'Granados',
			'Guanagazapa',
			'Ixcán',
			'Ixchiguán',
			'Jacaltenango',
			'Jalpatagua',
			'La Blanca',
			'La Democracia Huehuetenango',
			'La Libertad Huehuetenango', 
			'La Reforma',
			'La Tinta', --- NO ESTA
			'La Unión',
			'Las Cruces',
			'Livingston',
			'Malacatancito',
			'Mataquescuintla',
			'Melchor de Mencos',
			'Morazán',
			'Moyuta',
			'Nahualá',
			'Nebaj',
			'Nentón',
			'Nuevo Progreso',
			'Nuevo San Carlos',
			'Ocós',
			'Olintepeque',
			'Pachalum',
			'Panzós',
			'Pastores',
			'Purulhá',
			'Rabinal',
			'Raxruhá',
			'Sacapulas',
			'Samayac',
			'San Andrés Sajcabajá',
			'San Andrés Xecul',
			'San Antonio Aguas Calientes',
			'San Antonio Huista',
			'San Antonio Palopó',
			'San Carlos Alzatate',
			'San Carlos Sija',
			'San Cristóbal Cucho',
			'San Francisco',
			'San Gaspar Ixchil',
			'San Ildefonso Ixtaguacán',
			'San Jose Acatempa',
			'San Jose Ojetenam',
			'San Jose Poaquil',
			'San Juan Atitán',
			'San Juan Cotzal',
			'San Juan Ixcoy',
			'San Juan La Laguna',
			'San Lorenzo',
			'San Marcos',
			'San Lucas Tolimán',
			'San Marcos La Laguna',
			'San Martín Jilotepeque',
			'San Mateo Ixtatán',
			'San Miguel Acatán',
			'San Miguel Dueñas',
			'San Miguel Ixtahuacán',
			'San Miguel Sigüilá',
			'San Pablo',
			'San Pablo La Laguna',
			'San Pedro La Laguna',
			'San Pedro Necta',
			'San Pedro Pinula',
			'San Pedro Soloma',
			'San Rafael Pétzal',
			'San Rafael Pie de la Cuesta',
			'San Raymundo',
			'San Sebastián Coatán',
			'Santa Ana Huista',
			'Santa Apolonia',
			'Santa Bárbara Huehuetenango',
			'Santa Catarina Ixtahuacán',
			'Santa Catarina Palopó',
			'Santa Clara La Laguna',
			'Santa Cruz Barillas',
			'Santa Cruz el Chol',
			'Santa Eulalia',
			'Santa Lucía Utatlán',
			'Santa María Cahabón',
			'Santa María Chiquimula',
			'Santiago Atitlán',
			'Santiago Chimaltenango',
			'Santo Domingo Suchitepéquez',
			'Santo Domingo Xenacoj',
			'Santo Tomás La Unión',
			'Sayaxché',
			'Senahú',
			'Sipacapa',
			'Tacaná',
			'Tajumulco',
			'Tamahú',
			'Tectitán',
			'Tejutla',
			'Todos Santos Cuchumatán', -- NO ESTA
			'Tucurú',
			'Unión Cantinil',
			'Uspantán',
			'Yupiltepeque'
		)
	ORDER BY
		Twn.TownshipName ASC
		
	-- Tarifa normal
	INSERT INTO [DeliveryBackOffice].[dbo].[CorporateTownshipCoverage]
		(TownshipSourceId, TownshipDestinyId, SegmentTypeId, RowStatus, TokenCreated, DateCreated)
	SELECT
		TwnOrig.IdTownship
		,TwnDest.IdTownship
		,@EspTypeId
		,1
		,'SYS-ARUIZ'
		,GETDATE()
	FROM
		[DeliveryBackOffice].[dbo].[Township] TwnOrig WITH(NOLOCK)
		CROSS JOIN
			@EspecialDestination TwnDest
	WHERE
		TwnOrig.IdTownship != TwnDest.IdTownship
		AND
		NOT EXISTS(
			SELECT
				TOP 1
					1
			FROM
				[DeliveryBackOffice].[dbo].[CorporateTownshipCoverage] RTCCheck WITH(NOLOCK)
			WHERE
				RTCCheck.TownshipSourceId = TwnOrig.IdTownship
				AND
				RTCCheck.TownshipDestinyId = TwnDest.IdTownship
				AND
				RTCCheck.RowStatus = 1
		)

	--;THROW 50005, '', 1;

	COMMIT TRANSACTION;

	SELECT
		1 [blnResult]

END TRY
BEGIN CATCH

	ROLLBACK TRANSACTION;

	SELECT
		0 [blnResult]

END CATCH