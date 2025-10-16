-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <Create Date,12/07/2022>
-- Description:	<Description,muestra las membresias y credenciales disponibles con su respectivo detalle>
-- =============================================
-- =============================================
-- Author:		<Edelman Vásquez>
-- Create date: <Create Date,18/07/2023>
-- Description:	<Description,Descripción corta y larga de los beneficios>
-- =============================================
/*
	Actualización: Ordenar atributos de acuerdo a campo AttributePosition - 30-12-2022
	Actualización: Agregar campo de ícono a estructura de membresías y suscripciones - 11-01-2023
	Actualización: Validar rowStatus para atributos - 11-01-2023
	Actualización: Agregar objeto de descripciones para membresías - 20-01-2023
	Autor: Jerson Ochoa
*/
CREATE PROCEDURE [dbo].[SPHWPMembershipOrSubscriptions_TEMP]
    -- Add the parameters for the stored procedure here

    @Type AS NVARCHAR(50),
    --@Token AS NVARCHAR(50),
    @AccountId AS BIGINT = NULL
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    DECLARE @JsonResponse NVARCHAR(MAX) = N'';
    -- Insert statements for procedure here 

    DECLARE @CustomerId INT;
    IF (@AccountId IS NOT NULL)
    BEGIN
        SET @CustomerId =
        (
            SELECT TOP 1
                   Acc.IdCustomer
            FROM [DeliveryBackOffice].[dbo].[Account] Acc WITH (NOLOCK)
            WHERE Acc.AccIdAccount = @AccountId
        );
    END;

    IF (@Type = 'MEMBERSHIP')
    BEGIN
        SET @JsonResponse =
        (
            SELECT STUFF(
                            (
                                SELECT DISTINCT
                                       ',{' + '"Data" : [{' + '"Id":   "' + CAST(CM.IdCatMembership AS VARCHAR),
                                       +'"' + ',' + '"Name": "' + CM.MembershipName,
                                       +'"' + ',' + '"Icon": "' + CM.Icon,
                                       +'"' + ',' + '"Attibutos": ['
                                       +
                                       (
                                           SELECT STUFF(
                                                           (
                                                               SELECT ',' + '{' + '"Id":"'
                                                                      + CAST(CMA.IdCatMembershipAttribute AS VARCHAR)
                                                                      + '"' + ',' + '"Descripcion":"'
                                                                      + CMA.MembershipAttributeDescription + '"' + ','
                                                                      + '"DescripcionLong":"'
                                                                      + ISNULL(
                                                                                  CMA.MembershipAttributeDescriptionLong,
                                                                                  CMA.MembershipAttributeDescription
                                                                              ) + '"' + ',' + '"Valor":"'
                                                                      + CAST(CMA.MembershipAttributeValue AS VARCHAR)
                                                                      + '"' + ',' + '"Posicion":"'
                                                                      + CAST(CMA.MembershipAttributePosition AS VARCHAR)
                                                                      + '"' + '}'
                                                               FROM [dbo].[CatMembershipAttribute] CMA WITH (NOLOCK)
                                                               WHERE CatMembershipId = CM.IdCatMembership
                                                                     AND [CMA].[RowStatus] = 1
                                                               ORDER BY [CMA].[MembershipAttributePosition]
                                                               FOR XML PATH(''), TYPE
                                                           ).value('.', 'varchar(max)'),
                                                           1,
                                                           1,
                                                           ''
                                                       )
                                       ) + ']' + ',' + '"Descriptions":['
                                       + ISNULL(
                                         (
                                             SELECT STUFF(
                                                             (
                                                                 SELECT ','
                                                                        + ISNULL(
                                                                                    '{' + '"Id":"'
                                                                                    + CAST(CMD.IdCatMembershipDescription AS VARCHAR)
                                                                                    + '"' + ',' + '"Título":"' + CMD.Title
                                                                                    + '"' + ',' + '"Descripción":"'
                                                                                    + CAST(CMD.Description AS NVARCHAR(500))
                                                                                    + '"' + ',' + '"Tipo":"'
                                                                                    + CAST(CMD.Type AS VARCHAR) + '"'
                                                                                    + ',' + '"Posición":"'
                                                                                    + CAST(CMD.Position AS VARCHAR) + '"'
                                                                                    + '}',
                                                                                    ''
                                                                                )
                                                                 FROM [dbo].[CatMembershipDescription] CMD
                                                                 WHERE [CMD].[CatMembershipId] = [CM].[IdCatMembership]
                                                                       AND [CMD].[RowStatus] = 1
                                                                 ORDER BY [CMD].[Position],
                                                                          [CMD].[Type]
                                                                 FOR XML PATH(''), TYPE
                                                             ).value('.', 'varchar(max)'),
                                                             1,
                                                             1,
                                                             ''
                                                         )
                                         ),
                                         ''
                                               ) + ']' + ',' + '"Costo":"' + CAST(CM.MembershipCost AS VARCHAR) + '"'
                                       --+ ',' + '"Tiempo de validez":"' + CAST(CM.MembershipValidity AS VARCHAR) + '"'
                                       + ',' + '"ActiveClienteHasSalesPackage":'
                                       + CAST((CASE
                                                   WHEN ISNULL(MMBRSHP.IdMembership, 0) = 0 THEN
                                                       0
                                                   ELSE
                                                       1
                                               END
                                              ) AS VARCHAR) + '}]' + '}'
                                FROM [dbo].[CatMembership] CM WITH (NOLOCK)
                                    INNER JOIN [dbo].[CatMembershipAttribute] CMA WITH (NOLOCK)
                                        ON CM.IdCatMembership = CMA.CatMembershipId
                                    OUTER APPLY
                                (
                                    SELECT TOP 1
                                           MMBRSHP.IdMembership
                                    FROM [dbo].[Membership] MMBRSHP WITH (NOLOCK)
                                    WHERE MMBRSHP.CatMembershipId = CM.IdCatMembership
                                          AND
                                          (
                                              (
                                                  MMBRSHP.AccountId = @AccountId
                                                  AND MMBRSHP.CustomerId = @CustomerId
                                              )
                                              -- En caso no se encuentre el AccoundId registrado en la membresía
                                              OR MMBRSHP.CustomerId = @CustomerId
                                          )
                                          AND MMBRSHP.RowStatus = 1
                                ) MMBRSHP
                                WHERE CM.RowStatus = 1
                                --	ORDER BY CM.IdCatMembership Desc
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

    END;

    IF (@Type = 'Subscription')
    BEGIN
        SET @JsonResponse =
        (
            SELECT STUFF(
                            (
							
                                SELECT DISTINCT
                                       ',{' + '"Data" : [{' + '"Id":   "' + CAST(CS.IdCatSubscription AS VARCHAR),
                                       +'"' + ',' + '"Name": "' + CS.SubscriptionName,
                                       +'"' + ',' + '"Icon": "' + CS.Icon,
									   +'"' + ',' + '"Order": "' + CAST(COALESCE(CS.SubscriptionWeight,0) AS VARCHAR),
                                       +'"' + ',' + '"Attibutos": ['
                                       +
                                       (
                                           SELECT STUFF(
                                                           (
                                                               SELECT ',' + '{' + '"Id":"'
                                                                      + CAST(CSA.IdCatSubscriptionAttribute AS VARCHAR)
                                                                      + '"' + ',' + '"Descripcion":"'
                                                                      + CSA.SubscriptionAttributeDescription + '"' + ','
                                                                      + '"DescripcionLong":"'
                                                                      + ISNULL(
                                                                                  CSA.SubscriptionAttributeDescriptionLong,
                                                                                  CSA.SubscriptionAttributeDescription
                                                                              ) + '"' + ',' + '"Valor":"'
                                                                      + CAST(CSA.SubscriptionAttributeValue AS VARCHAR)
                                                                      + '"' + ',' + '"Posicion":"'
                                                                      + CAST(CSA.SubscriptionAttributePosition AS VARCHAR)
                                                                      + '"' + '}'
                                                               FROM [dbo].[CatSubscriptionAtribute] CSA WITH (NOLOCK)
                                                               WHERE CatSubscriptionId = CS.IdCatSubscription
                                                                     AND [CSA].[RowStatus] = 1
                                                               ORDER BY [CSA].[SubscriptionAttributePosition]
                                                               FOR XML PATH(''), TYPE
                                                           ).value('.', 'varchar(max)'),
                                                           1,
                                                           1,
                                                           ''
                                                       )
                                       ) + ']' + ',' + '"Descriptions":['
                                       + ISNULL(
                                         (
                                             SELECT STUFF(
                                                             (
                                                                 SELECT ','
                                                                        + ISNULL(
                                                                                    '{' + '"Id":"'
                                                                                    + CAST(CSD.IdCatSubscriptionDescription AS VARCHAR)
                                                                                    + '"' + ',' + '"Título":"' + CSD.Title
                                                                                    + '"' + ',' + '"Descripción":"'
                                                                                    + CAST(CSD.Description AS VARCHAR(500))
                                                                                    + '"' + ',' + '"Tipo":"'
                                                                                    + CAST(CSD.Type AS VARCHAR) + '"'
                                                                                    + ',' + '"Posición":"'
                                                                                    + CAST(CSD.Position AS VARCHAR) + '"'
                                                                                    + '}',
                                                                                    ''
                                                                                )
                                                                 FROM [dbo].[CatSubscriptionDescription] CSD
                                                                 WHERE [CSD].[CatSubscriptionId] = [CS].[IdCatSubscription]
                                                                       AND [CSD].[RowStatus] = 1
                                                                 ORDER BY [CSD].[Position],
                                                                          [CSD].[Type]
                                                                 FOR XML PATH(''), TYPE
                                                             ).value('.', 'varchar(max)'),
                                                             1,
                                                             1,
                                                             ''
                                                         )
                                         ),
                                         ''
                                               ) + ']' + ',' + '"Costo":"' + CAST(CS.SubscriptionCost AS VARCHAR) + '"'
                                       + ',' + '"Tiempo de validez":"' + CAST(CS.SubscriptionValidity AS VARCHAR) + '"'
                                       + ',' + '"ActiveClienteHasSalesPackage":'
                                       + CAST((CASE
                                                   WHEN ISNULL(SBSCRPTN.IdSubscription, 0) = 0 THEN
                                                       0
                                                   ELSE
                                                       1
                                               END
                                              ) AS VARCHAR) + '}]' + '}'
                                FROM [dbo].[CatSubscription] CS WITH (NOLOCK)
                                    INNER JOIN [dbo].[CatSubscriptionAtribute] CSA WITH (NOLOCK)
                                        ON CS.IdCatSubscription = CSA.CatSubscriptionId
                                    OUTER APPLY
                                (
                                    SELECT TOP 1
                                           SBSCRPTN.IdSubscription
                                    FROM [dbo].[Subscription] SBSCRPTN WITH (NOLOCK)
                                    WHERE SBSCRPTN.CatSubscriptionId = CS.IdCatSubscription
                                          AND
                                          (
                                              (
                                                  SBSCRPTN.AccountId = @AccountId
                                                  AND SBSCRPTN.CustomerId = @CustomerId
                                              )
                                              -- En caso no se encuentre el AccoundId registrado en la membresía
                                              OR SBSCRPTN.CustomerId = @CustomerId
                                          )
                                          AND SBSCRPTN.RowStatus = 1
                                ) SBSCRPTN
                                WHERE CS.RowStatus = 1
                                      AND
                                      (
                                          (ISNULL(@AccountId, 0) > 0) -- usuario individual
                                          OR (
                                          -- CS.IncludedMembershipId IS NOT NULL
                                          --AND 
                                          ISNULL(@AccountId, 0) = 0
                                             ) -- otros usuarios
                                      )
								
                                

                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

    END;


    IF (@JsonResponse IS NULL OR @JsonResponse = '')
    BEGIN

        SET @JsonResponse =
        (
            SELECT STUFF(
                            (
                                SELECT '{{"IdResult":500,' + '"Message":"No se encontraron registros"}'
                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );
    END;


    SELECT ('[' + @JsonResponse + ']') JsonOutput;
END;