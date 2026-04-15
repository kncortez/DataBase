/* =========================================================================================
   Script:    Insert_CustomerTownshipMapping_SV.sql
   Propósito: Carga masiva de mapeo de municipios para El Salvador usando CodeOfReference.
   Autor:     Tito García
   Fecha:     2026-04-15
========================================================================================= */
BEGIN TRY
    BEGIN TRANSACTION;

    -- ==========================================
    -- 1. VARIABLES DEL ENTORNO
    -- ==========================================
    DECLARE @CodeOfReference INT = 2664085;
    DECLARE @CountryId NVARCHAR(5) = 'SV';
    DECLARE @Token NVARCHAR(50) = 'SYS-TGARCIA';

    -- ==========================================
    -- 2. CREACIÓN DE TABLA TEMPORAL
    -- ==========================================
    IF OBJECT_ID('tempdb..#TempTownshipMapping') IS NOT NULL
        DROP TABLE #TempTownshipMapping;

    CREATE TABLE #TempTownshipMapping (
        HeaderCode NVARCHAR(50),
        ExternalTownshipId NVARCHAR(200),
        ExternalTownshipName NVARCHAR(200),
        ExternalProvinceId NVARCHAR(200),
        ExternalProvinceName NVARCHAR(200)
    );

    -- ==========================================
    -- 3. LLENADO EN MEMORIA
    -- ==========================================
    INSERT INTO #TempTownshipMapping (HeaderCode, ExternalTownshipId, ExternalTownshipName, ExternalProvinceId, ExternalProvinceName) VALUES
        ('S0101', '61000000000031', 'Ahuachapán', '61000000000005', 'Ahuachapan'),
        ('S0102', '61000000000228', 'Apaneca', '61000000000005', 'Ahuachapan'),
        ('S0103', '61000000000120', 'Atiquizaya', '61000000000005', 'Ahuachapan'),
        ('S0104', '61000000000151', 'Concepción De Ataco', '61000000000005', 'Ahuachapan'),
        ('S0106', '61000000000062', 'Guaymango', '61000000000005', 'Ahuachapan'),
        ('S0107', '61000000000206', 'Jujutla', '61000000000005', 'Ahuachapan'),
        ('S0108', '61000000000256', 'San Francisco Menéndez', '61000000000005', 'Ahuachapan'),
        ('S0109', '61000000000030', 'San Lorenzo', '61000000000005', 'Ahuachapan'),
        ('S0110', '61000000000021', 'San Pedro Puxtla', '61000000000005', 'Ahuachapan'),
        ('S0111', '61000000000085', 'Tacuba', '61000000000005', 'Ahuachapan'),
        ('S0112', '61000000000231', 'Turín', '61000000000005', 'Ahuachapan'),
        ('S0901', '61000000000191', 'Cinquera', '61000000000005', 'Cabañas'),
        ('S0909', '61000000000056', 'Dolores', '61000000000005', 'Cabañas'),
        ('S0902', '61000000000168', 'Guacotecti', '61000000000005', 'Cabañas'),
        ('S0903', '61000000000259', 'Ilobasco', '61000000000005', 'Cabañas'),
        ('S0904', '61000000000160', 'Jutiapa', '61000000000005', 'Cabañas'),
        ('S0905', '61000000000135', 'San Isidro', '61000000000005', 'Cabañas'),
        ('S0906', '61000000000242', 'Sensuntepeque', '61000000000005', 'Cabañas'),
        ('S0907', '61000000000089', 'Tejutepeque', '61000000000005', 'Cabañas'),
        ('S0908', '61000000000077', 'Victoria', '61000000000025', 'Cabañas'),
        ('S0401', '61000000000220', 'Agua Caliente', '61000000000025', 'Chalatenango'),
        ('S0402', '61000000000274', 'Arcatao', '61000000000025', 'Chalatenango'),
        ('S0403', '61000000000149', 'Azacualpa', '61000000000025', 'Chalatenango'),
        ('S0407', '61000000000205', 'Chalatenango', '61000000000025', 'Chalatenango'),
        ('S0404', '61000000000181', 'Citalá', '61000000000025', 'Chalatenango'),
        ('S0405', '61000000000027', 'Comalapa', '61000000000025', 'Chalatenango'),
        ('S0406', '61000000000048', 'Concepción Quezaltepeque', '61000000000025', 'Chalatenango'),
        ('S0408', '61000000000161', 'Dulce Nombre De María', '61000000000025', 'Chalatenango'),
        ('S0409', '61000000000223', 'El Carrizal', '61000000000025', 'Chalatenango'),
        ('S0410', '61000000000012', 'El Paraíso', '61000000000025', 'Chalatenango'),
        ('S0411', '61000000000187', 'La Laguna', '61000000000025', 'Chalatenango'),
        ('S0412', '61000000000137', 'La Palma', '61000000000025', 'Chalatenango'),
        ('S0413', '61000000000174', 'La Reina', '61000000000025', 'Chalatenango'),
        ('S0414', '61000000000192', 'Las Vueltas', '61000000000025', 'Chalatenango'),
        ('S0415', '61000000000019', 'Nombre De Jesús', '61000000000025', 'Chalatenango'),
        ('S0416', '61000000000104', 'Nueva Concepción', '61000000000025', 'Chalatenango'),
        ('S0417', '61000000000128', 'Nueva Trinidad', '61000000000025', 'Chalatenango'),
        ('S0418', '61000000000111', 'Ojos De Agua', '61000000000025', 'Chalatenango'),
        ('S0419', '61000000000209', 'Potonico', '61000000000025', 'Chalatenango'),
        ('S0420', '61000000000140', 'San Antonio De La Cruz', '61000000000025', 'Chalatenango'),
        ('S0421', '61000000000172', 'San Antonio Los Ranchos', '61000000000025', 'Chalatenango'),
        ('S0422', '61000000000197', 'San Fernando', '61000000000035', 'Chalatenango'),
        ('S0423', '61000000000212', 'San Francisco Lempa', '61000000000035', 'Chalatenango'),
        ('S0424', '61000000000249', 'San Francisco Morazán', '61000000000035', 'Chalatenango'),
        ('S0425', '61000000000041', 'San Ignacio', '61000000000035', 'Chalatenango'),
        ('S0426', '61000000000098', 'San Isidro Labrador', '61000000000035', 'Chalatenango'),
        ('S0435', '61000000000208', 'San José Cancasque', '61000000000035', 'Chalatenango'),
        ('S0434', '61000000000159', 'San José Las Flores', '61000000000035', 'Chalatenango'),
        ('S0429', '61000000000066', 'San Luis Del Carmen', '61000000000035', 'Chalatenango'),
        ('S0430', '61000000000058', 'San Miguel De Mercedes', '61000000000035', 'Chalatenango'),
        ('S0431', '61000000000217', 'San Rafael', '61000000000035', 'Chalatenango'),
        ('S0432', '61000000000138', 'Santa Rita', '61000000000035', 'Chalatenango'),
        ('S0433', '61000000000183', 'Tejutla', '61000000000035', 'Chalatenango'),
        ('S0701', '61000000000131', 'Candelaria', '61000000000035', 'Cuscatlan'),
        ('S0702', '61000000000043', 'Cojutepeque', '61000000000035', 'Cuscatlan'),
        ('S0703', '61000000000218', 'El Carmen', '61000000000035', 'Cuscatlan'),
        ('S0704', '61000000000002', 'El Rosario', '61000000000035', 'Cuscatlan'),
        ('S0705', '61000000000243', 'Monte San Juan', '61000000000035', 'Cuscatlan'),
        ('S0706', '61000000000176', 'Oratorio De Concepción', '61000000000035', 'Cuscatlan'),
        ('S0707', '61000000000018', 'San Bartolomé Perulapía', '61000000000003', 'Cuscatlan'),
        ('S0708', '61000000000269', 'San Cristóbal', '61000000000003', 'Cuscatlan'),
        ('S0709', '61000000000096', 'San José Guayabal', '61000000000003', 'Cuscatlan'),
        ('S0716', '61000000000188', 'San Pedro Perulapán', '61000000000003', 'Cuscatlan'),
        ('S0711', '61000000000037', 'San Rafael Cedros', '61000000000003', 'Cuscatlan'),
        ('S0712', '61000000000052', 'San Ramón', '61000000000003', 'Cuscatlan'),
        ('S0713', '61000000000235', 'Santa Cruz Analquito', '61000000000003', 'Cuscatlan'),
        ('S0714', '61000000000010', 'Santa Cruz Michapa', '61000000000003', 'Cuscatlan'),
        ('S0715', '61000000000166', 'Suchitoto', '61000000000003', 'Cuscatlan'),
        ('S0716', '61000000000173', 'Tenancingo', '61000000000003', 'Cuscatlan'),
        ('S0501', '61000000000238', 'Antiguo Cuscatlán', '61000000000003', 'La Libertad'),
        ('S0505', '61000000000145', 'Chiltiupán', '61000000000003', 'La Libertad'),
        ('S0502', '61000000000059', 'Ciudad Arce', '61000000000003', 'La Libertad'),
        ('S0503', '61000000000155', 'Colon', '61000000000003', 'La Libertad'),
        ('S0504', '61000000000039', 'Comasagua', '61000000000003', 'La Libertad'),
        ('S0506', '61000000000078', 'Huizúcar', '61000000000003', 'La Libertad'),
        ('S0507', '61000000000195', 'Jayaque', '61000000000003', 'La Libertad'),
        ('S0508', '61000000000022', 'Jicalapa', '61000000000003', 'La Libertad'),
        ('S0509', '61000000000063', 'La Libertad', '61000000000003', 'La Libertad'),
        ('S0510', '61000000000132', 'Nuevo Cuscatlán', '61000000000003', 'La Libertad'),
        ('S0512', '61000000000152', 'Quezaltepeque', '61000000000003', 'La Libertad'),
        ('S0513', '61000000000024', 'Sacacoyo', '61000000000003', 'La Libertad'),
        ('S0514', '61000000000121', 'San José Villanueva', '61000000000003', 'La Libertad'),
        ('S0515', '61000000000006', 'San Juan Opico', '61000000000003', 'La Libertad'),
        ('S0516', '61000000000124', 'San Matías', '61000000000003', 'La Libertad'),
        ('S0517', '61000000000029', 'San Pablo Tacachico', '61000000000003', 'La Libertad'),
        ('S0523', '61000000000215', 'Santa Tecla', '61000000000007', 'La Libertad'),
        ('S0519', '61000000000153', 'Talnique', '61000000000007', 'La Libertad'),
        ('S0518', '61000000000106', 'Tamanique', '61000000000007', 'La Libertad'),
        ('S0520', '61000000000093', 'Teotepeque', '61000000000007', 'La Libertad'),
        ('S0521', '61000000000065', 'Tepecoyo', '61000000000007', 'La Libertad'),
        ('S0522', '61000000000200', 'Zaragoza', '61000000000007', 'La Libertad'),
        ('S0801', '61000000000213', 'Cuyultitán', '61000000000007', 'La Paz'),
        ('S0802', '61000000000026', 'El Rosario', '61000000000007', 'La Paz'),
        ('S0803', '61000000000224', 'Jerusalén', '61000000000007', 'La Paz'),
        ('S0804', '61000000000240', 'Mercedes La Ceiba', '61000000000007', 'La Paz'),
        ('S0805', '61000000000071', 'Olocuilta', '61000000000007', 'La Paz'),
        ('S0806', '61000000000201', 'Paraíso De Osorio', '61000000000007', 'La Paz'),
        ('S0807', '61000000000264', 'San Antonio Masahuat', '61000000000007', 'La Paz'),
        ('S0808', '61000000000239', 'San Emigdio', '61000000000007', 'La Paz'),
        ('S0809', '61000000000115', 'San Francisco Chinameca', '61000000000007', 'La Paz'),
        ('S0810', '61000000000127', 'San Juan Nonualco', '61000000000007', 'La Paz'),
        ('S0811', '61000000000141', 'San Juan Talpa', '61000000000007', 'La Paz'),
        ('S0812', '61000000000241', 'San Juan Tepezontes', '61000000000007', 'La Paz'),
        ('S0822', '61000000000118', 'San Luis La Herradura', '61000000000007', 'La Paz'),
        ('S0813', '61000000000210', 'San Luis Talpa', '61000000000007', 'La Paz'),
        ('S0814', '61000000000122', 'San Miguel Tepezontes', '61000000000033', 'La Paz'),
        ('S0815', '61000000000057', 'San Pedro Masahuat', '61000000000033', 'La Paz'),
        ('S0816', '61000000000101', 'San Pedro Nonualco', '61000000000033', 'La Paz'),
        ('S0817', '61000000000253', 'San Rafael Obrajuelo', '61000000000033', 'La Paz'),
        ('S0818', '61000000000049', 'Santa María Ostuma', '61000000000033', 'La Paz'),
        ('S0819', '61000000000169', 'Santiago Nonualco', '61000000000033', 'La Paz'),
        ('S0820', '61000000000129', 'Tapalhuaca', '61000000000033', 'La Paz'),
        ('S0821', '61000000000236', 'Zacatecoluca', '61000000000033', 'La Paz'),
        ('S1401', '61000000000146', 'Anamorós', '61000000000033', 'La Union'),
        ('S1402', '61000000000203', 'Bolivar', '61000000000033', 'La Union'),
        ('S1403', '61000000000248', 'Concepción De Oriente', '61000000000033', 'La Union'),
        ('S1404', '61000000000133', 'Conchagua', '61000000000033', 'La Union'),
        ('S1405', '61000000000263', 'El Carmen', '61000000000033', 'La Union'),
        ('S1406', '61000000000102', 'El Sauce', '61000000000033', 'La Union'),
        ('S1407', '61000000000260', 'Intipucá', '61000000000033', 'La Union'),
        ('S1408', '61000000000230', 'La Unión', '61000000000033', 'La Union'),
        ('S1409', '61000000000144', 'Lislique', '61000000000033', 'La Union'),
        ('S1410', '61000000000036', 'Meanguera Del Golfo', '61000000000033', 'La Union'),
        ('S1411', '61000000000086', 'Nueva Esparta', '61000000000033', 'La Union'),
        ('S1412', '61000000000038', 'Pasaquina', '61000000000013', 'La Union'),
        ('S1413', '61000000000060', 'Polorós', '61000000000013', 'La Union'),
        ('S1414', '61000000000080', 'San Alejo', '61000000000013', 'La Union'),
        ('S1415', '61000000000099', 'San José De La Fuente', '61000000000013', 'La Union'),
        ('S1416', '61000000000234', 'Santa Rosa De Lima', '61000000000013', 'La Union'),
        ('S1417', '61000000000170', 'Yayantique', '61000000000013', 'La Union'),
        ('S1418', '61000000000257', 'Yucuaiquín', '61000000000013', 'La Union'),
        ('S1301', '61000000000088', 'Arambala', '61000000000013', 'Morazan'),
        ('S1302', '61000000000108', 'Cacaopera', '61000000000013', 'Morazan'),
        ('S1304', '61000000000265', 'Chilanga', '61000000000013', 'Morazan'),
        ('S1303', '61000000000139', 'Corinto', '61000000000013', 'Morazan'),
        ('S1305', '61000000000072', 'Delicias De Concepción', '61000000000013', 'Morazan'),
        ('S1306', '61000000000023', 'El Divisadero', '61000000000013', 'Morazan'),
        ('S1307', '61000000000261', 'El Rosario', '61000000000044', 'Morazan'),
        ('S1308', '61000000000009', 'Gualococti', '61000000000044', 'Morazan'),
        ('S1309', '61000000000028', 'Guatajiagua', '61000000000044', 'Morazan'),
        ('S1310', '61000000000054', 'Joateca', '61000000000044', 'Morazan'),
        ('S1311', '61000000000171', 'Jocoaitique', '61000000000044', 'Morazan'),
        ('S1312', '61000000000193', 'Jocoro', '61000000000044', 'Morazan'),
        ('S1313', '61000000000116', 'Lolotiquillo', '61000000000044', 'Morazan'),
        ('S1314', '61000000000198', 'Meanguera', '61000000000044', 'Morazan'),
        ('S1315', '61000000000180', 'Osicala', '61000000000044', 'Morazan'),
        ('S1316', '61000000000069', 'Perquín', '61000000000044', 'Morazan'),
        ('S1317', '61000000000273', 'San Carlos', '61000000000044', 'Morazan'),
        ('S1318', '61000000000094', 'San Fernando', '61000000000044', 'Morazan'),
        ('S1319', '61000000000154', 'San Francisco Gotera', '61000000000044', 'Morazan'),
        ('S1320', '61000000000074', 'San Isidro', '61000000000016', 'Morazan'),
        ('S1321', '61000000000004', 'San Simón', '61000000000016', 'Morazan'),
        ('S1322', '61000000000222', 'Sensembra', '61000000000016', 'Morazan'),
        ('S1323', '61000000000254', 'Sociedad', '61000000000016', 'Morazan'),
        ('S1324', '61000000000182', 'Torola', '61000000000016', 'Morazan'),
        ('S1325', '61000000000226', 'Yamabal', '61000000000016', 'Morazan'),
        ('S1326', '61000000000177', 'Yoloaiquín', '61000000000016', 'Morazan'),
        ('S1201', '61000000000075', 'Carolina', '61000000000016', 'San Miguel'),
        ('S1204', '61000000000252', 'Chapeltique', '61000000000016', 'San Miguel'),
        ('S1205', '61000000000110', 'Chinameca', '61000000000016', 'San Miguel'),
        ('S1206', '61000000000095', 'Chirilagua', '61000000000016', 'San Miguel'),
        ('S1202', '61000000000119', 'Ciudad Barrios', '61000000000016', 'San Miguel'),
        ('S1203', '61000000000123', 'Comacarán', '61000000000016', 'San Miguel'),
        ('S1207', '61000000000262', 'El Tránsito', '61000000000016', 'San Miguel'),
        ('S1208', '61000000000008', 'Lolotique', '61000000000016', 'San Miguel'),
        ('S1209', '61000000000100', 'Moncagua', '61000000000016', 'San Miguel'),
        ('S1210', '61000000000251', 'Nueva Guadalupe', '61000000000050', 'San Miguel'),
        ('S1211', '61000000000245', 'Nuevo Edén De San Juan', '61000000000050', 'San Miguel'),
        ('S1212', '61000000000015', 'Quelepa', '61000000000050', 'San Miguel'),
        ('S1213', '61000000000150', 'San Antonio Del Mosco', '61000000000050', 'San Miguel'),
        ('S1214', '61000000000143', 'San Gerardo', '61000000000050', 'San Miguel'),
        ('S1215', '61000000000126', 'San Jorge', '61000000000050', 'San Miguel'),
        ('S1216', '61000000000164', 'San Luis De La Reina', '61000000000050', 'San Miguel'),
        ('S1217', '61000000000042', 'San Miguel', '61000000000050', 'San Miguel'),
        ('S1218', '61000000000232', 'San Rafael Oriente', '61000000000050', 'San Miguel'),
        ('S1219', '61000000000214', 'Sesori', '61000000000050', 'San Miguel'),
        ('S1220', '61000000000270', 'Uluazapa', '61000000000050', 'San Miguel'),
        ('S0601', '61000000000194', 'Aguilares', '61000000000050', 'San Salvador'),
        ('S0602', '61000000000136', 'Apopa', '61000000000050', 'San Salvador'),
        ('S0603', '61000000000258', 'Ayutuxtepeque', '61000000000050', 'San Salvador'),
        ('S0619', '61000000000229', 'Ciudad Delgado', '61000000000050', 'San Salvador'),
        ('S0604', '61000000000219', 'Cuscatancingo', '61000000000050', 'San Salvador'),
        ('S0605', '61000000000105', 'El Paisnal', '61000000000050', 'San Salvador'),
        ('S0606', '61000000000167', 'Guazapa', '61000000000050', 'San Salvador'),
        ('S0607', '61000000000186', 'Ilopango', '61000000000050', 'San Salvador'),
        ('S0608', '61000000000047', 'Mejicanos', '61000000000050', 'San Salvador'),
        ('S0609', '61000000000134', 'Nejapa', '61000000000050', 'San Salvador'),
        ('S0610', '61000000000046', 'Panchimalco', '61000000000050', 'San Salvador'),
        ('S0611', '61000000000244', 'Rosario De Mora', '61000000000050', 'San Salvador'),
        ('S0612', '61000000000237', 'San Marcos', '', 'San Salvador'),
        ('S0613', '61000000000211', 'San Martín', '', 'San Salvador'),
        ('S0614', '61000000000040', 'San Salvador', '', 'San Salvador'),
        ('S0615', '61000000000162', 'Santiago Texacuangos', '', 'San Salvador'),
        ('S0616', '61000000000225', 'Santo Tomas', '', 'San Salvador'),
        ('S0617', '61000000000034', 'Soyapango', '', 'San Salvador'),
        ('S0618', '61000000000266', 'Tonacatepeque', '', 'San Salvador'),
        ('S1001', '61000000000070', 'Apastepeque', '', 'San Vicente'),
        ('S1002', '61000000000147', 'Guadalupe', '', 'San Vicente'),
        ('S1003', '61000000000267', 'San Cayetano Istepeque', '', 'San Vicente'),
        ('S1006', '61000000000113', 'San Esteban Catarina', '', 'San Vicente'),
        ('S1007', '61000000000156', 'San Ildefonso', '', 'San Vicente'),
        ('S1008', '61000000000184', 'San Lorenzo', '', 'San Vicente'),
        ('S1009', '61000000000079', 'San Sebastián', '', 'San Vicente'),
        ('S1010', '61000000000032', 'San Vicente', '', 'San Vicente'),
        ('S1004', '61000000000272', 'Santa Clara', '', 'San Vicente'),
        ('S1005', '61000000000014', 'Santo Domingo', '', 'San Vicente'),
        ('S1011', '61000000000064', 'Tecoluca', '', 'San Vicente'),
        ('S1012', '61000000000175', 'Tepetitán', '', 'San Vicente'),
        ('S1013', '61000000000097', 'Verapaz', '', 'San Vicente'),
        ('S0201', '61000000000185', 'Candelaria De La Frontera', '', 'Santa Ana'),
        ('S0203', '61000000000061', 'Chalchuapa', '', 'Santa Ana'),
        ('S0202', '61000000000189', 'Coatepeque', '', 'Santa Ana'),
        ('S0204', '61000000000117', 'El Congo', '', 'Santa Ana'),
        ('S0205', '61000000000148', 'El Porvenir', '', 'Santa Ana'),
        ('S0206', '61000000000076', 'Masahuat', '', 'Santa Ana'),
        ('S0207', '61000000000125', 'Metapán', '', 'Santa Ana'),
        ('S0208', '61000000000179', 'San Antonio Pajonal', '', 'Santa Ana'),
        ('S0209', '61000000000216', 'San Sebastian Salitrillo', '', 'Santa Ana'),
        ('S0210', '61000000000045', 'Santa Ana', '', 'Santa Ana'),
        ('S0211', '61000000000107', 'Santa Rosa Guachipilín', '', 'Santa Ana'),
        ('S0212', '61000000000112', 'Santiago De La Frontera', '', 'Santa Ana'),
        ('S0213', '61000000000227', 'Texistepeque', '', 'Santa Ana'),
        ('S0301', '61000000000255', 'Acajutla', '', 'Sonsonate'),
        ('S0302', '61000000000053', 'Armenia', '', 'Sonsonate'),
        ('S0303', '61000000000017', 'Caluco', '', 'Sonsonate'),
        ('S0304', '61000000000067', 'Cuisnahuat', '', 'Sonsonate'),
        ('S0306', '61000000000199', 'Izalco', '', 'Sonsonate'),
        ('S0307', '61000000000090', 'Juayúa', '', 'Sonsonate'),
        ('S0309', '61000000000250', 'Nahuilingo', '', 'Sonsonate'),
        ('S0308', '61000000000246', 'Nahuizalco', '', 'Sonsonate'),
        ('S0310', '61000000000092', 'Salcoatitán', '', 'Sonsonate'),
        ('S0311', '61000000000068', 'San Antonio Del Monte', '', 'Sonsonate'),
        ('S0312', '61000000000165', 'San Julián', '', 'Sonsonate'),
        ('S0313', '61000000000202', 'Santa Catarina Masahuat', '', 'Sonsonate'),
        ('S0305', '61000000000204', 'Santa Isabel Ishuatán', '', 'Sonsonate'),
        ('S0314', '61000000000081', 'Santo Domingo Guzmán', '', 'Sonsonate'),
        ('S0315', '61000000000163', 'Sonsonate', '', 'Sonsonate'),
        ('S0316', '61000000000130', 'Sonzacate', '', 'Sonsonate'),
        ('S1101', '61000000000247', 'Alegría', '', 'Usulutan'),
        ('S1102', '61000000000083', 'Berlín', '', 'Usulutan'),
        ('S1103', '61000000000268', 'California', '', 'Usulutan'),
        ('S1104', '61000000000276', 'Concepción Batres', '', 'Usulutan'),
        ('S1105', '61000000000196', 'El Triunfo', '', 'Usulutan'),
        ('S1107', '61000000000109', 'Ereguayquín', '', 'Usulutan'),
        ('S1107', '61000000000275', 'Estanzuelas', '', 'Usulutan'),
        ('S1108', '61000000000142', 'Jiquilisco', '', 'Usulutan'),
        ('S1109', '61000000000103', 'Jucuapa', '', 'Usulutan'),
        ('S1110', '61000000000157', 'Jucuarán', '', 'Usulutan'),
        ('S1111', '61000000000114', 'Mercedes Umaña', '', 'Usulutan'),
        ('S1112', '61000000000190', 'Nueva Granada', '', 'Usulutan'),
        ('S1113', '61000000000221', 'Ozatlán', '', 'Usulutan'),
        ('S1114', '61000000000091', 'Puerto El Triunfo', '', 'Usulutan'),
        ('S1115', '61000000000082', 'San Agustín', '', 'Usulutan'),
        ('S1116', '61000000000271', 'San Buenaventura', '', 'Usulutan'),
        ('S1117', '61000000000051', 'San Dionisio', '', 'Usulutan'),
        ('S1119', '61000000000087', 'San Francisco Javier', '', 'Usulutan'),
        ('S1118', '61000000000207', 'Santa Elena', '', 'Usulutan'),
        ('S1120', '61000000000084', 'Santa María', '', 'Usulutan'),
        ('S1121', '61000000000233', 'Santiago De María', '', 'Usulutan'),
        ('S1122', '61000000000178', 'Tecapán', '', 'Usulutan'),
        ('S1123', '61000000000073', 'Usulután', '', 'Usulutan');


    -- ==========================================
    -- 4. CRUCE E INSERCIÓN A LA TABLA PRINCIPAL
    -- ==========================================
    ;WITH MapeoSeguro AS (
        SELECT
            t.IdTownship,
            tmp.ExternalTownshipId,
            tmp.ExternalTownshipName,
            tmp.ExternalProvinceId,
            tmp.ExternalProvinceName,
            ROW_NUMBER() OVER (
                PARTITION BY tmp.ExternalTownshipId
                ORDER BY t.TownshipStatus DESC, t.IdTownship DESC
            ) AS FilaUnica
        FROM #TempTownshipMapping tmp
        INNER JOIN [dbo].[Township] t WITH(NOLOCK)
        ON (t.HeaderCode = tmp.HeaderCode OR t.HeaderCode = RIGHT('0000' + LTRIM(RTRIM(tmp.HeaderCode)), 4))
    )
    INSERT INTO [dbo].[CustomerTownshipMapping] (
        [TownshipId],
        [CodeOfReference],
        [CountryId],
        [ExternalTownshipId],
        [ExternalTownshipName],
        [ExternalProvinceId],
        [ExternalProvinceName],
        [RowStatus],
        [TokenCreated],
        [DateCreated]
    )
    SELECT
        ms.IdTownship,
        @CodeOfReference,
        @CountryId,
        ms.ExternalTownshipId,
        ms.ExternalTownshipName,
        ms.ExternalProvinceId,
        ms.ExternalProvinceName,
        1,
        @Token,
        GETDATE()
    FROM MapeoSeguro ms
    WHERE ms.FilaUnica = 1
      AND NOT EXISTS (
        SELECT 1
        FROM [dbo].[CustomerTownshipMapping] ctm WITH(NOLOCK)
        WHERE ctm.[ExternalTownshipId] = ms.ExternalTownshipId
          AND ctm.[CodeOfReference] = @CodeOfReference
    );

    PRINT 'Carga masiva ejecutada. Filas afectadas: ' + CAST(@@ROWCOUNT AS VARCHAR);

    -- Limpieza de tabla temporal
    DROP TABLE #TempTownshipMapping;

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;

    DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT 'Error crítico en el script: ' + @ErrorMessage;
END CATCH;
GO
