/*
Buscar para el mes de Setiembre de 2005, el nombre del vendedor, el nombre de la sucursal, 
la letra y número de factura, el código del articulo y su nombre, mostrando el precio
vendido y el precio de venta, para aquellos artículos que se vendieron a un valor inferior
del 10% menos del precio estipulado para la venta.
TABLAS: vencab, vendet, vendedores, articulos, sucursales
*/
SELECT * FROM VENDET
SELECT * FROM vencab
SELECT * FROM articulos
SELECT
	v.nombre,
	s.denominacion,
	vt.letra,
	vt.factura,
	vt.articulo,
	a.nombre,
	vt.precio AS 'precio',
	vt.precioventa AS 'precio venta'
FROM
	vendedores AS v 
	INNER JOIN vencab AS vc ON v.vendedor = vc.vendedor
	INNER JOIN sucursales AS s ON vc.sucursal = s.sucursal
	INNER JOIN vendet AS vt ON (vt.letra = vc.letra AND vt.factura = vc.factura)
	INNER JOIN articulos AS a ON a.articulo = vt.articulo
WHERE
	YEAR(vc.fecha) = 2005 AND
	MONTH(vc.fecha) = 10 AND
	vt.precioventa < vt.precio * 0.9 AND
	vc.anulada = 0
ORDER BY
	vt.letra,vt.factura,vt.articulo

/*

OBTENER LA CANTIDAD DE PRENDAS VENDIDAS POR CÓDIGO DE ARTÍCULO, PARA LOS ARTÍCULOS PERTENECIENTES AL RUBRO SWEATERS
REALIZADAS EN LA TEMPORADA DE INVIERNO DEL AÑO 2007.

PRESENTAR: artículo, nombre, preciomenor, preciomayor, cantidad, tipo de venta (x mayor o x menor)

ORDENAR POR CÓDIGO DE ARTICULO.

*/
SELECT rubro FROM articulos
SELECT * FROM rubros
SELECT
	a.articulo,
	a.nombre,
	a.preciomenor,
	a.preciomayor,
	SUM(vt.cantidad) AS 'Cantida prendas vendidas',
	'POR MENOR' AS "Tipo de venta"
FROM
	articulos AS a 
	INNER JOIN vendet AS vt ON a.articulo = vt.articulo
	INNER JOIN vencab AS vc ON (vc.letra = vt.letra AND vc.factura = vt.factura)
WHERE
	a.rubro = 40 AND
	vc.fecha BETWEEN '2007/06/1' AND '2007/08/31' and
	vc.anulada = 0
GROUP BY
	a.articulo,
	a.nombre,
	a.preciomenor,
	a.preciomayor
--
UNION
--
SELECT
	a.articulo,
	a.nombre,
	a.preciomenor,
	a.preciomayor,
	SUM(mt.cantidad) AS 'Cantida prendas vendidas',
	'POR MAYOR' AS "Tipo de venta"
FROM
	articulos AS a 
	INNER JOIN mayordet AS mt ON a.articulo = mt.articulo
	INNER JOIN mayorcab AS my ON (my.letra = mt.letra AND my.factura = mt.factura)
WHERE
	a.rubro = 40 AND
	my.fecha BETWEEN '2007/06/1' AND '2007/08/31' and
	my.anulada = 0
GROUP BY
	a.articulo,
	a.nombre,
	a.preciomenor,
	a.preciomayor
	
ORDER BY
	1