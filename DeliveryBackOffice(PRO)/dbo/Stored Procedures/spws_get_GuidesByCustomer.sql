-- =============================================
-- Author:		<Michael, Espinoza>
-- Create date: <2021-08-02>
-- Description:	<Devuelve el listado de GUIAS asiganadas a una cuenta usuario Individual>
-- =============================================
CREATE PROCEDURE [dbo].[spws_get_GuidesByCustomer]
    -- Add the parameters for the stored procedure here
    --@StartDate DATETIME,
    --@EndDate DATETIME ,
    @Token VARCHAR(200),
    @Email VARCHAR(50),
    @DPI VARCHAR(50),
    @InitialDate DATE,
    @EndDate DATE

AS

BEGIN

DECLARE @IdAccount INT;
DECLARE @IdUser INT;
DECLARE @jsonResult NVARCHAR(MAX);

IF (@Email='')

BEGIN

SELECT TOP 1 @IdAccount = rub.RuaIdAccount, @IdUser=UsrIdUser FROM dbo.Person 
JOIN dbo.RegisterUser ru ON ru.UsrIdPerson = PerIdPerson
JOIN dbo.RolByUserByAccount rub ON rub.RuaIdUser = UsrIdUser
WHERE PerIdentification= @DPI

END

ELSE

BEGIN

SELECT @IdAccount = rub.RuaIdAccount, @IdUser=UsrIdUser FROM dbo.RegisterUser 
JOIN dbo.RolByUserByAccount rub ON rub.RuaIdUser = UsrIdUser
WHERE UsrEmail = @Email

END

