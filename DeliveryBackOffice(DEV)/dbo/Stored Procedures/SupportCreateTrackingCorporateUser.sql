CREATE PROCEDURE SupportCreateTrackingCorporateUser

				@CodeOfReference INT,
				@User NVARCHAR(20),
				@Password NVARCHAR(100)


AS
BEGIN
SELECT *
FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
WHERE vpc.CodeOfReference = @CodeOfReference;

DECLARE @VisitpointDenariuas INT;
DECLARE @VPName NVARCHAR(50);
DECLARE @VpEmail NVARCHAR(50);
DECLARE @VpPhone NVARCHAR(30);
DECLARE @FirstName NVARCHAR(50);
DECLARE @LastName NVARCHAR(50);
DECLARE @VpAdress NVARCHAR(100);
DECLARE @CardCode NVARCHAR(15);

SELECT @VisitpointDenariuas = vpc.VisitPointId
     , @VPName              = vpc.DescriptionOfClient
     , @VpEmail             = vpc.Email
     , @VpPhone             = vpc.Phone
     , @FirstName           = vpc.DescriptionOfClient
     , @LastName            = N' '
     , @VpAdress            = vpc.Address
     , @CardCode            = cs.SAPCardCode
FROM DeliveryBackOffice.dbo.VisitPointClient vpc WITH (NOLOCK)
    INNER JOIN dbo.Customer                  cs
        ON cs.IdCustomer = vpc.CustomerID
WHERE vpc.CodeOfReference = @CodeOfReference;


