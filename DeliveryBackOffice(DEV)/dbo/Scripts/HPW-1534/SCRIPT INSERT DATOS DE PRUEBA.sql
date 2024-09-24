

	INSERT INTO [dbo].[CatProductTag] 
([Description], [RowStatus], [UserCreated], [DateCreated], [UserUpdated], [DateUpdated]) 
VALUES
('Electronics', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Home Appliances', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Books', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Clothing', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Furniture', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Toys', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Beauty Products', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Automotive', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Garden Supplies', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Fitness Equipment', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);





INSERT INTO [dbo].[CatProductCondition] 
([Name], [Description], [RowStatus], [UserCreated], [DateCreated], [UserUpdated], [DateUpdated])
VALUES
('Nuevo', 'Producto completamente nuevo, sin uso.', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Usado Como nuevo', 'Producto usado en excelentes condiciones, como si fuera nuevo.', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Usado en buen estado', 'Producto usado, pero en buen estado y funcional.', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Usado Aceptable', 'Producto usado con signos de desgaste, pero todavía funcional.', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);


INSERT INTO [dbo].[CatProductStatusStore] 
([Name], [RowStatus], [UserCreated], [DateCreated], [UserUpdated], [DateUpdated])
VALUES
('No publicado', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('En verificación', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Publicado', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
('Rechazado', 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);




INSERT INTO [dbo].[CatProductSubCategory] 
([ProductCategoryId], [Name], [Description], [Icon], [ProductSubCategoryParentId], [RowStatus], [UserCreated], [DateCreated], [UserUpdated], [DateUpdated])
VALUES
(5, 'Electrónica', 'Productos electrónicos como smartphones, laptops y televisores.', 'icon-electronics', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Hogar y Electrodomésticos', 'Electrodomésticos para el hogar, como refrigeradores y lavadoras.', 'icon-appliances', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Muebles', 'Muebles para el hogar, como sofás y mesas de comedor.', 'icon-furniture', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Herramientas', 'Herramientas eléctricas y manuales para el hogar y taller.', 'icon-tools', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Deportes y Exterior', 'Artículos deportivos como bicicletas y equipos de ejercicio.', 'icon-sports', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Juguetes', 'Juguetes y productos de entretenimiento para niños.', 'icon-toys', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Libros y Literatura', 'Libros de diversos géneros y temas.', 'icon-books', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Ofertas y Promociones', 'Subcategoría de productos con descuentos y promociones especiales.', 'icon-sales', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Accesorios', 'Accesorios para dispositivos electrónicos y ropa.', 'icon-accessories', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'Automotriz', 'Productos y accesorios para automóviles.', 'icon-automotive', NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);



INSERT INTO [dbo].[Product] 
([Token], [Name], [Description], [AccountId], [CatProductSubCategoryId], [IsPublic], [CatStatusStoreId], [CatProductConditionId], [Sku], [Stock], [StockRequired], [Price], [CatCurrencyCODId], [Brand], [AverageRating], [NameSale], [StartDateSale], [EndDateSale], [PercentageSale], [RowStatus], [UserCreated], [DateCreated], [UserUpdated], [DateUpdated])
VALUES

('ELEC123', 'Smartphone X100', 'Último modelo con soporte 5G, 128GB de almacenamiento y cámara dual.', 1, 1, 1, 3, 1, 'SMX100', 500, 1, 699.99, 1, 'TechCorp', 4.5, 'Black Friday', '2024-11-25', '2024-11-30', 20.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('ELEC456', 'Laptop Pro 15', 'Laptop de alto rendimiento con Intel i7, 16GB RAM y 512GB SSD.', 2, 1, 1, 3, 1, 'LP1500', 150, 1, 1299.99, 1, 'CompTech', 5, 'Cyber Monday', '2024-12-02', '2024-12-03', 15.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('HOME789', 'TV LED 4K 55"', 'Televisor UHD Smart con soporte HDR y apps integradas.', 3, 1, 1, 3, 2, 'LEDTV55', 300, 1, 799.99, 1, 'ViewPlus', 4, 'Holiday Sale', '2024-12-15', '2024-12-31', 10.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('APPL012', 'Refrigerador 350L', 'Refrigerador de alta eficiencia energética, capacidad de 350 litros.', 4, 2, 1, 3, 1, 'FRG350L', 120, 1, 599.99, 1, 'CoolHome', 3.5, 'Summer Sale', '2024-06-01', '2024-06-15', 5.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('APPL345', 'Lavadora 7kg', 'Lavadora de carga frontal con 10 programas de lavado.', 5, 2, 1, 3, 2, 'WM7KG', 80, 1, 449.99, 1, 'CleanWave', 4, NULL, NULL, NULL, NULL, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('TOOL678', 'Taladro Inalámbrico 18V', 'Taladro inalámbrico con batería de 18V y ajustes de velocidad.', 6, 3, 1, 3, 2, 'CD18V', 250, 1, 199.99, 1, 'PowerPro', 5, 'New Year Sale', '2024-01-01', '2024-01-10', 15.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('FURN901', 'Sofá de 3 Plazas', 'Sofá moderno con reposacabezas ajustables y cojines suaves.', 7, 3, 1, 3, 3, 'SF3ST', 50, 1, 899.99, 1, 'ComfortHouse', 4.5, 'Clearance Sale', '2024-07-01', '2024-07-15', 10.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('FURN234', 'Juego de Comedor', 'Mesa de comedor de madera con 6 sillas de diseño minimalista.', 8, 3, 1, 3, 3, 'DT6CH', 70, 1, 499.99, 1, 'WoodCraft', 5, 'Festive Sale', '2024-12-01', '2024-12-10', 20.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('SPORT567', 'Bicicleta de Montaña', 'Bicicleta resistente con 21 velocidades y absorción de impactos.', 9, 4, 1, 3, 4, 'MTB21SP', 100, 1, 349.99, 1, 'SpeedRider', 4, 'End of Season', '2024-09-01', '2024-09-15', 25.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

('TOY890', 'Auto RC Turbo', 'Auto a control remoto con modo turbo y tracción en las 4 ruedas.', 10, 5, 1, 3, 4, 'RCCAR4WD', 500, 1, 129.99, 1, 'ToyMaster', 4.5, 'Christmas Special', '2024-12-20', '2024-12-25', 30.00, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);



INSERT INTO [dbo].[TagByProduct] 
([TagId], [ProductId], [RowStatus], [UserCreated], [DateCreated], [UserUpdated], [DateUpdated])
VALUES

(1, 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(1, 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 
(2, 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(1, 3, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 
(3, 3, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(4, 4, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(4, 5, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(5, 6, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(6, 7, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(6, 8, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(7, 9, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL), 

(8, 10, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);





INSERT INTO [dbo].[ProductImages] 
([ProductId], [Url], [Position], [RowStatus], [UserCreated], [DateCreated], [UserUpdated], [DateUpdated])
VALUES

(1, 'https://images.example.com/smartphone_x100_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(1, 'https://images.example.com/smartphone_x100_back.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(1, 'https://images.example.com/smartphone_x100_side.jpg', 3, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),


(2, 'https://images.example.com/laptop_pro15_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(2, 'https://images.example.com/laptop_pro15_open.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(2, 'https://images.example.com/laptop_pro15_closed.jpg', 3, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),

(3, 'https://images.example.com/tv_led_4k55_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(3, 'https://images.example.com/tv_led_4k55_side.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),


(4, 'https://images.example.com/refrigerador_350l_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(4, 'https://images.example.com/refrigerador_350l_inside.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),


(5, 'https://images.example.com/lavadora_7kg_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(5, 'https://images.example.com/lavadora_7kg_side.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),


(6, 'https://images.example.com/taladro_inalambrico_18v_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(6, 'https://images.example.com/taladro_inalambrico_18v_battery.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),


(7, 'https://images.example.com/sofa_3plazas_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(7, 'https://images.example.com/sofa_3plazas_side.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),


(8, 'https://images.example.com/juego_de_comedor_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(8, 'https://images.example.com/juego_de_comedor_side.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),


(9, 'https://images.example.com/bicicleta_montana_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(9, 'https://images.example.com/bicicleta_montana_side.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),


(10, 'https://images.example.com/auto_rc_turbo_front.jpg', 1, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL),
(10, 'https://images.example.com/auto_rc_turbo_side.jpg', 2, 1, 'SYS-BPEDROZA', GETDATE(), NULL, NULL);
