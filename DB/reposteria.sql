-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 26-11-2025 a las 18:30:38
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
-- Estructura para la vista `v_pedidos_completos`
--
DROP TABLE IF EXISTS `v_pedidos_completos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `v_pedidos_completos`  AS SELECT `p`.`id` AS `id`, `p`.`nombre_cliente` AS `nombre_cliente`, `p`.`dia_pedido` AS `dia_pedido`, `p`.`entregado` AS `entregado`, `p`.`costo_total` AS `costo_total`, `p`.`numero_telefonico` AS `numero_telefonico`, `p`.`email` AS `email`, `p`.`pedido` AS `pedido`, CASE WHEN `cf`.`id` is not null THEN 1 ELSE 0 END AS `es_frecuente`, `cf`.`descuento` AS `descuento`, `cf`.`nombre` AS `nombre_frecuente` FROM (`pedido` `p` left join `cliente_frecuente` `cf` on(`p`.`cliente_frecuente_id` = `cf`.`id`)) ;

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
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `pedido`
--
ALTER TABLE `pedido`
  ADD CONSTRAINT `pedido_ibfk_1` FOREIGN KEY (`cliente_frecuente_id`) REFERENCES `cliente_frecuente` (`id`) ON DELETE SET NULL;

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