BEGIN TRY
    BEGIN TRANSACTION;
    IF @VisitpointDenariuas IS NULL
    BEGIN

        INSERT INTO DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints
        (
            RVP_RouteCode
          , RVP_ClientBranchName
          , RVP_SAPcardCode
          , RVP_SAPbranchNum
          , RVP_BranchAddress
          , RVP_Country
          , RVP_Station
          , RVP_SafeBox
          , RVP_BillDiv
          , RVP_SafeBoxNum
          , RVP_SafeBoxKeyAmount
          , RVP_BillDivCardCode
          , RVP_Sequence
          , RVP_EstimatedTime
          , RVP_Status
          , RVP_Contact
          , RVP_BranchPhone
          , RVP_BranchVisitDaysPUam
          , RVP_BranchVisitDaysDLam
          , RVP_BranchVisitDaysPUpm
          , RVP_BranchVisitDaysDLpm
          , RVP_BranchVisitDaysPUnight
          , RVP_RouteMondayAM
          , RVP_RouteTuesdayAM
          , RVP_RouteWednesdayAM
          , RVP_RouteThursdayAM
          , RVP_RouteFridayAM
          , RVP_RouteSaturdayAM
          , RVP_RouteSundayAM
          , RVP_RouteMondayPM
          , RVP_RouteTuesdayPM
          , RVP_RouteWednesdayPM
          , RVP_RouteThursdayPM
          , RVP_RouteFridayPM
          , RVP_RouteSaturdayPM
          , RVP_RouteSundayPM
          , RVP_RouteMondayNIGHT
          , RVP_RouteTuesdayNIGHT
          , RVP_RouteWednesdayNIGHT
          , RVP_RouteThursdayNIGHT
          , RVP_RouteFridayNIGHT
          , RVP_RouteSaturdayNIGHT
          , RVP_RouteSundayNIGHT
          , RVP_ZipCode
          , RVP_City
          , RVP_UserSign
          , RVP_LogInstanc
          , RVP_ObjType
          , RVP_LicTradNum
          , RVP_TaxCode
          , RVP_Building
          , RVP_AdresType
          , RVP_Address2
          , RVP_Address3
          , RVP_AddrType
          , RVP_StreetNo
          , RVP_U_CodPrince
          , RVP_U_sarea
          , RVP_U_FactDiv
          , RVP_U_CodSN
          , RVP_U_secuencia
          , RVP_U_sec5
          , RVP_U_sec6
          , RVP_U_sec2
          , RVP_U_sec3
          , RVP_U_sec4
          , RVP_U_xtipo
          , RVP_U_destino
          , RVP_U_giro
          , RVP_U_fechaalta
          , RVP_U_fechabaja
          , RVP_U_cfija
          , RVP_U_cvariable
          , RVP_U_cfijaca
          , RVP_U_cvariablecamb
          , RVP_U_kil1
          , RVP_U_kil2
          , RVP_U_p1
          , RVP_U_cont1
          , RVP_U_ctkilometraje
          , RVP_U_p2
          , RVP_U_p3
          , RVP_U_p4
          , RVP_U_resguardo
          , RVP_U_hora1
          , RVP_U_hora2
          , RVP_U_hora3
          , RVP_U_especial1
          , RVP_U_paquete
          , RVP_U_codigo
          , RVP_U_PremiumI
          , RVP_U_latitud
          , RVP_U_Longitud
          , RVP_Metadata
          , RVP_BranchVisitDaysDLnight
          , RVP_SecNightLV
          , RVP_SecNightSat
          , RVP_SecNightSun
          , RVP_DLTimeAM
          , RVP_DLTimePM
          , RVP_DLTimeNight
          , RVP_BusinessHours
          , RVP_Groupcode
          , RVP_kitCode
          , Rvp_GPS
          , RVP_IsBank
          , RVP_ClientId
          , RVP_SaturdayAM
          , RVP_SaturdayPM
          , RVP_SundayAM
          , RVP_SundayPM
          , RVP_Email
          , RVP_ESINSTRUCTIONS
          , RVP_ClientCostingCode
          , RVP_SAPNewcardCode
          , RVP_SAPNewbranchNum
          , RVP_AgCode
          , rvp_is_Concentration
          , rvp_is_Dotation
          , RVP_Is_CountingHouse
          , RVP_Alone_BillingCode
          , RVP_IVEMount
          , RVP_RelateCode
          , RVP_UTM
          , RVP_IVEFORM
          , rvp_sendfromclient
          , rvp_receiptfromclient
          , rvp_containeddelivery
          , rvp_piece_delivery
          , RVP_clientProject
          , rvp_onDemand
          , rvp_isATM
          , rvp_Masive_con
          , rvp_Mavive_Dot
          , rvp_isReturn
          , RVP_Sector
          , RVP_SaleAdvisor
          , RVP_U_FK_State_Validation
          , RVP_U_AddressVerified
          , RVP_U_WhoAttended
          , RVP_U_JobWhoAttended
          , RVP_U_PlaceToPickUp
          , RVP_U_OtherPlaceToPickup
          , RVP_U_DistanceUmbToPickUp
          , RVP_U_HowIdentifyCarrie
          , RVP_U_HasPhysicalSecurity
          , RVP_U_HasCCTV
          , RVP_U_HasParkingToUMB
          , RVP_U_FK_Supervisor
          , RVP_U_SupervisoryDate
          , RVP_U_FK_AgentAuthorizer
          , RVP_U_DateOk
          , RVP_U_WhereIdentifyCarrie
          , RVP_U_Risk
          , RVP_U_fechaActualizacion
          , updates
          , idIconDevice
          , RVP_Concentradora
          , RVP_Estatal
          , RVP_SinProcesamiento
          , RVP_ProcesamientoDiurno
          , RVP_ProcesamientoNocturno
          , RVP_ATM_ModelId
          , RVP_ATM_SwitchId
          , RVP_ATM_AtmBarCode
          , RVP_ATM_Frecuency
          , RVP_ATM_DispenserType
          , RVP_ATM_ReaderType
          , RVP_ATM_Type
          , RVP_ATM_LocationType
          , RVP_ATM_HasAlarm
          , RVP_ATM_WarrantyMonths
          , RVP_ATM_Serie
          , RVP_ATM_LimitSupply
          , RVP_ATM_InstalationDate
          , RVP_ATM_OSType
          , RVP_ATM_HasAntiSkimming
          , RVP_ATM_HasKeyBoardProtector
          , RVP_ATM_HasTOP
          , RVP_ATM_HasUPS
          , RVP_ATM_CommunicationCompanyProvider
          , RVP_ATM_ElectronicLockType
          , RVP_DateOff
          , RVP_IsCentralBank
          , RVP_Province
          , RVP_Township
          , RVP_WithCustodian
          , RVP_AssignedTransportCompany
          , RVP_CardCodeBankOwner
          , RVP_idCompany
          , RVP_U_TokenCreator
          , RVP_U_TokenUpdater
          , RVP_IsDeliveryOnRoute
          , RVP_StartContract
          , RVP_EndContract
          , RVP_DeliveryNeedsKey
          , RVP_distanceToStation
          , RVP_IsWarehouse
          , RVP_Central
          , RVP_correlativoFactura
        )
        SELECT RVP_RouteCode
             , @VPName
             , RVP_SAPcardCode
             , RVP_SAPbranchNum
             , RVP_BranchAddress
             , 'GT'
             , RVP_Station
             , RVP_SafeBox
             , RVP_BillDiv
             , RVP_SafeBoxNum
             , RVP_SafeBoxKeyAmount
             , RVP_BillDivCardCode
             , RVP_Sequence
             , RVP_EstimatedTime
             , RVP_Status
             , RVP_Contact
             , RVP_BranchPhone
             , RVP_BranchVisitDaysPUam
             , RVP_BranchVisitDaysDLam
             , RVP_BranchVisitDaysPUpm
             , RVP_BranchVisitDaysDLpm
             , RVP_BranchVisitDaysPUnight
             , RVP_RouteMondayAM
             , RVP_RouteTuesdayAM
             , RVP_RouteWednesdayAM
             , RVP_RouteThursdayAM
             , RVP_RouteFridayAM
             , RVP_RouteSaturdayAM
             , RVP_RouteSundayAM
             , RVP_RouteMondayPM
             , RVP_RouteTuesdayPM
             , RVP_RouteWednesdayPM
             , RVP_RouteThursdayPM
             , RVP_RouteFridayPM
             , RVP_RouteSaturdayPM
             , RVP_RouteSundayPM
             , RVP_RouteMondayNIGHT
             , RVP_RouteTuesdayNIGHT
             , RVP_RouteWednesdayNIGHT
             , RVP_RouteThursdayNIGHT
             , RVP_RouteFridayNIGHT
             , RVP_RouteSaturdayNIGHT
             , RVP_RouteSundayNIGHT
             , RVP_ZipCode
             , RVP_City
             , RVP_UserSign
             , RVP_LogInstanc
             , RVP_ObjType
             , RVP_LicTradNum
             , RVP_TaxCode
             , RVP_Building
             , RVP_AdresType
             , RVP_Address2
             , RVP_Address3
             , RVP_AddrType
             , RVP_StreetNo
             , RVP_U_CodPrince
             , RVP_U_sarea
             , RVP_U_FactDiv
             , RVP_U_CodSN
             , RVP_U_secuencia
             , RVP_U_sec5
             , RVP_U_sec6
             , RVP_U_sec2
             , RVP_U_sec3
             , RVP_U_sec4
             , RVP_U_xtipo
             , RVP_U_destino
             , RVP_U_giro
             , RVP_U_fechaalta
             , RVP_U_fechabaja
             , RVP_U_cfija
             , RVP_U_cvariable
             , RVP_U_cfijaca
             , RVP_U_cvariablecamb
             , RVP_U_kil1
             , RVP_U_kil2
             , RVP_U_p1
             , RVP_U_cont1
             , RVP_U_ctkilometraje
             , RVP_U_p2
             , RVP_U_p3
             , RVP_U_p4
             , RVP_U_resguardo
             , RVP_U_hora1
             , RVP_U_hora2
             , RVP_U_hora3
             , RVP_U_especial1
             , RVP_U_paquete
             , RVP_U_codigo
             , RVP_U_PremiumI
             , RVP_U_latitud
             , RVP_U_Longitud
             , RVP_Metadata
             , RVP_BranchVisitDaysDLnight
             , RVP_SecNightLV
             , RVP_SecNightSat
             , RVP_SecNightSun
             , RVP_DLTimeAM
             , RVP_DLTimePM
             , RVP_DLTimeNight
             , RVP_BusinessHours
             , RVP_Groupcode
             , RVP_kitCode
             , Rvp_GPS
             , RVP_IsBank
             , RVP_ClientId
             , RVP_SaturdayAM
             , RVP_SaturdayPM
             , RVP_SundayAM
             , RVP_SundayPM
             , RVP_Email
             , RVP_ESINSTRUCTIONS
             , RVP_ClientCostingCode
             , RVP_SAPNewcardCode
             , RVP_SAPNewbranchNum
             , RVP_AgCode
             , rvp_is_Concentration
             , rvp_is_Dotation
             , RVP_Is_CountingHouse
             , RVP_Alone_BillingCode
             , RVP_IVEMount
             , RVP_RelateCode
             , RVP_UTM
             , RVP_IVEFORM
             , rvp_sendfromclient
             , rvp_receiptfromclient
             , rvp_containeddelivery
             , rvp_piece_delivery
             , RVP_clientProject
             , rvp_onDemand
             , rvp_isATM
             , rvp_Masive_con
             , rvp_Mavive_Dot
             , rvp_isReturn
             , RVP_Sector
             , RVP_SaleAdvisor
             , RVP_U_FK_State_Validation
             , RVP_U_AddressVerified
             , RVP_U_WhoAttended
             , RVP_U_JobWhoAttended
             , RVP_U_PlaceToPickUp
             , RVP_U_OtherPlaceToPickup
             , RVP_U_DistanceUmbToPickUp
             , RVP_U_HowIdentifyCarrie
             , RVP_U_HasPhysicalSecurity
             , RVP_U_HasCCTV
             , RVP_U_HasParkingToUMB
             , RVP_U_FK_Supervisor
             , RVP_U_SupervisoryDate
             , RVP_U_FK_AgentAuthorizer
             , RVP_U_DateOk
             , RVP_U_WhereIdentifyCarrie
             , RVP_U_Risk
             , RVP_U_fechaActualizacion
             , updates
             , idIconDevice
             , RVP_Concentradora
             , RVP_Estatal
             , RVP_SinProcesamiento
             , RVP_ProcesamientoDiurno
             , RVP_ProcesamientoNocturno
             , RVP_ATM_ModelId
             , RVP_ATM_SwitchId
             , RVP_ATM_AtmBarCode
             , RVP_ATM_Frecuency
             , RVP_ATM_DispenserType
             , RVP_ATM_ReaderType
             , RVP_ATM_Type
             , RVP_ATM_LocationType
             , RVP_ATM_HasAlarm
             , RVP_ATM_WarrantyMonths
             , RVP_ATM_Serie
             , RVP_ATM_LimitSupply
             , RVP_ATM_InstalationDate
             , RVP_ATM_OSType
             , RVP_ATM_HasAntiSkimming
             , RVP_ATM_HasKeyBoardProtector
             , RVP_ATM_HasTOP
             , RVP_ATM_HasUPS
             , RVP_ATM_CommunicationCompanyProvider
             , RVP_ATM_ElectronicLockType
             , RVP_DateOff
             , RVP_IsCentralBank
             , RVP_Province
             , RVP_Township
             , RVP_WithCustodian
             , RVP_AssignedTransportCompany
             , RVP_CardCodeBankOwner
             , RVP_idCompany
             , RVP_U_TokenCreator
             , RVP_U_TokenUpdater
             , RVP_IsDeliveryOnRoute
             , RVP_StartContract
             , RVP_EndContract
             , RVP_DeliveryNeedsKey
             , RVP_distanceToStation
             , RVP_IsWarehouse
             , RVP_Central
             , RVP_correlativoFactura
        FROM DenariusDesktop_Dev.dbo.ADM_MNG_RouteVisitPoints
        WHERE RVP_VisitPointId = 145339;


        SET @VisitpointDenariuas = SCOPE_IDENTITY();



        UPDATE dbo.VisitPointClient
        SET VisitPointId = @VisitpointDenariuas
        WHERE CodeOfReference = @CodeOfReference;

        INSERT INTO DenariusWeb_Dev.dbo.[User]
        (
            USR_ShowEULA
          , USR_Jobname
          , USR_ServiceEmail
          , USR_ServicePhone
          , USR_FirstName
          , USR_LastName
          , USR_ClientCardCode
          , USR_BillingAddress
          , USR_BillingPhone
          , USR_BillingRazonSocial
          , USR_BillingNIT
          , USR_BillingTipoNitRcnRut
          , USR_BillingNombreComercial
          , USR_BillingDiadeCorte
          , USR_CollectionEmail
          , USR_CollectionPhone
          , USR_CollectionPhoneExt
          , USR_CollectionLastName
          , USR_CollectionFirstName
          , USR_CollectionAddress
          , USR_VisitPoint
          , USR_EULAAccepted
          , USR_Logo
          , USR_ClientCardCodeCountry
          , USR_CMS_CanAudit
          , USR_DEP_RV_CanChageDateTime
          , USR_BUZ_CanAuditBuzon
          , USR_ClientIdDocument
        )
        VALUES
        (   0                    -- USR_ShowEULA - bit
          , @VPName              -- USR_Jobname - varchar(50)
          , @VpEmail             -- USR_ServiceEmail - varchar(50)
          , @VpPhone             -- USR_ServicePhone - varchar(15)
          , ' '                  -- USR_FirstName - varchar(50)
          , ' '                  -- USR_LastName - varchar(50)
          , NULL                 -- USR_ClientCardCode - varchar(15)
          , NULL                 -- USR_BillingAddress - varchar(300)
          , NULL                 -- USR_BillingPhone - varchar(15)
          , NULL                 -- USR_BillingRazonSocial - varchar(50)
          , NULL                 -- USR_BillingNIT - varchar(10)
          , NULL                 -- USR_BillingTipoNitRcnRut - int
          , NULL                 -- USR_BillingNombreComercial - varchar(50)
          , NULL                 -- USR_BillingDiadeCorte - int
          , NULL                 -- USR_CollectionEmail - varchar(50)
          , NULL                 -- USR_CollectionPhone - varchar(15)
          , NULL                 -- USR_CollectionPhoneExt - varchar(10)
          , ''                   -- USR_CollectionLastName - varchar(50)
          , ''                   -- USR_CollectionFirstName - varchar(50)
          , NULL                 -- USR_CollectionAddress - varchar(300)
          , @VisitpointDenariuas -- USR_VisitPoint - bigint
          , NULL                 -- USR_EULAAccepted - datetime
          , NULL                 -- USR_Logo - varchar(100)
          , ''                   -- USR_ClientCardCodeCountry - varchar(2)
          , DEFAULT              -- USR_CMS_CanAudit - bit
          , NULL                 -- USR_DEP_RV_CanChageDateTime - bit
          , NULL                 -- USR_BUZ_CanAuditBuzon - bit
          , NULL                 -- USR_ClientIdDocument - bigint
            );

        DECLARE @wEBcLIENT INT;

        SET @wEBcLIENT = SCOPE_IDENTITY();


        INSERT INTO DenariusUser_Dev.dbo.LGN_User
        (
            USR_IdUser
          , USR_Username
          , USR_Password
          , USR_RestrictedIp
          , USR_IdEmployee
          , USR_IdWebClient
          , USR_Pin
          , USR_IdSafeClient
          , USR_Email
          , USR_OldPassword
          , USR_PasswordExpiration
          , USR_OldPassword2
          , USR_OldPassword3
          , USR_OldPassword4
          , USR_OldPassword5
          , USR_OldPassword6
          , USR_OldPassword7
          , USR_OldPassword8
          , USR_OldPassword9
          , USR_OldPassword10
          , USR_OldPassword11
          , USR_OldPassword12
          , USR_IdUserTicketSystem
          , USR_IsDepositSupervisor
          , USR_IsATMUser
          , USR_IsATMSupervisor
          , USR_CreationDate
          , USR_CreationToken
          , USR_UpdateDate
          , USR_UpdateToken
          , USR_IsSecurity2T
          , USR_ContextMenuCorporateSupervisor
          , USR_DeviceID
          , USR_RestrictedAddressIp
          , USR_Enable2FA
          , USR_IsCourierMan
        )
        SELECT CONVERT(NVARCHAR(50), @CodeOfReference)
             , @User
             , @Password
             , USR_RestrictedIp
             , USR_IdEmployee
             , @wEBcLIENT
             , USR_Pin
             , USR_IdSafeClient
             , USR_Email
             , USR_OldPassword
             , DATEADD(YEAR, 1, GETDATE())
             , USR_OldPassword2
             , USR_OldPassword3
             , USR_OldPassword4
             , USR_OldPassword5
             , USR_OldPassword6
             , USR_OldPassword7
             , USR_OldPassword8
             , USR_OldPassword9
             , USR_OldPassword10
             , USR_OldPassword11
             , USR_OldPassword12
             , USR_IdUserTicketSystem
             , USR_IsDepositSupervisor
             , USR_IsATMUser
             , USR_IsATMSupervisor
             , GETDATE()
             , USR_CreationToken
             , USR_UpdateDate
             , USR_UpdateToken
             , USR_IsSecurity2T
             , USR_ContextMenuCorporateSupervisor
             , USR_DeviceID
             , USR_RestrictedAddressIp
             , USR_Enable2FA
             , USR_IsCourierMan
        FROM DenariusUser_Dev.dbo.LGN_User
        WHERE USR_IdUser = 291579
              AND USR_Username = 'modinter.sa';


        INSERT INTO DenariusUser_Dev.dbo.LGN_Restriction
        (
            RST_IdUser
          , RST_Username
          , RST_IdSystem
          , RST_AccessRetries
          , RST_Status
          , RST_Retries
          , LGN_CreationDate
          , LGN_CreationToken
          , LGN_OperationDate
          , LGN_OperationToken
        )
        VALUES
        (   CONVERT(NVARCHAR(50), @CodeOfReference) -- RST_IdUser - nvarchar(50)
          , @User                                   -- RST_Username - varchar(50)
          , 12                                      -- RST_IdSystem - int
          , 10                                      -- RST_AccessRetries - int
          , 'ACTIVE'                                -- RST_Status - varchar(10)
          , 0                                       -- RST_Retries - int
          , GETDATE()                               -- LGN_CreationDate - datetime
          , NULL                                    -- LGN_CreationToken - varchar(50)
          , NULL                                    -- LGN_OperationDate - datetime
          , NULL                                    -- LGN_OperationToken - varchar(50)
            );


        INSERT INTO DenariusUser_Dev.dbo.LGN_RolByUserByRegion
        (
            RUR_IdRol
          , RUR_IdUser
          , RUR_IdStation
          , RUR_IdCountry
          , RUR_Username
          , RUR_Status
        )
        SELECT RUR_IdRol
             , CONVERT(NVARCHAR(50), @CodeOfReference)
             , RUR_IdStation
             , RUR_IdCountry
             , @User
             , RUR_Status
        FROM DenariusUser_Dev.dbo.LGN_RolByUserByRegion
        WHERE 1 = 1
              AND RUR_Username IN ( 'modinter.sa' );


        COMMIT TRANSACTION;
    END;
END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    SELECT ERROR_LINE()
         , ERROR_MESSAGE()
         , ERROR_NUMBER();


END CATCH;
END
GO
GRANT VIEW DEFINITION
    ON OBJECT::[dbo].[SupportCreateTrackingCorporateUser] TO [cvaldes]
    AS [dbo];


GO
GRANT EXECUTE
    ON OBJECT::[dbo].[SupportCreateTrackingCorporateUser] TO [ebarrios]
    AS [dbo];


GO
GRANT ALTER
    ON OBJECT::[dbo].[SupportCreateTrackingCorporateUser] TO [cvaldes]
    AS [dbo];

