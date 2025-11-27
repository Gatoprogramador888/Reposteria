-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 27-11-2025 a las 05:19:13
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `reposteria`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_registrar_venta_desde_pedido` (IN `p_pedido_id` INT)   BEGIN
    DECLARE v_monto DECIMAL(10,2);
    DECLARE v_fecha DATE;
    
    -- Obtener información del pedido
    SELECT costo_total, DATE(dia_pedido)
    INTO v_monto, v_fecha
    FROM pedido
    WHERE id = p_pedido_id;
    
    -- Insertar la venta
    INSERT INTO venta (monto, dia_creacion, pedido_id)
    VALUES (v_monto, v_fecha, p_pedido_id);
    
    SELECT 'Venta registrada exitosamente' AS mensaje, LAST_INSERT_ID() AS venta_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reporte_mensual` (IN `p_anio` INT, IN `p_mes` INT)   BEGIN
    SELECT 
        periodo,
        total_ventas,
        total_compras,
        ganancia_neta,
        CASE 
            WHEN total_ventas > 0 THEN ROUND((ganancia_neta / total_ventas) * 100, 2)
            ELSE 0 
        END AS margen_ganancia_porcentaje
    FROM v_resumen_financiero_mensual
    WHERE anio = p_anio AND mes = p_mes;
    
    -- También mostrar el detalle
    SELECT 
        fecha,
        tipo,
        monto,
        detalle,
        distribuidor
    FROM v_detalle_ganancias_mensual
    WHERE periodo = CONCAT(p_anio, '-', LPAD(p_mes, 2, '0'))
    ORDER BY fecha DESC, tipo;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `administrador`
--

CREATE TABLE `administrador` (
  `id` int(11) NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `contrasena` char(255) NOT NULL,
  `email` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cliente_frecuente`
--

CREATE TABLE `cliente_frecuente` (
  `id` int(11) NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `numero_telefonico` char(10) NOT NULL,
  `descuento` decimal(5,2) DEFAULT 0.00 CHECK (`descuento` >= 0 and `descuento` <= 100),
  `email` varchar(250) NOT NULL,
  `fecha_registro` date DEFAULT curdate()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `compra`
--

CREATE TABLE `compra` (
  `id` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL CHECK (`monto` >= 0),
  `dia_compra` datetime DEFAULT current_timestamp(),
  `distribuidor_id` int(11) DEFAULT NULL,
  `objeto_comprado` varchar(50) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `distribuidor`
--

CREATE TABLE `distribuidor` (
  `id` int(11) NOT NULL,
  `nombre` varchar(250) NOT NULL,
  `numero_telefonico` char(10) NOT NULL,
  `producto` varchar(50) NOT NULL,
  `precio` decimal(10,2) DEFAULT NULL CHECK (`precio` > 0),
  `email` varchar(250) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `log_eventos`
--

CREATE TABLE `log_eventos` (
  `id` int(11) NOT NULL,
  `evento` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `postres_actualizados` int(11) DEFAULT 0,
  `fecha_ejecucion` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `log_eventos`
--

INSERT INTO `log_eventos` (`id`, `evento`, `descripcion`, `postres_actualizados`, `fecha_ejecucion`) VALUES
(1, 'actualizar_postres_antiguos', 'Postres marcados como no nuevos después de 30 días', 0, '2025-11-26 11:29:23');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pedido`
--

CREATE TABLE `pedido` (
  `id` int(11) NOT NULL,
  `nombre_cliente` varchar(250) NOT NULL,
  `dia_pedido` datetime DEFAULT current_timestamp(),
  `entregado` tinyint(1) DEFAULT 0,
  `costo_total` decimal(10,2) NOT NULL CHECK (`costo_total` >= 0),
  `numero_telefonico` char(10) NOT NULL,
  `email` varchar(250) NOT NULL,
  `pedido` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`pedido`)),
  `cliente_frecuente_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Disparadores `pedido`
--
DELIMITER $$
CREATE TRIGGER `tr_crear_venta_al_entregar` AFTER UPDATE ON `pedido` FOR EACH ROW BEGIN
    -- Solo si cambió de no entregado a entregado
    IF OLD.entregado = FALSE AND NEW.entregado = TRUE THEN
        -- Verificar que no exista ya una venta para este pedido
        IF NOT EXISTS (SELECT 1 FROM venta WHERE pedido_id = NEW.id) THEN
            INSERT INTO venta (monto, dia_creacion, pedido_id)
            VALUES (NEW.costo_total, DATE(NEW.dia_pedido), NEW.id);
        END IF;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `postre`
--

CREATE TABLE `postre` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `precio` decimal(6,2) NOT NULL CHECK (`precio` > 0),
  `nombre_img` varchar(50) NOT NULL,
  `creacion` date DEFAULT curdate(),
  `nuevo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `venta`
