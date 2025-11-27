
-- =============================================
-- Author:		<Andres, Ruiz>
-- Create date: <2022-11-30>
-- Description:	< Carga de información para tutoriales y preguntas frecuentes >
-- =============================================
-- =============================================
-- Author:		<Tito Garcia>
-- Update date: <2024-07-10>
-- Description:	<Se Agrega filtro para mostrar el contenido (tutoriales y preguntas frecuentes)  segun el pais del cliente>
-- =============================================
CREATE PROCEDURE [dbo].[spHW_GetContentDataByType]
	@ContentTypeName NVARCHAR(100),
	@CountryId AS NVARCHAR(2) = 'GT'
AS
BEGIN

	-- Datos para pruebas
	--SET @ContentTypeName = 'TutorialesYPreguntasFrecuentes'
	--SET @ContentTypeName = 'ListasColapsadas'

	DECLARE @FilteredContentType TABLE (
		IdContentType BIGINT
	)

	DECLARE @FilteredContentTitle TABLE (
		IdContentTitle BIGINT	
	)

	DECLARE @FilteredContentDescription TABLE (
		IdContentDescription BIGINT
	)

	DECLARE @FilteredContentTags TABLE (
		IdContentTitle BIGINT,
		IdContentDescriptionTag BIGINT
	)

	IF ( @ContentTypeName = 'TutorialesYPreguntasFrecuentes' COLLATE Latin1_General_CI_AI )
	BEGIN

		INSERT INTO @FilteredContentType
			(IdContentType)
		VALUES
			( (SELECT TOP 1 CTC.IdCatTypeContent FROM [DeliveryBackOffice].[dbo].[CatTypeContent] CTC WITH(NOLOCK) WHERE CTC.CatTypeContentName = 'Preguntas frecuentes' COLLATE Latin1_General_CI_AI) )
			, ( (SELECT TOP 1 CTC.IdCatTypeContent FROM [DeliveryBackOffice].[dbo].[CatTypeContent] CTC WITH(NOLOCK) WHERE CTC.CatTypeContentName = 'Tutoriales' COLLATE Latin1_General_CI_AI) )

		-- Titulos de contenido valido
		INSERT INTO @FilteredContentTitle
			(IdContentTitle)
		SELECT CT.IdContentTitle
		FROM [DeliveryBackOffice].[dbo].[ContentTitle] CT WITH(NOLOCK)
			INNER JOIN @FilteredContentType FCT ON CT.TypeContentId = FCT.IdContentType					
		WHERE CT.RowStatus = 1
			AND	CT.CountryId = ISNULL(NULLIF(@CountryId,''), 'GT')
				
		-- Contenido de contenido valido
		INSERT INTO @FilteredContentDescription
			(IdContentDescription)
		SELECT
			CD.IdContentDetail
		FROM
			[DeliveryBackOffice].[dbo].[ContentDetail] CD WITH(NOLOCK)
			INNER JOIN @FilteredContentTitle FCT
				ON CD.ContentTitleId = FCT.IdContentTitle
		WHERE CD.RowStatus = 1

		-- Tags a tomar para titulo
		INSERT INTO @FilteredContentTags
			(IdContentTitle, IdContentDescriptionTag)
		SELECT
			DISTINCT
				FCT.IdContentTitle, CDBT.TagContentId
		FROM
			@FilteredContentTitle FCT
			INNER JOIN
				[DeliveryBackOffice].[dbo].[ContentDetail] CD WITH(NOLOCK)
				ON CD.ContentTitleId = FCT.IdContentTitle
			INNER JOIN
				[DeliveryBackOffice].[dbo].[ContentDetailByTag] CDBT WITH(NOLOCK)
				ON CD.IdContentDetail = CDBT.ContentDetailId
         WHERE CD.RowStatus = 1
           AND CDBT.RowStatus = 1

		IF(EXISTS (SELECT TOP 1 1 FROM @FilteredContentTitle) AND EXISTS (SELECT TOP 1 1 FROM @FilteredContentDescription))
		BEGIN

			SELECT
				200 'ResultCode',
				'Contenido encontrado.' 'ResultMessage'

			SELECT
				CT.IdContentTitle
				,CT.ContentTitle
				,CT.ContentDescription
				,CTC.CatTypeContentName
				,( 
					SELECT STUFF
					(
						( 
							SELECT 
								',' + CTC.CatTagContentName + ''
							FROM
								@FilteredContentTags FCT
								INNER JOIN
									[DeliveryBackOffice].[dbo].[CatTagContent] CTC WITH(NOLOCK)
									ON
										FCT.IdContentDescriptionTag = CTC.IdCatTagContent
							WHERE
								FCT.IdContentTitle = CT.IdContentTitle
							FOR XML PATH(''), TYPE 
						) 
						.value('.', 'varchar(max)'),1,1,'' 
					)
				) 'ContentTags'
			FROM
				[DeliveryBackOffice].[dbo].[ContentTitle] CT WITH(NOLOCK)
				INNER JOIN
					@FilteredContentTitle FCT
					ON
						CT.IdContentTitle = FCT.IdContentTitle
				INNER JOIN
					[DeliveryBackOffice].[dbo].[CatTypeContent] CTC
					ON
						CT.TypeContentId = CTC.IdCatTypeContent

			SELECT
				CD.ContentTitleId
				,CD.IdContentDetail
				,CD.ContentDetailTitle
				,CD.ContentDetailDescription
				,CD.ContentDetailVideoURL
				,CD.ContentDetailImageURL
				,CD.ContentDetailPageURLButton
				,CD.ContentDetailPageURL
				,( 
					SELECT STUFF
					(
						( 
							SELECT 
								',' + CTC.CatTagContentName + ''
							FROM
								[DeliveryBackOffice].[dbo].[ContentDetailByTag] CDBT WITH(NOLOCK)
								INNER JOIN
									[DeliveryBackOffice].[dbo].[CatTagContent] CTC WITH(NOLOCK)
									ON
										CDBT.TagContentId = CTC.IdCatTagContent
							WHERE
								CDBT.ContentDetailId = CD.IdContentDetail
							FOR XML PATH(''), TYPE 
						) 
						.value('.', 'varchar(max)'),1,1,'' 
					)
				) 'ContentTags'
				,ISNULL(CD.IsPageURLExternal, 0) 'IsPageURLExternal'
				,ISNULL(CD.IsVideoURLExternal, 0) 'IsVideoURLExternal'
			FROM
				[DeliveryBackOffice].[dbo].[ContentDetail] CD WITH(NOLOCK)
				INNER JOIN
					@FilteredContentDescription FCD
					ON
						CD.IdContentDetail = FCD.IdContentDescription

		END
		ELSE
		BEGIN

			SELECT
				204 'ResultCode',
				'Sin contenido.' 'ResultMessage'

		END

	END
	ELSE IF ( @ContentTypeName = 'ListasColapsadas' COLLATE Latin1_General_CI_AI )
	BEGIN

		INSERT INTO @FilteredContentType
			(IdContentType)
		VALUES
			( (SELECT TOP 1 CTC.IdCatTypeContent FROM [DeliveryBackOffice].[dbo].[CatTypeContent] CTC WITH(NOLOCK) WHERE CTC.CatTypeContentName = 'Informativo' COLLATE Latin1_General_CI_AI) )
	
		-- Titulos de contenido valido
		INSERT INTO @FilteredContentTitle
			(IdContentTitle)
		SELECT CT.IdContentTitle
		FROM [DeliveryBackOffice].[dbo].[ContentTitle] CT WITH(NOLOCK)
			INNER JOIN @FilteredContentType FCT ON CT.TypeContentId = FCT.IdContentType
		WHERE CT.RowStatus = 1
			AND	CT.CountryId = ISNULL(NULLIF(@CountryId,''), 'GT')
				
		-- Contenido de contenido valido
		INSERT INTO @FilteredContentDescription
			(IdContentDescription)
		SELECT
			CD.IdContentDetail
		FROM
			[DeliveryBackOffice].[dbo].[ContentDetail] CD WITH(NOLOCK)
			INNER JOIN
				@FilteredContentTitle FCT
				ON CD.ContentTitleId = FCT.IdContentTitle
		WHERE CD.RowStatus = 1

		-- Tags a tomar para titulo
		INSERT INTO @FilteredContentTags
			(IdContentTitle, IdContentDescriptionTag)
		SELECT
			DISTINCT
				FCT.IdContentTitle, CDBT.TagContentId
		FROM
			@FilteredContentTitle FCT
			INNER JOIN
				[DeliveryBackOffice].[dbo].[ContentDetail] CD WITH(NOLOCK)
				ON CD.ContentTitleId = FCT.IdContentTitle
			INNER JOIN
				[DeliveryBackOffice].[dbo].[ContentDetailByTag] CDBT WITH(NOLOCK)
				ON CD.IdContentDetail = CDBT.ContentDetailId
        WHERE CD.RowStatus = 1
          AND CDBT.RowStatus = 1

		IF(EXISTS (SELECT TOP 1 1 FROM @FilteredContentTitle) AND EXISTS (SELECT TOP 1 1 FROM @FilteredContentDescription))
		BEGIN

			SELECT
				200 'ResultCode',
				'Contenido encontrado.' 'ResultMessage'

			SELECT
				CT.IdContentTitle
				,CT.ContentTitle
				,CT.ContentDescription
				,CTC.CatTypeContentName
				,( 
					SELECT STUFF
					(
						( 
							SELECT 
								',' + CTC.CatTagContentName + ''
							FROM
								@FilteredContentTags FCT
								INNER JOIN
									[DeliveryBackOffice].[dbo].[CatTagContent] CTC WITH(NOLOCK)
									ON
										FCT.IdContentDescriptionTag = CTC.IdCatTagContent
							WHERE
								FCT.IdContentTitle = CT.IdContentTitle
							FOR XML PATH(''), TYPE 
						) 
						.value('.', 'varchar(max)'),1,1,'' 
					)
				) 'ContentTags'
			FROM
				[DeliveryBackOffice].[dbo].[ContentTitle] CT WITH(NOLOCK)
				INNER JOIN
					@FilteredContentTitle FCT
					ON
						CT.IdContentTitle = FCT.IdContentTitle
				INNER JOIN
					[DeliveryBackOffice].[dbo].[CatTypeContent] CTC
					ON
						CT.TypeContentId = CTC.IdCatTypeContent

			SELECT
				CD.ContentTitleId
				,CD.IdContentDetail
				,CD.ContentDetailTitle
				,CD.ContentDetailDescription
				,CD.ContentDetailVideoURL
				,CD.ContentDetailImageURL
				,CD.ContentDetailPageURLButton
				,CD.ContentDetailPageURL
				,( 
					SELECT STUFF
					(
						( 
							SELECT 
								',' + CTC.CatTagContentName + ''
							FROM
								[DeliveryBackOffice].[dbo].[ContentDetailByTag] CDBT WITH(NOLOCK)
								INNER JOIN
									[DeliveryBackOffice].[dbo].[CatTagContent] CTC WITH(NOLOCK)
									ON
										CDBT.TagContentId = CTC.IdCatTagContent
							WHERE
								CDBT.ContentDetailId = CD.IdContentDetail
							FOR XML PATH(''), TYPE 
						) 
						.value('.', 'varchar(max)'),1,1,'' 
					)
				) 'ContentTags'
				,ISNULL(CD.IsPageURLExternal, 0) 'IsPageURLExternal'
				,ISNULL(CD.IsVideoURLExternal, 0) 'IsVideoURLExternal'
			FROM
				[DeliveryBackOffice].[dbo].[ContentDetail] CD WITH(NOLOCK)
				INNER JOIN
					@FilteredContentDescription FCD
					ON
						CD.IdContentDetail = FCD.IdContentDescription

		END
		ELSE
		BEGIN

			SELECT
				204 'ResultCode',
				'Sin contenido.' 'ResultMessage'

		END

	END
	ELSE
	BEGIN

		SELECT
			404 'ResultCode',
			'Tipo de contenido a buscar no existe.' 'ResultMessage'

	END
END