SET @jsonResult =
        (
            SELECT STUFF(
                            (
                                SELECT ',{"Guide":"' + ISNULL(CONCAT(ord.Guide_Serie, ord.Guide_Number), 'N/A') + '",'
                                       + '"RequestDate":"' + ISNULL(CONVERT(VARCHAR, ord.DateCreated, 20), 'N/A')
                                       + '",' + '"Source":"'
                                       + ISNULL(CONCAT(twn.TownshipName, pr.ProvinceAbbreviation), 'N/A') + '",'
                                       + '"Destiny":"'
                                       + ISNULL(CONCAT(twd.TownshipName, prd.ProvinceAbbreviation), 'N/A') + '",'
                                       + '"NameofSender":"'
                                       + ISNULL(
                                                   dbo.fnt_String_Escape((CAST(UPPER(ISNULL(REPLACE(ord.Sender_FirstName,'"',''), '')) AS VARCHAR) + ' '
                                                   + CAST(UPPER(ISNULL(REPLACE(ord.Sender_LastName,'"',''), '')) AS VARCHAR)),'json')
												   ,
                                                   'N/A'
                                               ) + '",' + '"NameReceiver":"'
                                       + ISNULL(
                                                   CAST(UPPER(ISNULL(dbo.fnt_String_Escape(REPLACE(ord.Receiver_FirstName,'"',''),'json'), 'N/A')) AS VARCHAR) + ' '
                                                   + CAST(UPPER(ISNULL(dbo.fnt_String_Escape(REPLACE(ord.Receiver_LastName,'"',''),'json'), '')) AS VARCHAR) ,
                                                   'N/A'
                                               ) + '",' + '"AddresofSender":"'
                                       + ISNULL(
                                                   CAST(UPPER(ISNULL(
                                                                        dbo.fnt_String_Escape(
                                                                                                 REPLACE(ord.Sender_Address,'"',''),
                                                                                                 'json'
                                                                                             ),
                                                                        'N/A'
                                                                    )
                                                             ) AS VARCHAR),
                                                   'N/A'
                                               ) + '",' + '"DateRecoleccion":"'
                                       + ISNULL(CAST(CONVERT(VARCHAR, ord.Preparation_Date, 20) AS VARCHAR), 'N/A')
                                       + '",' + '"DateProgramadaEntrega":"'
                                       + ISNULL(CAST(CONVERT(VARCHAR, ord.Shipping_Date, 20) AS VARCHAR), 'N/A') + '",'
                                       + '"CurrencySymbol":"' + CONVERT(VARCHAR, 'Q.') + '",'
                                       +
                                    --'"GuideNumber":"' + CAST(ord.Guide_Serie AS varchar) +''+ cast(ord.Guide_Number as varchar)  + '",' +
                                    '"PrecioServicio":"'
                                       + CONVERT(VARCHAR, CAST(COALESCE(ord.PriceShippment, '0') AS MONEY), 1) + '",'
                                       + '"CollectOnDelivery":"'
                                       + CONVERT(VARCHAR, CAST(COALESCE(ord.Collect_OnDelivery, '0') AS MONEY), 1)
                                       + '",' + '"ShippmentComplete":'
                                       + CONVERT(VARCHAR, COALESCE(paydord.ShipmentCompleted, 'false')) + ','
                                       + '"IdStatus":' + CONVERT(VARCHAR, COALESCE(sto.StatusOrderId, '0')) + ','
                                       + '"Status":"' + ISNULL(CONVERT(VARCHAR, sto.OrderDescription), 'N/A') + '",'
                                       + '"WayToPay":"'
                                       + IIF(ISNULL(paydord.ShipmentCompleted, 0) = 0,
                                             'PENDIENTE',
                                             (ISNULL(CONVERT(   VARCHAR,
                                                                CASE
                                                                    WHEN paydord.TypeofInOutMoneyId = 1 THEN
                                                                        UPPER(catpay.PayTypeName)
                                                                    WHEN paydord.TypeofInOutMoneyId = 2 THEN
                                                                        UPPER(catpay.PayTypeName)
                                                                    ELSE
                                                                        CASE
                                                                            WHEN ord.IsCollect = 1 THEN
                                                                                'COLLECT'
                                                                            ELSE
                                                                                'CONTADO'
                                                                        END
                                                                END
                                                            ),
                                                     'N/A'
                                                    )
                                             )) + '",' + '"TimePayment":"'
                                       + ISNULL(CONVERT(VARCHAR, paydord.TimePlaId), '') + '",'
                                       + '"TimePaymentDescription":"'
                                       + ISNULL(
                                                   CONVERT(   VARCHAR,
                                                   (
                                                       SELECT TimePlaName
                                                       FROM DeliveryBackOffice.dbo.CatPaymentTime TMD
                                                       WHERE paydord.TimePlaId = TMD.TimePlaId
                                                   )
                                                          ),
                                                   ''
                                               ) + '",' + '"TypePayment":"'
                                       + ISNULL(
                                                   CONVERT(
                                                              VARCHAR,
                                                              CASE
                                                                  WHEN paydord.TypeofInOutMoneyId = 1 THEN
                                                                      UPPER(ctgmon.tio_pk_name)
                                                                  WHEN paydord.TypeofInOutMoneyId = 2 THEN
                                                                      UPPER(ctgmon.tio_pk_name)
                                                                  WHEN paydord.TypeofInOutMoneyId = 3 THEN
                                                                      UPPER(ctgmon.tio_pk_name)
                                                                  WHEN paydord.TypeofInOutMoneyId = 4 THEN
                                                                      UPPER(ctgmon.tio_pk_name)
                                                                  ELSE
                                                                      CASE
                                                                          WHEN ord.IsCollect = 1 THEN
                                                                              'EFECTIVO'
                                                                          ELSE
                                                                              CASE
                                                                                  WHEN
                                                                                  (
                                                                                      SELECT COUNT(*)
                                                                                      FROM Cost C
                                                                                          JOIN CostDetail CD
                                                                                              ON C.IdCost = CD.IdCost
                                                                                                 AND C.RowStatus = 1
                                                                                      WHERE ProductNumber = CONCAT(
                                                                                                                      ord.Guide_Serie,
                                                                                                                      ord.Guide_Number
                                                                                                                  )
                                                                                  ) > 1 THEN
                                                                                      'TARJETA'
                                                                                  WHEN
                                                                                  (
                                                                                      SELECT 1 FROM InternalUser WHERE RegisterUserID = @IdUser
                                                                                  ) = 1 THEN
                                                                                      'EFECTIVO'
                                                                                  ELSE
                                                                                      'TARJETA'
                                                                              END
                                                                      END
                                                              END
                                                          ),
                                                   'N/A'
                                               ) + '",' + '"CollectDelivery":"'
                                       + ISNULL(CONVERT(   VARCHAR,
                                                           CASE
                                                               WHEN ord.IsCollect = 1 THEN
                                                                   'SI'
                                                               ELSE
                                                                   'NO'
                                                           END
                                                       ),
                                                'N/A'
                                               ) + '",' + +'"TypeService":"'
                                       + ISNULL(CAST(ord.TypeService AS VARCHAR), '') + '"}'
                                FROM dbo.DeliveryOrder ord
                                    JOIN dbo.StatusOrder sto
                                        ON sto.StatusOrderId = ord.StatusOrderId
                                    LEFT JOIN [dbo].[DeliveryOrderPaymentDetail] paydord
                                        ON (ord.Guide_Number = paydord.GuideNumber)
                                    LEFT JOIN [dbo].[CatPaymentType] catpay
                                        ON (catpay.PayTypeId = paydord.PayTypeId)
                                    LEFT JOIN [dbo].[CatPaymentTime] cattime
                                        ON (cattime.TimePlaId = paydord.TimePlaId)
                                    LEFT JOIN [dbo].[ctgTypeOfInOutOfMoney] ctgmon
                                        ON (ctgmon.tio_pk_id = paydord.TypeofInOutMoneyId)
                                    --LEFT join dbo.UserAddress addruser on (addruser.UadIdAccount = @IdAccount)
                                    LEFT JOIN dbo.Township twn
                                        ON twn.IdTownship = ord.SenderIdTownship
                                    LEFT JOIN dbo.Province pr
                                        ON pr.IdProvince = twn.IdProvince
                                    LEFT JOIN dbo.Township twd
                                        ON twd.IdTownship = ord.ReceiverIdTownship
                                    LEFT JOIN dbo.Province prd
                                        ON prd.IdProvince = twd.IdProvince
                                --select convert(varchar ,cast(2000 as money),1) from

                                WHERE CONVERT(DATE , ord.DateCreated) BETWEEN @InitialDate AND  @EndDate AND ( ord.Sender_ID IN
                                      (
                                          SELECT ua.CodeOfReference
                                          FROM dbo.RolByUserByAccount rua
                                              INNER JOIN dbo.UserAddress ua
                                                  ON ua.UadIdAccount = rua.RuaIdAccount
                                          WHERE rua.RuaIdAccount = @IdAccount
                                                AND rua.RuaIdUser = @IdUser
                                                AND rua.RuaRowStatus = 1
                                                AND ua.CodeOfReference IS NOT NULL
                                      )
                                      OR
                                      (
                                         ---- ord.Sender_ID = 0
                                          --AND 
										  ord.IdCustomer =
                                          (
                                              SELECT TOP 1 IdCustomer FROM Account WHERE AccIdAccount = @IdAccount
                                          )
                                      ))
                                ORDER BY ord.Guide_Number DESC
                                --	where ord.Sender_ID = 4244
                                --and (ord.DateCreated between @StartDate and @EndDate)
                                --and (@Filter = '-1' or concat(ord.Guide_Serie,ord.Guide_Number)   like '%'+@Filter+ '%'
                                --	or twn.TownshipName like '%'+@Filter+ '%'
                                --	or twd.TownshipName like '%'+@Filter+ '%' )



                                FOR XML PATH(''), TYPE
                            ).value('.', 'varchar(max)'),
                            1,
                            1,
                            ''
                        )
        );

 SELECT ('[' + @jsonResult + ']') jsonResult;
END;