--

CREATE TABLE `venta` (
  `id` int(11) NOT NULL,
  `monto` decimal(10,2) NOT NULL CHECK (`monto` >= 0),
  `dia_creacion` date DEFAULT curdate(),
  `pedido_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_detalle_ganancias_mensual`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_detalle_ganancias_mensual` (
`periodo` varchar(7)
,`fecha` varchar(10)
,`tipo` varchar(6)
,`monto` decimal(10,2)
,`detalle` varchar(250)
,`distribuidor` varchar(250)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_pedidos_completos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_pedidos_completos` (
`id` int(11)
,`nombre_cliente` varchar(250)
,`dia_pedido` datetime
,`entregado` tinyint(1)
,`costo_total` decimal(10,2)
,`numero_telefonico` char(10)
,`email` varchar(250)
,`pedido` longtext
,`es_frecuente` int(1)
,`descuento` decimal(5,2)
,`nombre_frecuente` varchar(250)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `v_resumen_financiero_mensual`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `v_resumen_financiero_mensual` (
`anio` int(4)
,`mes` int(2)
,`periodo` varchar(7)
,`total_ventas` decimal(32,2)
,`total_compras` decimal(32,2)
,`ganancia_neta` decimal(33,2)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `v_detalle_ganancias_mensual`
--
DROP TABLE IF EXISTS `v_detalle_ganancias_mensual`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_detalle_ganancias_mensual`  AS SELECT date_format(`v`.`dia_creacion`,'%Y-%m') AS `periodo`, date_format(`v`.`dia_creacion`,'%Y-%m-%d') AS `fecha`, 'VENTA' AS `tipo`, `v`.`monto` AS `monto`, `p`.`nombre_cliente` AS `detalle`, NULL AS `distribuidor` FROM (`venta` `v` join `pedido` `p` on(`v`.`pedido_id` = `p`.`id`))union all select date_format(`c`.`dia_compra`,'%Y-%m') AS `periodo`,date_format(`c`.`dia_compra`,'%Y-%m-%d') AS `fecha`,'COMPRA' AS `tipo`,-`c`.`monto` AS `monto`,`c`.`objeto_comprado` AS `detalle`,`d`.`nombre` AS `distribuidor` from (`compra` `c` left join `distribuidor` `d` on(`c`.`distribuidor_id` = `d`.`id`)) order by `periodo` desc,`fecha` desc  ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_pedidos_completos`
--
DROP TABLE IF EXISTS `v_pedidos_completos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_pedidos_completos`  AS SELECT `p`.`id` AS `id`, `p`.`nombre_cliente` AS `nombre_cliente`, `p`.`dia_pedido` AS `dia_pedido`, `p`.`entregado` AS `entregado`, `p`.`costo_total` AS `costo_total`, `p`.`numero_telefonico` AS `numero_telefonico`, `p`.`email` AS `email`, `p`.`pedido` AS `pedido`, CASE WHEN `cf`.`id` is not null THEN 1 ELSE 0 END AS `es_frecuente`, `cf`.`descuento` AS `descuento`, `cf`.`nombre` AS `nombre_frecuente` FROM (`pedido` `p` left join `cliente_frecuente` `cf` on(`p`.`cliente_frecuente_id` = `cf`.`id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `v_resumen_financiero_mensual`
--
DROP TABLE IF EXISTS `v_resumen_financiero_mensual`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_resumen_financiero_mensual`  AS SELECT year(`movimientos`.`fecha`) AS `anio`, month(`movimientos`.`fecha`) AS `mes`, date_format(`movimientos`.`fecha`,'%Y-%m') AS `periodo`, coalesce(sum(`movimientos`.`ventas`),0) AS `total_ventas`, coalesce(sum(`movimientos`.`compras`),0) AS `total_compras`, coalesce(sum(`movimientos`.`ventas`),0) - coalesce(sum(`movimientos`.`compras`),0) AS `ganancia_neta` FROM (select `venta`.`dia_creacion` AS `fecha`,`venta`.`monto` AS `ventas`,0 AS `compras` from `venta` union all select cast(`compra`.`dia_compra` as date) AS `fecha`,0 AS `ventas`,`compra`.`monto` AS `compras` from `compra`) AS `movimientos` GROUP BY year(`movimientos`.`fecha`), month(`movimientos`.`fecha`) ORDER BY year(`movimientos`.`fecha`) DESC, month(`movimientos`.`fecha`) DESC ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `administrador`
--
ALTER TABLE `administrador`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_email` (`email`);

--
-- Indices de la tabla `cliente_frecuente`
--
ALTER TABLE `cliente_frecuente`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `idx_numero_telefonico` (`numero_telefonico`),
  ADD KEY `idx_email` (`email`);

--
-- Indices de la tabla `compra`
--
ALTER TABLE `compra`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dia_compra` (`dia_compra`),
  ADD KEY `idx_distribuidor` (`distribuidor_id`),
  ADD KEY `idx_objeto` (`objeto_comprado`);

--
-- Indices de la tabla `distribuidor`
--
ALTER TABLE `distribuidor`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_numero_telefonico` (`numero_telefonico`),
  ADD KEY `idx_producto` (`producto`),
  ADD KEY `idx_email` (`email`);

--
-- Indices de la tabla `log_eventos`
--
ALTER TABLE `log_eventos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_numero_telefonico` (`numero_telefonico`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `idx_dia_pedido` (`dia_pedido`),
  ADD KEY `idx_entregado` (`entregado`),
  ADD KEY `cliente_frecuente_id` (`cliente_frecuente_id`);

--
-- Indices de la tabla `postre`
--
ALTER TABLE `postre`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre` (`nombre`),
  ADD KEY `nuevo` (`nuevo`);

--
-- Indices de la tabla `venta`
--
ALTER TABLE `venta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_dia_creacion` (`dia_creacion`),
  ADD KEY `idx_pedido` (`pedido_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `administrador`
--
ALTER TABLE `administrador`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cliente_frecuente`
--
ALTER TABLE `cliente_frecuente`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `compra`
--
ALTER TABLE `compra`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `distribuidor`
--
ALTER TABLE `distribuidor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `log_eventos`
--
ALTER TABLE `log_eventos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `pedido`
--
ALTER TABLE `pedido`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `postre`
--
ALTER TABLE `postre`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `venta`
--
ALTER TABLE `venta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `compra`
--
ALTER TABLE `compra`
  ADD CONSTRAINT `compra_ibfk_1` FOREIGN KEY (`distribuidor_id`) REFERENCES `distribuidor` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `pedido_ibfk_1` FOREIGN KEY (`cliente_frecuente_id`) REFERENCES `cliente_frecuente` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `venta`
--
ALTER TABLE `venta`
  ADD CONSTRAINT `venta_ibfk_1` FOREIGN KEY (`pedido_id`) REFERENCES `pedido` (`id`) ON DELETE CASCADE;

DELIMITER $$
--
-- Eventos
--
CREATE DEFINER=`root`@`localhost` EVENT `actualizar_postres_antiguos` ON SCHEDULE EVERY 1 DAY STARTS '2025-11-27 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    -- Actualizar postres que tienen más de 1 mes (30 días) desde su creación
    UPDATE postre
    SET nuevo = FALSE
    WHERE nuevo = TRUE 
    AND DATEDIFF(CURRENT_DATE, creacion) > 30;
    
    -- Opcional: Log para saber cuántos se actualizaron
    -- Requiere una tabla de logs si quieres mantener historial
END$$

CREATE DEFINER=`root`@`localhost` EVENT `actualizar_postres_antiguos_con_log` ON SCHEDULE EVERY 1 DAY STARTS '2025-11-26 00:00:00' ON COMPLETION NOT PRESERVE ENABLE DO BEGIN
    DECLARE postres_modificados INT DEFAULT 0;
    
    -- Actualizar postres antiguos
    UPDATE postre
    SET nuevo = FALSE
    WHERE nuevo = TRUE 
    AND DATEDIFF(CURRENT_DATE, creacion) > 30;
    
    -- Obtener número de filas afectadas
    SET postres_modificados = ROW_COUNT();
    
    -- Registrar en log
    INSERT INTO log_eventos (evento, descripcion, postres_actualizados)
    VALUES ('actualizar_postres_antiguos', 
            CONCAT('Postres marcados como no nuevos después de 30 días'),
            postres_modificados);
END$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
